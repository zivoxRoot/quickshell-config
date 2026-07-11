import Quickshell
import QtQuick
import QtQuick.Layouts

// TODO: Extract animation in a function like in the other file (idk which...)

import "../config"

RowLayout {
  id: root
  property list<string> buttons: ["Button 1", "Button 2", "Button 3"]
  property int focused: 0
  property bool activated: true

  signal clicked(int index)

  spacing: 3

  Repeater {
    id: repeater
    model: buttons

    Rectangle {
      required property string modelData
      required property int index

      topLeftRadius: focused === index ? height / 2 : (index === 0 ? height / 2 : 3)
      bottomLeftRadius: focused === index ? height / 2 : (index === 0 ? height / 2 : 3)
      topRightRadius: focused === index ? height / 2 : (index === repeater.count - 1 ? height / 2 : 3)
      bottomRightRadius: focused === index ? height / 2 : (index === repeater.count - 1 ? height / 2 : 3)

      color: root.activated ? (focused === index ? Config.md3.primary : Config.md3.tertiary) : Qt.alpha(Config.md3.on_surface, 0.12)
      height: 30
      Layout.fillWidth: true

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Behavior on radius {
        NumberAnimation {
          duration: 150
          easing.type: Easing.InOutQuad
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.activated ? root.clicked(index) : null
      }

      Text {
        anchors.centerIn: parent
        text: modelData
        color: root.activated ? (focused === index ? Config.md3.on_primary : Config.md3.on_tertiary) : Qt.alpha(Config.md3.on_surface, 0.38)
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize

        Behavior on color {
          ColorAnimation { duration: 150 }
        }
      }
    }
  }
}
