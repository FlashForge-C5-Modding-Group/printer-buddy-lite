#!/bin/sh
# OpenCreator plugin service: runs Printer Buddy Lite. oc-plugin restarts it if it exits.
# Settings and photos live in the writable data folder; the binary, WebUI and models ship with the plugin.
HERE=$(cd "$(dirname "$0")/.." && pwd)
DATA="${OC_PLUGIN_DATA:-$HERE}"
CONF="$DATA/config.json"
OC_PLUGIN=/usr/data/opencreator/plugin-manager/oc-plugin
export SEP_AI_HOME="$DATA"
export SEP_AI_MODELS="$HERE/models"

if [ ! -x "$HERE/c/sep_ai" ]; then
    echo "Printer Buddy Lite: missing executable $HERE/c/sep_ai" >&2
    exit 1
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
    # The camera stays on the printer
    if [ -z "$(setting camera_url)" ]; then
        for cam in http://127.0.0.1:8080/snapshot "http://127.0.0.1:8080/?action=snapshot"; do
            if wget -q -T 3 -O /dev/null "$cam" 2>/dev/null; then
                set_setting camera_url "$cam"
                echo "Printer Buddy Lite: using the printer's camera at $cam"
                break
            fi
        done
    fi
fi

exec "$HERE/c/sep_ai"
