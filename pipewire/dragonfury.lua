-- @!host:dragonfury
-- @!os:linux
-- @!install:644:$HOME/.config/wireplumber/main.lua.d/80-local.lua

table.insert(alsa_monitor.rules, {
	matches = {{{"device.name", "equals", "alsa_output.pci-0000_2d_00.4"}}},
	apply_properties = {
		["device.nick"] = "System",
		["device.description"] = "System",
		["device.intended-roles"] = {"Music", "Movie", "Game", "Production"},
	},
})
table.insert(alsa_monitor.rules, {
	matches = {{{"node.name", "equals", "alsa_output.pci-0000_2d_00.4.analog-stereo"}}},
	apply_properties = {
		["node.nick"] = "Headphones",
		["node.description"] = "Headphones",
	},
})

table.insert(alsa_monitor.rules, {
	matches = {{{"device.name", "equals", "alsa_output.pci-0000_2b_00.1"}}},
	apply_properties = {
		["device.nick"] = "Graphics Card",
		["device.description"] = "Graphics Card",
		["device.intended-roles"] = {"Notification"},
	},
})
table.insert(alsa_monitor.rules, {
	matches = {{{"node.name", "equals", "alsa_output.pci-0000_2b_00.1.hdmi-stereo"}}},
	apply_properties = {
		["node.nick"] = "DisplayPort",
		["node.description"] = "DisplayPort",
	},
})

table.insert(alsa_monitor.rules, {
	matches = {{{"device.name", "equals", "alsa_output.usb-GN_Audio_A_S_Jabra_Engage_75_03334881200F-00"}}},
	apply_properties = {
		["device.nick"] = "Jabra",
		["device.description"] = "Jabra",
		["device.intended-roles"] = {"Communication"},
	},
})
table.insert(alsa_monitor.rules, {
	matches = {{{"node.name", "equals", "alsa_output.usb-GN_Audio_A_S_Jabra_Engage_75_03334881200F-00.iec958-stereo"}}},
	apply_properties = {
		["node.nick"] = "Headset",
		["node.description"] = "Headset",
	},
})
table.insert(alsa_monitor.rules, {
	matches = {{{"node.name", "equals", "alsa_input.usb-GN_Audio_A_S_Jabra_Engage_75_03334881200F-00.mono-fallback"}}},
	apply_properties = {
		["node.nick"] = "Headset",
		["node.description"] = "Headset",
	},
})


