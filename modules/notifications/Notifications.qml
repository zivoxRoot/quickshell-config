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
  property bool centerOpen: false
  property bool doNotDisturb: false
  property int focusedIndex: 0
  property double now: Date.now()
  ListModel { id: history }

  // Gives relative time for each notification
  function relativeTime(timestamp, now): string {
    const diff = Math.floor((now - timestamp) / 1000)

    if (diff < 60)
      return "now"

    if (diff < 3600)
      return Math.floor(diff / 60) + "m"

    if (diff < 86400)
      return Math.floor(diff / 3600) + "h"

    return Math.floor(diff / 86400) + "d"
  }

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

  // Update now time each minute
  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: now = Date.now()
  }

  NotificationServer {
    id: server
    actionsSupported: true
    imageSupported: true

    onNotification: n => {
      n.tracked = true
      history.insert(0, {
        notification: n,
        timestamp: Date.now(),
      })
    }
  }

  IpcHandler {
    target: "notifications"
    function toggle(): void {
      root.centerOpen = !root.centerOpen
    }
    function toggleDnd(): void {
      doNotDisturb = !doNotDisturb
    }
  }

  // Notification center
  PanelWindow {
    visible: root.centerOpen
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
            history.clear()
            focusedIndex = 0
            break

          // Close notification center
          case Qt.Key_Escape:
            root.centerOpen = false
            break

          case Qt.Key_Space:
            repeater.itemAt(focusedIndex).toggleImageOpen()
            break

          // Navigate with vim keybinds
          case Qt.Key_J:
            if (focusedIndex >= history.count - 1) {
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
            history.remove(focusedIndex)
            if (focusedIndex >= history.count && focusedIndex > 0) {
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
                history.clear()
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
              text: doNotDisturb ? "󰪑" : "󰂜"
              // notification = "󱅫";
              color: Config.md3.on_secondary
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize + 8
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.doNotDisturb = !root.doNotDisturb
              }
            }
          }
        }

        // No notifications placeholder
        Rectangle {
          visible: history.count === 0
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
          visible: history.count > 0
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
                model: history

                NotificationCard {
                  id: currentNotif
                  required property int index
                  required property var modelData

                  notification: modelData.notification

                  popupMode: false
                  width: notificationsColumn.width
                  selected: index == focusedIndex
                  showRelativeTime: true
                  relativeTimeText: relativeTime(modelData.timestamp, root.now)

                  onClicked: history.remove(index)
                }
              }
            }
          }
        }
      }
    }
  }

  // Single notification
  PanelWindow {
    visible: !doNotDisturb
    anchors { top: true; right: true }
    margins { top: 48; right: 10 }

    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
      id: column
      width: parent.width
      spacing: 10

      Repeater {
        model: server.trackedNotifications

        NotificationCard {
          required property var modelData
          Layout.fillWidth: true

          notification: modelData

          popupMode: true
          selected: false
          showRelativeTime: false

          onClicked: modelData.dismiss()
        }
      }
    }
  }
}
