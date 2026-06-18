import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../config"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }
      implicitHeight: 38
      color: Config.colBg

      // Main row
      RowLayout {
        anchors {
          fill: parent
          leftMargin: 14
          rightMargin: 14
        }

        Workspaces {}

        Item { Layout.fillWidth: true }

        ClockWidget {}
      }
    }
  }
}
