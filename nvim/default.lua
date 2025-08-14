-- @!os:unix
-- @!install:644:$HOME/.config/nvim/colors/default.lua

local Highlite = require 'highlite' -- @type Highlite
local Groups = require 'highlite.groups' -- @type highlite.Groups
local Palette = require 'highlite.color.palette' -- @type highlite.color.Palette

-- colors adjust
-- rotate in degrees, wrapping
-- 0 <= shift + scale <= 1
-- 0 <= sat <= 1
-- 0 <= contrast <= 1
local rotate = 0
local lvl_shift = 0.00
local lvl_scale = 0.50
local sat = 0.8
local contrast = 0.75

-- Lua doesn't have math.round for some reason...
local function round(num)
	local i, f = math.modf(num)
	if f >= 0.5 then
		if i < 0 then
			i = i - 1
		else
			i = i + 1
		end
	end
	return i
	--return num + (2^52 + 2^51) - (2^52 + 2^51)
end

local function clamp(num, min, max)
	return math.max(min, math.min(max, num))
end

-- (degrees, 0.0-1.0, 0.0-1.0)
local function hsl_to_rgb(hue, sat, level)
	local s = clamp(sat, 0, 1)
	local l = clamp(level, 0, 1)
	local a = sat * math.min(level, 1 - level)
	local function f(n)
		local k = (n + hue / 30) % 12;
		local color = level - a * math.max(math.min(k - 3, 9 - k, 1), -1)
		return round(255 * math.max(0, math.min(1, color)))
	end
	return {f(0), f(8), f(4)}
end

local bg = vim.api.nvim_get_option('background')

local function calculate_color(color)
	local h = color[1]
	local s = color[2] * sat --  - 1 + sat
	local l = color[3] * lvl_scale + lvl_shift

	-- calculate contrast level shift
	--l = l*contrast + 4.5 * (1 - contrast) * (l - 0.5)^3

	-- flip level for light mode
	if bg ~= "dark" then
		l = (clamp(l, 0, 1) * -1) + 1
	end

	local rgb = hsl_to_rgb(h, s, l)
	return string.format('#%02x%02x%02x', rgb[1], rgb[2], rgb[3])
	-- return {
	-- 	string.format('#%02x%02x%02x', rgb[1], rgb[2], rgb[3]),
	-- 	rgb_to_x256(rgb), name,
	-- }
end

local Red         = calculate_color({355, 0.9, 1.00})
local DarkRed     = calculate_color({355, 0.9, 0.75})
local Blue        = calculate_color({220, 0.9, 1.00})
local DarkBlue    = calculate_color({220, 0.9, 0.75})
local Green       = calculate_color({105, 0.9, 1.00})
local DarkGreen   = calculate_color({105, 0.9, 0.75})
local Orange      = calculate_color({ 29, 0.9, 1.00})
local DarkOrange  = calculate_color({ 29, 0.9, 0.75})
local Yellow      = calculate_color({ 39, 0.9, 1.00})
local DarkYellow  = calculate_color({ 39, 0.9, 0.75})
local Violet      = calculate_color({270, 0.9, 0.75})
local Purple      = calculate_color({286, 0.9, 1.00})
local Magenta     = calculate_color({295, 0.9, 1.00})
local DarkMagenta = calculate_color({295, 0.9, 0.75})
local Black       = calculate_color({  0, 0.0, 0.75})
local DarkGrey    = calculate_color({  0, 0.0, 0.50})
local Grey        = calculate_color({  0, 0.0, 0.75})
local White       = calculate_color({  0, 0.0, 1.00})
local Cyan        = calculate_color({187, 0.9, 1.00})
local DarkCyan    = calculate_color({187, 0.9, 0.75})
local Aqua        = calculate_color({105, 0.9, 1.00})

--[[
constructor and func are currently the same. This is because go doesn't really have
constructors, but something is insisting it does.
--]]

--TODO: manpage headers and vim help headers are hard to read

local colors = {
	red = 5,
	yellow = 39,
	blue = 207,
	green = 105,
}

local mono = 220
-- hsl, level 1 is fg, level 0 is bg
local palette = Palette.derive(bg, {
	bg          = calculate_color({mono, 0.00, 0.00}),
	text        = calculate_color({mono, 0.20, 1.00}),
	error       = calculate_color({   5, 0.90, 1.00}),
	warning     = calculate_color({  39, 0.90, 1.00}),
	hint        = calculate_color({ 207, 1.00, 1.00}),
	ok          = calculate_color({ 105, 0.80, 1.00}),
	select      = calculate_color({   0, 0.00, 0.40}),

	bg_contrast_low       = calculate_color({220, 0.1, 0.25}),
	bg_contrast_high      = calculate_color({220, 0.1, 0.50}),
	text_contrast_bg_low  = calculate_color({220, 0.1, 0.75}),
	text_contrast_bg_high = calculate_color({220, 0.1, 1.00}),

	comment     = calculate_color({mono, 0.40, 0.75}),
	exception   = calculate_color({   5, 0.90, 0.90}),
	constant    = calculate_color({ 105, 0.80, 0.80}),
	constructor = calculate_color({ 207, 1.00, 0.90}),
	include     = calculate_color({ 207, 1.00, 0.80}),
	statement   = calculate_color({ 286, 0.90, 0.90}),
	storage     = calculate_color({ 355, 0.90, 0.90}),
	uri         = calculate_color({ 220, 1.00, 0.90}),
	keyword     = calculate_color({ 355, 0.90, 0.90}),
	func        = calculate_color({ 207, 1.00, 0.90}),
	variable    = calculate_color({ 187, 0.80, 0.90}),
	type        = calculate_color({  16, 0.50, 0.80}),
	operator    = calculate_color({ 105, 0.80, 0.80}),
	property    = calculate_color({ 246, 0.40, 1.00}),
})


local terminal_palette = {
	Black, DarkRed, DarkGreen, DarkYellow, DarkBlue, DarkMagenta, DarkCyan, 
	Grey, DarkGrey, Red, Green, Yellow, Blue, Magenta, Cyan, White,
}

local groups = Highlite.groups('default', palette)
function groups:override(name, hl)
	if self[name] == nil then
		self[name] = {}
	end
	while type(self[name]) == 'string' or self[name].link ~= nil do
		if type(self[name]) == 'string' then
			self[name] = self[self[name]]
		else
			self[name] = self[self[name].link]
		end
		if self[name] == nil then
			self[name] = {}
		end
	end
	self[name] = Groups.extend(hl, self[name])
end
function groups:generate(name, terminal_palette)
	self.override = nil
	self.generate = nil
	Highlite.generate(name, self, terminal_palette)
end

groups.ColorColumn   = {bg = calculate_color({0, 0.0, 0.07})}
groups.PMenuSel      = {bg = calculate_color({0, 0.0, 0.07})}
groups["@exception"] = {fg = palette.exception}

groups["@operator"] = Groups.extend({italic = true, bold = false}, groups '@operator')

groups.Error = {bg = calculate_color({colors.red, 0.9, 0.2})}
groups.ExtraWhitespace = 'Error'
groups.NvimInternalError = {bg = palette.error, fg = palette.bg, bold = true}
--groups.ErrorMsg = {fg = palette.exception}

--groups["@text.title.1"] = {fg = palette.exception}

groups.DiagnosticOk    = {fg = calculate_color({colors.green,  0.8, 0.7})}
groups.DiagnosticHint  = {fg = calculate_color({colors.blue,   0.9, 1.0})}
groups.DiagnosticInfo  = {fg = calculate_color({colors.blue,   0.9, 1.0})}
groups.DiagnosticWarn  = {fg = calculate_color({colors.yellow, 0.9, 1.0})}
groups.DiagnosticError = {fg = calculate_color({colors.red,    0.9, 0.9})}

groups:override('DiagnosticUnderlineOk',    {sp = calculate_color({colors.green,  0.8, 0.5})})
groups:override('DiagnosticUnderlineHint',  {sp = calculate_color({colors.blue,   0.9, 0.7})})
groups:override('DiagnosticUnderlineInfo',  {sp = calculate_color({colors.blue,   0.9, 0.7})})
groups:override('DiagnosticUnderlineWarn',  {sp = calculate_color({colors.yellow, 0.9, 0.7})})
groups:override('DiagnosticUnderlineError', {sp = calculate_color({colors.red,    0.9, 0.6})})

groups.DiffAdd    = {bg = calculate_color({colors.green,  0.7, 0.1})}
groups.DiffChange = {bg = calculate_color({colors.yellow, 0.7, 0.1})}
groups.DiffText   = {bg = calculate_color({colors.yellow, 0.7, 0.2})}
groups.DiffDelete = {bg = calculate_color({colors.red,    0.7, 0.1})}

groups.IncSearch = {bg = calculate_color({30, 0.7, 0.3})}
groups.Search = {bg = calculate_color({30, 0.1, 0.3})}

groups.Folded = {
	fg = palette.comment,
	bg = calculate_color({colors.blue, 0.7, 0.1})
}

groups:generate('dracowizard', terminal_palette)
