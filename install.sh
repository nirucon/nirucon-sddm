#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="niru-noir"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/theme"
DEST_DIR="/usr/share/sddm/themes/${THEME_NAME}"
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="${CONF_DIR}/10-${THEME_NAME}.conf"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo ./install.sh"
  exit 1
fi

HOST="$(hostname -s 2>/dev/null || hostname)"
HOST="${HOST:-studio}"

USER_DEFAULT="${SUDO_USER:-}"
[[ "${USER_DEFAULT}" == "root" ]] && USER_DEFAULT=""

to_runes() {
  local input out ch i
  input="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  out=""
  for (( i=0; i<${#input}; i++ )); do
    ch="${input:i:1}"
    case "$ch" in
      a) out+="ᚨ" ;; b) out+="ᛒ" ;; c) out+="ᚲ" ;; d) out+="ᛞ" ;;
      e) out+="ᛖ" ;; f) out+="ᚠ" ;; g) out+="ᚷ" ;; h) out+="ᚺ" ;;
      i) out+="ᛁ" ;; j) out+="ᛃ" ;; k) out+="ᚲ" ;; l) out+="ᛚ" ;;
      m) out+="ᛗ" ;; n) out+="ᚾ" ;; o) out+="ᛟ" ;; p) out+="ᛈ" ;;
      q) out+="ᚲ" ;; r) out+="ᚱ" ;;
      # Sowilo old/stylized variant requested by Nicklas.
      s) out+="ᛊ" ;;
      t) out+="ᛏ" ;; u) out+="ᚢ" ;; v) out+="ᚹ" ;; w) out+="ᚹ" ;;
      x) out+="ᚲᛊ" ;; y) out+="ᛃ" ;; z) out+="ᛉ" ;;
      -|_|.) out+=" " ;;
      *) out+="$ch" ;;
    esac
  done
  printf '%s' "$out"
}

RUNES="$(to_runes "${HOST}")"

echo "Installing ${THEME_NAME}..."
rm -rf "${DEST_DIR}"
install -d "${DEST_DIR}"
cp -a "${SRC_DIR}/." "${DEST_DIR}/"

cat > "${DEST_DIR}/HostInfo.qml" <<EOF
pragma Singleton
import QtQuick 2.15
QtObject {
    property string hostname: "${HOST}"
    property string runes: "${RUNES}"
}
EOF

cat > "${DEST_DIR}/UserDefaults.qml" <<EOF
pragma Singleton
import QtQuick 2.15
QtObject {
    property string username: "${USER_DEFAULT}"
}
EOF

chown -R root:root "${DEST_DIR}"
find "${DEST_DIR}" -type d -exec chmod 755 {} \;
find "${DEST_DIR}" -type f -exec chmod 644 {} \;

install -d "${CONF_DIR}"
if [[ -f "${CONF_FILE}" ]]; then
  cp -a "${CONF_FILE}" "${CONF_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
fi

cat > "${CONF_FILE}" <<EOF
[Theme]
Current=${THEME_NAME}
EOF

echo
echo "Installed."
echo
echo "Hostname: ${HOST}"
echo "Runes:    ${RUNES}"
echo
echo "Test:"
echo "  sddm-greeter-qt6 --test-mode --theme ${DEST_DIR}"
echo
echo "Restart SDDM when ready:"
echo "  sudo systemctl restart sddm"
