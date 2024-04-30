local M = {}

---@class Plugin
---@field name string plugin name
---@field handle string owner/repo
---@field url string plugin url
---@field author string plugin author

---@return string packer|lazy
M.get_plugin_manager = function()
	local lazy_exists = pcall(require, "lazy")
	if lazy_exists then
		return "lazy"
	end

	local packer_exists = pcall(require, "packer")
	if packer_exists then
		return "packer"
	end

	return ""
end

---@param plugin_manager string
---@return Plugin[]
M.get_plugins = function(plugin_manager)
	local plugins = {}

	if plugin_manager == "packer" then
		for name, plugin in pairs(packer_plugins) do
			if plugin.url and plugin.url:find("https://github.com") then
				local url_parts = vim.split(plugin.url, "https://github.com/")
				local handle = url_parts[2]
				local name_parts = vim.split(handle, "/")
				local author = name_parts[1]

				table.insert(plugins, {
					name = name,
					handle = handle,
					url = plugin.url,
					author = author,
				})
			end
		end
	elseif plugin_manager == "lazy" then
		local installed_plugins = require("lazy").plugins()
		for _, plugin in ipairs(installed_plugins) do
			local handle = plugin[1]
			local name = plugin.name or handle
			local url = plugin.url

			if url and url:find("https://github.com") then
				local name_parts = vim.split(handle, "/")
				if #name_parts == 2 then
					local author = name_parts[1]

					table.insert(plugins, {
						name = name,
						handle = handle,
						url = url,
						author = author,
					})
				end
			end
		end
	else
		vim.notify("Only Lazy and packer plugin manager is supported at the moment", vim.log.levels.ERROR)
		return {}
	end

	if not plugins or not #plugins then
		vim.notify("No plugins found", vim.log.levels.ERROR)
		return {}
	end

	return plugins
end

---@param plugins Plugin[]
---@param cached_plugins string[]
---@return string[]
M.get_plugins_to_unstar = function(plugins, cached_plugins)
	local uninstalled_plugins = {}

	for _, plugin in ipairs(cached_plugins) do
		local found = false
		for _, installed_plugin in ipairs(plugins) do
			if plugin == installed_plugin.handle then
				found = true
				break
			end
		end

		if not found then
			table.insert(uninstalled_plugins, plugin)
		end
	end

	return uninstalled_plugins
end

---@param plugins Plugin[]
---@param cached_plugins string[]
---@return Plugin[]
M.get_plugins_to_star = function(plugins, cached_plugins)
	cached_plugins = cached_plugins or {}
	local plugins_to_star = {}

	for _, plugin in ipairs(plugins) do
		if not vim.tbl_contains(cached_plugins, plugin.handle) then
			table.insert(plugins_to_star, plugin)
		end
	end

	return plugins_to_star
end

---@param data table
---@param filename? string
M.persist_data = function(data, filename)
	filename = filename or "jsongerber-thanks.json"

	local dir = vim.fn.stdpath("data")
	local path = dir .. "/" .. filename

	local file = io.open(path, "w+")

	if not file then
		error("Failed to open file")
	end

	local str = vim.fn.json_encode(data)

	file:write(str)
	file:close()
end

---@param filename? string
---@return table
M.read_persisted_data = function(filename)
	filename = filename or "jsongerber-thanks.json"

	local dir = vim.fn.stdpath("data")
	local path = dir .. "/" .. filename

	local file = io.open(path, "r")

	if not file then
		return {}
	end

	local str = file:read("*a")
	file:close()

	local data = vim.fn.json_decode(str)
	if not data then
		return {}
	end

	return data
end

return M
