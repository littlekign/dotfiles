-- Linear issue search via Telescope

local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local previewers = require("telescope.previewers")

local _api_key_cache = nil
local function api_key()
	if _api_key_cache then return _api_key_cache end
	local key = vim.fn.system("security find-generic-password -a \"$(whoami)\" -s linear-api-key -w 2>/dev/null"):gsub("%s+$", "")
	if key ~= "" then _api_key_cache = key end
	return key
end

local function linear_query(query, variables)
	local payload = { query = query }
	if variables and next(variables) then
		payload.variables = variables
	end
	local body = vim.json.encode(payload)
	local result = vim.fn.system({
		"curl", "-s", "-X", "POST", "https://api.linear.app/graphql",
		"-H", "Authorization: " .. api_key(),
		"-H", "Content-Type: application/json",
		"-d", body,
	})
	local ok, data = pcall(vim.json.decode, result)
	if ok and data and data.data then
		return data.data
	end
	return nil
end

local state_hl = {
	started = "DiagnosticOk",
	completed = "Function",
	cancelled = "Comment",
	backlog = "Comment",
	unstarted = "DiagnosticWarn",
	triage = "DiagnosticWarn",
}

local function pick_issues(project_id, project_name)
	local data = linear_query([[
		query($projectId: String!) {
			project(id: $projectId) {
				issues(first: 100, orderBy: updatedAt) {
					nodes {
						identifier
						number
						title
						url
						description
						state { name type }
						assignee { name }
					}
				}
			}
		}
	]], { projectId = project_id })

	if not data or not data.project then
		vim.notify("No issues found in " .. project_name, vim.log.levels.WARN)
		return
	end

	local issues = data.project.issues.nodes

	pickers
		.new({}, {
			prompt_title = "Issues in " .. project_name,
			finder = finders.new_table({
				results = issues,
				entry_maker = function(entry)
					local assignee = (type(entry.assignee) == "table" and entry.assignee.name) or ""
					local state_name = (type(entry.state) == "table" and entry.state.name) or ""
					local state_type = (type(entry.state) == "table" and entry.state.type) or ""
					local id = entry.identifier or ""

					local displayer = entry_display.create({
						separator = " ",
						items = {
							{ width = #id },
							{ width = #state_name },
							{ remaining = true },
							{ width = #assignee + 2 },
						},
					})

					return {
						value = entry,
						ordinal = string.format("%s %s %s %s", id, entry.title, assignee, state_name),
						display = function()
							return displayer({
								{ id, "Number" },
								{ state_name, state_hl[state_type] or "Comment" },
								{ entry.title },
								{ "(" .. assignee .. ")", "Comment" },
							})
						end,
					}
				end,
			}),
			previewer = previewers.new_buffer_previewer({
				title = "Issue Description",
				define_preview = function(self, entry)
					local desc = entry.value.description or ""
					local lines = vim.split(desc, "\n")
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					vim.bo[self.state.bufnr].filetype = "markdown"
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					local issue = sel.value
					local link = string.format("[%s %s](%s)", issue.identifier, issue.title, issue.url)
					vim.api.nvim_put({ link }, "", true, true)
				end)
				actions.select_tab:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					local link = sel.value.identifier
					vim.api.nvim_put({ link }, "", true, true)
				end)
				map({ "i", "n" }, "<C-o>", function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					vim.fn.system({ "open", "-a", "Linear", sel.value.url })
				end)
				return true
			end,
		})
		:find()
end

function M.browse_projects()
	local data = linear_query("{ projects(first: 100, orderBy: updatedAt) { nodes { id name state } } }")

	if not data or not data.projects then
		vim.notify("Could not list Linear projects", vim.log.levels.ERROR)
		return
	end

	local projects = data.projects.nodes

	pickers
		.new({}, {
			prompt_title = "Linear Projects",
			finder = finders.new_table({
				results = projects,
				entry_maker = function(entry)
					local display = string.format("%s (%s)", entry.name, entry.state)
					return { value = entry, display = display, ordinal = display }
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					pick_issues(sel.value.id, sel.value.name)
				end)
				return true
			end,
		})
		:find()
end

function M.create_issue()
	local workspace = vim.env.LINEAR_WORKSPACE
	local team = vim.env.LINEAR_DEFAULT_TEAM
	if not workspace or workspace == "" or not team or team == "" then
		vim.notify("Set $LINEAR_WORKSPACE and $LINEAR_DEFAULT_TEAM in your shell.", vim.log.levels.WARN)
		return
	end
	local url = string.format("https://linear.app/%s/team/%s/new", workspace, team)
	vim.fn.system({ "open", "-a", "Linear", url })
end

return M
