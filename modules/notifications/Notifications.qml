import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQml
import QtQml.Models

pragma Singleton

Singleton {
  property bool centerOpen: false
  property bool doNotDisturb: false

  property double now: Date.now()
  ListModel { id: history }

  readonly property alias history: history
  readonly property alias popups: server.trackedNotifications

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

  IpcHandler {
    target: "notifications"

    function toggle(): void {
      Notifications.toggleCenter()
    }

    function toggleDnd(): void {
      Notifications.toggleDnd()
    }
  }

  function clear() {
    history.clear()
  }

  function remove(index) {
    history.remove(index)
  }

  function toggleCenter() {
    centerOpen = !centerOpen
  }

  function toggleDnd() {
    doNotDisturb = !doNotDisturb
  }
}
