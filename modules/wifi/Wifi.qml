import QtQuick
import QtQuick.Controls
import QtQml.Models
import Quickshell
import Quickshell.Networking
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

  property int focusedIndex: 0
  readonly property int maxPopupHeight: 600

  property var passwordNetwork: null
  property bool showPasswordInput: false
  property bool awaitingPassword: false

  readonly property var devices: (typeof Networking !== "undefined" && Networking && Networking.devices) ? Networking.devices.values : []
  readonly property var eth: devices.find(function(d) { return d && d.type === DeviceType.Wired && d.connected }) || null
  readonly property var wifiDev: devices.find(function(d) { return d && d.type === DeviceType.Wifi }) || null
  readonly property bool wired: eth !== null

  readonly property real ethSpeed: (eth && eth.linkSpeed) ? eth.linkSpeed : 0
  readonly property real ethSpeedText: ethSpeed > 0
    ? (ethSpeed >= 1000 ? (ethSpeed / 1000).toFixed(ethSpeed % 1000 === 0 ? 0 : 1) + " Gb/s" : ethSpeed + " Mb/s")
    : ""

  property string ethIp: ""
  Process {
    id: ipProc
    command: ["sh", "-c", "ip -4 -o addr show scope global up | awk '{for(i=1;i<=NF;i++) if($i==\"inet\"){print $(i+1); exit}}' | cut -d/ -f1"]
    running: false
    stdout: StdioCollector { onStreamFinished: root.ethIp = this.text.trim() }
  }
  Component.onCompleted: ipProc.running = true
  onWiredChanged: ipProc.running = true

  Timer {
    interval: 15000
    running: root.visible
    repeat: true
    triggeredOnStart: true
    onTriggered: ipProc.running = true
  }

  readonly property bool wifiOn: (typeof Networking !== "undefined" && Networking) ? Networking.wifiEnabled : false
  readonly property var wifiNets: (wifiDev && wifiDev.networks) ? wifiDev.networks.values : []
  readonly property var wifiActive: wifiNets.find(function(n) { return n && n.connected }) || null
  readonly property string wifiSsid: wifiActive ? (wifiActive.name || "") : (wifiOn ? "Not connected" : "Off")

  readonly property var wifiNetsSorted: {
    var arr = wifiNets.slice()
    
    arr.sort(function(a, b) {

      function rank(n) {
        if (!n) return 99;

        switch (n.state) {
        case ConnectionState.Connected:
          return 0;

        case ConnectionState.Connecting:
          return 1;

        case ConnectionState.Disconnecting:
          return 2;

        case ConnectionState.Disconnected:
          return n.known ? 3: 4;

        default:
          return 5;
        }
      }

      const r = rank(a) - rank(b)
      if (r !== 0) return r

      return (b.signalStrength || 0) - (a.signalStrength || 0)
    })

    return arr
  }

  function signalPercent(network) {
    if (!network) return 0;
    let s = network.signalStrength
    if (s <= 1) s *= 100
    return Math.round(s)
  }

  function metaFor(net) {
    if (!net) return "";

    switch (net.state) {
    case ConnectionState.Connected:
      return "Connected";
    case ConnectionState.Connecting:
      return "Connecting...";
    case ConnectionState.Disconnecting:
      return "Disconnecting...";
    case ConnectionState.Disconnected:
      return net.known ? "Disconnected" : "";
    default:
      return net.known ? "Known network" : "";
    }
  }

  // Autoscroll on vim keys
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
    onTriggered: if (Networking) wifiDev.scannerEnabled = false
  }

  IpcHandler {
    target: "wifi"
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
        focusedIndex = Math.min(focusedIndex + 1, root.wifiNetsSorted?.length - 1)
        break
      case Qt.Key_K:
        focusedIndex = Math.max(focusedIndex - 1, 0)
        break

      // (Dis)connect with `enter` or `space`
      case Qt.Key_Return:
      case Qt.Key_Space:
        const net = root.wifiNetsSorted[focusedIndex]
        if (!net) return;
        if (net.connected && typeof net.disconnect === "function") net.disconnect()
        else if (typeof net.connect === "function") {
          passwordNetwork = net
          awaitingPassword = true
          net.connect()
        }
        break

      // Forget device with `D`
      case Qt.Key_D:
        const network = root.wifiNetsSorted[focusedIndex]
        if (!network) return;
        network.forget()
        break

      // Search with `S`
      case Qt.Key_S:
        if (!Networking.wifiEnabled) return;
        wifiDev.scannerEnabled = !wifiDev.scannerEnabled;
        if (wifiDev.scannerEnabled)
          scanTimer.restart()
        else
          scanTimer.stop()
        break

      // Toggle bluetooth with `T`
      case Qt.Key_T:
        if (typeof Networking !== "undefined" && Networking) Networking.wifiEnabled = !Networking.wifiEnabled
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

      // Wifi enabled button
      RowLayout {
        Rectangle {
          color: Networking.wifiEnabled ? "#36393f" : "#1f222b"
          radius: 12
          height: 40
          width: 40

          Behavior on color {
            ColorAnimation { duration: 150 }
          }

          Text {
            anchors.centerIn: parent
            text: Networking.wifiEnabled ? "󰖩" : "󰖪"
            color: Config.colFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize + 6
          }
    
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (typeof Networking !== "undefined" && Networking) Networking.wifiEnabled = !Networking.wifiEnabled
            }
          }
        }

        Text {
          text :"Wifi"
          color: Config.colFg
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize + 2
          leftPadding: 10
        }
      }
      // Keep padding under button when bluetooth desactivated
      Item {
        visible: !Networking.wifiEnabled
        height: 0
      }

      // Scan button
      Rectangle {
        visible: Networking.wifiEnabled
        id: scanBtn
        property bool scanning: Networking ? wifiDev.scannerEnabled : false
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
            text: scanBtn.scanning ? "Scanning..." : "Scan for networks"
            color: Config.colFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
          }
        }
  
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (!Networking.wifiEnabled) return;
            wifiDev.scannerEnabled = !wifiDev.scannerEnabled;
            if (wifiDev.scannerEnabled)
              scanTimer.restart()
            else
              scanTimer.stop()
          }
        }
      }

      // No devices placeholder
      Rectangle {
        visible: root.wired && !root.wifiDev
        radius: 10
        color: "#36393f"
        
        Text {
          anchors.centerIn: parent
          text: "No devices found"
        }
      }

      // Devices list
      Rectangle {
        visible: !root.wired && root.wifiDev
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
              model: root.wifiNetsSorted

              Rectangle {
                required property var modelData
                required property int index
                readonly property bool isTop: index === 0
                readonly property bool isBottom: index === root.wifiNetsSorted.length - 1
                readonly property bool active: modelData && modelData.connected
                implicitHeight: 100
                width: rows.width
                topLeftRadius: isTop ? 10 : 0
                topRightRadius: isTop ? 10 : 0
                bottomLeftRadius: isBottom ? 10 : 0
                bottomRightRadius: isBottom ? 10 : 0
                color: index === focusedIndex ? "#36393f" : "#1f222b"

                // Wait for connection error to show password input
                Connections {
                  target: modelData

                  function onConnectionFailed(reason) {
                    if (!awaitingPassword) return

                    if (reason === ConnectionFailReason.NoSecrets) {
                      passwordNetwork = modelData
                      showPasswordInput = true
                    }

                    awaitingPassword = false
                  }
                }

                // Connect on click
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (!modelData) return;
                    if (active) { if (typeof modelData.disconnect === "function") modelData.disconnect() }
                    else if (typeof modelData.connect === "function") {
                      passwordNetwork = modelData
                      awaitingPassword = true
                      modelData.connect()
                    }
                  }
                }

                ColumnLayout {
                  anchors.fill: parent

                  RowLayout {
                    id: content
                    spacing: 12
                    
                    Text {
                      leftPadding: 10
                      text: "󰖩"
                      color: active ? Config.colFocused : Config.colFg
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
                        text: (modelData && modelData.name) ? modelData.name : "Hidden"
                        elide: Text.ElideRight
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

                    // Push the signal strength to the right
                    Item {
                      Layout.fillWidth: true
                    }

                    // Signal strength
                    Item {
                      Layout.preferredWidth: 50
                      Layout.preferredHeight: 50

                      Text {
                        anchors.centerIn: parent
                        text: signalPercent(modelData) + "%"
                        color: Config.colFg
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize - 2
                      }
                    }
                  }

                  // Password input
                  RowLayout {
                    id: pwdInput
                    visible: showPasswordInput && modelData === passwordNetwork
                    Layout.fillWidth: true
                    Layout.leftMargin: 5
                    Layout.bottomMargin: 5
                    spacing: 8

                    // Password input
                    TextField {
                      id: input
                      Layout.fillWidth: true
                      placeholderText: "Password"
                      placeholderTextColor: Config.colFg
                      color: "white"
                      background: textBg
                      focus: pwdInput.visible

                      Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                          focusItem.forceActiveFocus()
                          showPasswordInput = false
                          event.accepted = true
                        }
                        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                          if (!passwordNetwork) return

                          passwordNetwork.connectWithPsk(input.text)

                          showPasswordInput = false
                          awaitingPassword = false

                          input.text = ""
                          focusItem.forceActiveFocus()
                        }
                      }
                    }
                    Item {
                      id: textBg
                      Layout.fillWidth: true
                    }

                    // Connect button
                    Rectangle {
                      color: "#1f222b"
                      Layout.preferredWidth: 90
                      Layout.preferredHeight: 36
                      Layout.bottomMargin: 5
                      Layout.rightMargin: 10
                      radius: 6

                      Text {
                        id: passwordField
                        anchors.centerIn: parent
                        text: "Connect"
                        color: Config.colFg
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                      }
                
                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                          if (!passwordNetwork) return

                          passwordNetwork.connectWithPsk(input.text)

                          showPasswordInput = false
                          awaitingPassword = false

                          input.text = ""
                          focusItem.forceActiveFocus()
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
  }
}
