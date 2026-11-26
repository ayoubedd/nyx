"""Build the emoji picker's data file (run by ../default.nix at build time).

usage: build.py <emoji-test.txt> <cldr annotations dir> <out.json>

Output: {"groups": [...], "emoji": [[char, name, groupIndex, keywords, tones?], ...]}
in Unicode order. Skin-tone variants aren't separate entries: an emoji that
has them gets `tones`, its 5 variants light -> dark (only variants where every
person has the same tone; mixed-tone couples are skipped). Keywords come from
CLDR's English annotations.
"""

import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

test_file, cldr_dir, out_file = sys.argv[1:4]

SKIN_TONES = {chr(c) for c in range(0x1F3FB, 0x1F400)}
GROUP_NAMES = {
    "Smileys & Emotion": "Smileys",
    "People & Body": "People",
    "Animals & Nature": "Nature",
    "Food & Drink": "Food",
    "Travel & Places": "Travel",
    "Activities": "Activities",
    "Objects": "Objects",
    "Symbols": "Symbols",
    "Flags": "Flags",
}

# CLDR keywords, keyed by the emoji with and without the FE0F selector.
keywords = {}
for name in ("annotations/en.xml", "annotationsDerived/en.xml"):
    path = Path(cldr_dir) / name
    if not path.exists():
        continue
    for a in ET.parse(path).getroot().iter("annotation"):
        if a.get("type") == "tts" or not a.text:
            continue
        cp = a.get("cp", "")
        words = [w.strip() for w in a.text.split("|") if w.strip()]
        keywords.setdefault(cp.replace("️", ""), []).extend(words)

groups = []
emoji = []
group = None
line_re = re.compile(r"^[0-9A-F ]+;\s*fully-qualified\s*#\s*(\S+)\s+E[\d.]+\s+(.+)$")
TONE_ORDER = [chr(c) for c in range(0x1F3FB, 0x1F400)]  # light -> dark


def base_key(s):
    """The emoji without skin tones or the FE0F emoji-style selector."""
    return "".join(c for c in s if c not in SKIN_TONES and c != "️")


# Pass 1: skin-tone variants, keyed by their base emoji.
variants = {}  # base key -> {tone index: variant}
for line in Path(test_file).read_text(encoding="utf-8").splitlines():
    m = line_re.match(line)
    if not m:
        continue
    char = m.group(1)
    tones = {c for c in char if c in SKIN_TONES}
    if len(tones) != 1:
        continue  # no tone, or mixed tones (e.g. a couple with two tones)
    variants.setdefault(base_key(char), {})[TONE_ORDER.index(tones.pop())] = char

for line in Path(test_file).read_text(encoding="utf-8").splitlines():
    if line.startswith("# group:"):
        g = line.split(":", 1)[1].strip()
        group = GROUP_NAMES.get(g)
        if group and group not in groups:
            groups.append(group)
        continue
    if group is None:
        continue  # e.g. "Component" (bare skin tones / hair styles)
    m = line_re.match(line)
    if not m:
        continue
    char, name = m.group(1), m.group(2).strip()
    if any(c in SKIN_TONES for c in char):
        continue
    if name.startswith("flag: "):
        name = name[6:] + " flag"
    words = keywords.get(char.replace("️", ""), [])
    extra = sorted({w.lower() for w in words} - set(name.lower().split()))
    entry = [char, name, groups.index(group), " ".join(extra)]
    tones = variants.get(base_key(char), {})
    if len(tones) == 5:
        entry.append([tones[i] for i in range(5)])
    emoji.append(entry)

Path(out_file).write_text(
    json.dumps({"groups": groups, "emoji": emoji}, ensure_ascii=False, separators=(",", ":")),
    encoding="utf-8",
)
print(
    f"{len(emoji)} emoji in {len(groups)} groups, {sum(len(e) > 4 for e in emoji)} with skin tones",
    file=sys.stderr,
)
