pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  property bool freeze: false

  function toggleFreeze() {
    freeze = !freeze
  }

  function full() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenshot.sh"), "fullscreen", freeze ? "freeze" : ""])
  }

  function window() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenshot.sh"), "window", freeze ? "freeze" : ""])
  }

  function region() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenshot.sh"), "region", freeze ? "freeze" : ""])
  }
}
