local M = {}

---@param options table
M.config = function(options)
	local config = {
		plugin_manager = "lazy",
	}

	if options then
		for k, v in pairs(options) do
			config[k] = v
		end
	end

	return config
end

---@param github GithubApi
---@param plugins Plugin[]
---@param index number
local function star_interval(github, plugins, index)
	if index > #plugins then
		return
	end

	-- Check if github url
	if plugins[index].url:find("https://github.com") then
		local pluginTest = {
			name = "nvim-px-to-rem",
			url = "https://github.com/jsongerber/nvim-px-to-rem",
			handle = "jsongerber/nvim-px-to-rem",
		}
		github:star(pluginTest)
		-- github:star(plugins[index])
	else
		vim.notify("Plugin " .. plugins[index].name .. " is not a github url, cannot star", vim.log.levels.INFO)
	end

	vim.defer_fn(function()
		-- star_interval(github, plugins, index + 1)
	end, 500)
end

---@param options table
M.setup = function(options)
	-- Set the options
	M.config = M.config(options)

	-- LazyInstall

	-- Create :Stargaz command
	vim.api.nvim_create_user_command("ThanksGithubAuth", function()
		local github = require("thanks.github_api"):new()
		github:authenticate()
	end, {})

	vim.api.nvim_create_user_command("ThanksEveryone", function()
		local plugins = require("thanks.utils").get_plugins(M.config.plugin_manager)
		local github = require("thanks.github_api"):new()

		if github:get_auth() then
			star_interval(github, plugins, 1)
		else
			vim.notify("Please authenticate with Github first using :ThanksGithubAuth", vim.log.levels.INFO)
		end
	end, {})
end

return M
