#!/usr/bin/env bash
set -euo pipefail
if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo ./uninstall.sh"
  exit 1
fi
rm -rf /usr/share/sddm/themes/niru-noir
rm -f /etc/sddm.conf.d/10-niru-noir.conf
echo "Removed niru-noir."
