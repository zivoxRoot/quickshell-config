import QtQuick.Effects
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../../config"

Rectangle {
  id: root

  property var notification

  property bool popupMode
  property bool selected: false
  property bool showRelativeTime: false
  property string relativeTimeText: ""

  signal clicked()

  color: selected ? Config.md3.secondary_container : Config.md3.surface

  implicitHeight: layout.implicitHeight + 20
  radius: 14

  HoverHandler {
    id: hover
  }

  Timer {
    running: popupMode && notification.urgency !== NotificationUrgency.Critical && !hover.hovered
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

    // App icon
    Rectangle {
      visible: appIcon.source.toString() !== ""
      Layout.preferredHeight: 36
      Layout.preferredWidth: 36
      Layout.alignment: Qt.AlignTop

      Image {
        id: appIcon
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: root.notification.image
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 10

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        RowLayout {

          // Title
          Text {
            text: root.notification.summary
            color: selected ? Config.md3.on_secondary_container : Config.md3.on_surface
            font {
              family: Config.fontFamily
              pixelSize: Config.fontSize
              bold: true
            }
            elide: Text.ElideRight
          }

          // Time
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

        // Body
        Text {
          Layout.fillWidth: true
          text: root.notification.body
          visible: text !== ""
          color: selected ? Config.md3.on_secondary_container : Config.md3.on_surface
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
          wrapMode: Text.WordWrap
        }
      }

      // Image
      Image {
        visible: source.toString() !== ""
        width: parent.width
        Layout.fillWidth: true
        fillMode: Image.PreserveAspectFit
        source: root.notification.appIcon
        asynchronous: true
        smooth: true
        readonly property real aspectRatio: (implicitWidth > 0 && implicitHeight > 0
          ? implicitWidth / implicitHeight
          : 16 / 9)
        Layout.preferredHeight: width / aspectRatio
      }

      // Actions
      RowLayout {
        Layout.fillWidth: true

        Repeater {
          model: root.notification.actions

          Rectangle {
            required property var modelData
            height: action.height + 10
            width: action.width + 15
            color: actionHover.hovered ? Config.md3.primary : "transparent"
            radius: height / 2

            Behavior on color {
              ColorAnimation { duration: 150 }
            }

            HoverHandler {
              id: actionHover
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: modelData.invoke()
            }

            Text {
              anchors.centerIn: parent
              id: action
              text: modelData.text
              color: selected ? (actionHover.hovered ? Config.md3.on_primary : Config.md3.on_secondary_container) : (actionHover.hovered ? Config.md3.on_primary : Config.md3.on_surface)
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize
              wrapMode: Text.WordWrap
            }
          }
        }
      }
    }
  }
}
