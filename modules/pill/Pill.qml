import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../../modules/wifi"
import "../../modules/bluetooth"
import "../../modules/music"
import "../../modules/logoutMenu"
import "../../modules/launcher"
import "../../modules/wallpaper_switcher"
import "../../modules/control_center"

import "../../config"
import "../../services/time"

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

    function bluetooth(): void {
      toggle("bluetooth")
    }

    function music(): void {
      toggle("music")
    }

    function logout(): void {
      toggle("logout")
    }

    function launcher(): void {
      toggle("launcher")
    }

    function wallpaper_switcher(): void {
      toggle("wallpaper_switcher")
    }

    function control_center(): void {
      toggle("control_center")
    }
  }

  Component {
    id: wifiMenu
    Wifi {}
  }

  Component {
    id: bluetoothMenu
    Bluetooth {}
  }

  Component {
    id: musicMenu
    Music {}
  }

  Component {
    id: logoutMenu
    LogoutMenu {}
  }

  Component {
    id: launcherMenu
    Launcher {}
  }

  Component {
    id: wallpaperSwitcherMenu
    Switcher {}
  }

  Component {
    id: controlCenterMenu
    ControlCenter {}
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
      color: "transparent"
      implicitHeight: loader.item ? loader.item.implicitHeight : pillHeight
      implicitWidth: loader.item ? loader.item.implicitWidth : pillWidth

      Behavior on height {
        NumberAnimation {
          duration: 180
          easing.type: Easing.OutCubic
        }
      }

      Behavior on width {
        NumberAnimation {
          duration: 180
          easing.type: Easing.OutCubic
        }
      }

      Rectangle {
        anchors.fill: parent
        color: Config.md3.background
        radius: height / 2

        Text {
          text: Qt.formatDateTime(Time.time, "hh:mm")
          anchors.centerIn: parent
          color: Config.md3.on_background
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }
      }

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
          currentSurface === "bluetooth" ? bluetoothMenu :
          currentSurface === "music" ? musicMenu :
          currentSurface === "logout" ? logoutMenu :
          currentSurface === "launcher" ? launcherMenu :
          currentSurface === "wallpaper_switcher" ? wallpaperSwitcherMenu :
          currentSurface === "control_center" ? controlCenterMenu :
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
