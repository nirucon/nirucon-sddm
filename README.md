# NIRU Noir SDDM 1.5.0

Minimal dark SDDM theme for Debian 13 and Arch.

Changes in 1.5.0:
- hostname is now the main runic title
- removed the large standalone Sowilo symbol
- `s` maps to the stylized/older-looking Sowilo variant `ᛊ`
- cleaner top section
- DWM session display retained

## Install

```bash
unzip niru-noir-sddm-1.5.0.zip
cd niru-noir-sddm-1.5.0
sudo ./install.sh
```

## Test

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/niru-noir
```

## Restart

```bash
sudo systemctl restart sddm
```
