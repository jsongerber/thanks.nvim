local M = {}

---@class Config
---@field plugin_manager string
---@field star_on_startup boolean
---@field star_on_install boolean
---@field ignore_repos string[]
---@field ignore_authors string[]
---@field unstar_on_uninstall boolean
---@field ask_before_unstarring boolean

M.default_config = {
	plugin_manager = "",
	star_on_startup = false,
	star_on_install = true,
	ignore_repos = {},
	ignore_authors = {},
	unstar_on_uninstall = false,
	ask_before_unstarring = false,
}
---@param options table
M.get_config = function(options)
	return vim.tbl_deep_extend("force", M.default_config, options or {})
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
		error = 0,
		unstar_ignored = 0,
	}
	if github:get_auth() then
		require("thanks.star").star_interval(github, to_star, to_unstar, data, 1, stats, called_from_command, M.config)
	else
		vim.notify("Please authenticate with Github first using :ThanksGithubAuth", vim.log.levels.INFO)
	end
end

return M
