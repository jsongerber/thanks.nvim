local M = {}

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
---@param stats { starred: number, unstarred: number, ignored: number, already_starred: number, error: number }
---@param called_from_command boolean
M.star_interval = function(github, to_star, to_unstar, data, index, stats, called_from_command)
	-- Check if we're done
	if index > #to_star + #to_unstar then
		if stats.starred > 0 or called_from_command then
			vim.notify(M.generate_starred_message(stats), vim.log.levels.INFO)
		end
		return
	end

	-- Get the plugin handle and author
	local plugin_handle, plugin_author = M.get_plugin_handle_and_author(to_star, to_unstar, index)
	if not plugin_handle or not plugin_author then
		stats.error = stats.error + 1
		M.star_interval(github, to_star, to_unstar, data, index + 1, stats, called_from_command)
		return
	end

	-- Handle ignored plugins
	local is_ignored = M.is_ignored(plugin_handle, plugin_author)
	if is_ignored then
		stats.ignored = stats.ignored + 1
		M.star_interval(github, to_star, to_unstar, data, index + 1, stats, called_from_command)
		return
	end

	local starred_plugins = data.starred_plugins or {}
	if index <= #to_star then
		local starred = github:star(plugin_handle)

		if starred then
			stats.starred = stats.starred + 1

			-- Save the starred plugin to disk
			table.insert(starred_plugins, plugin_handle)
			data.starred_plugins = starred_plugins
		else
			vim.notify("Failed to star " .. plugin_handle, vim.log.levels.ERROR)
		end
	else
		local unstarred = github:star(plugin_handle, false)

		if unstarred then
			stats.unstarred = stats.unstarred + 1

			-- Remove the unstarred plugin from disk
			for i, starred_plugin in ipairs(starred_plugins) do
				if starred_plugin == plugin_handle then
					table.remove(starred_plugins, i)
					break
				end
			end
		else
			vim.notify("Failed to unstar " .. plugin_handle, vim.log.levels.ERROR)
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

---@param stats { starred: number, unstarred: number, ignored: number, already_starred: number }
---@return string
M.generate_starred_message = function(stats)
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

	return message
end

---@param to_star Plugin[]
---@param to_unstar string[]
---@param index number
---@return string?, string?
M.get_plugin_handle_and_author = function(to_star, to_unstar, index)
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

	return plugin_handle, plugin_author
end

---@param plugin_handle string
---@param plugin_author string
---@return boolean
M.is_ignored = function(plugin_handle, plugin_author)
	-- Check if plugin is ignored
	if vim.tbl_contains(M.config.ignore_repos, plugin_handle) then
		return true
	end

	-- Check if author is ignored
	if vim.tbl_contains(M.config.ignore_authors, plugin_author) then
		return true
	end

	return false
end

return M
