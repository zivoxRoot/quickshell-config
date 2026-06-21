import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick

import "../../config"

RowLayout {
  spacing: 7

  Repeater {
    model: 9

    Text {
      property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
      property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
      text: index + 1

      color: isActive ? Config.colFocused : (ws ? Config.colFg : "#999796")
      font {
        family: Config.fontFamily
        pixelSize: Config.fontSize
        weight: isActive ? 900 : 500
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace " + (index + 1))
      }
    }
  }
}
