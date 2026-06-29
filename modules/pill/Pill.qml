import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../../modules/wifi"

ShellRoot {
  readonly property int pillHeight: 35
  readonly property int pillWidth: 100
  property string currentSurface: ""

  // Transparent, just used to take place at the top and push windows under it
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { left: true; top: true; right: true; }
      color: "transparent"
      implicitHeight: pillHeight
    }
  }

  function toggle(surface) {
    currentSurface = currentSurface === surface ? "" : surface
  }

  IpcHandler {
    target: "pill"
    function wifi(): void {
      toggle("wifi")
    }
  }

  Component {
    id: wifiMenu
    Wifi {}
  }

  // Centered pill that morphes into other elements
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      exclusionMode: ExclusionMode.Ignore
      anchors { top: true; }
      margins { top: 5; }
      color: "green"
      implicitHeight: loader.item ? loader.item.implicitHeight : pillHeight
      implicitWidth: loader.item ? loader.item.implicitWidth : pillWidth

      WlrLayershell.keyboardFocus:
        currentSurface !== "" ?
          WlrKeyboardFocus.Exclusive :
          WlrKeyboardFocus.None

      Loader {
        id: loader
        anchors.fill: parent
        focus: true

        sourceComponent:
          currentSurface === "wifi" ? wifiMenu :
          null

        onItemChanged: {
          if (item) {
            item.focus = true
            Qt.callLater(() => item.forceActiveFocus())
          }
        }
      }
    }
  }
}
