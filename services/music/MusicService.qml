pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
  property int index: 0
  readonly property list<MprisPlayer> players: Mpris.players.values
  property MprisPlayer active: players[index] ?? null
  property real songPercentage: 0.0

  // Timer to track song position
  Timer {
    running: active && active.playbackState === MprisPlaybackState.Playing
    interval: 1000
    repeat: true
    onTriggered: {
      active.positionChanged()
      if (active.length > 0) {
        songPercentage = (active.position / active.length) * 100
      } else {
        songPercentage = 0
      }
    }
  }

  function nextPlayer() {
    if (index == players.length - 1) {
      index = 0
    } else {
      index += 1
    }
  }

  function getPlayerIcon() {
    const p = active.identity.trim().toLowerCase()
    if (p.includes("zen")) return ""
    else return ""
  }
}
