local M = {}

M.default_config = {
	plugin_manager = "",
	star_on_startup = false,
	star_on_install = true,
	unstar_on_uninstall = false,
	ignore_repos = {},
	ignore_authors = {},
}

---@param options table
M.get_config = function(options)
	return vim.tbl_deep_extend("force", M.default_config, options or {})
end

-- Stars or unstars a plugin
-- To go easy on the Github API rate limit, we star/unstar plugins in intervals
-- This function is called recursively until all plugins are starred/unstarred
-- Having real async functions would help for testing, but this is good enough for now
-- Will be refactored when I'm less dumb
---@param github GithubApi
---@param to_star Plugin[]
---@param to_unstar string[]
---@param data { starred_plugins: string[] }
---@param index number
---@param stats { starred: number, unstarred: number, ignored: number, already_starred: number }
---@param called_from_command boolean
local function star_interval(github, to_star, to_unstar, data, index, stats, called_from_command)
	if index > #to_star + #to_unstar then
		if stats.starred > 0 or called_from_command then
			local message = "Starred " .. stats.starred .. " plugins"

			if stats.already_starred > 0 then
				message = message .. " - " .. stats.already_starred .. " already starred"
			end

			if stats.unstarred > 0 then
				message = message .. " - " .. stats.unstarred .. " unstarred"
			end

			if stats.ignored > 0 then
				message = message .. " - " .. stats.ignored .. " ignored"
			end

			vim.notify(message, vim.log.levels.INFO)
		end
		return
	end

	local plugin_handle = nil
	local plugin_author = nil
	if index <= #to_star then
		-- Star
		plugin_handle = to_star[index].handle
		plugin_author = to_star[index].author
	else
		-- Unstar
		plugin_handle = to_unstar[index - #to_star]
		local parts = vim.split(plugin_handle, "/")
		plugin_author = parts[1]
	end

	if not plugin_handle then
		star_interval(github, to_star, to_unstar, data, index + 1, stats, called_from_command)
		return
	end

	-- Check if plugin is ignored
	if vim.tbl_contains(M.config.ignore_repos, plugin_handle) then
		stats.ignored = stats.ignored + 1
		star_interval(github, to_star, to_unstar, data, index + 1, stats, called_from_command)
		return
	end

	-- Check if author is ignored
	if vim.tbl_contains(M.config.ignore_authors, plugin_author) then
		stats.ignored = stats.ignored + 1
		star_interval(github, to_star, to_unstar, data, index + 1, stats, called_from_command)
		return
	end

	local starred_plugins = data.starred_plugins or {}
	if index <= #to_star then
		stats.starred = stats.starred + 1
		github:star(plugin_handle)

		-- Save the starred plugin to disk
		table.insert(starred_plugins, plugin_handle)
		data.starred_plugins = starred_plugins
	else
		stats.unstarred = stats.unstarred + 1
		github:star(plugin_handle, false)

		-- Remove the unstarred plugin from disk
		for i, starred_plugin in ipairs(starred_plugins) do
			if starred_plugin == plugin_handle then
				table.remove(starred_plugins, i)
				break
			end
		end
	end
	require("thanks.utils").persist_data(data)

	vim.defer_fn(function()
		vim.notify(
			"Successfully " .. (index > #to_star and "unstarred " or "starred ") .. plugin_handle,
			vim.log.levels.INFO
		)

		star_interval(github, to_star, to_unstar, data, index + 1, stats, called_from_command)
	end, 500)
end

---@param options table
M.setup = function(options)
	-- Set the options
	M.config = M.get_config(options)

	if M.config.plugin_manager ~= "lazy" and M.config.plugin_manager ~= "packer" then
		vim.notify("Only Lazy and Packer plugin manager is supported at the moment", vim.log.levels.ERROR)
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

	if M.config.star_on_startup then
		-- LazyInstall is only triggered after :Lazy sync, not on startup install, check why this doesn't work later

		-- Trigger star_all on startup
		vim.schedule(function()
			M.star_all(false)
		end)
	end

	if M.config.star_on_install then
		local event = ""
		if M.config.plugin_manager == "lazy" then
			event = "LazyInstall"
		elseif M.config.plugin_manager == "packer" then
			event = "PackerComplete"
		end

		vim.api.nvim_create_autocmd({ "user" }, {
			group = vim.api.nvim_create_augroup("ThanksStarAll", {
				clear = true,
			}),
			pattern = event,
			callback = function()
				vim.schedule(function()
					M.star_all(false)
				end)
			end,
		})
	end
end

---@param called_from_command boolean
M.star_all = function(called_from_command)
	local utils = require("thanks.utils")
	local installed_plugins = utils.get_plugins(M.config.plugin_manager)
	local data = utils.read_persisted_data() or {}
	local cached_plugins = data.starred_plugins or {}

	local to_unstar = M.config.unstar_on_uninstall and utils.get_plugins_to_unstar(installed_plugins, cached_plugins)
		or {}
	local to_star = utils.get_plugins_to_star(installed_plugins, cached_plugins)

	local github = require("thanks.github_api"):new()

	local stats = {
		unstarred = 0,
		starred = 0,
		ignored = 0,
		already_starred = 0,
	}
	if github:get_auth() then
		star_interval(github, to_star, to_unstar, data, 1, stats, called_from_command)
	else
		vim.notify("Please authenticate with Github first using :ThanksGithubAuth", vim.log.levels.INFO)
	end
end

return M
