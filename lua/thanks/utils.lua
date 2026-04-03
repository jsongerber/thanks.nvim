local M = {}

---@class Plugin
---@field name string plugin name
---@field handle string owner/repo
---@field url string plugin url
---@field author string plugin author

---@return string[]
M.get_plugin_managers = function()
	local plugin_managers = {}
	local lazy_exists = pcall(require, "lazy")
	if lazy_exists then
		table.insert(plugin_managers, "lazy")
	end

	local packer_exists = pcall(require, "packer")
	if packer_exists then
		table.insert(plugin_managers, "packer")
	end

	local minideps_exists = pcall(require, "mini.deps")
	if minideps_exists then
		table.insert(plugin_managers, "mini.deps")
	end

	-- Check if "$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json" exists
	local pack_exists = vim.fn.filereadable(vim.fn.stdpath("config") .. "/nvim-pack-lock.json") == 1
	if pack_exists then
		table.insert(plugin_managers, "vim.pack")
	end

	return plugin_managers
end

---@param plugin_managers string[]
---@return Plugin[]
M.get_plugins = function(plugin_managers)
	local plugins = {}

	for _, plugin_manager in ipairs(plugin_managers) do
		if plugin_manager == "packer" then
			plugins = vim.list_extend(plugins, M.get_packer_plugins())
		elseif plugin_manager == "lazy" then
			plugins = vim.list_extend(plugins, M.get_lazy_plugins())
		elseif plugin_manager == "mini.deps" then
			plugins = vim.list_extend(plugins, M.get_minideps_plugins())
		elseif plugin_manager == "vim.pack" then
			plugins = vim.list_extend(plugins, M.get_vimpack_plugins())
		else
			vim.notify(
				"Only vim.pack, Lazy, Packer and mini.deps plugin managers are supported at the moment",
				vim.log.levels.ERROR
			)
			return {}
		end
	end

	-- Remove duplicates from plugins list based on handle
	local seen = {}
	local unique_plugins = {}
	for _, plugin in ipairs(plugins) do
		if not seen[plugin.handle] then
			table.insert(unique_plugins, plugin)
			seen[plugin.handle] = true
		else
			vim.notify("Duplicate plugin found: " .. plugin.handle, vim.log.levels.WARN)
		end
	end

	if not unique_plugins or not #unique_plugins then
		vim.notify("No plugins found", vim.log.levels.ERROR)
		return {}
	end

	return unique_plugins
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

---@return Plugin[]
M.get_packer_plugins = function()
	local plugins = {}
	for _, plugin in pairs(packer_plugins) do
		local pluginData = M.get_plugin_infos_from_url(plugin.url)
		if plugin then
			table.insert(plugins, pluginData)
		end
	end

	return plugins
end

---@return Plugin[]
M.get_lazy_plugins = function()
	local plugins = {}
	local installed_plugins = require("lazy").plugins()
	for _, plugin in ipairs(installed_plugins) do
		local pluginData = M.get_plugin_infos_from_url(plugin.url)
		if plugin then
			table.insert(plugins, pluginData)
		end
	end

	return plugins
end

---@return Plugin[]
M.get_minideps_plugins = function()
	local plugins = {}
	local installed_plugins = require("mini.deps").get_session()
	for _, plugin in ipairs(installed_plugins) do
		local pluginData = M.get_plugin_infos_from_url(plugin.source)
		if plugin then
			table.insert(plugins, pluginData)
		end
	end

	return plugins
end

---@return Plugin[]
M.get_vimpack_plugins = function()
	local plugins = {}
	local installed_plugins = vim.fn.json_decode(vim.fn.readfile(vim.fn.stdpath("config") .. "/nvim-pack-lock.json"))

	if not installed_plugins or not installed_plugins["plugins"] or not #installed_plugins["plugins"] then
		vim.notify("No plugins found in nvim-pack-lock.json", vim.log.levels.ERROR)
		return plugins
	end

	for _, plugin in pairs(installed_plugins["plugins"]) do
		local pluginData = M.get_plugin_infos_from_url(plugin.src)
		if plugin then
			table.insert(plugins, pluginData)
		end
	end

	return plugins
end

---@param url string
---@return Plugin[]|nil
M.get_plugin_infos_from_url = function(url)
	if not url or not url:find("https://github.com") then
		return nil
	end

	-- remove .git at the end of the url if it exists
	url = url:gsub("%.git$", "")
	local url_parts = vim.split(url, "https://github.com/")
	local handle = url_parts[2]
	local name_parts = vim.split(handle, "/")
	local author = name_parts[1]
	local name = name_parts[2]

	return {
		name = name,
		handle = handle,
		url = url,
		author = author,
	}
end

return M
