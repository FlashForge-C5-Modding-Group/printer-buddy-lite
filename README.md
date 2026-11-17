# Printer Buddy Lite

OpenCreator Plugin for the RISC-V core in the x2600, running with almost zero input from the main CPU.

> **Want the fully featured version with sharing and more features? Use [Printer Buddy](https://github.com/printer-buddy/printer-buddy).**

## Install

On the printer, install this repository with OpenCreator's plugin manager:

```sh
oc-plugin install https://github.com/FlashForge-C5-Modding-Group/printer-buddy-lite.git
```

Open **http://PRINTER-IP:7180/** after installation. The plugin starts automatically and restarts on boot.

## Contents

- `c/sep_ai` — compiled native service and WebUI/photo API
- `models/` — X2600 firmware, integer network, and model metadata
- `webui/index.html` — browser interface
- `plugin/` — OpenCreator install, launch, and uninstall scripts
- `opencreator-plugin.json` — plugin manifest

Settings and captured photos are stored outside this repository in OpenCreator's plugin data directory.
