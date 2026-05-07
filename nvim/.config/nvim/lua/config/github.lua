-- GitHub PR search via Telescope + gh CLI

local M = {}

local function gh_org()
	local org = vim.env.GH_ORG
	if not org or org == "" then
		vim.notify("$GH_ORG is not set; cannot browse org repos.", vim.log.levels.WARN)
		return nil
	end
	return org
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local previewers = require("telescope.previewers")

-- Show a PR picker for a given repo and state, with <C-s> to toggle open/closed
local function pick_prs(full_repo, state)
	local result = vim.fn.system({
		"gh", "pr", "list", "--repo", full_repo,
		"--state", state, "--json", "number,title,author,body", "--limit", "100",
	})
	local ok, prs = pcall(vim.json.decode, result)
	if not ok then prs = {} end
	if not prs then prs = {} end

	pickers
		.new({}, {
			prompt_title = state .. " PRs in " .. full_repo,
			finder = finders.new_table({
				results = prs,
				entry_maker = function(entry)
					local author = entry.author and entry.author.login or ""
					local displayer = entry_display.create({
						separator = " ",
						items = {
							{ width = #tostring(entry.number) + 1 },
							{ remaining = true },
							{ width = #author + 2 },
						},
					})
					local ordinal = string.format("#%d %s %s", entry.number, entry.title, author)
					return {
						value = entry,
						ordinal = ordinal,
						display = function()
							return displayer({
								{ "#" .. entry.number, "Number" },
								{ entry.title },
								{ "(" .. author .. ")", "Comment" },
							})
						end,
					}
				end,
			}),
			previewer = previewers.new_buffer_previewer({
				title = "PR Description",
				define_preview = function(self, entry)
					local body = entry.value.body or ""
					local lines = vim.split(body, "\n")
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					vim.bo[self.state.bufnr].filetype = "markdown"
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				-- <CR> inserts full URL
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					local url = string.format("https://github.com/%s/pull/%d", full_repo, sel.value.number)
					vim.api.nvim_put({ url }, "", true, true)
				end)
				-- <C-t> inserts owner/repo#123 shorthand
				actions.select_tab:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					local link = string.format("%s#%d", full_repo, sel.value.number)
					vim.api.nvim_put({ link }, "", true, true)
				end)
				-- <C-o> opens in browser
				map({ "i", "n" }, "<C-o>", function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					local url = string.format("https://github.com/%s/pull/%d", full_repo, sel.value.number)
					vim.fn.system({ "open", url })
				end)
				-- <C-s> toggles between open/closed
				map({ "i", "n" }, "<C-s>", function()
					actions.close(prompt_bufnr)
					local next_state = state == "open" and "closed" or "open"
					pick_prs(full_repo, next_state)
				end)
				return true
			end,
		})
		:find()
end

-- Pick a repo from $GH_ORG, then show PRs
local function pick_org_repo(state)
	local org = gh_org()
	if not org then return end

	local result = vim.fn.system({
		"gh", "repo", "list", org,
		"--json", "name", "--limit", "200",
	})
	local ok, repos = pcall(vim.json.decode, result)
	if not ok or not repos or #repos == 0 then
		vim.notify("Could not list " .. org .. " repos", vim.log.levels.ERROR)
		return
	end

	pickers
		.new({}, {
			prompt_title = org .. " repos",
			finder = finders.new_table({
				results = repos,
				entry_maker = function(entry)
					return { value = entry.name, display = entry.name, ordinal = entry.name }
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					pick_prs(org .. "/" .. sel.value, state)
				end)
				return true
			end,
		})
		:find()
end

-- Detect current repo or bail
local function current_repo()
	local repo = vim.fn.system("gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null"):gsub("%s+$", "")
	if vim.v.shell_error ~= 0 or repo == "" then
		vim.notify("Not in a GitHub repo", vim.log.levels.WARN)
		return nil
	end
	return repo
end

-- <leader>gi - open PRs for current repo
function M.open_prs()
	local repo = current_repo()
	if repo then pick_prs(repo, "open") end
end

-- <leader>gg - pick a repo from $GH_ORG, then browse PRs
function M.org_prs()
	pick_org_repo("open")
end

return M
