#!/bin/sh
# Remove the optional Fluidd/Mainsail status card. User settings and photos are left alone.
CFG="${OC_CONFIG_DIR:-/usr/data/opencreator/klipper/config}"
rm -rf "$CFG/.printer-buddy-ai"
exit 0
