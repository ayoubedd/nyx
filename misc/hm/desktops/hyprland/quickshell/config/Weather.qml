pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Current weather + 3-day forecast for wherever this machine is.
//
// Location: approximate (city-level) from the public IP, trying ipinfo.io,
// then geojs.io, then ipapi.co (shared networks often get rate-limited by
// one of them); falls back to the last good location.
// Forecast: Open-Meteo (no account / API key).
// Refreshes every 30 min, and when the Home tab opens with stale data.
Singleton {
    id: root

    property bool ready: false
    property bool loading: false
    property string error: ""
    property real updatedAt: 0

    property string city: ""
    property string lastLocation: "" // "lat lon city" from the last good lookup

    property real temperature: 0
    property real feelsLike: 0
    property int code: 0
    property bool isDay: true
    property int humidity: 0
    property real wind: 0 // km/h
    property var daily: [] // [{ date: Date, code, max, min }]

    readonly property string icon: iconFor(code, isDay)
    readonly property string condition: describe(code)

    function refresh() {
        if (loading)
            return;
        loading = true;
        fetch.command = ["sh", "-c", fetch.script, "sh", lastLocation];
        fetch.running = true;
    }

    function refreshIfStale() {
        if (Date.now() - updatedAt > 30 * 60000)
            refresh();
    }

    // WMO weather interpretation codes (Open-Meteo).
    function describe(c) {
        if (c === 0)
            return "Clear";
        if (c === 1)
            return "Mostly clear";
        if (c === 2)
            return "Partly cloudy";
        if (c === 3)
            return "Overcast";
        if (c === 45 || c === 48)
            return "Fog";
        if (c >= 51 && c <= 55)
            return "Drizzle";
        if (c === 56 || c === 57)
            return "Freezing drizzle";
        if (c >= 61 && c <= 65)
            return "Rain";
        if (c === 66 || c === 67)
            return "Freezing rain";
        if (c >= 71 && c <= 77)
            return "Snow";
        if (c >= 80 && c <= 82)
            return "Showers";
        if (c === 85 || c === 86)
            return "Snow showers";
        if (c === 95)
            return "Thunderstorm";
        if (c === 96 || c === 99)
            return "Thunderstorm, hail";
        return "Unknown";
    }

    function iconFor(c, day) {
        if (c === 0)
            return day ? "sunny" : "clear_night";
        if (c === 1 || c === 2)
            return day ? "partly_cloudy_day" : "partly_cloudy_night";
        if (c === 3)
            return "cloud";
        if (c === 45 || c === 48)
            return "foggy";
        if ((c >= 71 && c <= 77) || c === 85 || c === 86)
            return "weather_snowy";
        if (c >= 95)
            return "thunderstorm";
        if (c >= 51)
            return "rainy";
        return "cloud";
    }

    Process {
        id: fetch

        // $1 = last good "lat lon city" (fallback if every lookup fails).
        readonly property string script: `
            loc=$(curl -fsS --max-time 8 https://ipinfo.io/json 2>/dev/null \
                | jq -r 'select(.loc) | (.loc | split(",") | .[0] + " " + .[1]) + " " + (.city // "")' 2>/dev/null)
            [ -n "$loc" ] || loc=$(curl -fsS --max-time 8 https://get.geojs.io/v1/ip/geo.json 2>/dev/null \
                | jq -r 'select(.latitude) | .latitude + " " + .longitude + " " + (.city // "")' 2>/dev/null)
            [ -n "$loc" ] || loc=$(curl -fsS --max-time 8 https://ipapi.co/json/ 2>/dev/null \
                | jq -r 'select(.latitude) | (.latitude|tostring) + " " + (.longitude|tostring) + " " + (.city // "")' 2>/dev/null)
            [ -n "$loc" ] || loc="$1"
            [ -n "$loc" ] || { echo "ERR location"; exit 0; }
            echo "LOC $loc"
            set -- $loc
            curl -fsS --max-time 10 "https://api.open-meteo.com/v1/forecast?latitude=$1&longitude=$2&current=temperature_2m,apparent_temperature,weather_code,is_day,relative_humidity_2m,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=auto&forecast_days=4" \
                || echo "ERR forecast"
        `

        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                const lines = text.split("\n");
                const err = lines.find(l => l.startsWith("ERR"));
                const loc = lines.find(l => l.startsWith("LOC "));
                const json = lines.filter(l => !l.startsWith("LOC ") && !l.startsWith("ERR")).join("\n").trim();
                if (loc) {
                    root.lastLocation = loc.slice(4).trim();
                    root.city = root.lastLocation.split(" ").slice(2).join(" ");
                }
                if (err || !json) {
                    root.error = err === "ERR location" ? "Location unavailable" : "Weather unavailable";
                    return;
                }
                try {
                    const d = JSON.parse(json);
                    const c = d.current;
                    root.temperature = c.temperature_2m;
                    root.feelsLike = c.apparent_temperature;
                    root.code = c.weather_code;
                    root.isDay = c.is_day === 1;
                    root.humidity = c.relative_humidity_2m;
                    root.wind = c.wind_speed_10m;
                    root.daily = d.daily.time.map((t, i) => ({
                                date: new Date(`${t}T12:00:00`),
                                code: d.daily.weather_code[i],
                                max: d.daily.temperature_2m_max[i],
                                min: d.daily.temperature_2m_min[i]
                            }));
                    root.error = "";
                    root.ready = true;
                    root.updatedAt = Date.now();
                } catch (e) {
                    root.error = "Weather unavailable";
                }
            }
        }
    }

    Timer {
        running: true
        interval: 30 * 60000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
