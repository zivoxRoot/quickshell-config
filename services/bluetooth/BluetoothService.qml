pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
  readonly property var adapter: typeof Bluetooth !== "undefined" && Bluetooth ? Bluetooth.defaultAdapter : null
  readonly property var devices: typeof Bluetooth !== "undefined" && Bluetooth && Bluetooth.devices ? Bluetooth.devices.values : []
  readonly property int connectedCount: {
    var n = 0;
    for (var i = 0; i < devices.length; i++) if (devices[i] && devices[i].connected) n++;
    return n
  }
  readonly property var sortedDevices: {
    var arr = devices.slice();
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

  Timer {
    id: scanTimer
    interval: 25000
    repeat: false
    onTriggered: if (adapter) adapter.discovering = false
  }
}
