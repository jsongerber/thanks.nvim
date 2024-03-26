---@class Device
---@field device_code string
---@field user_code string
---@field verification_uri string
---@field expires_in number
---@field interval number

---@class AuthResponse
---@field access_token string
---@field expires_in number
---@field refresh_token string
---@field refresh_token_expires_in number
---@field scope string
---@field token_type string

---@class GithubApi
---@field client_id string
---@field auth AuthResponse
local GithubApi = {}

GithubApi.__index = GithubApi
function GithubApi:new()
	return setmetatable({
		-- client_id = "Iv1.f49b8eaaa67d69c0",
		client_id = "02a6f4a30c2cb467b535",
	}, self)
end

function GithubApi:get_auth()
	if self.auth then
		return self.auth
	end

	local data = require("thanks.utils").read_persisted_data()
	if data.auth then
		self.auth = data.auth

		return self.auth
	end

	return nil
end

local function open_signin_popup(code, url)
	local lines = {
		" [Copilot] ",
		"",
		" First copy your one-time code: ",
		"   " .. code .. " ",
		" In your browser, visit: ",
		"   " .. url .. " ",
		"",
		" ...waiting, it might take a while and ",
		" this popup will auto close once done... ",
		"",
		"",
	}
	local height, width = #lines, math.max(unpack(vim.tbl_map(function(line)
		return #line
	end, lines)))

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	local winid = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		style = "minimal",
		border = "single",
		row = (vim.o.lines - height) / 2,
		col = (vim.o.columns - width) / 2,
		height = height,
		width = width,
	})
	vim.api.nvim_win_set_option(winid, "winhighlight", "Normal:Normal")

	return function()
		vim.api.nvim_win_close(winid, true)
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end, function(str)
		vim.api.nvim_buf_set_lines(bufnr, #lines - 1, #lines, false, { str })
	end
end

---@param device Device
---@param time_passed number
---@param add_to_buff function
---@param close_popup function
function GithubApi:checkDeviceRegistered(device, time_passed, add_to_buff, close_popup)
	local waiting_texts = {
		" ...waiting ",
		" ...please wait ",
		" ...still waiting ",
		" ...did you paste the code?",
		" ...please wait a bit longer ",
		" ...waiting for device registration ",
		" ...is this plugin working? ",
	}

	time_passed = time_passed + 1

	vim.defer_fn(function()
		-- -- Check if the device code has expired
		if device.expires_in < time_passed then
			add_to_buff(" !WARNING! Device code expired!")
			return
		end

		-- Not the right interval yet
		if time_passed % device.interval ~= 0 then
			self:checkDeviceRegistered(device, time_passed, add_to_buff, close_popup)
			return
		end

		add_to_buff(waiting_texts[((time_passed / device.interval) % #waiting_texts) + 1])

		local check_response, errorR = require("thanks.curl").curl(
			"POST",
			"https://github.com/login/oauth/access_token",
			{
				Accept = "application/json",
			},
			{
				client_id = self.client_id,
				device_code = device.device_code,
				grant_type = "urn:ietf:params:oauth:grant-type:device_code",
			}
		)
		check_response = check_response --[[@as AuthResponse]]

		if errorR then
			if errorR.error == "authorization_pending" then
				-- Still wating, do nothing
				self:checkDeviceRegistered(device, time_passed, add_to_buff, close_popup)
			elseif errorR.error == "slow_down" then
				device.interval = errorR.interval
				self:checkDeviceRegistered(device, time_passed, add_to_buff, close_popup)
			-- elseif errorR.error == "expired_token" then
			-- elseif errorR.error == "incorrect_device_code" then
			-- elseif errorR.error == "access_denied" then
			else
				close_popup()
				vim.notify(errorR.error_description, vim.log.levels.ERROR)
				-- add_to_buff(" !ERROR! " .. errorR.error_description)
			end
		else
			-- require('thanks.curl').curl('GET', 'https://api.github.com/user', {
			-- 	Accept = 'application/vnd.github+json',
			-- 	Authorization = 'Bearer ' .. check_response.access_token,
			-- })

			-- Save the access token
			local utils = require("thanks.utils")
			local data = utils.read_persisted_data(nil)
			data.auth = check_response
			utils.persist_data(data)

			close_popup()
			vim.notify("Successfully authenticated to GitHub!", vim.log.levels.INFO)
		end
	end, 1000)
end

function GithubApi:authenticate()
	local url = "https://github.com/login/device/code"
	local data = {
		client_id = self.client_id,
		scope = "public_repo,repo",
	}

	local response, errorR = require("thanks.curl").curl("POST", url, { Accept = "application/json" }, data)

	if errorR then
		vim.notify(errorR.error_description, vim.log.levels.ERROR)
		return
	end

	response = response --[[@as Device]]

	-- test
	-- local device = {
	-- 	device_code = "test",
	-- 	user_code = "test",
	-- 	verification_uri = "https://google.com",
	-- 	expires_in = 100,
	-- 	interval = 5,
	-- }

	local close_popup, add_to_buff = open_signin_popup(response.user_code, response.verification_uri)

	self:checkDeviceRegistered(response, -1, add_to_buff, close_popup)
end

---@param plugin Plugin
function GithubApi:star(plugin)
	local access_token = self:get_auth().access_token

	local url = "https://api.github.com/user/starred/" .. plugin.handle
	local headers = {
		Accept = "application/vnd.github+json",
		Authorization = "Bearer " .. access_token,
		["Content-Length"] = 0,
	}

	local response, errorR = require("thanks.curl").curl("PUT", url, headers)

	if errorR then
		vim.notify(errorR.error_description, vim.log.levels.ERROR)
		return
	end
end

function GithubApi:logout()
	-- Can't really logout from GitHub, so just remove the token
	local data = require("thanks.utils").read_persisted_data()
	data.auth = nil
	require("thanks.utils").persist_data(data)

	vim.notify(
		"Successfully logged out from GitHub! (You need to manually revoke the app access here: https://github.com/settings/applications)",
		vim.log.levels.INFO
	)
end

return GithubApi
