// @ !os:linux
// @ !user:dracowizard
// @ !install:644:$HOME/.config/quickshell/shell.qml
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
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
				visible: notifOnScreen.count > 0
				anchor.window: parent
				anchor.edges: Edges.Bottom | Edges.right
				anchor.gravity: Edges.Bottom | Edges.right
				screen: parent.screen

				ListView {
					model: notifOnScreen
					delegate: notifOnScreenDelegate
				}
			}
		}
	}

	Component {
		id: notifOnScreenDelegate
		required property string appName
		required property string body
		required property string image
		required property string appIcon
		imageSource: image != "" ? image : appIcon

		Rectangle {
			width: 250

			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter

				spacing: 5

				IconImage {
					visible: imageSource != ""
					source: imageSource
					height: 65
					width: 65
				}

				Column {
					width: 170
					spacing: 5

					Text {
						width: 160

						anchors.horizontalCenter: parent.horizontalCenter

						text: appName

						font.pixelSize: 20
						horizontalAlignment: Text.AlignHCenter
						elide: Text.ElideRight
					}

					Text {
						width: 160

						anchors.horizontalCenter: parent.horizontalCenter

						text: body

						font.pixelSize: 16
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

	/*
	component NotifModel : QtObject {
		property bool visible
		property alias expireTimeout: notif.expireTimeout
		property alias summary: notif.summary
		property alias tracked: notif.tracked
		property alias desktopEntry: notif.desktopEntry
		property alias hasInlineReply: notif.hasInlineReply
		property alias hints: notif.hints
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		property alias notifId: notif.id
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		property alias X: notif.X
		default property Notification notif
	}
	*/

	ObjectModel {
		id: notifOnScreen
	}
	ObjectModel {
		id: allNotif
	}

	function handleNotifClosed(closed) {
		notifOnScreen.remove(notifOnScreen.indexOf(notification), 1);
		allNotif.remove(allNotif.indexOf(notification), 1);
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

			allNotif.append(notification);
			if (!notification.lastGeneration) {
				notifOnScreen.append(notification);
			}

			let timeout = 0
			if (notification.expireTimeout == -1) {
				if (notification.urgency == NotificationUrgency.Normal) {
					timeout = 30
				} else if (notification.urgency == NotificationUrgency.Low) {
					timeout = 5
				}
			}
			if (timeout > 0) {
				after(timeout * 1000, () => {
					notifOnScreen.remove(notifOnScreen.indexOf(notification), 1);
				});
			}
		}
	}
}
