# Printer Buddy Lite

OpenCreator Plugin for the RISC-V core in the x2600, running with almost zero input from the main CPU.

> **Want the fully featured version with sharing and more features? Use [Printer Buddy](https://github.com/printer-buddy/printer-buddy).**

## Install

On the printer, install this repository with OpenCreator's plugin manager:

```sh
oc-plugin install https://github.com/FlashForge-C5-Modding-Group/printer-buddy-lite.git
```

Open **http://PRINTER-IP:7180/** after installation. The plugin starts automatically and restarts on boot.

### Tunneled printers

Install it on the printer, not the SBC: it runs on the printer's X2600. It finds the SBC's Moonraker by itself
(`oc-plugin moonraker --find`). If several tunneled printers are on the
network, pick this printer's SBC once with `oc-plugin moonraker --scan`. To use another Moonraker, set
`moonraker` in the settings yourself; it's left alone unless it points at the printer itself.

## Contents

- `c/sep_ai` — compiled native service and WebUI/photo API
- `models/` — X2600 firmware, integer network, and model metadata
- `webui/index.html` — browser interface
- `plugin/` — OpenCreator install, launch, and uninstall scripts
- `opencreator-plugin.json` — plugin manifest

Settings and captured photos are stored outside this repository in OpenCreator's plugin data directory.

### Camera

At every start the plugin finds the camera itself instead of using the snapshot address in Moonraker's webcam
settings, which often doesn't work from the printer (a relative `/webcam/` path, a `.local` name, or none). It
tries the printer's own camera (`http://127.0.0.1:8080`) and then the IP and port of each webcam's stream address,
with `/?action=snapshot` and `/snapshot`, and writes the first that answers to `camera_url`. If none answers,
`camera_url` is left as it is.

### Sending photos to the dataset

With `contribute` and `autosend` on, photos labelled automatically when a print ends are sent one in every
`autosend_every` (default 25; the count carries over between prints). The rest aren't sent. Photos you label
yourself are always sent.
