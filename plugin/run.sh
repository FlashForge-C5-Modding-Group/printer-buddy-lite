#!/bin/sh
# OpenCreator plugin service: runs Printer Buddy Lite. oc-plugin restarts it if it exits.
# Settings and photos live in the writable data folder; the binary, WebUI and models ship with the plugin.
HERE=$(cd "$(dirname "$0")/.." && pwd)
DATA="${OC_PLUGIN_DATA:-$HERE}"
CONF="$DATA/config.json"
OC_PLUGIN=/usr/data/opencreator/plugin-manager/oc-plugin
export SEP_AI_HOME="$DATA"
export SEP_AI_MODELS="$HERE/models"

BIN=/usr/data/opencreator/sep-ai/c/sep_ai

if [ ! -f "$BIN" ]; then
    echo "Printer Buddy Lite: external binary is missing: $BIN" >&2
    exit 1
fi

if [ ! -x "$BIN" ]; then
    chmod 755 "$BIN" || {
        echo "Printer Buddy Lite: unable to restore executable permissions" >&2
        exit 1
    }
    echo "Printer Buddy Lite: executable permissions restored."
fi


setting() { sed -n "s|.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*|\1|p" "$CONF" | head -n 1; }
set_setting() { sed -i "s|\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"|\"$1\": \"$2\"|" "$CONF"; }

# Tunneled printer: Klipper and Moonraker are on the SBC. Unless config.json already points
# somewhere else, find the SBC; until it answers, wait and let oc-plugin start this again.
if [ "$OC_TUNNELED" = 1 ] && [ -f "$CONF" ]; then
    case $(setting moonraker) in
        ""|http://127.0.0.1*|http://localhost*)
            url=$(sh "$OC_PLUGIN" moonraker --find)
            case $? in
                0) set_setting moonraker "$url"
                   echo "Printer Buddy Lite: using the SBC's Moonraker at $url" ;;
                2) echo "Printer Buddy Lite: several tunnel SBCs found; pick this printer's with: oc-plugin moonraker --scan" >&2
                   sleep 60; exit 1 ;;
                *) echo "Printer Buddy Lite: no tunnel SBC found yet; trying again" >&2
                   sleep 30; exit 1 ;;
            esac ;;
    esac
fi

# The camera: always taken straight from the camera itself, never from Moonraker's webcam
# entry, whose snapshot address often doesn't work from the printer (a relative /webcam/
# path nginx doesn't serve, a .local name, or none at all). First the printer's own camera,
# then the IP and port of each webcam's stream address, which a browser already shows.
# Whichever answers is written to camera_url at every start; if none does, it's left as is.
camera_hosts() {
    echo http://127.0.0.1:8080
    mr=$(setting moonraker)
    wget -q -T 5 -O - "${mr:-http://127.0.0.1:7125}/server/webcams/list" 2>/dev/null |
        grep -o '"\(stream\|snapshot\)_url": *"https\{0,1\}://[^/"]*' |
        sed 's|.*"\(https\{0,1\}://[^/"]*\)$|\1|'
}
if [ -f "$CONF" ]; then
    found=
    for host in $(camera_hosts | awk '!seen[$0]++'); do
        for path in "/?action=snapshot" /snapshot; do
            if wget -q -T 3 -O /dev/null "$host$path" 2>/dev/null; then
                found=$host$path
                break 2
            fi
        done
    done
    if [ -n "$found" ]; then
        [ "$(setting camera_url)" = "$found" ] || set_setting camera_url "$found"
        echo "Printer Buddy Lite: camera at $found"
    else
        echo "Printer Buddy Lite: no camera answered; keeping camera_url '$(setting camera_url)'" >&2
    fi
fi

exec "$BIN"
