#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="niru-noir"
VERSION="1.5.3"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme"
DEST_DIR="/usr/share/sddm/themes/${THEME_NAME}"
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="${CONF_DIR}/10-${THEME_NAME}.conf"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo ./install.sh"
  exit 1
fi

USER_DEFAULT="${SUDO_USER:-}"
[[ "${USER_DEFAULT}" == "root" ]] && USER_DEFAULT=""

qml_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "${value}"
}

USER_DEFAULT_QML="$(qml_escape "${USER_DEFAULT}")"
HOST_DEFAULT="$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || true)"
HOST_DEFAULT="${HOST_DEFAULT%%$'\n'*}"
HOST_DEFAULT_QML="$(qml_escape "${HOST_DEFAULT}")"

echo "Installing ${THEME_NAME}..."
rm -rf "${DEST_DIR}"
install -d "${DEST_DIR}"
cp -a "${SRC_DIR}/." "${DEST_DIR}/"

# Username default is intentionally local to this machine.
# Hostname fallback is written here; Main.qml prefers /etc/hostname at greeter runtime.
cat > "${DEST_DIR}/UserDefaults.qml" <<EOF2
pragma Singleton
import QtQuick 2.15
QtObject {
    property string username: "${USER_DEFAULT_QML}"
}
EOF2

# Offline fallback for SDDM builds that do not expose sddm.hostName correctly.
# Main.qml still prefers /etc/hostname when it is readable at greeter runtime.
cat > "${DEST_DIR}/HostInfo.qml" <<EOF2
pragma Singleton
import QtQuick 2.15
QtObject {
    property string hostname: "${HOST_DEFAULT_QML}"
    property string runes: ""
}
EOF2

chown -R root:root "${DEST_DIR}"
find "${DEST_DIR}" -type d -exec chmod 755 {} \;
find "${DEST_DIR}" -type f -exec chmod 644 {} \;

install -d "${CONF_DIR}"
if [[ -f "${CONF_FILE}" ]]; then
  cp -a "${CONF_FILE}" "${CONF_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
fi

cat > "${CONF_FILE}" <<EOF2
[Theme]
Current=${THEME_NAME}
EOF2

echo
echo "Installed ${THEME_NAME}."
echo
echo "Test:"
echo "  sddm-greeter-qt6 --test-mode --theme ${DEST_DIR}"
echo
echo "Restart SDDM when ready:"
echo "  sudo systemctl restart sddm"
