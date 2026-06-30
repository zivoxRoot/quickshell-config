import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../config"

Scope {
  id: root
  property int focusedIndex: 0

  onFocusedIndexChanged: {
    const item = repeater.itemAt(focusedIndex)

    if (!item) return

    const itemTop = item.y
    const itemBottom = item.y + item.height

    const viewTop = list.contentY
    const viewBottom = list.contentY + list.height

    if (itemTop < viewTop) {
      list.contentY = itemTop
    } else if (itemBottom > viewBottom) {
      list.contentY = itemBottom - list.height
    }
  }

  PanelWindow {
    visible: Notifications.centerOpen
    anchors { top: true; right: true }
    margins { top: 48; right: 10 }

    readonly property int maxPopupSize: 600
    implicitWidth: 380
    implicitHeight: Math.min(
      centerCol.implicitHeight + 10,
      maxPopupSize
    )
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Item {
      id: focusItem
      anchors.fill: parent
      focus: true

      Keys.onPressed: event => {
        switch (event.key) {

          // Dismiss all
          case Qt.Key_C:
          case Qt.Key_Backspace:
          case Qt.Key_Delete:
            Notifications.clear()
            focusedIndex = 0
            break

          // Close notification center
          case Qt.Key_Escape:
            Notifications.toggleCenter()
            break

          // Navigate with vim keybinds
          case Qt.Key_J:
            if (focusedIndex >= Notifications.history.count - 1) {
              break
            }
            focusedIndex += 1
            break

          case Qt.Key_K:
            if (focusedIndex == 0) {
              break
            }
            focusedIndex -= 1
            break

          // Dismiss single notification
          case Qt.Key_D:
          case Qt.Key_X:
            Notifications.remove(focusedIndex)
            if (focusedIndex >= Notifications.history.count && focusedIndex > 0) {
              focusedIndex -= 1
            }
            break
        }
      }
    }

    Rectangle {
      anchors.fill: parent
      color: Config.md3.background
      radius: 14

      ColumnLayout {
        id: centerCol
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Top informations
        RowLayout {

          // Clear all
          Rectangle {
            Layout.preferredHeight: clearText.implicitHeight + 18
            Layout.fillWidth: true
            color: Config.md3.primary
            radius: height / 2

            Text {
              id: clearText
              anchors.centerIn: parent
              text: "Clear all"
              color: Config.md3.on_primary
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                Notifications.clear()
                focusedIndex = 0
              }
            }
          }

          // Do not disturb
          Rectangle {
            Layout.preferredHeight: dndText.implicitWidth + 18
            Layout.preferredWidth: dndText.implicitWidth + 18
            color: Config.md3.secondary
            radius: height / 2

            Text {
              id: dndText
              anchors.centerIn: parent
              text: Notifications.doNotDisturb ? "󰪑" : "󰂜"
              // notification = "󱅫";
              color: Config.md3.on_secondary
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize + 8
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                Notifications.toggleDnd()
              }
            }
          }
        }

        // No notifications placeholder
        Rectangle {
          visible: Notifications.history.count === 0
          Layout.fillWidth: true
          Layout.preferredHeight: text.implicitHeight + 30
          color: "transparent"

          Text {
            id: text
            anchors.centerIn: parent
            text: "No notifications"
            color: Config.md3.on_background
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
          }
        }

        // Notifications list
        Rectangle {
          visible: Notifications.history.count > 0
          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(notificationsColumn.implicitHeight + 10, 410)
          color: "transparent"

          Flickable {
            id: list
            anchors.fill: parent
            contentHeight: notificationsColumn.implicitHeight
            contentWidth: notificationsColumn.width
            clip: true
            bottomMargin: 10

            Column {
              id: notificationsColumn
              width: list.width
              spacing: 10

              Repeater {
                id: repeater
                model: Notifications.history

                NotificationCard {
                  id: currentNotif
                  required property int index
                  required property var modelData

                  notification: modelData.notification

                  popupMode: false
                  width: notificationsColumn.width
                  selected: index == focusedIndex
                  showRelativeTime: true
                  relativeTimeText: Notifications.relativeTime(modelData.timestamp, Notifications.now)

                  onClicked: Notifications.remove(index)
                }
              }
            }
          }
        }
      }
    }
  }
}
