import QtQuick 2.15
import SddmComponents 2.0
import "."

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#050505"

    property color fg: "#d9d9d9"
    property color muted: "#777777"
    property color dim: "#4f4f4f"
    property color line: "#282828"
    property color inputBg: "#0f0f0f"
    property color inputBorder: "#383838"
    property color focusBorder: "#9a9a9a"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    function clampSession() {
        if (sessionModel.count <= 0) {
            sessionIndex = 0
            return
        }
        if (sessionIndex < 0) sessionIndex = sessionModel.count - 1
        if (sessionIndex >= sessionModel.count) sessionIndex = 0
    }

    function prevSession() {
        sessionIndex--
        clampSession()
    }

    function nextSession() {
        sessionIndex++
        clampSession()
    }

    function doLogin() {
        errorText.text = ""
        sddm.login(userInput.text, passInput.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "login failed"
            passInput.text = ""
            passInput.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorText.text = ""
        }
    }

    Canvas {
        anchors.fill: parent
        opacity: 0.30
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var g = ctx.createRadialGradient(width/2, height*0.46, 50, width/2, height*0.46, Math.max(width, height)*0.62)
            g.addColorStop(0, "#151515")
            g.addColorStop(0.52, "#080808")
            g.addColorStop(1, "#000000")
            ctx.fillStyle = g
            ctx.fillRect(0, 0, width, height)

            ctx.globalAlpha = 0.11
            ctx.strokeStyle = "#202020"
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.arc(width/2, height*0.47, Math.min(width, height)*0.33, 0, 2*Math.PI)
            ctx.stroke()
        }
    }

    Column {
        id: header
        anchors {
            top: parent.top
            topMargin: Math.max(62, parent.height * 0.085)
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 12

        // Hostname as Elder Futhark. The font is intentionally normal sans,
        // because most systems already render Unicode runes cleanly.
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: HostInfo.runes
            color: root.fg
            opacity: 0.96
            font.pixelSize: Math.max(42, root.height * 0.064)
            font.letterSpacing: 9
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: HostInfo.hostname.toUpperCase()
            color: root.muted
            opacity: 0.88
            font.pixelSize: 15
            font.letterSpacing: 7
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 275
            height: 1
            color: root.line
            opacity: 0.9
        }
    }

    Column {
        id: panel
        width: Math.min(340, root.width - 80)
        spacing: 11
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Math.max(310, parent.height * 0.385)
        }

        Rectangle {
            width: parent.width
            height: 42
            color: root.inputBg
            border.color: userInput.activeFocus ? root.focusBorder : root.inputBorder
            border.width: 1

            TextInput {
                id: userInput
                anchors.fill: parent
                anchors.leftMargin: 13
                anchors.rightMargin: 13
                verticalAlignment: TextInput.AlignVCenter
                color: root.fg
                selectionColor: "#404040"
                selectedTextColor: "#ffffff"
                font.pixelSize: 15
                text: UserDefaults.username
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "user"
                    color: root.muted
                    font.pixelSize: 15
                    visible: userInput.text.length === 0 && !userInput.activeFocus
                }

                Keys.onReturnPressed: passInput.forceActiveFocus()
                Keys.onEnterPressed: passInput.forceActiveFocus()
            }
        }

        Rectangle {
            width: parent.width
            height: 42
            color: root.inputBg
            border.color: passInput.activeFocus ? root.focusBorder : root.inputBorder
            border.width: 1

            TextInput {
                id: passInput
                anchors.fill: parent
                anchors.leftMargin: 13
                anchors.rightMargin: 13
                verticalAlignment: TextInput.AlignVCenter
                color: root.fg
                selectionColor: "#404040"
                selectedTextColor: "#ffffff"
                font.pixelSize: 15
                echoMode: TextInput.Password
                passwordCharacter: "●"
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "password"
                    color: root.muted
                    font.pixelSize: 15
                    visible: passInput.text.length === 0 && !passInput.activeFocus
                }

                Keys.onReturnPressed: root.doLogin()
                Keys.onEnterPressed: root.doLogin()
                Component.onCompleted: forceActiveFocus()
            }
        }

        Rectangle {
            width: parent.width
            height: 38
            color: "#0b0b0b"
            border.color: root.inputBorder
            border.width: 1

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "‹"
                color: root.muted
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevSession()
                }
            }

            Item {
                anchors.centerIn: parent
                width: parent.width - 90
                height: parent.height

                Repeater {
                    model: sessionModel
                    delegate: Text {
                        anchors.centerIn: parent
                        visible: index === root.sessionIndex
                        text: {
                            if (typeof name !== "undefined" && name !== "") return String(name).toUpperCase()
                            if (typeof file !== "undefined" && file !== "") return String(file).replace(".desktop", "").toUpperCase()
                            return "SESSION"
                        }
                        color: root.fg
                        font.pixelSize: 13
                        font.letterSpacing: 3
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: sessionModel.count <= 0
                    text: "SESSION"
                    color: root.fg
                    font.pixelSize: 13
                    font.letterSpacing: 3
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "›"
                color: root.muted
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -12
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextSession()
                }
            }
        }

        Rectangle {
            width: 180
            height: 38
            anchors.horizontalCenter: parent.horizontalCenter
            color: loginArea.pressed ? "#2a2a2a" : "#151515"
            border.color: loginArea.containsMouse ? root.focusBorder : root.inputBorder
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "ENTER"
                color: root.fg
                font.pixelSize: 12
                font.letterSpacing: 4
            }

            MouseArea {
                id: loginArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.doLogin()
            }
        }

        Text {
            id: errorText
            width: parent.width
            text: ""
            color: "#b85c5c"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Column {
        anchors {
            bottom: parent.bottom
            bottomMargin: 26
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "hh:mm")
            color: root.dim
            font.pixelSize: 13
            font.letterSpacing: 4
            Timer {
                interval: 10000
                running: true
                repeat: true
                onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm")
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 28

            Text {
                text: "shutdown"
                color: root.muted
                opacity: 0.75
                font.pixelSize: 11
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.powerOff()
                }
            }

            Text {
                text: "reboot"
                color: root.muted
                opacity: 0.75
                font.pixelSize: 11
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.reboot()
                }
            }
        }
    }
}
