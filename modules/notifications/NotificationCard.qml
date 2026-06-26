import QtQuick.Effects
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../../config"

Rectangle {
  id: root

  property string summary
  property string body
  property string icon
  property int urgency

  property bool popupMode
  property bool selected: false
  property bool showRelativeTime: false
  property string relativeTimeText: ""

  signal clicked()

  color: selected ? Config.md3.secondary_container : Config.md3.surface

  implicitHeight: layout.implicitHeight + 20
  radius: height / 4

  Timer {
    running: popupMode && urgency !== NotificationUrgency.Critical
    interval: 2000
    onTriggered: root.clicked()
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
  }

  RowLayout {
    id: layout
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    Rectangle {
      visible: image.source.toString() !== ""
      Layout.preferredHeight: 36
      Layout.preferredWidth: 36
      Layout.alignment: Qt.AlignTop

      Image {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.icon
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      // Top notification informations
      RowLayout {

        Text {
          text: root.summary
          color: selected ? Config.md3.on_secondary_container : Config.md3.on_surface
          font {
            family: Config.fontFamily
            pixelSize: Config.fontSize
            bold: true
          }
          elide: Text.ElideRight
        }

        Text {
          visible: showRelativeTime
          color: selected ? Config.md3.on_secondary_container : Config.md3.on_surface
          text: "· " + relativeTimeText
          font {
            family: Config.fontFamily
            pixelSize: Config.fontSize
            bold: true
          }
          elide: Text.ElideRight
        }
      }

      Text {
        Layout.fillWidth: true
        text: root.body
        visible: text !== ""
        color: selected ? Config.md3.on_secondary_container : Config.md3.on_surface
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        wrapMode: Text.WordWrap
      }
    }
  }
}
