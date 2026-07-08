pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  property bool freeze: false
  property bool screen_recording: false
  property list<string> outputs: []
  property int output_to_record: 0

  // TODO: use now()
  readonly property list<string> hyprshot_args: ["hyprshot", "--output-folder", Quickshell.env("HOME") + "/Pictures/Screenshots", freeze ? "--freeze" : ""]
  readonly property string screen_recording_path: Quickshell.env("HOME") + "/Pictures/Recordings/"

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
    case "screen_record_fullscreen":
      screen_record_fullscreen.running = true
      break
    case "stop_screen_recording":
      stop_screen_recording.running = true
      break
    }
  }

  function now() {
    return Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
  }

  // Screen recording
  Process {
    id: create_recording_directory
    command: ["mkdir", "-p", screen_recording_path]
    running: true
  }

  Process {
    id: screen_record_fullscreen
    command: ["wf-recorder", "--output", outputs[output_to_record], "-f", screen_recording_path + now() + ".mkv"]
    onStarted: screen_recording = true
    onExited: screen_recording = false
  }

  Process {
    id: stop_screen_recording
    command: ["pkill", "-x", "wf-recorder"]
  }

  Process {
    id: list_outputs
    command: ["wf-recorder", "--list-output"]
    stdout: StdioCollector {
      onStreamFinished: outputs = text.trim().split("\n").map(line => line.split(" ")[2])
    }
    running: true
  }

  // Screenshots
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
