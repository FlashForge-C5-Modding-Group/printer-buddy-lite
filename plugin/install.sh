#!/bin/sh
# OpenCreator install/update: validate the bundled native service and create writable data directories.
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
DATA="${OC_PLUGIN_DATA:-$HERE}"

# The native service runs on the printer's X2600, so on a tunneled install it goes on the
# printer, not the SBC.
if [ ! -d /usr/prog/PROGRAM ]; then
    echo "Printer Buddy Lite: install this on the printer itself (SoC or tunneled), not on the SBC" >&2
    exit 1
fi

for f in c/sep_ai webui/index.html models/pbai-x2600rv.bin models/printer-buddy-lite256.int8.bin models/int8.json; do
    [ -f "$HERE/$f" ] || { echo "Printer Buddy Lite: package file missing: $f" >&2; exit 1; }
done
chmod +x "$HERE/c/sep_ai"
mkdir -p "$DATA/data/frames"

[ -f "$DATA/config.json" ] || cat > "$DATA/config.json" <<'JSON'
{
  "moonraker": "http://127.0.0.1:7125",
  "camera_url": "",
  "backend": "auto",
  "interval": 20,
  "threshold": 0.6,
  "checks_in_a_row": 3,
  "pause": false,
  "card": true,
  "card_dir": "",
  "port": 7180,
  "photo_every": 15,
  "save_spaghetti_at": 0.4,
  "keep_frames": 40,
  "keep_alerts": 60,
  "contribute": false,
  "autosend": false,
  "autosend_every": 25,
  "crop_left": 5,
  "crop_right": 5,
  "crop_top": 0,
  "crop_bottom": 0,
  "skip_same": true,
  "same_eps": 2.0,
  "max_same_skips": 10,
  "adaptive_interval": true,
  "mid_factor": 2.0
}
JSON

echo "Printer Buddy Lite: web page on port 7180"
