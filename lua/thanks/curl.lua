local M = {}

---@class Error
---@field error string
---@field error_description string
---@field error_uri string
---@field [string] any

---@param method string
---@param url string
---@param data? table
---@param headers? table
---@return table|string|nil, Error|nil
M.curl = function(method, url, headers, data)
	local curl_command = "curl -X " .. method .. " -s -f "

	if headers then
		for key, value in pairs(headers) do
			curl_command = curl_command .. '-H "' .. key .. ": " .. value .. '" '
		end
	end

	if data then
		local query_params = {}
		for key, value in pairs(data) do
			table.insert(query_params, key .. "=" .. value)
		end

		curl_command = curl_command .. '-d "' .. table.concat(query_params, "&") .. '" '
	end

	curl_command = curl_command .. url

	local response = vim.fn.system(curl_command)

	if vim.v.shell_error ~= 0 then
		return nil, {
			error = "api_error",
			error_description = "Error in response from Github",
		}
	end

	if headers and headers.Accept == "application/json" then
		local responseObj = vim.fn.json_decode(response)

		if nil == responseObj then
			return nil, {
				error = "api_error",
				error_description = "No response from GitHub",
			}
		end

		if nil ~= responseObj.error then
			return nil, responseObj
		end

		return responseObj, nil
	end

	return response, nil
end

return M
