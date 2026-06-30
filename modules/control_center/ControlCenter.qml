import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

import "../../config"
import "../../services/time"

FocusScope {
  id: root
  implicitHeight: 60
  implicitWidth: 600

  Keys.onPressed: event => {
    switch (event.key) {
    // Close with `escape`
    case Qt.Key_Escape:
      root.visible = false
      focusedIndex = 0
      break

    // Navigate with vim keys
    case Qt.Key_J:
      focusedIndex = Math.min(focusedIndex + 1, devices?.length - 1)
      break
    case Qt.Key_K:
      focusedIndex = Math.max(focusedIndex - 1, 0)
      break

    // (Dis)connect with `enter` or `space`
    case Qt.Key_Return:
    case Qt.Key_Space:
      const device = root.sortedDevices[focusedIndex]
      if (!device) return;
      if (device.connected) device.disconnect();
      else if (device.pairing) device.cancelPair();
      else device.connect();
      break

    // Forget device with `D`
    case Qt.Key_D:
      const dev = root.sortedDevices[focusedIndex]
      if (!dev) return;
      dev.forget()
      break

    // Search with `S`
    case Qt.Key_S:
      if (!root.adapter) return;
      root.adapter.discovering = !root.adapter.discovering;
      if (root.adapter.discovering)
        scanTimer.restart()
      else
        scanTimer.stop()
      break

    // Toggle bluetooth with `T`
    case Qt.Key_T:
      if (root.adapter) root.adapter.enabled = !root.adapter.enabled
      break
    }
  }

  // Main window layout
  Rectangle {
    anchors.fill: parent
    color: Config.md3.background
    radius: 14

    RowLayout {
      anchors.fill: parent
      anchors.margins: 10
      spacing: 10

      Workspaces {}

      Item {
        Layout.fillWidth: true
      }

      // Date and time
      ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        Text {
          text: Qt.formatDateTime(Time.time, "hh:mm")
          color: Config.md3.on_background
          anchors.horizontalCenter: parent.horizontalCenter
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }

        Text {
          text: Qt.formatDateTime(Time.time, "ddd d MMMM")
          color: Config.md3.primary
          anchors.horizontalCenter: parent.horizontalCenter
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }
      }

      Item {
        Layout.fillWidth: true
      }

      RowLayout {
        spacing: 10

        ThemeButton {}
        Power {}
      }
    }
  }
}
