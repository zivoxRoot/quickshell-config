pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  property bool freeze: false
  readonly property list<string> hyprshot_args: ["hyprshot", "--output-folder", Quickshell.env("HOME") + "/Pictures/Screenshots", freeze ? "--freeze" : ""]

  function toggleFreeze() {
    freeze = !freeze
  }

  function launchCommand(command) {
    switch (command) {
    case "screenshot_fullscreen":
      screenshot_fullscreen.running = true
      break
    case "screenshot_window":
      screenshot_window.running = true
      break
    case "screenshot_region":
      screenshot_region.running = true
      break
    }
  }

  Process {
    id: screenshot_fullscreen
    running: false
    command: [...hyprshot_args, "--mode", "output"]
  }

  Process {
    id: screenshot_window
    running: false
    command: [...hyprshot_args, "--mode", "window"]
  }

  Process {
    id: screenshot_region
    running: false
    command: [...hyprshot_args, "--mode", "region"]
  }
}
