-- @!os:linux
-- @!user:dracowizard
-- @!host:dragonfury
-- @!install:644:$HOME/.config/hypr/local.lua

local monitors = {
	["DP-1"] = "0x0", ["DP-2"] = "2880x0", ["DP-3"] = "5760x0",
	["DP-5"] = "0x0", ["DP-6"] = "2880x0", ["DP-7"] = "5760x0",
}

for out, pos in pairs(monitors) do
	hl.monitor({
		output = out,
		position = pos,
		mode = "preferred",
		scale = 1.3333,
		vrr = 1
	})
end

-- HDR alternative (commented out):
-- hl.monitor({ output = "",     mode = "preferred", position = "auto",  scale = 1.3333, vrr = 1, bitdepth = 10, cm = "auto" })
-- hl.monitor({ output = "DP-1", mode = "preferred", position = "0x0",   scale = 1.3333, vrr = 1, bitdepth = 10, cm = "hdr", sdrbrightness = 1.5, sdrsaturation = 1.0 })
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "2880x0", scale = 1.3333, vrr = 1, bitdepth = 10, cm = "hdr", sdrbrightness = 1.5, sdrsaturation = 1.0 })
-- hl.monitor({ output = "DP-3", mode = "preferred", position = "5760x0", scale = 1.3333, vrr = 1, bitdepth = 10, cm = "hdr", sdrbrightness = 1.5, sdrsaturation = 1.0 })

-- hl.monitor({ output = "DP-3", mode = "preferred", position = "6398x0", scale = 1.3333, bitdepth = 10, vrr = 1, mirror = "DP-2" })
-- hl.monitor({ output = "DP-1", reserved_area = { top = 0, right = 0, bottom = 24, left = 0 } })

hl.config({ misc = { vrr = 1 } })

hl.env("AQ_DRM_DEVICES", "/dev/dri/card-rx6600")
hl.env("DRI_PRIME", "1002:73ff!")
hl.env("QT_SCALE_FACTOR", "1.4")
hl.env("GDK_SCALE", "2")

-- software synths
hl.env("DPF_SCALE_FACTOR", "1.4")
hl.env("JUCE_SCALE_FACTOR", "1.4")
