.pragma library

// Search helpers for the launcher: fuzzy matching and a small calculator.

// How well `q` (lowercase, one word) matches `text`; 0 = no match.
//   exact 100 > prefix ~90 > word start ~75 > initials 70 > substring ~55
//   > in-order letters (fewer gaps = better) 5..40
function scoreWord(q, text) {
    if (!text || !q)
        return 0;
    const t = text.toLowerCase();
    if (t === q)
        return 100;
    if (t.startsWith(q))
        return 90 - Math.min(20, (t.length - q.length) * 0.5);
    const i = t.indexOf(q);
    if (i > 0) {
        const wordStart = /[\s\-_.:/()]/.test(t[i - 1]);
        return (wordStart ? 75 : 55) - Math.min(10, i * 0.2);
    }
    if (q.length >= 2) {
        const initials = t.split(/[\s\-_.]+/).filter(w => w).map(w => w[0]).join("");
        if (initials.startsWith(q))
            return 70;
    }
    if (q.length < 2)
        return 0;
    let from = 0, gaps = 0, last = -1;
    for (const c of q) {
        const f = t.indexOf(c, from);
        if (f < 0)
            return 0;
        if (last >= 0)
            gaps += f - last - 1;
        last = f;
        from = f + 1;
    }
    return Math.max(5, 40 - gaps * 2);
}

// Score a query against weighted fields: [[text, weight], ...].
// Every word of the query has to match some field; the result is the
// average of each word's best (weighted) score.
function score(query, fields) {
    const words = query.toLowerCase().split(/\s+/).filter(w => w);
    if (words.length === 0)
        return 0;
    // The whole query against the main field first (multi-word names).
    const whole = scoreWord(query.toLowerCase().trim(), fields[0][0]) * fields[0][1];
    let total = 0;
    for (const w of words) {
        let best = 0;
        for (const [text, weight] of fields) {
            const s = scoreWord(w, text) * weight;
            if (s > best)
                best = s;
        }
        if (best === 0)
            return whole;
        total += best;
    }
    return Math.max(whole, total / words.length);
}

// ---- calculator ----------------------------------------------------------
// + - * / % ^ (or **), parentheses, implicit "2(3)" is not supported.
// Functions: sqrt cbrt abs round floor ceil exp ln log log2 sin cos tan asin
// acos atan (radians). Constants: pi, e. "×" and "÷" work too.

const FUNCS = {
    sqrt: Math.sqrt,
    cbrt: Math.cbrt,
    abs: Math.abs,
    round: Math.round,
    floor: Math.floor,
    ceil: Math.ceil,
    exp: Math.exp,
    ln: Math.log,
    log: Math.log10,
    log2: Math.log2,
    sin: Math.sin,
    cos: Math.cos,
    tan: Math.tan,
    asin: Math.asin,
    acos: Math.acos,
    atan: Math.atan
};
const CONSTS = {
    pi: Math.PI,
    e: Math.E
};

function tokenize(s) {
    const tokens = [];
    const re = /\s*(?:(\d+(?:[.,]\d+)?(?:e[+-]?\d+)?|\.\d+)|(\*\*|[-+*\/%^()×÷])|([a-z][a-z0-9]*))/giy;
    let m;
    let pos = 0;
    while (pos < s.length) {
        re.lastIndex = pos;
        m = re.exec(s);
        if (!m) {
            if (/^\s*$/.test(s.slice(pos)))
                break;
            return null;
        }
        pos = re.lastIndex;
        if (m[1] !== undefined)
            tokens.push({ t: "num", v: parseFloat(m[1].replace(",", ".")) });
        else if (m[2] !== undefined)
            tokens.push({ t: "op", v: m[2] === "×" ? "*" : m[2] === "÷" ? "/" : m[2] === "**" ? "^" : m[2] });
        else
            tokens.push({ t: "id", v: m[3].toLowerCase() });
    }
    return tokens;
}

// Evaluate `text`; returns a number, or null when it isn't a calculation
// (a lone number or word doesn't count, so typing "5" or "firefox" shows no
// result).
function calculate(text) {
    const s = text.trim();
    if (!s || !/[\d)]/.test(s) || s.length > 200)
        return null;
    const tokens = tokenize(s);
    if (!tokens || tokens.length < 2)
        return null;
    if (!tokens.some(t => t.t === "op" || (t.t === "id" && FUNCS[t.v])))
        return null;

    let i = 0;
    const peek = () => tokens[i];
    const take = () => tokens[i++];

    function primary() {
        const tok = take();
        if (!tok)
            throw "end";
        if (tok.t === "num")
            return tok.v;
        if (tok.t === "op" && tok.v === "(") {
            const v = expr();
            if (take()?.v !== ")")
                throw "paren";
            return v;
        }
        if (tok.t === "op" && (tok.v === "-" || tok.v === "+")) {
            const v = power();
            return tok.v === "-" ? -v : v;
        }
        if (tok.t === "id") {
            if (CONSTS[tok.v] !== undefined)
                return CONSTS[tok.v];
            const f = FUNCS[tok.v];
            if (f) {
                if (peek()?.v === "(") {
                    take();
                    const v = expr();
                    if (take()?.v !== ")")
                        throw "paren";
                    return f(v);
                }
                return f(power());
            }
        }
        throw "token";
    }

    function power() {
        const base = primary();
        if (peek()?.v === "^") {
            take();
            return Math.pow(base, unary());
        }
        return base;
    }

    function unary() {
        if (peek()?.t === "op" && (peek().v === "-" || peek().v === "+")) {
            const op = take().v;
            const v = unary();
            return op === "-" ? -v : v;
        }
        return power();
    }

    function term() {
        let v = unary();
        while (peek()?.t === "op" && "*/%".includes(peek().v)) {
            const op = take().v;
            const r = unary();
            v = op === "*" ? v * r : op === "/" ? v / r : v % r;
        }
        return v;
    }

    function expr() {
        let v = term();
        while (peek()?.t === "op" && (peek().v === "+" || peek().v === "-")) {
            const op = take().v;
            const r = term();
            v = op === "+" ? v + r : v - r;
        }
        return v;
    }

    try {
        const v = expr();
        if (i !== tokens.length || !isFinite(v))
            return null;
        return v;
    } catch (e) {
        return null;
    }
}

function formatNumber(v) {
    if (Number.isInteger(v) && Math.abs(v) < 1e15)
        return v.toLocaleString("en-US").replace(/,/g, " ");
    const s = Math.abs(v) >= 1e15 || (Math.abs(v) < 1e-6 && v !== 0) ? v.toExponential(6) : parseFloat(v.toPrecision(12)).toString();
    return s;
}

// Plain form for the clipboard (no digit grouping).
function plainNumber(v) {
    if (Number.isInteger(v) && Math.abs(v) < 1e15)
        return v.toString();
    return parseFloat(v.toPrecision(12)).toString();
}
