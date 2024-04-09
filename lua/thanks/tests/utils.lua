local utils = require("thanks.utils")
local testfile = "jsongerber-thanks-test.json"

describe("read_and_write_data_to_disk", function()
	after_each(function()
		vim.fn.delete(vim.fn.stdpath("data") .. "/" .. testfile)
	end)

	it("should return an empty table if the dir does not exist", function()
		vim.fn.delete(vim.fn.stdpath("data") .. "/" .. testfile)

		assert.same({}, utils.read_persisted_data(testfile))
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

describe("get_plugins_to_star", function()
	it("should return plugins that are not starred", function()
		local plugins = {
			{ handle = "a" },
			{ handle = "b" },
			{ handle = "c" },
		}
		local cached_plugins = {
			"a",
		}

		assert.same({ plugins[2], plugins[3] }, utils.get_plugins_to_star(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
			{ handle = "c" },
		}

		cached_plugins = {
			"a",
			"b",
			"c",
		}

		assert.same({}, utils.get_plugins_to_star(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
			{ handle = "c" },
		}

		cached_plugins = {
			"a",
			"b",
		}

		assert.same({ plugins[3] }, utils.get_plugins_to_star(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
			{ handle = "c" },
		}

		cached_plugins = {}

		assert.same(plugins, utils.get_plugins_to_star(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
			{ handle = "c" },
		}

		cached_plugins = {
			"a",
			"b",
			"c",
			"d",
		}

		assert.same({}, utils.get_plugins_to_star(plugins, cached_plugins))
	end)

	it("should return plugins that are starred but not installed", function()
		local plugins = {
			{ handle = "a" },
			{ handle = "b" },
		}

		local cached_plugins = {
			"a",
			"b",
			"c",
		}

		assert.same({ cached_plugins[3] }, utils.get_plugins_to_unstar(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
		}

		cached_plugins = {
			"a",
			"b",
		}

		assert.same({}, utils.get_plugins_to_unstar(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
		}

		cached_plugins = {
			"a",
		}

		assert.same({}, utils.get_plugins_to_unstar(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
		}

		cached_plugins = {}

		assert.same({}, utils.get_plugins_to_unstar(plugins, cached_plugins))

		plugins = {
			{ handle = "a" },
			{ handle = "b" },
		}

		cached_plugins = {
			"a",
			"b",
			"c",
			"d",
		}

		assert.same({ cached_plugins[3], cached_plugins[4] }, utils.get_plugins_to_unstar(plugins, cached_plugins))
	end)
end)
