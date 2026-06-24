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
  color: "transparent"
  implicitHeight: Math.min(
    maxPopupHeight,
    contentColumn.implicitHeight + 10
  )
  implicitWidth: 380
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  readonly property int maxPopupHeight: 600
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

  function iconFor(device) {
    switch (device.icon) {
    case "audio-headphones":
      return "󰋋";
    case "audio-headset":
      return "󰋎";
    case "input-mouse":
      return "󰍽";
    case "input-keyboard":
      return "󰌓";
    default:
      return "󰂯";
    }
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
    const block =  parts.join(" · ");
    if (block.length === 0) return ""
    return block.charAt(0).toUpperCase() + block.slice(1)
  }

  function batteryFor(d) {
    if (!d || d.battery === undefined || d.battery === null) return "";
    var b = d.battery;
    if (b <= 0) return "";
    if (b <= 1) b = b * 100;
    return Math.round(b) + "%";
  }

  property int focusedIndex: 0

  // Autoscroll
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
      // Close with `escape`
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

      // (Dis)connect with `enter` or `space`
      case Qt.Key_Return:
      case Qt.Key_Space:
        const device = root.sortedDevices[focusedIndex]
        if (!device) return;
        if (device.connected) device.disconnect();
        else if (device.pairing) device.cancelPair();
        else device.connect();
        break

      // Forget device with `D`
      case Qt.Key_D:
        const dev = root.sortedDevices[focusedIndex]
        if (!dev) return;
        dev.forget()
        break

      // Search with `S`
      case Qt.Key_S:
        if (!root.adapter) return;
        root.adapter.discovering = !root.adapter.discovering;
        if (root.adapter.discovering)
          scanTimer.restart()
        else
          scanTimer.stop()
        break

      // Toggle bluetooth with `T`
      case Qt.Key_T:
        if (root.adapter) root.adapter.enabled = !root.adapter.enabled
        break
      }
    }
  }

  // Main window layout
  Rectangle {
    anchors.fill: parent
    color: "#1b1e25"
    radius: 14

    ColumnLayout {
      id: contentColumn
      anchors.fill: parent
      anchors.margins: 10
      spacing: 10

      // Bluetooth enabled button
      RowLayout {
        Rectangle {
          id: toggleBluetooth
          color: root.adapter ? (root.adapter.enabled ? "#36393f" : "#1f222b") : "#1f222b"
          radius: 12
          height: 40
          width: 40

          Behavior on color {
            ColorAnimation { duration: 150 }
          }

          Text {
            anchors.centerIn: parent
            text: root.adapter ? (root.adapter.enabled ? "󰂯" : "󰂲") : "󰂲"
            color: Config.colFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize + 6
          }
    
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.adapter) root.adapter.enabled = !root.adapter.enabled
            }
          }
        }

        Text {
          text :"Bluetooth"
          color: Config.colFg
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize + 2
          leftPadding: 10
        }
      }
      // Keep padding under button when bluetooth desactivated
      Item {
        visible: !root.adapter.enabled
        height: 0
      }

      // Scan button
      Rectangle {
        visible: root.adapter.enabled
        id: scanBtn
        property bool scanning: root.adapter ? root.adapter.discovering : false
        color: "#1f222b"
        height: 40
        radius: 10
        Layout.fillWidth: true

        RowLayout {
          anchors.centerIn: parent
          spacing: 8

          Text {
            visible: !scanBtn.scanning
            text: "󰑓"
            color: Config.colFg
            font.pixelSize: Config.fontSize + 6
          }
          Text {
            text: scanBtn.scanning ? "Scanning..." : "Scan for devices"
            color: Config.colFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
          }
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

      // No devices placeholder
      Rectangle {
        visible: root.sortedDevices.length === 0
        radius: 10
        color: "#36393f"
        
        Text {
          anchors.centerIn: parent
          text: "No devices found"
        }
      }

      // Devices list
      Rectangle {
        visible: root.adapter.enabled
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(rows.implicitHeight + 10, 410)
        color: "transparent"

        Flickable {
          id: list
          anchors.fill: parent
          contentHeight: rows.implicitHeight
          contentWidth: rows.width
          clip: true
          bottomMargin: 10

          Column {
            id: rows
            width: list.width

            Repeater {
              id: repeater
              model: root.sortedDevices

              Rectangle {
                required property var modelData
                required property int index
                readonly property bool isTop: index === 0
                readonly property bool isBottom: index === root.sortedDevices.length - 1
                readonly property bool isConnected: modelData ? modelData.connected : false
                readonly property string battery: root.batteryFor(modelData)
                implicitHeight: 54
                width: rows.width
                topLeftRadius: isTop ? 10 : 0
                topRightRadius: isTop ? 10 : 0
                bottomLeftRadius: isBottom ? 10 : 0
                bottomRightRadius: isBottom ? 10 : 0
                color: index === focusedIndex ? "#36393f" : "#1f222b"

                // Click to connect
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
                  spacing: 12
                  
                  Text {
                    leftPadding: 10
                    text: iconFor(modelData)
                    color: isConnected ? Config.colFocused : Config.colFg
                    font.pixelSize: Config.fontSize + 4

                    Behavior on color {
                      ColorAnimation { duration: 150 }
                    }
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

                  // Push the battery to the right
                  Item {
                    Layout.fillWidth: true
                  }

                  // Battery
                  Item {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50

                    Text {
                      anchors.centerIn: parent
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
  }
}
