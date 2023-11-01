// @!os:linux
// @!user:dracowizard
// @!install:644:$HOME/.config/ags/config.js

import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

const barVertical = true;
const barAnchor = barVertical ? ['top', 'left', 'bottom'] : ['left', 'top', 'right'];

// MBox is a list of widgets laid out in the bar orientation
const MBox = (children) =>  Widget.Box({
	vertical: barVertical,
	children: children,
});

// CBox is a list of widgets laid out across the bar orientation
const CBox = (children) => Widget.Box({
	vertical: !barVertical,
	children: children,
});

const bar = Widget.Window({
	name: 'bar',
	anchor: ['top', 'left', 'bottom'],
	exclusive: true,
	focusable: true,
	monitor: 0,
	layer: 'top',
	child: MBox([
		Widget.Button({
			onPrimaryClick: 'wofi --show drun',
			child: Widget.Icon({
				icon: 'system-run',
				size: 18,
			}),
		}),
	]),
});

export default {
	// closeWindowDelay: {},
	notificationPopupTimeout: 5000,
	cacheNotificationActions: false,
	maxStreamVolume: 1,
	style: App.configDir + '/style.css',
	windows: [bar],
};
