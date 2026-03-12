-- Autocommands
-- Automatic commands triggered by events

-- Show line numbers in Telescope preview windows
vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function(args)
		vim.wo.number = true
	end,
})
