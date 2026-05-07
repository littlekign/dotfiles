-- nvim-cmp source for GitHub PR links
-- Trigger: type gh:// to complete a repo from $GH_ORG,
-- then / to complete a PR. Accepting inserts [PR title](url).

local source = {}

local function gh_org()
	local org = vim.env.GH_ORG
	if not org or org == "" then
		vim.notify("$GH_ORG is not set; cannot list repos for completion.", vim.log.levels.WARN)
		return nil
	end
	return org
end

local REPO_CACHE_TTL = 300 -- 5 minutes; repo list rarely changes
local PR_CACHE_TTL = 10 -- seconds
local repo_data = nil
local repo_data_time = 0
local pr_data = {}
local pr_data_time = {}

local function cache_valid(ts, ttl)
	return ts and (os.time() - ts) < ttl
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

local function build_repo_items(repos, gh_start, row)
	local items = {}
	for _, r in ipairs(repos) do
		table.insert(items, {
			label = r.name,
			filterText = "gh://" .. r.name,
			textEdit = {
				newText = "gh://" .. r.name .. "/",
				range = {
					start = { line = row, character = gh_start },
					["end"] = { line = row, character = gh_start + 999 },
				},
			},
		})
	end
	return items
end

local function build_pr_items(prs, repo, gh_start, row)
	local items = {}
	for _, pr in ipairs(prs) do
		local author = pr.author and pr.author.login or ""
		local state = pr.state or "OPEN"
		table.insert(items, {
			label = string.format("#%d %s (%s)", pr.number, pr.title, author),
			kind = 1,
			sortText = string.format("%010d", 999999999 - pr.number),
			data = { state = state, url = pr.url },
			filterText = "gh://" .. repo .. "/" .. string.format("%d %s %s", pr.number, pr.title, author),
			textEdit = {
				newText = string.format("[%s](%s)", pr.title, pr.url),
				range = {
					start = { line = row, character = gh_start },
					["end"] = { line = row, character = gh_start + 999 },
				},
			},
			documentation = pr.url,
		})
	end
	return items
end

source.complete = function(self, params, callback)
	local line = params.context.cursor_before_line
	local prefix = line:match("gh://(.*)$")
	if not prefix then
		callback({ items = {}, isIncomplete = false })
		return
	end

	local gh_start = #line - #prefix - 5
	local row = params.context.cursor.row - 1

	local repo, _ = prefix:match("^([^/]+)/(.*)$")

	if repo then
		local org = gh_org()
		if not org then
			callback({ items = {}, isIncomplete = false })
			return
		end
		local full_repo = org .. "/" .. repo

		if pr_data[full_repo] and cache_valid(pr_data_time[full_repo], PR_CACHE_TTL) then
			callback({ items = build_pr_items(pr_data[full_repo], repo, gh_start, row), isIncomplete = false })
			return
		end

		vim.fn.jobstart({
			"gh", "pr", "list", "--repo", full_repo,
			"--state", "all", "--json", "number,title,author,url,state", "--limit", "100",
		}, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				local text = table.concat(data, "")
				local ok, prs = pcall(vim.json.decode, text)
				if not ok or not prs then
					callback({ items = {}, isIncomplete = false })
					return
				end
				pr_data[full_repo] = prs
				pr_data_time[full_repo] = os.time()
				callback({ items = build_pr_items(prs, repo, gh_start, row), isIncomplete = false })
			end,
		})
	else
		if repo_data and cache_valid(repo_data_time, REPO_CACHE_TTL) then
			callback({ items = build_repo_items(repo_data, gh_start, row), isIncomplete = false })
			return
		end

		local org = gh_org()
		if not org then
			callback({ items = {}, isIncomplete = false })
			return
		end
		vim.fn.jobstart({
			"gh", "repo", "list", org,
			"--json", "name", "--limit", "200",
		}, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				local text = table.concat(data, "")
				local ok, repos = pcall(vim.json.decode, text)
				if not ok or not repos then
					callback({ items = {}, isIncomplete = false })
					return
				end
				repo_data = repos
				repo_data_time = os.time()
				callback({ items = build_repo_items(repos, gh_start, row), isIncomplete = false })
			end,
		})
	end
end

return source
