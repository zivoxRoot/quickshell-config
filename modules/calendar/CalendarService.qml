pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	function getMonthCalendar(year, month) {
		const firstDay = new Date(year, month, 1);

		// Monday = 0, Sunday = 6
		const startDay = (firstDay.getDay() + 6) % 7;

		const daysInMonth = new Date(year, month + 1, 0).getDate();

		const weeks = [];
		let week = []

		// Empty cells before the first day
		for (let i = 0; i < startDay; i++)
			week.push(null);

		// Real days
		for (let day = 1; day <= daysInMonth; day++)
		{
			week.push(new Date(year, month, day));

			if (week.length === 7)
			{
				weeks.push(week);
				week = [];
			}
		}

		// Remaining cells
		while (week.length < 7)
			week.push(null);

		if (week.length > 0)
			weeks.push(week);

		return weeks;
	}

	property var months: [
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	]

	property date today: new Date()
	property date focusedDay: new Date()
	property var calendar: getMonthCalendar(focusedDay.getFullYear(), focusedDay.getMonth(), focusedDay.getDate())

	function parseKhalDates(str) {
		const parts = str.split(" ")
		const date = parts[0].split("/")

		const day = date[0]
		const month = date[1] - 1
		const year = date[2]

		if (parts.length === 1)
			return new Date(year, month, day)

		const time = parts[1].split(":")
		const hour = Number(time[0])
		const minutes = Number(time[1])
		return new Date(year, month, day, hour, minutes)
	}

	function getCleanHours(day) {
		const startHour = day.start.getHours()
		let startMinutes = day.start.getMinutes()
		if (startMinutes == '0')
			startMinutes += '0'
		const endHour = day.end.getHours()
		let endMinutes = day.end.getMinutes()
		if (endMinutes == '0')
			endMinutes += '0'
		return startHour + ":" + startMinutes + " - " + endHour + ":" + endMinutes
	}

	function getDateForKhal(day) {
		const res = day.getDate() + "/" + (day.getMonth() + 1) + "/" + day.getFullYear()
		return res
	}

	property var events: []
	property var jsonEvents: []

	Process {
		id: loadEvents
		running: true
		command: ["khal", "list", "--json", "start", "--json", "end", "--json", "title", "--json", "all-day", "1/" + (focusedDay.getMonth() + 1) + "/" + focusedDay.getFullYear(), "31d"]
		stdout: StdioCollector {
			onStreamFinished: {
				const text = this.text.trim()

				const matches = text.match(/\[[\s\S]*?\]/g) ?? []
				for (const json of matches) {
					const parsed = JSON.parse(json)

					for (const event of parsed) {
						jsonEvents.push(event)
					}
				}

				// Convert fields start and end to Date objects
				events = jsonEvents.map(event => ({
					start: parseKhalDates(event.start),
					end: parseKhalDates(event.end),
					title: event.title,
					allDay: event["all-day"] === "True"
				}))
			}
		}
	}

	function reloadEvents()
	{
		events = []
		jsonEvents = []
		loadEvents.running = true
	}

	// Sync events
	property alias syncEvents: syncEvents
	Process {
		id: syncEvents
		running: false
		command: ["vdirsyncer", "sync"]
		onExited: (exitCode, exitStatus) => {
			if (exitCode === 0)
				reloadEvents()
		}
	}

	// Create new event
	Process {
		id: newEventProcess
		onExited: (exitCode, exitStatus) => {
			if (exitCode === 0)
				syncEvents.running = true
		}
	}

	function newEvent(day, title) {
		newEventProcess.command = ["khal", "new", getDateForKhal(day), title]
		newEventProcess.running = true
	}

	// Delete event
	Process {
		id: deleteEventProcess
		onStarted: {
			write("D\ny\n")
		}
	}

	function deleteEvent(title) {
		deleteEventProcess.command = ["khal", "edit", title]
		deleteEventProcess.running = true
	}

	function sameDay(a, b)
	{
		return a.getFullYear() === b.getFullYear() &&
			a.getMonth() === b.getMonth() &&
			a.getDate() === b.getDate()
	}

	function hasEvents(day)
	{
		return events.some(event => sameDay(event.start, day))
	}

	function getFocusedDayTasks(day)
	{
		return events.filter(event => sameDay(event.start, day))
	}

	function focusToday()
	{
		focusedDay.setDate(today.getDate())
		focusedDay.setMonth(today.getMonth())
		focusedDay.setFullYear(today.getFullYear())
	}

	property var focusedDayTasks: getFocusedDayTasks(focusedDay)
}
