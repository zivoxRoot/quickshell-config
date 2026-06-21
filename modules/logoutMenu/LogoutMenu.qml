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
  color: Config.colBg
  visible: false
  implicitHeight: layout.implicitHeight
  implicitWidth: layout.implicitWidth

  property int focusedIndex: 0

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  property var actions: [
    {
      name: "Lock",
      command: ["hyprlock"]
    },
    {
      name: "Hybernate",
      command: ["systemctl", "hybernate"]
    },
    {
      name: "Logout",
      command: ["loginctl", "terminate-user", "$USER"]
    },
    {
      name: "Shutdown",
      command: ["systemctl", "poweroff"]
    },
    {
      name: "Suspend",
      command: ["systemctl", "suspend"]
    },
    {
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
          break

        // Navigate buttons with vim keys
        case Qt.Key_K:
        case Qt.Key_H:
          focusedIndex = Math.max(
            focusedIndex - 1,
            0
          )
          break
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
      root.visible = !root.visible
    }
  }

  Row {
    id: layout
    Layout.fillWidth: true
    spacing: 6
    padding: 10

    Repeater {
      model: actions

      Rectangle {
        required property int index
        required property var modelData
        implicitWidth: label.implicitWidth + 20
        implicitHeight: label.implicitHeight + 20
        color: Config.colBg
        border.width: 2
        border.color: index == focusedIndex ? Config.colFocused : Config.colFg

        Text {
          id: label
          text: modelData.name
          color: Config.colFg
          font.pixelSize: 18
          Layout.fillWidth: true
          anchors.centerIn: parent
        }
          
        MouseArea {
          anchors.fill: parent
          onClicked: {
            root.visible = false
            launcher.command = modelData.command
            launcher.running = true
          }
        }
      }
    }
  }
}
