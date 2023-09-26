-- @install:$HOME/.config/nvim/init.lua:644:unix:*
--[===[ ]===]
local o, bo, wo, g = vim.o, vim.bo, vim.wo, vim.cmd, vim.g
local b, api = vim.b, vim.api, vim.api.nvim_set_keymap

cmd, map = vim.cmd, vim.keymap.set

home = os.getenv("HOME")
g.mapleader = ' '

function nnoremap(from, to)
    map('n', from, to, { noremap = true })
end

o.hidden = true
o.backup = false
o.writebackup = false
o.cmdheight = 2
o.updatetime = 300
o.signcolumn = 'number'
o.colorcolumn = '100'
o.number = true
o.termguicolors = true
wo.foldenable = false
o.foldlevelstart = 99
if not string.find(o.shortmess, 'c', 1, true) then
	o.shortmess = o.shortmess .. 'c'
end

g.man_hardwrap = 72

o.laststatus = 2
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = false
o.wrap = false

g.polyglot_disabled = { 'csv.plugin' }
g.ale_disable_lsp = 1
g.ale_sign_column_always = 1
g.ale_linters_ignore = { 'mcs', 'mcsc', 'csc' }
g.OmniSharp_server_use_net6 = 1

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

	-- Language support
	'sebdah/vim-delve', 'sheerun/vim-polyglot',

	-- Git
	--'tpope/vim-fugitive',
	'rhysd/git-messenger.vim',
	'junegunn/gv.vim',
	'jreybert/vimagit',
	{'idanarye/vim-merginal', dependencies = {'tpope/vim-fugitive'}},

	-- Status bar
	{ 'nvim-lualine/lualine.nvim', dependencies = {'kyazdani42/nvim-web-devicons'}},

	-- Navigation
	{ 'vimwiki/vimwiki', disable = true },
	{ 'phaazon/hop.nvim', branch = 'v2' },
	'christoomey/vim-tmux-navigator',
	'ds26gte/info.vim',

	-- Unknown
--	'andreshazard/vim-freemarker',
	'psf/black',
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
	},
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

cmd('colorscheme dracowizard')

-- cmd('colorscheme asmanian-blood')
-- colorscheme ayu
-- colorscheme afterglow
-- colorscheme sonokai

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
cmp.setup {
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
	mapping = {
		['<C-Space>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
			else
				cmp.complete({reason = 'manual'})
			end
		end, {"c", "i"}),
		['<C-n>'] = cmp.mapping({
			c = function()
				if cmp.visible() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				elseif luasnip.expandable_or_locally_jumpable() then
					luasnip.expand_or_jump()
				else
					vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
				end
			end,
			i = function(fallback)
				if cmp.visible() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				else
					fallback()
				end
			end,
		}),
		['<C-p>'] = cmp.mapping({
			c = function()
				if cmp.visible() then
					cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
				end
			end,
			i = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
				else
					fallback()
				end
			end,
		}),
		['<C-o>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.close()
			else
				fallback()
			end
		end, {"c", "i"}),
		['<C-u>'] = cmp.mapping.scroll_docs(-8),
		['<C-d>'] = cmp.mapping.scroll_docs(8),

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
local caps = require('cmp_nvim_lsp').default_capabilities()
local lsp = require 'lspconfig'
local servers = {
	'gopls', 'fsautocomplete', 'pyright', 'ocamllsp', 'rust_analyzer',
	'erlangls', 'phpactor', 'sourcekit', 'ols',
}
for _, s in ipairs(servers) do
	lsp[s].setup {capabilities = caps}
end
lsp.omnisharp.setup {
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
}
lsp.hls.setup {
	capabilities = caps,
	filetypes = { 'haskell', 'lhaskell', 'cabal' },
}
-- End setup for 'hrsh7th/nvim-cmp'
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

require('nvim-treesitter.configs').setup {
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
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
	bufmap('n', ' c', vim.lsp.buf.signature_help)
	bufmap('i', '<C-c>', vim.lsp.buf.signature_help)
	bufmap('n', ' c', vim.lsp.buf.rename)
	bufmap('n', 'gl', vim.diagnostic.open_float)
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

local auFormat = augroup("format")
au(auFormat, "BufWritePre", {"*.cs", "*.go", "go.work", "go.mod"}, function(ev)
	vim.lsp.buf.format({bufnr = ev.buf})
end)

--[[
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

-- LEAVE MY INDENTATION ALONE!
indent(4, false, "*")

-- YAML is an abomination
indent(2, true, "*.yml", "*.yaml")

-- Here we compensate for people who are wrong.
indent(4, true, "*.hs", "*.cabal", "*.zig", "*.elm")

-- Help mode needs large tabstops
indent(8, false, "*.txt")
]]

au(augroup("resize"), "VimResized", "*", "wincmd =")

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
