import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
  visible: !Notifications.doNotDisturb
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
      model: Notifications.popups

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
