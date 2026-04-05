-- Autocommands
-- Automatic commands triggered by events

-- Track LSP readiness per buffer
-- Marks a client as "loading" on attach, then "ready" once diagnostics arrive
_G._lsp_loading = {}
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client then
			_G._lsp_loading[client.name] = true
		end
	end,
})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		_G._lsp_loading = {}
	end,
})

-- Show line numbers in Telescope preview windows
vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function(_)
		vim.wo.number = true
	end,
})
