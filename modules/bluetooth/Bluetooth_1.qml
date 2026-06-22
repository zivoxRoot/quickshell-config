import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

import "../../config"

PanelWindow {
  id: root
  visible: false
  anchors { top: true; right: true }
  margins { top: 48; right: 10 }

  readonly property int maxPopupHeight: 600
  // implicitHeight: 600
  implicitHeight: Math.min(
    maxPopupHeight,
    contentColumn.implicitHeight + 10
  )
  implicitWidth: 380
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  readonly property var adapter: typeof Bluetooth !== "undefined" && Bluetooth ? Bluetooth.defaultAdapter : null
  readonly property var devices: typeof Bluetooth !== "undefined" && Bluetooth && Bluetooth.devices ? Bluetooth.devices.values : []
  readonly property int connectedCount: {
    var n = 0;
    for (var i = 0; i < devices.length; i++) if (devices[i] && devices[i].connected) n++;
    return n
  }
  readonly property var sortedDevices: {
    var arr = root.devices.slice();

    arr.sort(function(a, b) {
      function rank(d) {
        if (d.connected) return 0;
        if (d.trusted) return 1;
        if (d.paired) return 2;
        return 3;
      }

      return rank(a) - rank(b);
    });

    return arr;
  }

  function metaFor(d) {
    if (!d) return "";
    var parts = [];
    if (d.connected) parts.push("connected");
    else if (d.paired) parts.push("paired");
    if (d.state !== undefined && typeof BluetoothDeviceState !== "undefined") {
      var st = BluetoothDeviceState.toString(d.state);
      if(st && st.length > 0 && parts.indexOf(st.toLowerCase()) === -1) parts.push(st.toLowerCase());
    }
    return parts.join(" · ");
  }

  function batteryFor(d) {
    if (!d || d.battery === undefined || d.battery === null) return "";
    var b = d.battery;
    if (b <= 0) return "";
    if (b <= 1) b = b * 100;
    return Math.round(b) + "%";
  }

  property int focusedIndex: 0

  Timer {
    id: scanTimer
    interval: 25000
    repeat: false
    onTriggered: if (root.adapter) root.adapter.discovering = false
  }

  IpcHandler {
    target: "bluetooth"
    function toggle(): void {
      if (root.visible) focusedIndex = 0
      root.visible = !root.visible
    }
  }

  Item {
    id: focusItem
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
      // Close with escape
      case Qt.Key_Escape:
        root.visible = false
        focusedIndex = 0
        break

      // Navigate with vim keys
      case Qt.Key_J:
        focusedIndex = Math.min(focusedIndex + 1, devices?.length - 1)
        break
      case Qt.Key_K:
        focusedIndex = Math.max(focusedIndex - 1, 0)
        break

      // (Dis)connect with enter or space
      case Qt.Key_Enter:
      case Qt.Key_Space:
        const device = root.devices[focusedIndex]
        if (!device) return;
        if (device.connected) device.disconnect();
        else device.connect();
        break

      // Search with S
      case Qt.Key_S:
        if (!root.adapter) return;
        root.adapter.discovering = !root.adapter.discovering;
        if (root.adapter.discovering)
          scanTimer.restart()
        else
          scanTimer.stop()
        break
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Config.colBg
    border.color: Config.colFg

    ColumnLayout {
      id: contentColumn
      anchors.fill: parent
      anchors.margins: 10
      spacing: 10

      Text {
        visible: root.devices.length === 0
        text: (root.adapter && root.adapter.discovering) ? "Searching..." : "No devices"
      }

      // Bluetooth enabled button
      Rectangle {
        id: toggleBluetooth
        color: Config.colBg
        border.color: Config.colFg
        height: 40
        Layout.fillWidth: true

        Text {
          anchors.centerIn: parent
          text: "Bluetooth " + (root.adapter ? (root.adapter.enabled ? "activated" : "desactivated") : "desactivated")
          color: Config.colFg
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }
  
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.adapter) root.adapter.enabled = !root.adapter.enabled
          }
        }
      }

      // Scan
      Rectangle {
        visible: root.adapter.enabled
        id: scanBtn
        property bool scanning: root.adapter ? root.adapter.discovering : false
        color: Config.colBg
        border.color: Config.colFg
        height: 40
        Layout.fillWidth: true

        Text {
          anchors.centerIn: parent
          text: scanBtn.scanning ? "Scanning..." : "Scan for devices"
          color: Config.colFg
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }
  
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (!root.adapter) return;
            root.adapter.discovering = !root.adapter.discovering;
            if (root.adapter.discovering)
              scanTimer.restart()
            else
              scanTimer.stop()
          }
        }
      }

      // Devices list
      Flickable {
        id: list
        visible: root.devices.length > 0 && root.adapter.enabled
        Layout.fillWidth: true
        // Layout.fillHeight: true
        Layout.preferredHeight: Math.min(rows.implicitHeight, 400)
        contentHeight: rows.implicitHeight
        contentWidth: rows.width
        clip: true

        Column {
          id: rows
          width: list.width
          spacing: 10

          Repeater {
            // model: root.devices
            model: root.sortedDevices

            // One device
            Rectangle {
              required property var modelData
              required property int index
              color: isConnected ? Config.colFocused : Config.colBg
              border.color: index === focusedIndex ? "blue" : Config.colFg
              // implicitHeight: content.implicitHeight + 10
              // implicitWidth: content.implicitWidth + 10
              implicitHeight: 54
              readonly property bool isConnected: modelData ? modelData.connected : false
              readonly property string battery: root.batteryFor(modelData)
              width: rows.width

              // Connect on click
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (!modelData) return;
                  if (modelData.connected) modelData.disconnect();
                  else modelData.connect();
                }
              }

              RowLayout {
                id: content
                anchors.fill: parent
                
                Text {
                  leftPadding: 10
                  text: "🎧"
                  color: Config.colFg
                  font.family: Config.fontFamily
                  font.pixelSize: Config.fontSize
                }

                ColumnLayout  {
                  Layout.fillWidth: true
                  Layout.topMargin: 5
                  Layout.bottomMargin: 5
                  spacing: 2

                  Text {
                    id: label
                    text: (modelData ? (modelData.deviceName || modelData.name || "Unknown") : "Unknown")
                    color: Config.colFg
                    font.bold: true
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                  }
                  Text {
                    id: connected
                    text: root.metaFor(modelData)
                    color: Config.colFg
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize - 2
                  }
                }

                // Device's battery
                Text {
                  visible: isConnected && battery.length > 0
                  text: battery
                  color: Config.colFg
                  font.family: Config.fontFamily
                  font.pixelSize: Config.fontSize - 2
                }
              }
            }
          }
        }
      }
    }
  }
}
