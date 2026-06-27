import QtQuick
import Quickshell.Wayland
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls

import "../../config"

PanelWindow {
  id: root
  anchors { top: true }
  margins { top: 48 }
  color: "transparent"
  visible: false
  implicitHeight: layout.implicitHeight
  implicitWidth: layout.implicitWidth

  property int focusedIndex: 0

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property var actions: [
    {
      icon: "󰌾",
      name: "Lock",
      command: ["qs", "ipc", "call", "lockscreen", "lock"]
    },
    {
      icon: "",
      name: "Hybernate",
      command: ["systemctl", "hybernate"]
    },
    {
      icon: "󰍃",
      name: "Logout",
      command: ["loginctl", "terminate-user", "$USER"]
    },
    {
      icon: "",
      name: "Shutdown",
      command: ["systemctl", "poweroff"]
    },
    {
      icon: "",
      name: "Suspend",
      command: ["systemctl", "suspend"]
    },
    {
      icon: "",
      name: "Reboot",
      command: ["systemctl", "reboot"]
    },
  ]

  
  Item {
    id: focusItem
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
        // Close logout menu
        case Qt.Key_Escape:
          root.visible = false
          root.focusedIndex = false
          break

        // Navigate buttons with vim keys and tabs
        case Qt.Key_Backtab:
        case Qt.Key_K:
        case Qt.Key_H:
          focusedIndex = Math.max(
            focusedIndex - 1,
            0
          )
          break

        case Qt.Key_Tab:
        case Qt.Key_J:
        case Qt.Key_L:
          focusedIndex = Math.min(
            focusedIndex + 1,
            actions.length - 1
          )
          break

        // Click a button
        case Qt.Key_Return:
        case Qt.Key_Enter:
          launcher.command = root.actions[focusedIndex].command
          launcher.running = true
          root.visible = false
          break
      }
    }
  }

  Process {
    id: launcher
    running: false
  }
  
  IpcHandler {
    target: "logout"
    function toggle(): void {
      root.focusedIndex = false
      root.visible = !root.visible
    }
  }

  // Actions list
  Rectangle {
    anchors.fill: parent
    color: Config.md3.background
    radius: 14

    Row {
      id: layout
      Layout.fillWidth: true
      spacing: 6
      padding: 10

      Repeater {
        model: actions

        // Single action
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 16
          required property int index
          required property var modelData

          Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: label.implicitHeight + 25
            implicitHeight: label.implicitHeight + 25
            color: index == focusedIndex ? Config.md3.primary : Config.md3.tertiary
            radius: height / 2

            Text {
              id: label
              text: modelData.icon
              color: index == focusedIndex ? Config.md3.on_primary : Config.md3.on_tertiary
              font.pixelSize: 20
              Layout.fillWidth: true
              anchors.centerIn: parent
            }
              
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.visible = false
                launcher.command = modelData.command
                launcher.running = true
              }
            }
          }

          Text {
            text: modelData.name
            Layout.alignment: Qt.AlignHCenter
            color: index == focusedIndex ? Config.md3.primary : Config.md3.on_background
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize - 2
          }
        }
      }
    }
  }
}
