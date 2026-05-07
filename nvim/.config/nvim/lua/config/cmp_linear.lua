-- nvim-cmp source for Linear issue links
-- Trigger: type lin:// to complete a team,
-- then / to complete an issue. Accepting inserts [TEAM-123 title](url).

local source = {}

local CACHE_TTL = 10 -- seconds
local team_data = nil
local team_data_time = 0
local issue_data = {}
local issue_data_time = {}

local function cache_valid(ts)
	return ts and (os.time() - ts) < CACHE_TTL
end

local _api_key_cache = nil
local function api_key()
	if _api_key_cache then return _api_key_cache end
	local key = vim.fn.system("security find-generic-password -a \"$(whoami)\" -s linear-api-key -w 2>/dev/null"):gsub("%s+$", "")
	if key ~= "" then _api_key_cache = key end
	return key
end

local function linear_query(query, variables, cb)
	local key = api_key()
	if key == "" then
		cb(nil)
		return
	end

	local payload = { query = query }
	if variables and next(variables) then
		payload.variables = variables
	end
	local body = vim.json.encode(payload)

	vim.fn.jobstart({
		"curl", "-s", "-X", "POST", "https://api.linear.app/graphql",
		"-H", "Authorization: " .. key,
		"-H", "Content-Type: application/json",
		"-d", body,
	}, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			local text = table.concat(data, "")
			vim.schedule(function()
				local ok, result = pcall(vim.json.decode, text)
				if ok and result and result.data then
					cb(result.data)
				else
					cb(nil)
				end
			end)
		end,
	})
end

source.new = function()
	return setmetatable({}, { __index = source })
end

source.get_trigger_characters = function()
	return { ":", "/" }
end

source.is_available = function()
	return true
end

local function build_team_items(teams, ln_start, row)
	local items = {}
	for _, t in ipairs(teams) do
		table.insert(items, {
			label = t.key .. " — " .. t.name,
			filterText = "lin://" .. t.key .. " " .. t.name,
			textEdit = {
				newText = "lin://" .. t.key .. "/",
				range = {
					start = { line = row, character = ln_start },
					["end"] = { line = row, character = ln_start + 999 },
				},
			},
		})
	end
	return items
end

local function build_issue_items(issues, team_key, ln_start, row)
	local items = {}
	for _, issue in ipairs(issues) do
		local id = issue.identifier or (team_key .. "-" .. issue.number)
		local assignee = (type(issue.assignee) == "table" and issue.assignee.name) or ""
		local state_name = (type(issue.state) == "table" and issue.state.name) or ""
		local state_type = (type(issue.state) == "table" and issue.state.type) or ""

		table.insert(items, {
			label = string.format("%s %s (%s)", id, issue.title, assignee),
			kind = 1,
			sortText = string.format("%010d", 999999999 - issue.number),
			data = { state_type = state_type, state_name = state_name, url = issue.url },
			filterText = "lin://" .. team_key .. "/" .. string.format("%s %d %s %s", id, issue.number, issue.title, assignee),
			textEdit = {
				newText = string.format("[%s %s](%s)", id, issue.title, issue.url),
				range = {
					start = { line = row, character = ln_start },
					["end"] = { line = row, character = ln_start + 999 },
				},
			},
			documentation = string.format("%s\nState: %s\nAssignee: %s", issue.url, state_name, assignee),
		})
	end
	return items
end

source.complete = function(self, params, callback)
	local line = params.context.cursor_before_line
	local prefix = line:match("lin://(.*)$")
	if not prefix then
		callback({ items = {}, isIncomplete = false })
		return
	end

	local ln_start = #line - #prefix - 6 -- 6 = #"lin://"
	local row = params.context.cursor.row - 1

	local team_key, _ = prefix:match("^([^/]+)/(.*)$")

	if team_key then
		-- After team/ — complete issues
		if issue_data[team_key] and cache_valid(issue_data_time[team_key]) then
			callback({ items = build_issue_items(issue_data[team_key], team_key, ln_start, row), isIncomplete = true })
			return
		end

		local query = [[
			query($teamKey: String!) {
				issues(
					filter: { team: { key: { eq: $teamKey } } }
					orderBy: updatedAt
					first: 100
				) {
					nodes {
						number
						identifier
						title
						url
						state { name type }
						assignee { name }
					}
				}
			}
		]]

		linear_query(query, { teamKey = team_key }, function(data)
			if not data or not data.issues then
				callback({ items = {}, isIncomplete = true })
				return
			end
			local issues = data.issues.nodes
			issue_data[team_key] = issues
			issue_data_time[team_key] = os.time()
			callback({ items = build_issue_items(issues, team_key, ln_start, row), isIncomplete = true })
		end)
	else
		-- Before / — complete team keys
		if team_data and cache_valid(team_data_time) then
			callback({ items = build_team_items(team_data, ln_start, row), isIncomplete = true })
			return
		end

		linear_query("{ teams { nodes { id name key } } }", nil, function(data)
			if not data or not data.teams then
				callback({ items = {}, isIncomplete = true })
				return
			end
			team_data = data.teams.nodes
			team_data_time = os.time()
			callback({ items = build_team_items(team_data, ln_start, row), isIncomplete = true })
		end)
	end
end

return source
