import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../config"
import "./CalendarService.qml"

PanelWindow {
	id: root
	anchors.top: true
	implicitHeight: Math.min(600, topIndication.height + calendar.height + (isNewEventOpen ? 50 : tasks.height) + 10)
	implicitWidth: 400
	exclusionMode: ExclusionMode.Ignore
	visible: false
	color: "transparent"

	WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
	property bool areTasksFocused: true
	property bool isNewEventOpen: false
	property int focusedTaskIndex: 0
	property string newEventText: ""

	// Autoscroll tasks
	onFocusedTaskIndexChanged: {
		const item = taskRepeater.itemAt(focusedTaskIndex)

		if (!item) return

		const itemTop = item.y
		const itemBottom = item.y + item.height

		const viewTop = taskList.contentY
		const viewBottom = taskList.contentY + taskList.height

		if (itemTop < viewTop) {
			taskList.contentY = itemTop
		} else if (itemBottom > viewBottom) {
			taskList.contentY = itemBottom - taskList.height
		}
	}

	// IPC
	IpcHandler {
		target: "calendar"
		function toggle() {
			if (visible) {
				CalendarService.focusToday()
				areTasksFocused = true
				focusedTaskIndex = 0
			}
			visible = !visible
		}
	}

	// Keybinds handling
	Item {
		id: focusItem
		anchors.fill: parent
		focus: true

		Keys.onPressed: event => {
			switch (event.key)
			{
				//// GENERAL
				// Close menu with escape
				case Qt.Key_Escape:
					CalendarService.focusToday()
					areTasksFocused = true
					focusedTaskIndex = 0
					root.visible = false
					break
				// Toggle focus
				case Qt.Key_O:
				case Qt.Key_Tab:
					if (!areTasksFocused && CalendarService.focusedDayTasks.length === 0)
						break
					areTasksFocused = !areTasksFocused
					focusedTaskIndex = 0
					break
				// Synchronize events
				case Qt.Key_R:
					CalendarService.syncEvents.running = true
					focusedTaskIndex = 0
					break

				// CALENDAR
				// Move in calendar with vim keys
				case Qt.Key_H:
					if (!areTasksFocused)
						CalendarService.focusedDay.setDate(CalendarService.focusedDay.getDate() - 1)
					break
				case Qt.Key_L:
					if (!areTasksFocused)
						CalendarService.focusedDay.setDate(CalendarService.focusedDay.getDate() + 1)
					break
				case Qt.Key_K:
					if (!areTasksFocused)
						CalendarService.focusedDay.setDate(CalendarService.focusedDay.getDate() - 7)
					else
						focusedTaskIndex = Math.max(focusedTaskIndex - 1, 0)
					break
				case Qt.Key_J:
					if (!areTasksFocused)
						CalendarService.focusedDay.setDate(CalendarService.focusedDay.getDate() + 7)
					else
						focusedTaskIndex = Math.min(focusedTaskIndex + 1, CalendarService.getFocusedDayTasks(CalendarService.focusedDay).length - 1)
					break
				// Focus today
				case Qt.Key_T:
					if (!areTasksFocused)
						CalendarService.focusToday()
					break

				//// TASKS
				// Delete focused task
				case Qt.Key_D:
					if (!areTasksFocused)
						break
					CalendarService.deleteEvent(CalendarService.focusedDayTasks[focusedTaskIndex].title)  // TODO: (later) synchronize back and change locally for no-flicker
					CalendarService.syncEvents.running = true
					if (focusedTaskIndex == CalendarService.focusedDayTasks.length - 1)
						focusedTaskIndex--
					else if (focusedTaskIndex == 0)
						areTasksFocused = false
					break
				// Create new event
				case Qt.Key_N:
					isNewEventOpen = true
					break
			}
		}
	}

	Rectangle {
		anchors.fill: parent
		color: Config.md3.background
		bottomLeftRadius: 14
		bottomRightRadius: 14

		Column {
			anchors.right: parent.right
			anchors.rightMargin: 10
			width: 380

			Row {
				id: topIndication
				width: parent.width
				height: 30

				Rectangle {
					width: parent.width
					anchors.right: parent.right
					height: 30
					color: "transparent"

					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: CalendarService.months[CalendarService.focusedDay.getMonth()] + " " + CalendarService.focusedDay.getFullYear()
						color: Config.md3.on_background
						font.family: Config.fontFamily
						font.pixelSize: Config.fontSize + 4
						font.weight: 600
					}
				}

				Text {
					visible: CalendarService.syncEvents.running === true
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					color: Config.md3.on_background
					font.family: Config.fontFamily
					font.pixelSize: Config.fontSize
					text: "Syncing..."
				}
			}
		
			Rectangle {
				id: calendar
				width: 400
				height: 250
				color: Config.md3.background
				z: 10

				ColumnLayout {
					height: 250
					width: parent.width
					anchors.right: parent.right

					RowLayout {
						height: 2

						Repeater {
							model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

							Rectangle {
								required property string modelData
								color: "transparent"
								Layout.fillWidth: true
								Layout.fillHeight: true

								Text {
									text: modelData
									color: Config.md3.tertiary
									font.family: Config.fontFamily
									font.pixelSize: Config.fontSize
								}
							}
						}
					}

					// Weeks repeater
					ColumnLayout {

						Repeater {
							model: CalendarService.calendar

							Rectangle {
								required property var modelData
								color: "transparent"
								Layout.fillWidth: true
								Layout.fillHeight: true

								// Days repeater
								RowLayout {
									anchors.fill: parent

									Repeater {
										model: modelData

										Rectangle {
											required property date modelData
											height: 30
											width: 30
											color: CalendarService.sameDay(CalendarService.focusedDay, modelData) ? (areTasksFocused ? Config.md3.secondary : Config.md3.primary)
												: (CalendarService.sameDay(modelData, CalendarService.today) ? Config.md3.tertiary
												: "transparent")
											radius: height / 4

											Text {
												text: isNaN(modelData.getDate()) ? "-" : modelData.getDate()
												anchors.centerIn: parent
												color: CalendarService.sameDay(CalendarService.focusedDay, modelData) ? (areTasksFocused ? Config.md3.on_secondary : Config.md3.on_primary)
													: (CalendarService.sameDay(modelData, CalendarService.today) ? Config.md3.on_tertiary
													: Config.md3.on_background)
												font.family: Config.fontFamily
												font.pixelSize: Config.fontSize

												// Has events indicator
												Text {
													visible: CalendarService.hasEvents(modelData)
													text: "•"
													font.pixelSize: 20
													color: CalendarService.sameDay(CalendarService.focusedDay, modelData) ? Config.md3.on_primary
														: (CalendarService.sameDay(modelData, CalendarService.today) ? Config.md3.on_primary
														: Config.md3.primary)
													anchors.bottom: parent.bottom
													anchors.bottomMargin: -15
													anchors.horizontalCenter: parent.horizontalCenter
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}

			// Tasks list for the focused day
			Rectangle {
				visible: !isNewEventOpen
				id: tasks
				color: "transparent"
				implicitHeight: Math.min(rows.implicitHeight, 150)
				width: 380

				Flickable {
					id: taskList
					anchors.fill: parent
					contentHeight: rows.implicitHeight

					Column {
						id: rows

						Repeater {
							id: taskRepeater
							model: CalendarService.focusedDayTasks

							Rectangle {
								required property var modelData
								required property int index
								property bool isTop: index === 0
								property bool isBottom: index === CalendarService.getFocusedDayTasks(CalendarService.focusedDay).length - 1
								topLeftRadius: isTop ? 10 : 0
								topRightRadius: isTop ? 10 : 0
								bottomLeftRadius: isBottom ? 10 : 0
								bottomRightRadius: isBottom ? 10 : 0
								implicitHeight: 50
								width: 380
								color: index === focusedTaskIndex ? (areTasksFocused ? Config.md3.primary : Config.md3.secondary)
									: "transparent"

								Column {
									spacing: 3

									Text {
										text: modelData.title
										color: index === focusedTaskIndex ? (areTasksFocused ? Config.md3.on_primary : Config.md3.on_secondary)
											: Config.md3.on_background
										leftPadding: 5
										topPadding: 5
										font.weight: 600
										font.pixelSize: Config.fontSize + 2
									}
									Text {
										text: modelData.allDay ? "All day" : CalendarService.getCleanHours(modelData)
										color: index === focusedTaskIndex ? (areTasksFocused ? Config.md3.on_primary : Config.md3.on_secondary)
											: Config.md3.on_background
										leftPadding: 5
										font.pixelSize: Config.fontSize
									}
								}
							}
						}
					}
				}
			}

			// New event input
			Rectangle {
				id: newTaskInput
				visible: isNewEventOpen
				color: "transparent"
				implicitHeight: 50
				width: 380

				ColumnLayout {
					anchors.fill: parent

					Text {
						text: "New event"
						color: Config.md3.on_background
						font.family: Config.fontFamily
						font.pixelSize: Config.fontSize + 4
						font.weight: 600
						Layout.alignment: Qt.AlignHCenter
					}

					TextInput {
						focus: isNewEventOpen
						Layout.fillWidth: true
						color: Config.md3.on_background
						font.family: Config.fontFamily
						font.pixelSize: Config.fontSize

						Keys.onPressed: event => {
							if (event.key === Qt.Key_Escape && isNewEventOpen) {
								this.text = ""
								isNewEventOpen = false
								focusItem.forceActiveFocus()
							}

							if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
								if (!isNewEventOpen)
									return
								CalendarService.newEvent(CalendarService.focusedDay, newEventText)
								newEventText = ""
								this.text = ""
								isNewEventOpen = false
								focusItem.forceActiveFocus()
							}
						}
						onTextChanged: {
							newEventText = this.text
						}
					}
				}
			}
		}
	}
}
