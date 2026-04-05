-- LSP Configuration
-- Purpose: Language Server Protocol setup for code intelligence
-- Plugins:
--   - neovim/nvim-lspconfig - LSP client configurations
--   - mason.nvim - LSP server installer
--   - mason-lspconfig.nvim - Bridge between mason and lspconfig
--   - mason-tool-installer.nvim - Auto-install LSP servers
--   - fidget.nvim - LSP progress UI
--   - lazydev.nvim - Lua/Neovim LSP enhancements
--   - stevanmilic/nvim-lspimport - Auto-import symbols

return {
	-- Lua development setup
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },

	-- Auto-import support (keymaps in config/keymaps.lua)
	"stevanmilic/nvim-lspimport",

	-- LSP progress indicator
	{ "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

	-- Main LSP configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			{ "mason-org/mason-lspconfig.nvim", opts = {} },
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			-- LSP keymaps are configured in config/keymaps.lua via LspAttach autocmd
			-- This keeps all keymaps centralized and easy to reference

			-- Highlight references under cursor when LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-highlight-references", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end
				end,
			})

			-- Get capabilities from completion plugin
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Language servers to install and configure
			local servers = {
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								diagnosticSeverityOverrides = {
									reportUnusedCallResult = "none",
								},
							},
						},
					},
				},
				ruff = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								globals = {
									"vim",
									"require",
								},
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
							},
						},
					},
				},
			}

			-- Ensure servers are installed
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"lua_ls",
				"stylua",
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			-- Configure and enable each server
			for name, server in pairs(servers) do
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end

			-- Special Lua config for Neovim development
			vim.lsp.config("lua_ls", {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if
							path ~= vim.fn.stdpath("config")
							and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
						then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
						runtime = {
							version = "LuaJIT",
							path = { "lua/?.lua", "lua/?/init.lua" },
						},
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
					})
				end,
				settings = {
					Lua = {},
				},
			})
			vim.lsp.enable("lua_ls")
		end,
	},
}
