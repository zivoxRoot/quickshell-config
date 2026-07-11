import Quickshell
import QtQuick


import "../config"

Rectangle {
  id: root

  property string icon: ""
  property string text: "My button"

  signal clicked

  height: 30
  width: icon.width + text.width + 20
  color: Config.md3.primary
  radius: height / 2

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
  }

  Row {
    anchors.centerIn: parent
    spacing: 5
  
    // Icon
    Text {
      id: icon
      visible: root.icon !== ""
      anchors.verticalCenter: parent.verticalCenter
      text: root.icon
      color: Config.md3.on_primary
      font.pixelSize: Config.fontSize + 6
    }

    // Text
    Text {
      id: text
      anchors.verticalCenter: parent.verticalCenter
      text: root.text
      color: Config.md3.on_primary
      font.family: Config.fontFamily
      font.pixelSize: Config.fontSize
    }
  }
}
