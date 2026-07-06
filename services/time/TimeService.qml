pragma Singleton

import Quickshell

Singleton {
  id: root
  readonly property string time: clock.date

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
