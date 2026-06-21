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

  color: Config.colBg

  implicitHeight: layout.implicitHeight + 20
  border.width: 2
  border.color: root.urgency === NotificationUrgency.Critical ? "red" : (selected ? Config.colFocused : Config.colFg)

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

    Image {
      Layout.preferredHeight: 36
      Layout.preferredWidth: 36
      Layout.alignment: Qt.AlignTop
      fillMode: Image.PreserveAspectFit
      visible: source.toString() !== ""
      source: root.icon
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      // Top notification informations
      RowLayout {
        Layout.fillWidth: true

        Text {
          Layout.fillWidth: true
          text: root.summary
          color: Config.colFg
          font {
            family: Config.fontFamily
            pixelSize: Config.fontSize
            bold: true
          }
          elide: Text.ElideRight
        }

        Item { Layout.fillWidth: true }

        Text {
          visible: showRelativeTime
          color: Config.colFg
          text: relativeTimeText
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
        color: Config.colFg
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        wrapMode: Text.WordWrap
      }
    }
  }
}
