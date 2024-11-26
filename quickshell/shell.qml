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

			PopupWindow {
				visible: notifShowing.length > 0
				anchor.window: parent
				anchor.edges: Edges.Bottom | Edges.right
				anchor.gravity: Edges.Bottom | Edges.right
				screen: parent.screen

				ListView {
					model: notifShowing
					delegate: Rectangle {
						width: 250
					}
				}
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

	function Timer() {
		return Qt.createQmlObject("import QtQuick; Timer {}", root);
	}

	function after(delay, do) {
		timer = new Timer();
		timer.interval = delay;
		timer.repeat = false;
		timer.triggered.connect(cb);
		timer.triggered.connect(function release() {
			timer.triggered.disconnect(cb);
			timer.triggered.disconnect(release);
		})
	}

	property var notifHist: []
	property var notifShowing: []

	function handleNotifClosed(closed) {
		notifHist = notifHist.filter(notif => notif.id != closed.id);
		notifShowing = notifShowing.filter(notif => notif.id != closed.id);
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

			notification.closed.connect(handleNotifClosed);
			if (notification.lastGeneration) {
				notifHist.push(notification)
			} else {
				notifShowing.push(notification)
			}

			let timeout = notification.expireTimeout
			if (timeout = -1) {
				if (notification.urgency == NotificationUrgency.Critical) {
					timeout = 0
				} else if (notification.urgency == NotificationUrgency.Normal) {
					timeout = 30
				} else if (notification.urgency == NotificationUrgency.Low) {
					timeout = 5
				}
			}
			if (timeout > 0) {
				after(timeout * 1000, () => {
					notification.expire();
				});
			}
		}
	}
}
