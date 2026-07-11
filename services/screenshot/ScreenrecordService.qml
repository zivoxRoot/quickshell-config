pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  property bool screen_recording: false
  property list<string> outputs: []
  property int output_to_record: 0

  Process {
    id: list_outputs
    command: ["wf-recorder", "--list-output"]
    stdout: StdioCollector {
      onStreamFinished: outputs = text.trim().split("\n").map(line => line.split(" ")[2])
    }
    running: true
  }

  function full() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenrecord.sh"), "fullscreen", outputs[output_to_record]])
    screen_recording = true
  }

  function window() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenrecord.sh"), "window"])
    screen_recording = true
  }

  function region() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenrecord.sh"), "region"])
    screen_recording = true
  }

  function stop() {
    Quickshell.execDetached(["bash", Quickshell.shellPath("services/screenshot/screenrecord.sh"), "stop"])
    screen_recording = false
  }
}
