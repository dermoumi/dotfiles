import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ShellRoot {
  // 1. Define the Window (The Bar)
  PanelWindow {
    screen: Quickshell.screens[1]

    anchors {
      top: true
      left: true
      right: true
    }
    height: 30
    color: "#1a1b26" // Tokyo Night background color

    // Container for right side items
    Row {
      anchors {
        right: parent.right
        rightMargin: 15
        verticalCenter: parent.verticalCenter
      }
      spacing: 12

      // // System tray
      // Row {
      //   id: tray
      //   spacing: 8
      //   verticalCenter: parent.verticalCenter
      //
      //   Repeater: {
      //     model: SystemTray.items
      //
      //     delegate: Icon {
      //       required property var modelData
      //
      //       source: modelData.icon
      //       width: 20
      //       height: 20
      //
      //       TapHandler {
      //         onTapped: modelData.activate()
      //       }
      //     }
      //   }
      // }


      // Clock
      Text {
        id: clockText
        anchors {
          right: parent.right
          rightMargin: 10
          verticalCenter: parent.verticalCenter
        }
        color: "white"
        font.pixelSize: 16
        font.family: "JetBrains Mono" // Or your preferred font
        text: "Loading..."

        Timer {
          interval: 1000 // Update every 1 second
          running: true
          repeat: true
          triggeredOnStart: true
          onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "hh:mm")
          }
        }
      }
    }
  }
}
