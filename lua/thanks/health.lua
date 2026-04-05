local M = {}
M.check = function()
	local start = vim.health.start or vim.health.report_start
	local ok = vim.health.ok or vim.health.report_ok
	local warn = vim.health.warn or vim.health.report_warn
	local error = vim.health.error or vim.health.report_error
	local info = vim.health.info or vim.health.report_info

	local thanks = require("thanks")
	local github = require("thanks.github_api"):new()
	local is_auth = github:get_auth()
	local plugin_managers = require("thanks.utils").get_plugin_managers()
	start("Checking thanks.nvim config")

	if not thanks.config then
		error("setup() has not been called")
		return
	else
		local default_config = thanks.default_config
		local has_wrong_key = false
		for key, value in pairs(thanks.config) do
			if default_config[key] == nil then
				warn(string.format("Unknown config key: %s", key))
				has_wrong_key = true
			end
		end

		if not has_wrong_key then
			ok("Config keys are valid")
		end

		if thanks.config.ignore_unauthenticated and not is_auth then
			warn("ignore_unauthenticated is enabled — this plugin won't work on this machine")
		end
	end

	start("Checking plugin managers")
	if #plugin_managers == 0 then
		error("No supported plugin manager found. Supported plugin managers are: vim.pack, lazy.nvim, packer.nvim.")
		info(
			"If you are using a supported plugin manager and it's not detected, please open an issue with details about your setup."
		)
	else
		ok("Found supported plugin managers: " .. table.concat(plugin_managers, ", "))
	end

	start("Checking GitHub authentication")
	if is_auth then
		ok("GitHub authentication is set up correctly")
	else
		warn("GitHub authentication is not set up, please run :ThanksGithubAuth to log in")
	end
end
return M
