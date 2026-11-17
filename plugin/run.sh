#!/bin/sh
# OpenCreator plugin service: runs Printer Buddy Lite. oc-plugin restarts it if it exits.
# Settings and photos live in the writable data folder; the binary, WebUI and models ship with the plugin.
HERE=$(cd "$(dirname "$0")/.." && pwd)
DATA="${OC_PLUGIN_DATA:-$HERE}"
export SEP_AI_HOME="$DATA"
export SEP_AI_MODELS="$HERE/models"

if [ ! -x "$HERE/c/sep_ai" ]; then
    echo "Printer Buddy Lite: missing executable $HERE/c/sep_ai" >&2
    exit 1
fi
exec "$HERE/c/sep_ai"
