local M = {}

M.default_config = {
	plugin_manager = "",
	star_on_install = true,
	ignore_repos = {},
	ignore_authors = {},
}

---@param options table
M.get_config = function(options)
	return vim.tbl_deep_extend("force", M.default_config, options or {})
end

---@param github GithubApi
---@param plugins Plugin[]
---@param index number
---@param stats { starred: number, ignored: number, already_starred: number }
---@param called_from_command boolean
local function star_interval(github, plugins, index, stats, called_from_command)
	if index > #plugins then
		if stats.starred > 0 or called_from_command then
			local message = "Starred " .. stats.starred .. " plugins"

			if stats.already_starred > 0 then
				message = message .. " - " .. stats.already_starred .. " already starred"
			end

			if stats.ignored > 0 then
				message = message .. " - " .. stats.ignored .. " ignored"
			end

			vim.notify(message, vim.log.levels.INFO)
		end
		return
	end

	-- Check if plugin is ignored
	if vim.tbl_contains(M.config.ignore_repos, plugins[index].handle) then
		stats.ignored = stats.ignored + 1
		star_interval(github, plugins, index + 1, stats, called_from_command)
		return
	end

	-- Check if author is ignored
	if vim.tbl_contains(M.config.ignore_authors, plugins[index].author) then
		stats.ignored = stats.ignored + 1
		star_interval(github, plugins, index + 1, stats, called_from_command)
		return
	end

	-- Check if plugin is already starred
	local data = require("thanks.utils").read_persisted_data()
	local starred_plugins = data.starred_plugins or {}
	if vim.tbl_contains(starred_plugins, plugins[index].handle) then
		stats.already_starred = stats.already_starred + 1
		star_interval(github, plugins, index + 1, stats, called_from_command)
		return
	end

	stats.starred = stats.starred + 1
	github:star(plugins[index])

	-- Save the starred plugin
	table.insert(starred_plugins, plugins[index].handle)
	data.starred_plugins = starred_plugins
	require("thanks.utils").persist_data(data)

	vim.defer_fn(function()
		vim.notify("Successfully starred " .. plugins[index].name, vim.log.levels.INFO)

		star_interval(github, plugins, index + 1, stats, called_from_command)
	end, 500)
end

---@param options table
M.setup = function(options)
	-- Set the options
	M.config = M.get_config(options)

	if M.config.plugin_manager ~= "lazy" then
		vim.notify("Only lazy plugin manager is supported at the moment", vim.log.levels.ERROR)
		return
	end

	vim.api.nvim_create_user_command("ThanksGithubAuth", function()
		local github = require("thanks.github_api"):new()
		github:authenticate()
	end, {})

	vim.api.nvim_create_user_command("ThanksAll", function()
		M.star_all(true)
	end, {})

	-- Log out
	vim.api.nvim_create_user_command("ThanksGithubLogout", function()
		local github = require("thanks.github_api"):new()
		github:logout()
	end, {})

	-- Delete starred plugins cache
	vim.api.nvim_create_user_command("ThanksClearCache", function()
		local data = require("thanks.utils").read_persisted_data()
		data.starred_plugins = {}
		require("thanks.utils").persist_data(data)
		vim.notify("Cleared starred plugins cache", vim.log.levels.INFO)
	end, {})

	if M.config.star_on_install then
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyInstall",
			once = true,
			callback = function()
				M.star_all(false)
			end,
		})
	end
end

---@param called_from_command boolean
M.star_all = function(called_from_command)
	local plugins = require("thanks.utils").get_plugins(M.config.plugin_manager)
	local github = require("thanks.github_api"):new()

	local stats = {
		starred = 0,
		ignored = 0,
		already_starred = 0,
	}
	if github:get_auth() then
		star_interval(github, plugins, 1, stats, called_from_command)
	else
		vim.notify("Please authenticate with Github first using :ThanksGithubAuth", vim.log.levels.INFO)
	end
end

return M
