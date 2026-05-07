-- ============================================================================
-- KEYMAPS - All keybindings in one place
-- ============================================================================
-- This file contains ALL keymaps for easy reference and conflict detection.
-- Organized by category for easy scanning.

-- ============================================================================
-- GENERAL / EDITOR
-- ============================================================================

-- Clear search highlighting
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>h", ":noh<CR>")
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Edit/source config files
vim.keymap.set("n", "<leader>ev", ":tabe ~/.config/nvim/init.lua<CR>", { desc = "Edit init.lua" })
vim.keymap.set("n", "<leader>sv", ":luafile ~/.config/nvim/init.lua<CR>", { desc = "Source init.lua" })
vim.keymap.set("n", "<leader>ep", ":tabe ~/.config/nvim/lua/plugins/<CR>", { desc = "Edit plugins/" })

-- Lazy plugin manager
vim.keymap.set("n", "<leader>l", ":Lazy<CR>", { desc = "Open Lazy" })

-- Tab navigation
vim.keymap.set("n", "<leader><tab>h", ":tabp<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader><tab>l", ":tabn<CR>", { desc = "Next tab" })

-- Copy file path to clipboard
vim.keymap.set("n", "<leader>yp", ":let @+ = expand('%:p')<CR>", { desc = "Copy full path to clipboard" })

-- Terminal mode escape
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ============================================================================
-- WINDOW NAVIGATION
-- ============================================================================

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- ============================================================================
-- DIAGNOSTICS
-- ============================================================================

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

-- Diagnostic toggles
local function diagnostic_toggle(setting)
	return function()
		local new_config = not vim.diagnostic.config()[setting]
		vim.diagnostic.config({ [setting] = new_config })
	end
end
vim.keymap.set("n", "<leader>di", diagnostic_toggle("virtual_text"), { desc = "Toggle diagnostic virtual text" })
vim.keymap.set("n", "<leader>dl", diagnostic_toggle("virtual_lines"), { desc = "Toggle diagnostic virtual lines" })

-- ============================================================================
-- QUICKFIX / LOCATION LIST
-- ============================================================================

vim.keymap.set("n", "[q", ":cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[Q", ":cfirst<CR>", { desc = "First quickfix" })
vim.keymap.set("n", "]Q", ":clast<CR>", { desc = "Last quickfix" })
vim.keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix" })
vim.keymap.set("n", "<leader>qp", ":cexpr system('pbpaste')<CR>:copen<CR>", { desc = "Paste into quickfix" })

-- ============================================================================
-- FILE EXPLORER (Oil.nvim)
-- ============================================================================

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- ============================================================================
-- TREESITTER TEXT OBJECTS (Navigate by function/class)
-- ============================================================================

local ts_move_ok, ts_move = pcall(require, "nvim-treesitter-textobjects.move")
if ts_move_ok then
	vim.keymap.set({ "n", "x", "o" }, "]m", function()
		ts_move.goto_next_start("@function.outer", "textobjects")
	end, { desc = "Next function start" })
	vim.keymap.set({ "n", "x", "o" }, "]M", function()
		ts_move.goto_next_end("@function.outer", "textobjects")
	end, { desc = "Next function end" })
	vim.keymap.set({ "n", "x", "o" }, "]]", function()
		ts_move.goto_next_start("@class.outer", "textobjects")
	end, { desc = "Next class start" })
	vim.keymap.set({ "n", "x", "o" }, "][", function()
		ts_move.goto_next_end("@class.outer", "textobjects")
	end, { desc = "Next class end" })
	vim.keymap.set({ "n", "x", "o" }, "[m", function()
		ts_move.goto_previous_start("@function.outer", "textobjects")
	end, { desc = "Previous function start" })
	vim.keymap.set({ "n", "x", "o" }, "[M", function()
		ts_move.goto_previous_end("@function.outer", "textobjects")
	end, { desc = "Previous function end" })
	vim.keymap.set({ "n", "x", "o" }, "[[", function()
		ts_move.goto_previous_start("@class.outer", "textobjects")
	end, { desc = "Previous class start" })
	vim.keymap.set({ "n", "x", "o" }, "[]", function()
		ts_move.goto_previous_end("@class.outer", "textobjects")
	end, { desc = "Previous class end" })
end

-- ============================================================================
-- TELESCOPE (Fuzzy Finder)
-- ============================================================================

local telescope_ok, builtin = pcall(require, "telescope.builtin")
if telescope_ok then
	-- File finding
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
	vim.keymap.set("n", "<leader>f.", function()
		builtin.find_files({ hidden = true })
	end, { desc = "Find hidden files" })
	vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
	vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "Resume last picker" })

	-- File type specific finders
	local function find_by_ext(glob)
		return function()
			builtin.find_files({ find_command = { "rg", "--files", "--glob", glob } })
		end
	end
	vim.keymap.set("n", "<leader>fp", find_by_ext("*py"), { desc = "Find Python files" })
	vim.keymap.set("n", "<leader>fr", find_by_ext("*rs"), { desc = "Find Rust files" })
	vim.keymap.set("n", "<leader>fg", find_by_ext("*go"), { desc = "Find Go files" })
	vim.keymap.set("n", "<leader>fm", find_by_ext("*md"), { desc = "Find Markdown files" })

	-- Text search
	vim.keymap.set("n", "<leader>ft", builtin.live_grep, { desc = "Live grep" })
	vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
	vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })

	-- Navigation helpers
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
	vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Search keymaps" })

	-- LSP via Telescope
	vim.keymap.set("n", "<leader>cd", builtin.lsp_document_symbols, { desc = "Document symbols" })
	vim.keymap.set("n", "<leader>cw", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
	vim.keymap.set("n", "<leader>cs", builtin.lsp_dynamic_workspace_symbols, { desc = "Dynamic workspace symbols" })
	vim.keymap.set("n", "grr", builtin.lsp_references, { desc = "LSP references" })

	-- Diagnostics via Telescope
	vim.keymap.set("n", "<leader>dd", builtin.diagnostics, { desc = "Buffer diagnostics" })
end

-- ============================================================================
-- LSP (Language Server Protocol)
-- ============================================================================

-- These keymaps are set when LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("user-lsp-keymaps", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Jump to definition/implementation/type
		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gI", vim.lsp.buf.implementation, "Go to implementation")
		map("gy", vim.lsp.buf.type_definition, "Go to type definition")
		map("<C-]>", vim.lsp.buf.definition, "Go to definition (vim-style)")

		-- Rename and refactor
		map("grn", vim.lsp.buf.rename, "Rename symbol")
		map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })

		-- Declaration (e.g., C header files)
		map("grD", vim.lsp.buf.declaration, "Go to declaration")

		-- Inlay hints toggle
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/inlayHint", event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "Toggle inlay hints")
		end
	end,
})

-- Auto-import (nvim-lspimport)
vim.keymap.set("n", "<leader>ai", function()
	local ok, lspimport = pcall(require, "lspimport")
	if ok then
		lspimport.import()
	end
end, { desc = "Auto import symbol" })

-- ============================================================================
-- TROUBLE (Diagnostics UI)
-- ============================================================================

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list (Trouble)" })

-- ============================================================================
-- GIT
-- ============================================================================

vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen main<cr>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>go", "<cmd>GBrowse<cr>", { desc = "Git open" })
vim.keymap.set("v", "<leader>go", ":'<,'>GBrowse<cr>", { desc = "Git open (selected lines)" })
vim.keymap.set("n", "<leader>gi", function()
	require("config.github").open_prs()
end, { desc = "PRs (current repo)" })
vim.keymap.set("n", "<leader>gg", function()
	require("config.github").org_prs()
end, { desc = "PRs ($GH_ORG)" })
vim.keymap.set("n", "<leader>ll", function()
	require("config.linear").browse_projects()
end, { desc = "Linear project issues" })
vim.keymap.set("n", "<leader>lc", function()
	require("config.linear").create_issue()
end, { desc = "Create Linear issue ($LINEAR_DEFAULT_TEAM)" })

-- ============================================================================
-- TESTING (Neotest)
-- ============================================================================

vim.keymap.set("n", "<leader>tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })

vim.keymap.set("n", "<leader>tt", function()
	require("neotest").run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tr", function()
	require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })

-- ============================================================================
-- NOTES (Obsidian)
-- ============================================================================

vim.keymap.set("n", "<leader>oi", "<cmd>edit ~/notes/index.md<cr>", { desc = "Open notes index" })
vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", { desc = "Obsidian quick switcher" })
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<cr>", { desc = "New note" })
vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<cr>", { desc = "Search notes" })
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<cr>", { desc = "Today's daily note" })
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<cr>", { desc = "Show backlinks" })
vim.keymap.set("n", "<leader>od", "<cmd>ObsidianDailies<cr>", { desc = "Show Dailies" })

local function open_most_recent(dir)
	return function()
		local files = vim.fn.glob(vim.fn.expand("~/notes/" .. dir .. "/*.md"), false, true)
		if #files == 0 then
			vim.notify("No " .. dir .. " notes found", vim.log.levels.WARN)
			return
		end
		table.sort(files)
		vim.cmd("edit " .. vim.fn.fnameescape(files[#files]))
	end
end
vim.keymap.set("n", "<leader>ow", open_most_recent("weekly"), { desc = "Most recent weekly note" })
vim.keymap.set("n", "<leader>om", open_most_recent("monthly"), { desc = "Most recent monthly note" })
