import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick

import "../../config"

RowLayout {
  spacing: 3

  Repeater {
    model: 9

    Item {
      width: 20
      height: 10

      Rectangle {
        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
        height: 10
        anchors.centerIn: parent
        width: isActive ? 20 : (ws ? 15 : 10)
        radius: height / 2

        color: isActive ? Config.md3.primary : (ws ? Config.md3.secondary : "white")

        Behavior on color {
          ColorAnimation { duration: 150 }
        }

        MouseArea {
          cursorShape: Qt.PointingHandCursor
          anchors.fill: parent
          onClicked: Hyprland.dispatch("workspace " + (index + 1))
        }
      }
    }
  }
}
