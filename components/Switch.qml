import Quickshell
import QtQuick

import "../config"

Rectangle {
  id: root

  property bool toggled: false

  property int padding: 3
  color: toggled ? Config.md3.primary : Config.md3.background
  height: 25
  width: height * 2
  radius: height / 2

  // Moving inside pills
  Rectangle {
    color: toggled ? Config.md3.on_primary : Config.md3.on_background
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.toggled ? parent.width - width - root.padding : 3
    radius: height / 2
    height: parent.height - root.padding * 2
    width: height

    Behavior on anchors.leftMargin {
      NumberAnimation {
        duration: 180
        easing.type: Easing.OutCubic
      }
    }
  }
}
