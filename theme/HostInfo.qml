pragma Singleton
import QtQuick 2.15

// Kept only for compatibility with older installs.
// Main.qml now reads the live hostname from SDDM instead of using this file.
QtObject {
    property string hostname: ""
    property string runes: ""
}
