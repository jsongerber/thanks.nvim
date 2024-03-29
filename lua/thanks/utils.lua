local M = {}

---@class Plugin
---@field name string plugin name
---@field handle string owner/repo
---@field url string plugin url
---@field author string plugin author

---@param plugin_manager string
---@return Plugin[]
M.get_plugins = function(plugin_manager)
	if plugin_manager ~= "lazy" then
		error("Plugin manager not supported")
	end

	local installed_plugins = require("lazy").plugins()

	if not installed_plugins or not #installed_plugins then
		error("No plugins found")
	end

	local plugins = {}

	for _, plugin in ipairs(installed_plugins) do
		local handle = plugin[1]
		local name = plugin.name
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

	return plugins
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
