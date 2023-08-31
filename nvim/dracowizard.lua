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

local mono = 220
-- hsl, level 1 is fg, level 0 is bg
local palette = Palette.derive(bg, {
	bg          = calculate_color({mono, 0.00, 0.00}),
	text        = calculate_color({mono, 0.20, 1.00}),
	error       = calculate_color({   5, 0.90, 0.20}),
	warning     = calculate_color({  39, 0.90, 1.00}),
	hint        = calculate_color({ 207, 1.00, 1.00}),
	ok          = calculate_color({ 105, 0.80, 1.00}),

	bg_contrast_low = calculate_color({0, 0.0, 0.06}),

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
groups.ColorColumn   = {bg = calculate_color({0, 0.0, 0.07})}
groups.PMenuSel      = {bg = calculate_color({0, 0.0, 0.07})}
groups["@exception"] = {fg = calculate_color({5, 0.9, 0.90})}

groups["@operator"] = Groups.extend({italic = true, bold = false}, groups '@operator')

Highlite.generate('dracowizard', groups, terminal_palette)

-- hsl, level 1 is fg, level 0 is bg
local mono          = 220
local mono_1        = calculate_color({mono, 0.20,  1.00}, "mono_1")
local mono_2        = calculate_color({mono, 0.30,  0.90}, "mono_2") 
local mono_3        = calculate_color({mono, 0.30,  0.75}, "mono_3")
local mono_4        = calculate_color({mono, 0.30,  0.80}, "mono_4")
local hue_1         = calculate_color({ 187, 0.80,  1.00}, "hue_1")
local hue_2         = calculate_color({ 207, 1.00,  1.00}, "hue_2")
local hue_3         = calculate_color({ 286, 0.90,  1.00}, "hue_3")
local hue_4         = calculate_color({ 105, 0.80,  1.00}, "hue_4")
local hue_5         = calculate_color({ 355, 0.90,  1.00}, "hue_5")
local hue_5_2       = calculate_color({   5, 0.80,  1.00}, "hue_5_2")
local hue_6         = calculate_color({  29, 0.85,  1.00}, "hue_6")
local hue_6_2       = calculate_color({  39, 0.90,  1.00}, "hue_6_2")
local syntax_bg     = calculate_color({mono, 0.20,  0.00}, "syntax_bg")
local syntax_gutter = calculate_color({mono, 1.00,  0.10}, "syntax_gutter")
local syntax_cursor = calculate_color({mono, 0.90,  0.10}, "syntax_cursor") 
local syntax_accent = calculate_color({mono, 0.70,  0.90}, "syntax_accent")
local vertsplit     = calculate_color({mono, 1.00,  0.10}, "vertsplit")
local special_grey  = calculate_color({mono, 0.60,  0.00}, "special_grey")
local visual_grey   = calculate_color({mono, 0.60,  0.10}, "visual_grey")
local pmenu         = calculate_color({ 230, 0.60,  0.10}, "pmenu")
local term_black    = calculate_color({mono, 0.10,  0.00}, "term_black")
local term_blue     = calculate_color({ 220, 1.00,  0.20}, "term_blue")
local term_cyan     = calculate_color({ 190, 1.00,  0.20}, "term_cyan")
local term_white    = calculate_color({mono, 0.10,  1.00}, "term_white")
local term_gray     = calculate_color({mono, 0.10,  0.80}, "term_8")
local color_column  = calculate_color({mono, 0.60,  0.05}, "color_column")
local syntax_color_added    = calculate_color({150, 0.8, 0.1}, "syntax_color_added")
local syntax_color_modified = calculate_color({40, 0.8, 0.1}, "syntax_color_modified")
local syntax_color_removed  = calculate_color({0, 0.8, 0.1}, "syntax_color_removed")
local syntax_color_renamed  = calculate_color({208, 0.8, 0.1}, "syntax_color_renamed")
local pink = calculate_color({187, 0.9, 0.9}, "pink")

--[==[
local function v2ci(v)
	if v < 48 then
		return 1
	elseif v < 115 then
		return 2
	else
		return math.floor((v - 35) / 40) + 1
	end
end

local function dist_square(A, B, C, a, b, c)
	return (A-a)*(A-a) + (B-b)*(B-b) + (C-c)*(C-c)
end

local function rgb_to_x256(rgb)
	local r = rgb[1]
	local g = rgb[2]
	local b = rgb[3]

	-- convert colors to range 1..6
	local ir, ig, ib = v2ci(r), v2ci(g), v2ci(b)

	-- calculate nearest color number
	local color_index = 16 + 36 * ir + 6 * ig + ib

	-- calculate nearest grayscale number
	local avg = (r + g + b) / 3
	local gray_index = 23
	if avg <= 238 then
		gray_index = math.floor((avg - 3) / 10)
	end

	-- Calculate the colors/grayscale it would be
	local i2cv = {0, 0x5f, 0x87, 0xaf, 0xd7, 0xff}
	local cr, cg, cb = i2cv[ir], i2cv[ig], i2cv[ib]
	local gv = 8 + 10 * gray_index

	-- check whether gray or color is nearest
	local color_err = dist_square(cr, cg, cb, r, g, b)
	local gray_err = dist_square(gv, gv, gv, r, g, b)
	if color_err <= gray_err then
		return color_index
	else
		return gray_index + 232
	end
end

local normal = { fg = mono_1, bg = syntax_bg }

-- This is where the rest of your highlights should go.
local highlight_groups = {
    -------------------------------------------------------------
    -- Syntax Groups (descriptions and ordering from `:h w18`) --
    -------------------------------------------------------------
     Normal       = normal,
     NormalFloat  = normal,
     bold         = { style = 'bold'},
     ColorColumn  = { fg = none, bg = color_column },
     Conceal      = { fg = mono_4, bg = syntax_bg },
     Cursor       = { fg = none, bg = syntax_accent },
     CursorIM     = { fg = none},
     CursorColumn = { fg = none, bg = syntax_cursor },
     CursorLine   = { fg = none, bg = syntax_cursor },
     Directory    = { fg = hue_2 },
     ErrorMsg     = { fg = hue_5, bg = syntax_bg },
     VertSplit    = { fg = vertsplit },
     FloatBorder  = { fg = mono_1, bg = none},
     Folded       = { fg = mono_3, bg = syntax_bg },
     FoldColumn   = { fg = mono_3, bg = syntax_cursor },
     IncSearch    = { fg = hue_6, bg = mono_3 },
     LineNr       = { fg = mono_4 },
     CursorLineNr = { fg = mono_1, bg = syntax_cursor },
     MatchParen   = { fg = hue_5, bg = syntax_cursor, style = {'bold', 'underline'} },
     Italic       = { fg = none, style = 'italic'},
     ModeMsg      = { fg = mono_1 },
     MoreMsg      = { fg = mono_1 },
     NonText      = { fg = mono_3 },
     PMenu        = { fg = none, bg = pmenu },
     PMenuSel     = { fg = none, bg = mono_4 },
     PMenuSbar    = { fg = none, bg = syntax_bg },
     PMenuThumb   = { fg = none, bg = mono_1 },
     Question     = { fg = hue_2 },
     Search       = { fg = syntax_bg, bg = hue_6_2 },
     SpecialKey   = { fg = special_grey},
     Whitespace   = { fg = special_grey},
     StatusLine   = { fg = mono_1, bg = syntax_cursor },
     StatusLineNC = { fg = mono_3 },
     TabLine      = { fg = mono_2, bg = visual_grey},
     TabLineFill  = { fg = mono_3, bg = visual_grey},
     TabLineSel   = { fg = syntax_bg, bg = hue_2 },
     Title        = { fg = mono_1, bg = none, style = 'bold'},
     Visual       = { fg = none, bg = visual_grey},
     VisualNOS    = { fg = none, bg = visual_grey},
     WarningMsg   = { fg = hue_5 },
     TooLong      = { fg = hue_5 },
     WildMenu     = { fg = mono_1, bg = syntax_gutter },
     --WildMenu     = { fg = mono_1, bg = mono_3 },
     SignColumn   = { fg = none, bg = syntax_bg },
     Special      = { fg = hue_2 },

---------------------------
-- Vim Help Highlighting --
---------------------------

     helpCommand      = { fg = hue_6_2 },
     helpExample      = { fg = hue_6_2 },
     helpHeader       = { fg = mono_1, style = 'bold'},
     helpSectionDelim = { fg = mono_3,},

----------------------------------
-- Standard Syntax Highlighting --
----------------------------------

     Comment        = { fg = mono_3,  style = 'italic'},
     Constant       = { fg = hue_4, bg = none},
     String         = { fg = hue_4, bg = none},
     Character      = { fg = hue_4, bg = none},
     Number         = { fg = hue_6, bg = none},
     Boolean        = { fg = hue_6, bg = none},
     Float          = { fg = hue_6, bg = none},
     Identifier     = { fg = hue_5, bg = none},
     Function       = { fg = hue_2, bg = none},
     Statement      = { fg = hue_3, bg = none},
     Conditional    = { fg = hue_3, bg = none},
     Repeat         = { fg = hue_3, bg = none},
     Label          = { fg = hue_3, bg = none},
     Operator       = { fg = syntax_accent },
     Keyword        = { fg = hue_5, bg = none},
     Exception      = { fg = hue_3, bg = none},
     PreProc        = { fg = hue_6_2, bg = none},
     Include        = { fg = hue_2, bg = none},
     Define         = { fg = hue_3, bg = none},
     Macro          = { fg = hue_3, bg = none},
     PreCondit      = { fg = hue_6_2, bg = none},
     Type           = { fg = hue_6_2, bg = none},
     StorageClass   = { fg = hue_6_2, bg = none},
     Structure      = { fg = hue_6_2, bg = none},
     Typedef        = { fg = hue_6_2, bg = none},
     Special        = { fg = hue_2, bg = none},
     SpecialChar    = { fg = none},
     Tag            = { fg = none},
     Delimiter      = { fg = none},
     SpecialComment = { fg = none},
     Debug          = { fg = none},
     Underlined     = { fg = none, style = 'underline' },
     Ignore         = { fg = none},
     Error          = { style = 'undercurl'},
     Todo           = { fg = hue_3, bg = mono_3 },

-----------------------
-- Diff Highlighting --
-----------------------

     DiffAdd     = { fg = syntax_color_added, bg = visual_grey},
     DiffChange  = { fg = syntax_color_modified, bg = visual_grey},
     DiffDelete  = { fg = syntax_color_removed, bg = visual_grey},
     DiffText    = { fg = hue_2, bg = visual_grey},
     DiffAdded   = { fg = hue_4, bg = visual_grey},
     DiffFile    = { fg = hue_5, bg = visual_grey},
     DiffNewFile = { fg = hue_4, bg = visual_grey},
     DiffLine    = { fg = hue_2, bg = visual_grey},
     DiffRemoved = { fg = hue_5, bg = visual_grey},

---------------------------
-- Filetype Highlighting --
---------------------------

-- Asciidoc
     asciidocListingBlock = { fg = mono_2 },

-- C/C++ highlighting
     cInclude           = { fg = hue_3 },
     cPreCondit         = { fg = hue_3 },
     cPreConditMatch    = { fg = hue_3 },
     cType              = { fg = hue_3 },
     cStorageClass      = { fg = hue_3 },
     cStructure         = { fg = hue_3 },
     cOperator          = { fg = hue_3 },
     cStatement         = { fg = hue_3 },
     cTODO              = { fg = hue_3 },
     cConstant          = { fg = hue_6 },
     cSpecial           = { fg = hue_1 },
     cSpecialCharacter  = { fg = hue_1 },
     cString            = { fg = hue_4 },
     cppType            = { fg = hue_3 },
     cppStorageClass    = { fg = hue_3 },
     cppStructure       = { fg = hue_3 },
     cppModifier        = { fg = hue_3 },
     cppOperator        = { fg = hue_3 },
     cppAccess          = { fg = hue_3 },
     cppStatement       = { fg = hue_3 },
     cppConstant        = { fg = hue_5 },
     cCppString         = { fg = hue_4 },

-- Cucumber
     cucumberGiven           = { fg = hue_2 },
     cucumberWhen            = { fg = hue_2 },
     cucumberWhenAnd         = { fg = hue_2 },
     cucumberThen            = { fg = hue_2 },
     cucumberThenAnd         = { fg = hue_2 },
     cucumberUnparsed        = { fg = hue_6 },
     cucumberFeature         = { fg = hue_5, style = 'bold'},
     cucumberBackground      = { fg = hue_3, style = 'bold'},
     cucumberScenario        = { fg = hue_3, style = 'bold'},
     cucumberScenarioOutline = { fg = hue_3, style = 'bold'},
     cucumberTags            = { fg = mono_3, style = 'bold'},
     cucumberDelimiter       = { fg = mono_3, style = 'bold'},

-- CSS/Sass
     cssAttrComma         = { fg = hue_3 },
     cssAttributeSelector = { fg = hue_4 },
     cssBraces            = { fg = mono_2 },
     cssClassName         = { fg = hue_6 },
     cssClassNameDot      = { fg = hue_6 },
     cssDefinition        = { fg = hue_3 },
     cssFontAttr          = { fg = hue_6 },
     cssFontDescriptor    = { fg = hue_3 },
     cssFunctionName      = { fg = hue_2 },
     cssIdentifier        = { fg = hue_2 },
     cssImportant         = { fg = hue_3 },
     cssInclude           = { fg = mono_1 },
     cssIncludeKeyword    = { fg = hue_3 },
     cssMediaType         = { fg = hue_6 },
     cssProp              = { fg = hue_1 },
     cssPseudoClassId     = { fg = hue_6 },
     cssSelectorOp        = { fg = hue_3 },
     cssSelectorOp2       = { fg = hue_3 },
     cssStringQ           = { fg = hue_4 },
     cssStringQQ          = { fg = hue_4 },
     cssTagName           = { fg = hue_5 },
     cssAttr              = { fg = hue_6 },
     sassAmpersand      = { fg = hue_5 },
     sassClass          = { fg = hue_6_2 },
     sassControl        = { fg = hue_3 },
     sassExtend         = { fg = hue_3 },
     sassFor            = { fg = mono_1 },
     sassProperty       = { fg = hue_1 },
     sassFunction       = { fg = hue_1 },
     sassId             = { fg = hue_2 },
     sassInclude        = { fg = hue_3 },
     sassMedia          = { fg = hue_3 },
     sassMediaOperators = { fg = mono_1 },
     sassMixin          = { fg = hue_3 },
     sassMixinName      = { fg = hue_2 },
     sassMixing         = { fg = hue_3 },
     scssSelectorName   = { fg = hue_6_2 },

-- Elixir highlighting
     elixirModuleDefine      = 'Define',
     elixirAlias             = { fg = hue_6_2 },
     elixirAtom              = { fg = hue_1 },
     elixirBlockDefinition   = { fg = hue_3 },
     elixirModuleDeclaration = { fg = hue_6 },
     elixirInclude           = { fg = hue_5 },
     elixirOperator          = { fg = hue_6 },

-- Git and git related plugins
     gitcommitComment        = { fg = mono_3 },
     gitcommitUnmerged       = { fg = hue_4 },
     gitcommitOnBranch       = { fg = none},
     gitcommitBranch         = { fg = hue_3 },
     gitcommitDiscardedType  = { fg = hue_5 },
     gitcommitSelectedType   = { fg = hue_4 },
     gitcommitHeader         = { fg = none},
     gitcommitUntrackedFile  = { fg = hue_1 },
     gitcommitDiscardedFile  = { fg = hue_5 },
     gitcommitSelectedFile   = { fg = hue_4 },
     gitcommitUnmergedFile   = { fg = hue_6_2 },
     gitcommitFile           = { fg = none},
     gitcommitNoBranch       = 'gitcommitBranch',
     gitcommitUntracked      = 'gitcommitComment',
     gitcommitDiscarded      = 'gitcommitComment',
     gitcommitDiscardedArrow = 'gitcommitDiscardedFile',
     gitcommitSelectedArrow  = 'gitcommitSelectedFile',
     gitcommitUnmergedArrow  = 'gitcommitUnmergedFile',
     SignifySignAdd          = { fg = syntax_color_added },
     SignifySignChange       = { fg = syntax_color_modified },
     SignifySignDelete       = { fg = syntax_color_removed },
     GitGutterAdd            = 'SignifySignAdd',
     GitGutterChange         = 'SignifySignChange',
     GitGutterDelete         = 'SignifySignDelete',
     GitSignsAdd             = 'SignifySignAdd',
     GitSignsChange          = 'SignifySignChange',
     GitSignsDelete          = 'SignifySignDelete',

-- Go
     goDeclaration  = { fg = hue_3 },
     goField        = { fg = hue_5 },
     goMethod       = { fg = hue_1 },
     goType         = { fg = hue_3 },
     goUnsignedInts = { fg = hue_1 },

-- Haskell highlighting
     haskellDeclKeyword    = { fg = hue_2 },
     haskellType           = { fg = hue_4 },
     haskellWhere          = { fg = hue_5 },
     haskellImportKeywords = { fg = hue_2 },
     haskellOperators      = { fg = hue_5 },
     haskellDelimiter      = { fg = hue_2 },
     haskellIdentifier     = { fg = hue_6 },
     haskellKeyword        = { fg = hue_5 },
     haskellNumber         = { fg = hue_1 },
     haskellString         = { fg = hue_1 },

-- HTML
     htmlArg            = { fg = hue_6 },
     htmlTagName        = { fg = hue_5 },
     htmlTagN           = { fg = hue_5 },
     htmlSpecialTagName = { fg = hue_5 },
     htmlTag            = { fg = mono_2 },
     htmlEndTag         = { fg = mono_2 },
     MatchTag           = { fg = hue_5, bg = syntax_cursor, style = {'bold', 'underline'} },

-- JavaScript
     coffeeString           = { fg = hue_4 },
     javaScriptBraces       = { fg = mono_2 },
     javaScriptFunction     = { fg = hue_3 },
     javaScriptIdentifier   = { fg = hue_3 },
     javaScriptNull         = { fg = hue_6 },
     javaScriptNumber       = { fg = hue_6 },
     javaScriptRequire      = { fg = hue_1 },
     javaScriptReserved     = { fg = hue_3 },
-- httpc.//github.com/pangloss/vim-javascript
     jsArrowFunction        = { fg = hue_3 },
     jsBraces               = { fg = mono_2 },
     jsClassBraces          = { fg = mono_2 },
     jsClassKeywords        = { fg = hue_3 },
     jsDocParam             = { fg = hue_2 },
     jsDocTags              = { fg = hue_3 },
     jsFuncBraces           = { fg = mono_2 },
     jsFuncCall             = { fg = hue_2 },
     jsFuncParens           = { fg = mono_2 },
     jsFunction             = { fg = hue_3 },
     jsGlobalObjects        = { fg = hue_6_2 },
     jsModuleWords          = { fg = hue_3 },
     jsModules              = { fg = hue_3 },
     jsNoise                = { fg = mono_2 },
     jsNull                 = { fg = hue_6 },
     jsOperator             = { fg = hue_3 },
     jsParens               = { fg = mono_2 },
     jsStorageClass         = { fg = hue_3 },
     jsTemplateBraces       = { fg = hue_5_2 },
     jsTemplateVar          = { fg = hue_4 },
     jsThis                 = { fg = hue_5 },
     jsUndefined            = { fg = hue_6 },
     jsObjectValue          = { fg = hue_2 },
     jsObjectKey            = { fg = hue_1 },
     jsReturn               = { fg = hue_3 },
-- httpc.//github.com/othree/yajs.vim
     javascriptArrowFunc    = { fg = hue_3 },
     javascriptClassExtends = { fg = hue_3 },
     javascriptClassKeyword = { fg = hue_3 },
     javascriptDocNotation  = { fg = hue_3 },
     javascriptDocParamName = { fg = hue_2 },
     javascriptDocTags      = { fg = hue_3 },
     javascriptEndColons    = { fg = mono_3 },
     javascriptExport       = { fg = hue_3 },
     javascriptFuncArg      = { fg = mono_1 },
     javascriptFuncKeyword  = { fg = hue_3 },
     javascriptIdentifier   = { fg = hue_5 },
     javascriptImport       = { fg = hue_3 },
     javascriptObjectLabel  = { fg = mono_1 },
     javascriptOpSymbol     = { fg = hue_1 },
     javascriptOpSymbols    = { fg = hue_1 },
     javascriptPropertyName = { fg = hue_4 },
     javascriptTemplateSB   = { fg = hue_5_2 },
     javascriptVariable     = { fg = hue_3 },

-- JSON
     jsonCommentError       = { fg = mono_1 },
     jsonKeyword            = { fg = hue_5 },
     jsonQuote              = { fg = mono_3 },
     jsonTrailingCommaError = { fg = hue_5, style = 'reverse' },
     jsonMissingCommaError  = { fg = hue_5, style = 'reverse' },
     jsonNoQuotesError      = { fg = hue_5, style = 'reverse' },
     jsonNumError           = { fg = hue_5, style = 'reverse' },
     jsonString             = { fg = hue_4 },
     jsonBoolean            = { fg = hue_3 },
     jsonNumber             = { fg = hue_6 },
     jsonStringSQError      = { fg = hue_5, style = 'reverse' },
     jsonSemicolonError     = { fg = hue_5, style = 'reverse' },

-- Markdown
     markdownUrl              = { fg = mono_3, stlye = 'underline' },
     markdownBold             = { fg = hue_6, style = 'bold' },
     markdownItalic           = { fg = hue_6, style = 'italic' },
     markdownCode             = { fg = hue_4 },
     markdownCodeBlock        = { fg = hue_5 },
     markdownCodeDelimiter    = { fg = hue_4 },
     markdownHeadingDelimiter = { fg = hue_5_2 },
     markdownH1               = { fg = hue_5 },
     markdownH2               = { fg = hue_5 },
     markdownH3               = { fg = hue_5 },
     markdownH3               = { fg = hue_5 },
     markdownH4               = { fg = hue_5 },
     markdownH5               = { fg = hue_5 },
     markdownH6               = { fg = hue_5 },
     markdownListMarker       = { fg = hue_5 },

-- PHP
     phpClass        = { fg = hue_6_2 },
     phpFunction     = { fg = hue_2 },
     phpFunctions    = { fg = hue_2 },
     phpInclude      = { fg = hue_3 },
     phpKeyword      = { fg = hue_3 },
     phpParent       = { fg = mono_3 },
     phpType         = { fg = hue_3 },
     phpSuperGlobals = { fg = hue_5 },

-- Pug (Formerly Jade)
     pugAttributesDelimiter = { fg = hue_6 },
     pugClass               = { fg = hue_6 },
     pugDocType             = { fg = mono_3, style = 'italic'},
     pugTag                 = { fg = hue_5 },

-- PureScript
     purescriptKeyword     = { fg = hue_3 },
     purescriptModuleName  = { fg = mono_1 },
     purescriptIdentifier  = { fg = mono_1 },
     purescriptType        = { fg = hue_6_2 },
     purescriptTypeVar     = { fg = hue_5 },
     purescriptConstructor = { fg = hue_5 },
     purescriptOperator    = { fg = mono_1 },

-- Python
     pythonImport          = { fg = hue_3 },
     pythonBuiltin         = { fg = hue_1 },
     pythonStatement       = { fg = hue_3 },
     pythonParam           = { fg = hue_6 },
     pythonEscape          = { fg = hue_5 },
     pythonSelf            = { fg = mono_2, style = 'italic'},
     pythonClass           = { fg = hue_2 },
     pythonOperator        = { fg = hue_3 },
     pythonEscape          = { fg = hue_5 },
     pythonFunction        = { fg = hue_2 },
     pythonKeyword         = { fg = hue_2 },
     pythonModule          = { fg = hue_3 },
     pythonStringDelimiter = { fg = hue_4 },
     pythonSymbol          = { fg = hue_1 },

-- Ruby
     rubyBlock                     = { fg = hue_3 },
     rubyBlockParameter            = { fg = hue_5 },
     rubyBlockParameterList        = { fg = hue_5 },
     rubyCapitalizedMethod         = { fg = hue_3 },
     rubyClass                     = { fg = hue_3 },
     rubyConstant                  = { fg = hue_6_2 },
     rubyControl                   = { fg = hue_3 },
     rubyDefine                    = { fg = hue_3 },
     rubyEscape                    = { fg = hue_5 },
     rubyFunction                  = { fg = hue_2 },
     rubyGlobalVariable            = { fg = hue_5 },
     rubyInclude                   = { fg = hue_2 },
     rubyIncluderubyGlobalVariable = { fg = hue_5 },
     rubyInstanceVariable          = { fg = hue_5 },
     rubyInterpolation             = { fg = hue_1 },
     rubyInterpolationDelimiter    = { fg = hue_5 },
     rubyKeyword                   = { fg = hue_2 },
     rubyModule                    = { fg = hue_3 },
     rubyPseudoVariable            = { fg = hue_5 },
     rubyRegexp                    = { fg = hue_1 },
     rubyRegexpDelimiter           = { fg = hue_1 },
     rubyStringDelimiter           = { fg = hue_4 },
     rubySymbol                    = { fg = hue_1 },

-- Spelling
     SpellBad   = { fg = mono_3, style = 'undercurl'},
     SpellLocal = { fg = mono_3, style = 'undercurl'},
     SpellCap   = { fg = mono_3, style = 'undercurl'},
     SpellRare  = { fg = mono_3, style = 'undercurl'},

-- Vim
     vimCommand      = { fg = hue_3 },
     vimCommentTitle = { fg = mono_3, style = 'bold'},
     vimFunction     = { fg = hue_1 },
     vimFuncName     = { fg = hue_3 },
     vimHighlight    = { fg = hue_2 },
     vimLineComment  = { fg = mono_3, style = 'italic'},
     vimParenSep     = { fg = mono_2 },
     vimSep          = { fg = mono_2 },
     vimUserFunc     = { fg = hue_1 },
     vimVar          = { fg = hue_5 },

-- XML
     xmlAttrib  = { fg = hue_6_2 },
     xmlEndTag  = { fg = hue_5 },
     xmlTag     = { fg = hue_5 },
     xmlTagName = { fg = hue_5 },

-- ZSH
     zshCommands    = { fg = mono_1 },
     zshDeref       = { fg = hue_5 },
     zshShortDeref  = { fg = hue_5 },
     zshFunction    = { fg = hue_1 },
     zshKeyword     = { fg = hue_3 },
     zshSubst       = { fg = hue_5 },
     zshSubstDelim  = { fg = mono_3 },
     zshTypes       = { fg = hue_3 },
     zshVariableDef = { fg = hue_6 },

-- Rust
     rustExternCrate          = { fg = hue_5,  style = 'bold'},
     rustIdentifier           = { fg = hue_2 },
     rustDeriveTrait          = { fg = hue_4 },
     SpecialComment           = { fg = mono_3 },
     rustCommentLine          = { fg = mono_3 },
     rustCommentLineDoc       = { fg = mono_3 },
     rustCommentLineDocError  = { fg = mono_3 },
     rustCommentBlock         = { fg = mono_3 },
     rustCommentBlockDoc      = { fg = mono_3 },
     rustCommentBlockDocError = { fg = mono_3 },

-- Man
     manTitle  = 'String',
     manFooter = { fg = mono_3 },

-------------------------
-- Plugin Highlighting --
-------------------------

-- ALE (Asynchronous Lint Engine)
     ALEWarningSign = { fg = hue_6_2 },
     ALEErrorSign   = { fg = hue_5 },

-- Neovim NERDTree Background fix
     NERDTreeFile = { fg = mono_1 },

-- Coc.nvim
CocFloating = { bg = none },
NormalFloating = { bg = none },

-----------------------------
--     LSP Highlighting    --
-----------------------------

LspDiagnosticsDefaultError           = { fg = hue_5 },
LspDiagnosticsDefaultWarning         = { fg = hue_6_2 },
LspDiagnosticsDefaultInformation     = { fg = hue_1 },
LspDiagnosticsDefaultHint            = { fg = hue_4 },
LspDiagnosticsVirtualTextError       = { fg = hue_5 },
LspDiagnosticsVirtualTextWarning     = { fg = hue_6_2 },
LspDiagnosticsVirtualTextInformation = { fg = hue_1 },
LspDiagnosticsVirtualTextHint        = { fg = hue_4 },
LspDiagnosticsUnderlineError         = { fg = hue_5 , style = 'underline' },
LspDiagnosticsUnderlineWarning       = { fg = hue_6_2 , style = 'underline' },
LspDiagnosticsUnderlineInformation   = { fg = hue_1 , style = 'underline' },
LspDiagnosticsUnderlineHint          = { fg = hue_4 , style = 'underline' },
LspDiagnosticsFloatingError          = { fg = hue_5 , bg = pmenu },
LspDiagnosticsFloatingWarning        = { fg = hue_6_2 , bg = pmenu },
LspDiagnosticsFloatingInformation    = { fg = hue_1 , bg = pmenu },
LspDiagnosticsFloatingHint           = { fg = hue_4 , bg = pmenu },
LspDiagnosticsSignError              = { fg = hue_5 },
LspDiagnosticsSignWarning            = { fg = hue_6_2 },
LspDiagnosticsSignInformation        = { fg = hue_1 },
LspDiagnosticsSignHint               = { fg = hue_4 },
LspReferenceText                     = { style = 'reverse' },
LspReferenceRead                     = { style = 'reverse' },
LspReferenceWrite                    = { fg = hue_6_2, style = 'reverse' },

-----------------------------
-- TreeSitter Highlighting --
-----------------------------

     TSAnnotation         = 'PreProc',
     TSAttribute          = 'PreProc',
     TSBoolean            = 'Boolean',
     TSCharacter          = 'Character',
     TSComment            = 'Comment',
     TSConditional        = 'Conditional',
     TSConstant           = 'Constant',
     TSConstBuiltin       = 'Special',
     TSConstMacro         = 'Define',
     TSConstructor        = 'Special',
     TSEmphasis           = 'Italic',
     TSError              = 'Error',
     TSException          = 'Exception',
     TSField              = 'Normal',
     TSFloat              = 'Float',
     TSFunction           = 'Function',
     TSFuncBuiltin        = 'Special',
     TSFuncMacro          = 'Macro',
     TSInclude            = 'Include',
     TSKeyword            = 'Keyword',
     TSKeywordFunction    = 'Keyword',
     TSKeywordOperator    = 'Operator',
     TSLabel              = 'Label',
     TSLiteral            = 'String',
     TSMethod             = 'Function',
     TSNamespace          = 'Include',
     TSNumber             = 'Number',
     TSOperator           = 'Operator',
     TSParameter          = 'Identifier',
     TSParameterReference = 'Identifier',
     TSProperty           = 'Identifier',
     TSPunctBracket       = 'Delimiter',
     TSPunctDelimiter     = 'Delimiter',
     TSPunctSpecial       = 'Delimiter',
     TSRepeat             = 'Repeat',
     TSString             = 'String',
     TSStringEscape       = 'SpecialChar',
     TSStringRegex        = 'String',
     TSStrong             = 'bold',
     TSTag                = 'Label',
     TSTagDelimiter       = 'Label',
     -- TSText               = { fg = hue_6_2 },
     TSTitle              = 'Title',
     TSType               = 'Type',
     TSTypeBuiltin        = 'Type',
     TSUnderline          = 'Underlined',
     TSURI                = 'Underlined',
     TSVariableBuiltin    = 'Special',
}

local terminal_ansi_colors = {
    [0]  = term_black,
    [1]  = hue_5,
    [2]  = hue_4,
    [3]  = hue_6_2,
    [4]  = term_blue,
    [5]  = hue_3,
    [6]  = term_cyan,
    [7]  = term_white,
    [8]  = term_8,
    [9]  = hue_5,
    [10] = hue_4,
    [11] = hue_6_2,
    [12] = term_blue,
    [13] = hue_3,
    [14] = term_cyan,
    [15] = term_white
}
--]==]
