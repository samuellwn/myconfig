// @!os:linux
// @!user:dracowizard
// @!install:644:$HOME/.config/quickshell/shell.qml
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick

ShellRoot {
	id: root

	// dark mode palette
	readonly property color colPanel: Qt.rgba(0, 0, 0, 0.25)
	readonly property color colPopupBg: "#1b1b22"
	readonly property color colCard: "#26262e"
	readonly property color colCardHover: "#2e2e38"
	readonly property color colBorder: "#3a3a46"
	readonly property color colText: "#e7e7ee"
	readonly property color colSubtext: "#9d9daa"
	readonly property color colDim: "#7d7d8a"
	readonly property color colCritical: "#ff6b6b"
	readonly property color colAccent: "#8ab4ff"

	property string time

	// appearance timestamp per object (Notification on screen, history entry in drawer);
	// keyed by object so it survives ScriptModel value reassignments / delegate recreation
	property var shownAt: new Map()
	// live Notification -> history entry
	property var entryFor: new Map()

	function after(ms, cb) {
		const timer = Qt.createQmlObject("import QtQuick; Timer {}", root);
		timer.interval = ms;
		timer.repeat = false;
		timer.triggered.connect(() => {
			cb();
			timer.destroy();
		});
		timer.start();
	}

	function armImmunity(key) {
		shownAt.set(key, Date.now());
	}

	function clickAllowed(key) {
		const t = shownAt.get(key);
		return t !== undefined && Date.now() - t >= 100;
	}

	function armHistory() {
		const values = history.values;
		for (let i = 0; i < values.length; i++) armImmunity(values[i]);
	}

	function actionFor(notif) {
		const actions = notif.actions;
		for (let i = 0; i < actions.length; i++) {
			if (actions[i].identifier === "default") return actions[i];
		}
		return actions.length === 1 ? actions[0] : null;
	}

	// left click: perform the action if any and still active, expire if active,
	// and make the notification disappear completely
	function activateNotification(notif, entry) {
		if (notif) {
			const action = actionFor(notif);
			const resident = notif.resident;
			if (action) action.invoke(); // closes the notification automatically unless resident
			if (!action || resident) notif.expire();
		}
		removeEntry(entry);
	}

	// quickshell stores the raw spec value (milliseconds), despite its docs saying seconds
	function notifTimeoutMs(notif) {
		if (notif.urgency === NotificationUrgency.Critical) return 0;
		let ms = notif.expireTimeout;
		if (ms <= 0) ms = notif.urgency === NotificationUrgency.Low ? 4000 : 6000;
		return ms;
	}

	// right click: expire if active, and make the notification disappear completely
	function dismissNotification(notif, entry) {
		if (notif) notif.expire();
		removeEntry(entry);
	}

	function removeEntry(entry) {
		if (!entry) return;
		const values = history.values;
		const idx = values.indexOf(entry);
		if (idx !== -1) history.values = values.slice(0, idx).concat(values.slice(idx + 1));
		shownAt.delete(entry);
	}

	function iconSourceFor(notif) {
		if (notif.image !== "") return notif.image;
		const icon = notif.appIcon;
		if (icon === "") return "";
		if (icon.startsWith("file:")) return icon;
		if (icon.startsWith("/")) return "file://" + icon;
		return "image://icon/" + icon;
	}

	function addToScreen(notif) {
		const values = screenNotifs.values;
		const idx = values.indexOf(notif);
		if (idx !== -1) screenNotifs.values = values.slice(0, idx).concat(values.slice(idx + 1));
		screenNotifs.values = [notif].concat(screenNotifs.values);
		armImmunity(notif);
	}

	function removeFromScreen(notif) {
		const values = screenNotifs.values;
		const idx = values.indexOf(notif);
		if (idx !== -1) screenNotifs.values = values.slice(0, idx).concat(values.slice(idx + 1));
	}

	function makeEntry(notif) {
		return entryComponent.createObject(root, {
			notif,
			app: notif.appName,
			title: notif.summary !== "" ? notif.summary : notif.appName,
			body: notif.body,
			icon: iconSourceFor(notif),
			urgency: notif.urgency,
			time: Qt.formatDateTime(new Date(), "HH:mm:ss")
		});
	}

	function onNotifReceived(notif) {
		const known = entryFor.has(notif);
		// transient notifications are shown but never remembered;
		// ones carried over from a previous generation are neither shown nor remembered
		const remember = !(notif.transient && !notif.lastGeneration);

		if (!known) {
			notif.tracked = true;
			if (remember) {
				const entry = makeEntry(notif);
				entryFor.set(notif, entry);
				history.values = [entry].concat(history.values);
				armImmunity(entry);
			}
			notif.closed.connect(() => onNotifClosed(notif));
		} else {
			// re-emitted because the client replaced the notification
			const entry = entryFor.get(notif);
			entry.app = notif.appName;
			entry.title = notif.summary !== "" ? notif.summary : notif.appName;
			entry.body = notif.body;
			entry.icon = iconSourceFor(notif);
			entry.urgency = notif.urgency;
			entry.time = Qt.formatDateTime(new Date(), "HH:mm:ss");
		}

		if (!notif.lastGeneration) {
			addToScreen(notif);
			const timeout = notifTimeoutMs(notif);
			if (timeout > 0) {
				after(timeout, () => {
					if (screenNotifs.values.indexOf(notif) !== -1) notif.expire();
				});
			}
		}
	}

	function onNotifClosed(notif) {
		removeFromScreen(notif);
		const entry = entryFor.get(notif);
		if (entry) entry.notif = null;
		entryFor.delete(notif);
		shownAt.delete(notif);
	}

	function clearHistory() {
		const live = [];
		const values = history.values;
		for (let i = 0; i < values.length; i++) {
			if (values[i].notif !== null) live.push(values[i]);
			else shownAt.delete(values[i]);
		}
		history.values = live;
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: () => {
			let now = new Date();
			let str = Qt.formatDateTime(now, "(MMM) M/d/yy h:mm:ss A tttt");
			// You can't format a date in a specific timezone in qml.
			let pad = num => String(num).padStart(2, '0');
			str = `${str} (UTC ${now.getUTCHours()}:${pad(now.getUTCMinutes())})`;
			root.time = str;
		}
	}

	component HistoryEntry: QtObject {
		property var notif
		property string app
		property string title
		property string body
		property string icon
		property int urgency
		property string time
	}

	Component {
		id: entryComponent

		HistoryEntry {
		}
	}

	ScriptModel {
		id: screenNotifs
		values: []
	}

	ScriptModel {
		id: history
		values: []
	}

	component NotifCard: Rectangle {
		id: card

		property var notif // live Notification, null for closed history entries
		property var entry // history entry; null for transient popups
		property var immunityKey
		property string appName
		property string title
		property string body
		property string iconSource
		property int urgency
		property string timeLabel: ""
		property bool dimmed: false

		radius: 10
		color: cardMouse.containsMouse ? root.colCardHover : root.colCard
		border.width: 1
		border.color: card.urgency === NotificationUrgency.Critical ? root.colCritical : root.colBorder
		opacity: card.dimmed ? 0.55 : 1
		implicitHeight: cardRow.height + 20

		Rectangle {
			visible: card.urgency === NotificationUrgency.Critical
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.margins: 4
			width: 3
			radius: 1.5
			color: root.colCritical
		}

		MouseArea {
			id: cardMouse
			anchors.fill: parent
			hoverEnabled: true
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			onPressed: mouse => {
				if (!root.clickAllowed(card.immunityKey)) return;
				if (mouse.button === Qt.RightButton) root.dismissNotification(card.notif, card.entry);
				else root.activateNotification(card.notif, card.entry);
			}
		}

		Row {
			id: cardRow
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.margins: 10
			spacing: 10

			IconImage {
				id: icon
				visible: card.iconSource !== ""
				source: card.iconSource
				implicitSize: 44
				anchors.verticalCenter: parent.verticalCenter
			}

			Column {
				width: parent.width - (icon.visible ? 54 : 0)
				spacing: 3

				Item {
					width: parent.width
					height: titleText.implicitHeight

					Text {
						id: titleText
						width: parent.width - (timeText.visible ? timeText.width + 8 : 0)
						color: root.colText
						font.pixelSize: 13
						font.bold: true
						elide: Text.ElideRight
						text: card.title
					}

					Text {
						id: timeText
						visible: card.timeLabel !== ""
						anchors.right: parent.right
						color: root.colDim
						font.pixelSize: 11
						text: card.timeLabel
					}
				}

				Text {
					width: parent.width
					visible: card.appName !== ""
					color: root.colSubtext
					font.pixelSize: 11
					elide: Text.ElideRight
					text: card.appName
				}

				Text {
					width: parent.width
					visible: card.body !== ""
					color: root.colText
					font.pixelSize: 12
					textFormat: Text.PlainText
					wrapMode: Text.Wrap
					maximumLineCount: 4
					elide: Text.ElideRight
					text: card.body
				}
			}
		}
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: bar

			property var modelData
			screen: modelData
			property bool drawerOpen: false

			anchors {
				top: true
				left: true
				right: true
			}
			implicitHeight: 24
			color: root.colPanel

			Text {
				color: root.colSubtext
				font.pixelSize: 18
				anchors.right: parent.right
				anchors.rightMargin: 8
				anchors.verticalCenter: parent.verticalCenter
				text: root.time
			}

			Rectangle {
				id: bellButton

				anchors.left: parent.left
				anchors.leftMargin: 4
				anchors.verticalCenter: parent.verticalCenter
				width: 36
				height: 18
				radius: 9
				color: bellMouse.containsMouse || bar.drawerOpen ? root.colCardHover : "transparent"

				Rectangle {
					anchors.left: parent.left
					anchors.leftMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					width: 6
					height: 6
					radius: 3
					color: screenNotifs.values.length > 0 ? root.colAccent : root.colDim
				}

				Text {
					anchors.right: parent.right
					anchors.rightMargin: 7
					anchors.verticalCenter: parent.verticalCenter
					color: root.colSubtext
					font.pixelSize: 11
					text: history.values.length > 0 ? history.values.length : ""
				}

				MouseArea {
					id: bellMouse

					anchors.fill: parent
					hoverEnabled: true
					onClicked: bar.drawerOpen = !bar.drawerOpen
				}
			}

			PopupWindow {
				id: notifPopup

				anchor.window: bar
				anchor.rect.x: 8
				anchor.rect.y: bar.height + 8
				anchor.edges: Edges.Bottom | Edges.Left
				anchor.gravity: Edges.Bottom | Edges.Right

				implicitWidth: 360
				implicitHeight: Math.min(notifList.contentHeight + 16, bar.screen.height - 48)
				visible: screenNotifs.values.length > 0 && !bar.drawerOpen
				color: "transparent"
				grabFocus: false

				ListView {
					id: notifList

					anchors.fill: parent
					anchors.margins: 8
					spacing: 8
					clip: true
					model: screenNotifs

					delegate: NotifCard {
						width: notifList.width
						notif: modelData
						entry: root.entryFor.get(modelData)
						immunityKey: modelData
						appName: modelData.appName
						title: modelData.summary !== "" ? modelData.summary : modelData.appName
						body: modelData.body
						iconSource: root.iconSourceFor(modelData)
						urgency: modelData.urgency
					}
				}
			}

			PopupWindow {
				id: drawer

				anchor.window: bar
				anchor.rect.x: 8
				anchor.rect.y: bar.height + 8
				anchor.edges: Edges.Bottom | Edges.Left
				anchor.gravity: Edges.Bottom | Edges.Right

				implicitWidth: 400
				implicitHeight: Math.max(120, Math.min(headerRow.height + 24 + historyList.contentHeight, bar.screen.height - 48))
				visible: bar.drawerOpen
				color: root.colPopupBg
				grabFocus: false

				onVisibleChanged: if (visible) root.armHistory()

				Column {
					id: drawerColumn

					anchors.fill: parent
					anchors.margins: 8
					spacing: 8

					Row {
						id: headerRow

						width: parent.width
						spacing: 8

						Text {
							width: parent.width - clearButton.width - 8
							anchors.verticalCenter: parent.verticalCenter
							color: root.colSubtext
							font.pixelSize: 13
							font.bold: true
							text: "Notification history"
						}

						Rectangle {
							id: clearButton

							width: 52
							height: 20
							radius: 6
							color: clearMouse.containsMouse ? root.colCardHover : root.colCard
							border.width: 1
							border.color: root.colBorder

							Text {
								anchors.centerIn: parent
								color: root.colSubtext
								font.pixelSize: 11
								text: "Clear"
							}

							MouseArea {
								id: clearMouse

								anchors.fill: parent
								hoverEnabled: true
								onClicked: root.clearHistory()
							}
						}
					}

					ListView {
						id: historyList

						width: parent.width
						height: drawer.height - headerRow.height - 24
						spacing: 8
						clip: true
						model: history

						Text {
							anchors.centerIn: parent
							visible: history.values.length === 0
							color: root.colDim
							text: "No notifications"
						}

						delegate: NotifCard {
							width: historyList.width
							notif: modelData.notif
							entry: modelData
							immunityKey: modelData
							appName: modelData.app
							title: modelData.title
							body: modelData.body
							iconSource: modelData.icon
							urgency: modelData.urgency
							timeLabel: modelData.time
							dimmed: modelData.notif === null
						}
					}
				}
			}
		}
	}

	NotificationServer {
		id: server

		bodySupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		imageSupported: true
		actionsSupported: true
		actionIconsSupported: true
		persistenceSupported: true
		keepOnReload: true

		onNotification: notif => root.onNotifReceived(notif)
	}

}
