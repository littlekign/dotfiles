-- Neovim Configuration
-- Entry point that loads all configuration modules
--
-- Structure:
--   lua/config/
--     ├── options.lua   - Vim settings (vim.opt)
--     ├── keymaps.lua   - General keybindings
--     ├── autocmds.lua  - Autocommands
--     └── lazy.lua      - Plugin manager setup
--
--   lua/plugins/
--     ├── ui.lua         - Color schemes
--     ├── editor.lua     - Oil, treesitter, formatting
--     ├── telescope.lua  - Fuzzy finder
--     ├── lsp.lua        - Language servers
--     ├── completion.lua - Autocomplete
--     ├── trouble.lua    - Diagnostic UI
--     ├── git.lua        - Git integration
--     ├── test.lua       - Test runner
--     └── notes.lua      - Note taking

-- Load configuration
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")

vim.cmd.colorscheme("monokai-pro")

-- Diff: no full-line background, just gutter signs + inline text highlights
vim.api.nvim_set_hl(0, "DiffAdd", { bg = "none" })
vim.api.nvim_set_hl(0, "DiffDelete", { bg = "none" })
vim.api.nvim_set_hl(0, "DiffChange", { bg = "none" })
