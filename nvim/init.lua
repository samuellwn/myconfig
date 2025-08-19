-- @!os:unix
-- @!install:644:$HOME/.config/nvim/init.lua
--[===[ ]===]
local o, bo, wo, g = vim.o, vim.bo, vim.wo, vim.g
local b, api = vim.b, vim.api, vim.api.nvim_set_keymap

cmd, map = vim.cmd, vim.keymap.set

home = os.getenv("HOME")
g.mapleader = ' '

--for line in string.gmatch(vim.fn.system({"env"}), "[^\r\n]+"

function nnoremap(from, to)
    map('n', from, to, { noremap = true })
end

o.hidden = true
o.backup = false
o.writebackup = false
o.cmdheight = 2
o.updatetime = 300
o.signcolumn = 'yes:1'
o.colorcolumn = '100'
o.number = true
o.termguicolors = true
wo.foldenable = false
o.foldlevelstart = 99
if not string.find(o.shortmess, 'c', 1, true) then
	o.shortmess = o.shortmess .. 'c'
end

g.man_hardwrap = 1

o.laststatus = 2
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = false

o.breakindent = true
o.breakindentopt = 'shift:8'
o.linebreak = true
o.wrap = false

g.polyglot_disabled = { 'csv.plugin', 'terraform' }
g.ale_disable_lsp = 1
g.ale_sign_column_always = 1
g.ale_linters_ignore = { 'mcs', 'mcsc', 'csc' }
g.OmniSharp_server_use_net6 = 1
g.instant_username = vim.env.USER

g.suda_smart_edit = 1

cmd('set diffopt-=filler')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	-- IDE features
	{
		'L3MON4D3/LuaSnip',
		version = "1.*",
		build = "make install_jsregexp",
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'L3MON4D3/LuaSnip', 'neovim/nvim-lspconfig', 'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer', 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets',
			'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline',
		},
	},
	'andythigpen/nvim-coverage', -- Test coverage in gutter
	{
		'stevearc/conform.nvim',
		opts = {
			formatters_by_ft = {
				python = { "ruff_format" },
			},
			format_on_save = function(bufnr)
				-- Skip format on save if the current buffer has errors
				local diag = vim.diagnostic
				local errors = diag.get(bufnr, { severity = diag.severity.ERROR })
				if #errors > 0 then
					return nil
				end

				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end,
		},
	},
	--'mfussenegger/nvim-dap', -- Browser debugger connection

	-- Language support
	'sebdah/vim-delve', 'sheerun/vim-polyglot',
	{
		'mason-org/mason-lspconfig.nvim',
		opts = {
			automatic_enable = false,
			ensure_installed = { 'gopls', 'rust_analyzer', 'zls', 'pyright', 'ruff' },
		},
		dependencies = {
			{ 'mason-org/mason.nvim', opts = {} },
			'neovim/nvim-lspconfig',
		},
	},
	-- { 'phpactor/phpactor', build = 'composer  install' },
	'psf/black', -- opinionated python autofomatter
	'terrastruct/d2-vim',

	-- Git
	'tpope/vim-fugitive',
	'rhysd/git-messenger.vim',
	'junegunn/gv.vim',
	'jreybert/vimagit',
	{'idanarye/vim-merginal', dependencies = {'tpope/vim-fugitive'}},
	'lewis6991/gitsigns.nvim',

	-- UI Improvements
	{ 'nvim-lualine/lualine.nvim', dependencies = {'kyazdani42/nvim-web-devicons'}},
	{
		'nvim-telescope/telescope.nvim', branch = '0.1.x',
		dependencies = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
	},
	{
		'nvim-telescope/telescope-fzf-native.nvim', build = 'make',
		dependencies = {{'nvim-telescope/telescope.nvim'}},
	},
	{ 'stevearc/dressing.nvim', dependencies = {{'nvim-telescope/telescope.nvim'}}},
	{ 'Shatur/neovim-session-manager', dependencies = {{'nvim-lua/plenary.nvim'}}},

	-- Navigation
	{ 'vimwiki/vimwiki', disable = true },
	{ 'phaazon/hop.nvim', branch = 'v2' },
	'christoomey/vim-tmux-navigator',
	'ds26gte/info.vim',
	'andymass/vim-tradewinds',

	-- Collaborative editing
	'jbyuki/instant.nvim',

	-- Unknown
--	'andreshazard/vim-freemarker',
--	'sidebar-nvim/sidebar.nvim',
	'andreshazard/vim-logreview', 'tpope/vim-repeat', 'tpope/vim-surround',
	'Valloric/ListToggle', 'posva/vim-vue', 'elzr/vim-json',
	'ekalinin/Dockerfile.vim', 'liuchengxu/graphviz.vim',
	'tmhedberg/SimpylFold', 'mbbill/undotree', 'Joorem/vim-haproxy',
--	'Raimondi/DelimitMate', -- auto-insert closing parens, etc.
--	'neovim/nvim-lspconfig', 'ap/vim-buftabline'
	{ 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
	{ 'junegunn/fzf.vim', dependencies = 'fzf' },
	{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
	'lambdalisue/suda.vim',
--	use { 'antoinemadec/coc-fzf', branch = 'release', after = { 'fzf', 'fzf.vim' } }

	-- Colors
	{ 'Iron-E/nvim-highlite', branch = 'master-v4' },
	'ntpeters/vim-better-whitespace',

	-- Normally, neovim GUIs take care of loading this plugin for us. lazy.nvim
	-- breaks this somehow. Add the plugin manually. This doesn't break plain
	-- neovim. (I checked).
	'equalsraf/neovim-gui-shim',

	-- my colorscheme
--	use 'samuellwn/nvim-colors'
--	use '~/Projects/nvim-colors'

	-- extra colorschemes
-- Plug 'gosukiwi/vim-atom-dark'
-- Plug 'sainnhe/sonokai'
-- Plug 'ChristianChiarulli/nvcode-color-schemes.vim'
-- Plug 'Mofiqul/vim-code-dark'
-- Plug 'doums/darcula'
-- Plug 'tanvirtin/monokai.nvim'
--	use 'flazz/vim-colorschemes'
--	use 'sainnhe/edge'
--	use 'fenetikm/falcon'
--	use 'romgrk/doom-one.vim'
--	use 'Luxed/ayu-vim'
})

-- Setup for 'Iron-E/nvim-highlite'
require('highlite').setup()
-- End setup for 'Iron-E/nvim-highlite'

-- This checks if a color scheme that matches your username exists.
-- If it doesn't exist, it uses a default scheme instead.

local username = vim.env.USER
local colors_dir = vim.fn.stdpath('config') .. '/colors/'
local colorscheme_file = colors_dir .. username .. '.lua'

if vim.fn.filereadable(colorscheme_file) == 1 then
	vim.cmd('colorscheme ' .. username)
else
	vim.cmd('colorscheme default')
end

-- cmd('colorscheme asmanian-blood')
-- colorscheme ayu
-- colorscheme afterglow
-- colorscheme sonokai

cmd('packadd cfilter')

-- The Neovim clipboard provider priority is wrong and can't be overridden. I have to
-- rewrite the functionality neovim already has so it actually works. I don't know who
-- though it would be a good idea to prefer the system clipboard over lemonade.
-- vim.g.clipboard = {
-- 	name = 'my-clipboard',
-- 	copy = {
-- 		['+'] = {'zsh', '-c', '(lemonade copy || pbcopy || wl-copy || xclip -selection clipboard -i) 2>/dev/null'},
-- 		['*'] = {'zsh', '-c', '(pbcopy || wl-copy || xclip -selection clipboard -i) 2>/dev/null'},
-- 	},
-- 	paste = {
-- 		['+'] = {'zsh', '-c', '(lemonade paste || pbpaste || wl-paste || xclip -selection clipboard -o) 2>/dev/null'},
-- 		['*'] = {'zsh', '-c', '(pbpaste || wl-paste || xclip -selection clipboard -o) 2>/dev/null'},
-- 	},
-- }

--[[
require("sidebar-nvim").setup {
	side = "left",
	open = true,
	update_interval = 1000,
	sections = { "buffers", "git", "symbols", "diagnostics", "files", "todos" },
	todos = {
		ignored_paths = { "~" },
	},
	section_separator = {"═══════════════════════════════════"},
	section_title_separator = {""},
}
]]
-- Setup for 'vimwiki/vimwiki'
vim.g.vimwiki_list = {
	{ path = '~/wikis/general' },
	{ 
		path = '~/Work/devdocs/src',
		path_html = '~/Work/devdocs/html',
		index = 'index',
		ext = '.md',
		syntax = 'markdown',
		auto_toc = 1
	}
}
-- End setup for 'vimwiki/vimwiki'

-- Setup for 'hrsh7th/nvim-cmp'
local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

require('luasnip.loaders.from_vscode').lazy_load()

local cmp = require 'cmp'
local luasnip = require('luasnip')
local function cmpShowOrComplete()
	if cmp.visible() then
		cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
	else
		cmp.complete({reason = 'manual'})
	end
end
local function cmpSelectNextOrJump(fallback)
	if cmp.visible() then
		cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
	elseif luasnip.expand_or_locally_jumpable() then
		luasnip.expand_or_jump()
	else
		fallback()
	end
end
local function cmpSelectPrevOrJump(fallback)
	if cmp.visible() then
		cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
	elseif luasnip.locally_jumpable(-1) then
		luasnip.jump(-1)
	else
		fallback()
	end
end
local function cmpClose(fallback)
	if cmp.visible() then
		cmp.abort()
	else
		fallback()
	end
end

cmp.setup {
	mapping = {
		['<C-Space>'] = cmp.mapping(cmpShowOrComplete, {"c", "i"}),
		['<S-Space>'] = cmp.mapping(cmpShowOrComplete, {"c", "i"}),
		['<C-n>'] = cmp.mapping(cmpSelectNextOrJump, {"c", "i"}),
		['<Tab>'] = cmp.mapping(cmpSelectNextOrJump, {"c", "i"}),
		['<C-p>'] = cmp.mapping(cmpSelectPrevOrJump, {"c", "i"}),
		['<S-Tab>'] = cmp.mapping(cmpSelectPrevOrJump, {"c", "i"}),
		['<C-o>'] = cmp.mapping(cmpClose, {"c", "i"}),
		['<C-u>'] = cmp.mapping.scroll_docs(-8),
		['<C-d>'] = cmp.mapping.scroll_docs(8),

	},
	snippet = {
		expand = function(args)
			luasnip.snip_expand(luasnip.parser.parse_snippet(
				{trig = "lsp"}, args.body, { trim_empty = false, dedent = true }
			))
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered({
			max_width = 60,
			max_height = 80,
		}),
	},
	preselect = cmp.PreselectMode.None,
	sorting = {
		comparators = {
			cmp.config.compare.score, -- lsp-provided score?
			cmp.config.compare.sort_text, -- lsp-provided sorting text
			cmp.config.compare.scope, -- variable scope
			cmp.config.compare.recently_used,
			cmp.config.compare.locality, -- more close cursor more better
			-- cmp.config.compare.length,
			-- cmp.config.compare.kind,
			-- cmp.config.compare.offset,
		},
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		--{ name = 'luasnip' },
	}, {
		{ name = 'buffer' },
	}),
}
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})
local path = require('lspconfig/util').path
local function get_python_path(workspace)
	-- Use activated venv
	if vim.env.VIRTUAL_ENV then
		return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
	end

	if workspace ~= nil then
		-- Find and use virtualenv in workspace directory.
		for _, pattern in ipairs({'*', '.*'}) do
			local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
			if match ~= '' then
				return path.join(path.dirname(match), 'bin', 'python')
			end
		end

		-- Use venv from poetry
		local match = vim.fn.glob(path.join(workspace, 'pyproject.toml'))
		if match ~= '' then
			local venv = vim.fn.trim(vim.fn.system(
				'poetry --directory "' .. workspace .. '" env info -p'
			))
			return path.join(venv, 'bin', 'python')
		end
	end

	-- Fallback to system Python
	return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python3' or 'python'
end
local caps = require('cmp_nvim_lsp').default_capabilities(
	vim.lsp.protocol.make_client_capabilities()
)
local lspdefaults = {
	capabilities = caps,
}
local servers = {
	gopls = lspdefaults,
	fsautocomplete = lspdefaults,
	ocamllsp = lspdefaults,
	rust_analyzer = lspdefaults,
	erlangls = lspdefaults,
	phpactor = lspdefaults,
	clangd = lspdefaults,
	ols = lspdefaults,
	gdscript = lspdefaults,
	zls = lspdefaults,
	yamlls = lspdefaults,
	systemd_ls = lspdefaults,
	jsonls = lspdefaults,
	jsonnet_ls = lspdefaults,
	jqls = lspdefaults,
	html = lspdefaults,
	ts_ls = lspdefaults,
	pyright = {
		capabilities = caps,
		before_init = function(_, config)
			config.settings.python.pythonPath = get_python_path(config.root_dir)
		end,
	},
	ruff = {
		capabilities = caps,
		before_init = function(_, config)
			config.settings.interpreter = get_python_path(config.root_dir)
		end,
	},
	omnisharp = {
		capabilities = caps,
		cmd = { "omnisharp" },
		enable_import_completion = true,
		-- Thanks, Microsoft, for requiring this stupidity
		on_attach = function(client, _)
			client.server_capabilities.semanticTokensProvider = {
				full = vim.empty_dict(),
				legend = {
					tokenModifiers = { "static_symbol" },
					tokenTypes = {
						"comment", "excluded_code", "identifier",
						"keyword", "keyword_control", "number",
						"operator", "operator_overloaded",
						"preprocessor_keyword", "string", "whitespace",
						"text", "static_symbol", "preprocessor_text",
						"punctuation", "string_verbatim",
						"string_escape_character", "class_name",
						"delegate_name", "enum_name", "interface_name",
						"module_name", "struct_name",
						"type_parameter_name", "field_name",
						"enum_member_name", "constant_name",
						"local_name", "parameter_name", "method_name",
						"extension_method_name", "property_name",
						"event_name", "namespace_name", "label_name",
						"xml_doc_comment_attribute_name",
						"xml_doc_comment_attribute_quotes",
						"xml_doc_comment_attribute_value",
						"xml_doc_comment_cdata_section",
						"xml_doc_comment_comment",
						"xml_doc_comment_delimiter",
						"xml_doc_comment_entity_reference",
						"xml_doc_comment_name",
						"xml_doc_comment_processing_instruction",
						"xml_doc_comment_text",
						"xml_literal_attribute_name",
						"xml_literal_attribute_quotes",
						"xml_literal_attribute_value",
						"xml_literal_cdata_section",
						"xml_literal_comment", "xml_literal_delimiter",
						"xml_literal_embedded_expression",
						"xml_literal_entity_reference",
						"xml_literal_name",
						"xml_literal_processing_instruction",
						"xml_literal_text", "regex_comment",
						"regex_character_class", "regex_anchor",
						"regex_quantifier", "regex_grouping",
						"regex_alternation", "regex_text",
						"regex_self_escaped_character",
						"regex_other_escape",
					},
				},
				range = true,
			}
		end,
	},
	hls = {
		capabilities = caps,
		filetypes = { 'haskell', 'lhaskell', 'cabal' },
	},
}
for s, c in pairs(servers) do
	vim.lsp.config(s, c)
	vim.lsp.enable(s)
end
-- End setup for 'hrsh7th/nvim-cmp'
-- Setup for 'nvim-telescope/telescope.nvim`
require('telescope').setup{}
require('telescope').load_extension('fzf')
-- End setup for 'nvim-telescope/telescope.nvim`
-- Setup for 'Shatur/neovim-session-manager'
map('n', ' e', '<cmd>SessionManager load_session<cr>', { noremap = true })
-- End setup for 'Shatur/neovim-session-manager'
-- Setup for 'nvim-lualine/lualine.nvim'
require('lualine').setup{
	options = {
		theme = 'jellybeans',
		--[[
		section_separators = {
			left = '┫', -- ╡╣
			right = '┣', -- ╞╠
		}, 
		component_separators = {
			left = '╎', -- ┊
			right = '╎', -- ┊
		},
		]]
		-- section_separators = {'>>', '<<'},
		-- component_separators = {'>', '<'},
		-- section_separators = {
		-- 	left = '',
		-- 	right = ''
		-- },
		-- component_separators = {
		-- 	left = '',
		-- 	right = '',
		-- },
		-- section_separators = {
		-- 	left = ' ',
		-- 	right = ' ',
		-- },
		-- component_separators = {
		-- 	left = '>',
		-- 	right = '<',
		-- },
		disabled_filetypes = {'SidebarNvim'},
		icons_enabled = true
	},
	sections = {
		lualine_a = {{'mode', upper = true}},
		lualine_b = {{'branch', icon = ''}},
		lualine_c = {{'filename', file_status = true}},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress', {'diagnostics', sources = {'nvim_diagnostic', 'ale'}}},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	},
	extensions = {'fzf'}
}
-- End setup for 'nvim-lualine/lualine.nvim'
-- Setup for 'phaazon/hop.nvim'
local hop = require 'hop'
local fwd = require('hop.hint').HintDirection.AFTER_CURSOR
local bwd = require('hop.hint').HintDirection.BEFORE_CURSOR
hop.setup {
	keys = 'etovxqpdygfblzhckisuran',
}
map('n', ' f', hop.hint_char1, {})
map('n', ' w', hop.hint_words, {})
map('n', ' t', function()
	hop.hint_char1({ direction = fwd, hint_offset = -1 })
end, {})
map('n', ' T', function()
	hop.hint_char1({ direction = bwd, hint_offset = 1 })
end, {})
-- End setup for 'phaazon/hop.nvim'
-- Setup for 'christoomey/vim-tmux-navigator'
vim.g.tmux_navigator_save_on_switch = 0
vim.g.tmux_navigator_disable_when_zoomed = 1
-- End setup for 'christoomey/vim-tmux-navigator'
-- Setup for 'lewis6991/gitsigns.nvim'
require('gitsigns').setup {
	sign_priority = 6,
}
map('n', ' gs', require('gitsigns').toggle_signs, {})
-- End setup for 'lewis6991/gitsigns.nvim'
-- Setup for 'andythigpen/nvim-coverage'
local cov = require('coverage')
cov.setup {
	commands = true,
	signs = {
		covered = { hl = "@diff.plus", text = "║" },
		uncovered = { hl = "@diff.minus", text = "║" },
	},
}
map('n', ' cl', function() cov.load(true) end, {})
map('n', ' cL', function() cov.load_lcov(".lcov", true) end, {})
map('n', ' ct', cov.toggle, {})
-- End setup for 'andythigpen/nvim-coverage'

local autocmd = vim.api.nvim_create_autocmd

function augroup(name)
	return vim.api.nvim_create_augroup(name, {clear = true})
end

function au(group, event, pattern, cmd)
	if type(cmd) == "function" then
		autocmd(event, {group = group, pattern = pattern, callback = cmd})
	else
		autocmd(event, {group = group, pattern = pattern, command = cmd})
	end
end

-- font size keybindings
local font = "Fira Code"
local font_size = 12

function apply_font_size()
	vim.o.guifont = font .. ":h" .. tostring(font_size) .. ":w12"
end

function reset_font_size()
	font_size = 12
	vim.notify("font size reset")
	apply_font_size()
end

function inc_font_size()
	font_size = font_size + 1
	apply_font_size()
end

function dec_font_size()
	font_size = font_size - 1
	apply_font_size()
end

-- bind these keys in all modes
map({'n', 'v', 'o', 'l', 't'}, '<C-=>', inc_font_size, {})
map({'n', 'v', 'o', 'l', 't'}, '<C-->', dec_font_size, {})
map({'n', 'v', 'o', 'l', 't'}, '<C-S-+>', reset_font_size, {})

require('nvim-treesitter.configs').setup {
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
	},
	indent = {
		enable = { "bash" },
	},
}

vim.diagnostic.config {
	virtual_text = {
		prefix = "!",
	},
	underline = true,
	update_in_insert = true,
}

map('n', ' d', vim.diagnostic.goto_next, {})

au(augroup("indent"), "FileType", "python", function(args)
	vim.opt_local.cindent = false
	vim.opt_local.smartindent = false
	vim.opt_local.indentexpr = ""
end)

local auLsp = augroup("lsp")
au(auLsp, "LspAttach", "*", function(args)
	local bufmap = function(mode, lhs, rhs)
		vim.keymap.set(mode, lhs, rhs, {buffer = true})
	end
	bufmap('n', ' k', vim.lsp.buf.hover)
	bufmap('n', 'gd', vim.lsp.buf.definition)
	bufmap('n', 'gD', vim.lsp.buf.declaration)
	bufmap('n', 'gi', vim.lsp.buf.implementation)
	bufmap('n', 'go', vim.lsp.buf.type_definition)
	bufmap('n', 'gr', vim.lsp.buf.references)
	bufmap('n', ' s', vim.lsp.buf.signature_help)
	bufmap('i', '<C-c>', vim.lsp.buf.signature_help)
	bufmap('n', ' C', vim.lsp.buf.rename)
	bufmap('n', 'gl', vim.diagnostic.open_float)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if client ~= nil and client.name == 'ruff' then
		client.server_capabilities.hoverProvider = false
	end
end)

local auBin = augroup("Binary")
au(auBin, "BufReadPre", "*.dat", function()
	vim.b.bin = 1
end)
au(auBin, "BufReadPost", "*.dat", function()
	if vim.b.bin == 1 then
		cmd([[%!xxd]])
		vim.b.filetype = "xxd"
	end
end)
au(auBin, "BufWritePre", "*.dat", function()
	if vim.b.bin == 1 then
		cmd([[%!xxd -r]])
	end
end)
au(auBin, "BufWritePost", "*.dat", function()
	if vim.b.bin == 1 then
		cmd([[%!xxd]])
		vim.b.nomod = true
	end
end)

--[[
local auFormat = augroup("format")
au(auFormat, "BufWritePre", {"*.cs", "*.go", "go.work", "go.mod"}, function(ev)
	vim.lsp.buf.format({bufnr = ev.buf})
end)
au(auFormat, "BufWritePre", {"*.py"}, "Black")
]]

-- The Telegram codebase is full of stupidly long lines.
local auWrap = augroup("wrap")
au(auWrap, {"BufEnter", "BufFilePost"}, {"*.swift", "*.m "}, function()
	vim.b.wrap = true
end)

local auIndent = augroup("indentation")
function indent(width, expand, ...)
	if expand == nil then
		expand = false
	end
	au(auIndent, {"BufEnter", "BufFilePost"}, ..., function()
		vim.b.shiftwidth = width
		vim.b.tabstop = width
		vim.b.expandtab = expand
	end)
end

-- YAML is an abomination
indent(2, true, "*.yml", "*.yaml")

-- Here we compensate for people who are wrong.
indent(4, true, "*.hs", "*.cabal", "*.zig", "*.elm", "*.py")

--[[
-- LEAVE MY INDENTATION ALONE!
indent(4, false, "*")

-- Help mode needs large tabstops
indent(8, false, "*.txt")
]]

au(augroup("resize"), "VimResized", "*", "wincmd =")

au(augroup("filetypes"), {"BufRead", "BufNewFile"}, {"*.hcl", "*.hcldec"}, "set filetype=hcl")

-- cmd([[
-- 	augroup filetypes
-- 		au!
-- 		au BufRead,BufNewFile *.json set filetype=jsonc
-- 	augroup END
-- ]])
-- cmd([[
-- 	" for debugging syntax files
-- 	function! SynDebug()
-- 		for id in synstack(line("."), col("."))
-- 			echon synIDattr(id, "name")
-- 			echon " "
-- 		endfor
-- 		echo ""
-- 	endfunction
-- ]])

function get_nanoid()
	return vim.call("system", "nanoid -s 16 | tr -d '\n'")
end

function _G.insert_nanoid()
	local pos = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local nline = line:sub(0, pos + 1) .. get_nanoid() .. line:sub(pos + 2)
	vim.api.nvim_set_current_line(nline)
end
map('n', '<Leader>i', '<cmd>lua insert_nanoid()<cr>', { noremap = true})

function _G.ledger_insert_transaction_ids()
	local pos = vim.api.nvim_win_get_cursor(0)
	local lines = {"\t; ID: " .. get_nanoid(), "\t; RID: " .. get_nanoid()}
	-- get_cursor is 1-based index, set_lines is 0-based; added text will be
	-- on lines following cursor
	vim.api.nvim_buf_set_lines(0, pos[1], pos[1], false, lines)
	vim.api.nvim_win_set_cursor(0, {pos[1]+2, pos[2]})
end
map('n', '<Leader>t', '<cmd>lua ledger_insert_transaction_ids()<cr>', { noremap = true })

map('t', '<c-space>', '<C-\\>', { noremap = true })

-- g.ayucolor = "dark"
-- g.ayu_extended_palette = 1
--[=[
cmd([[
	function! MyColors() abort
		highlight Pmenu ctermfg=15 ctermbg=7 guibg=#050505
		highlight PmenuSel ctermfg=15 ctermbg=5 guibg=#151515
	endfunction

	augroup MyColors
		autocmd!
		autocmd ColorScheme * call MyColors()
	augroup END
]])
]=]
-- ]===]
