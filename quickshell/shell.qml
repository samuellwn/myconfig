// @ !os:linux
// @ !user:dracowizard
// @ !install:644:$HOME/.config/quickshell/shell.qml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQml

ShellRoot {
	Variants {
		model: Quickshell.screens
		PanelWindow {
			color: Qt.rgba(0, 0, 0, 0.25)
			property var modelData
			screen: modelData
			anchors {
				top: true
				left: true
				right: true
			}
			height: 24

			Text {
				color: Qt.rgba(0.5, 0.5, 0.5, 1.0)
				font.pixelSize: parent.height - 6
				anchors.right: parent.right
				anchors.rightMargin: 4
				anchors.verticalCenter: parent.verticalCenter
				text: time
			}
		}
	}

	property string time

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: time = (new Date()).toLocaleString(Qt.locale())
	}

	property list<Notification> notifHist: []
	property list<Notification> notifShowingCrit: []
	property list<Notification> notifShowingNorm: []
	property list<Notification> notifShowingLow: []

	function handleNotifClosed(closed) {
		for (let notif of notifHist) {
			if (notif.id == notifHist.id) {
				// remove
			}
		}
	}

	function handleNotifHidden(notif) {
	}

	NotificationServer {
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		bodySupported: true
		persistenceSupported: true
		keepOnReload: true
		onNotification: notification => {
			if (!notification.transient || !notification.lastGeneration) {
				notification.tracked = true
			} else {
				notification.expire()
				return
			}
			if (!notification.transient) {
				notifHist.push(notification)
			}
			if (notification.lastGeneration) {
				return
			}
			if (notification.urgency == NotificationUrgency.Critical) {
				notifShowingCrit.push(notification)
			} else if (notification.urgency == NotificationUrgency.Normal {
				notifShowingNorm.push(notification)
			} else {
				notifShowingLow.push(notification)
			}
		}
	}
}
