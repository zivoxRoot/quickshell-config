pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io

import "../../config"

Singleton {
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
  Component.onCompleted: {
    ipProc.running = true
  }
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
      return net.known ? "Disconnected" : "Unknown";
    default:
      return net.known ? "Known network" : "Unknown";
    }
  }

  Timer {
    id: scanTimer
    interval: 25000
    repeat: false
    onTriggered: if (Networking) wifiDev.scannerEnabled = false
  }
}
