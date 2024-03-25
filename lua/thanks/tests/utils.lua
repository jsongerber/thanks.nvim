local utils = require("thanks.utils")
local testfile = "jsongerber-thanks-test.json"

describe("utils", function()
	after_each(function()
		vim.fn.delete(vim.fn.stdpath("data") .. "/" .. testfile)
	end)

	it("should return an empty table if the dir does not exist", function()
		vim.fn.delete(vim.fn.stdpath("data") .. "/" .. testfile)

		assert.are.same({}, utils.read_persisted_data(testfile))
	end)

	it("should persist and read a data", function()
		local data = {
			test_int = 1,
			test_string = "test",
			test_table = { test = "test" },
		}
		utils.persist_data(data, testfile)

		assert.same(data, utils.read_persisted_data(testfile))
	end)
end)
