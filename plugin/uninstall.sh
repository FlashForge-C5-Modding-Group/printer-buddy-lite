#!/bin/sh
# Remove the optional Fluidd/Mainsail status card. User settings and photos are left alone.
CFG="${OC_CONFIG_DIR:-/usr/data/opencreator/klipper/config}"
rm -rf "$CFG/.printer-buddy-ai"

# Remove the external executable without touching other data.
rm -f /usr/data/opencreator/sep-ai/sep_ai
rm -f /usr/data/opencreator/sep-ai/c/sep_ai
rm -f /usr/data/opencreator/sep-ai/webui
rmdir /usr/data/opencreator/sep-ai/c 2>/dev/null || true
rmdir /usr/data/opencreator/sep-ai 2>/dev/null || true
exit 0
