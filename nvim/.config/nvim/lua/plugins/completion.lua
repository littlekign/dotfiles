-- Completion
-- Purpose: Autocompletion and snippets
-- Plugins:
--   - hrsh7th/nvim-cmp - Completion engine
--   - L3MON4D3/LuaSnip - Snippet engine
--   - cmp-nvim-lsp - LSP completion source
--   - cmp-path - File path completion

return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.register_source("github", require("config.cmp_github").new())
			cmp.register_source("linear", require("config.cmp_linear").new())

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				formatting = {
					format = function(entry, vim_item)
						if entry.source.name == "github" then
							local item = entry:get_completion_item()
							local state = item.data and item.data.state
							if state then
								local hl = ({ OPEN = "DiagnosticOk", MERGED = "Function", CLOSED = "DiagnosticError" })[state]
								vim_item.kind = state == "MERGED" and "Merged" or state == "CLOSED" and "Closed" or "Open"
								vim_item.kind_hl_group = hl
							end
						elseif entry.source.name == "linear" then
							local item = entry:get_completion_item()
							local state_type = item.data and item.data.state_type
							if state_type then
								local hl = ({
									started = "DiagnosticOk",
									completed = "Function",
									cancelled = "Comment",
									backlog = "Comment",
									unstarted = "DiagnosticWarn",
								})[state_type] or "Comment"
								vim_item.kind = item.data.state_name or state_type
								vim_item.kind_hl_group = hl
							end
						end
						return vim_item
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
					["<C-o>"] = cmp.mapping(function()
						local entry = cmp.get_selected_entry()
						if entry then
							local item = entry:get_completion_item()
							local url = item.data and item.data.url
							if url then
								cmp.close()
								vim.fn.system({ "open", url })
							end
						end
					end, { "i" }),
				}),
				sources = {
					{
						name = "lazydev",
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "github" },
					{ name = "linear" },
				},
			})
		end,
	},
}
