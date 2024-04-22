# thanks.nvim

> Never forget to star a repo

Automatically star all the Neovim plugins you use.

> [!NOTE]  
> Only works with [lazy.nvim](https://github.com/folke/lazy.nvim) and [packer](https://github.com/wbthomason/packer.nvim).  
> Please open an issue or PR if you want to use it with another plugin manager.

## 🚀 Usage

After installing thanks.nvim, you must first log in to GitHub using the `:ThanksGithubAuth` command. This step is necessary only once.

Once you're authenticated, you can star all the installed plugins using the `:ThanksAll` command.  
The initial run may take a minute if you have a lot of plugins, but next runs will be faster due to the utilization of a local cache.  
The local cache can be deleted using the `:ThanksClearCache` command. It will be recreated the next time you execute `:ThanksAll`.

With the default configuration, every time a new plugin is installed, `:ThanksAll` will be automatically executed.

## 🔧 Requirements and dependencies

-   A plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) or [packer](https://github.com/wbthomason/packer.nvim)
-   Linux or MacOs: not tested on Windows but maybe work, please let me know if you try it.
-   cURL: if you don't have curl installed, use your favorite plugin manager to install it.

## 📋 Installation

-   With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- add this to your lua/plugins.lua, lua/plugins/init.lua, or the file you keep your other plugins:
{
    'jsongerber/thanks.nvim',
	config = true,
}
```

-   With [packer](https://github.com/wbthomason/packer.nvim)

```lua
use({
    'jsongerber/thanks.nvim',
	config = function()
		require("thanks").setup()
	end,
})
```

## ⚙ Configuration

```lua
-- Those are the default values and can be ommited
require("thanks").setup({
	star_on_startup = false,
	star_on_install = true,
	ignore_repos = {},
	ignore_authors = {},
	unstar_on_uninstall = false,
	ask_before_unstarring = false,
})
```

| Option            | Type    | Description                                                                                                                                            | Default value |
| ----------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `star_on_startup` | Boolean | Same that `star_on_install`, but run on startup so it check if you have any new plugins everytime you open Neovim                                      | `false`       |
| `star_on_install` | Boolean | Automatically run on **install**, so you can forget about it and it will automatically star your new plugins | `true`        |
| `ignore_repos`    | Table   | Repos you wish to ignore when calling `:ThanksAll` eg: `{ "author/repo" }`                                                                             | `{}`          |
| `ignore_authors`  | Table   | Authors you wish to ignore when calling `:ThanksAll` (e.g. if you don't want to star you own repos: `{ "author" }`)                                  | `{}`          |
| `unstar_on_uninstall` | Boolean | Automatically unstar plugins when they are uninstalled | `false` |
| `ask_before_unstarring` | Boolean | Ask before unstarring a plugin | `false` |

## 🧰 Commands

| Command               | Description                                                                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `:ThanksAll`          | Star all the plugins you have installed                                                                                                                                               |
| `:ThanksGithubAuth`   | Authenticate with your GitHub account                                                                                                                                                 |
| `:ThanksGithubLogout` | Logout of your GitHub account (this command only delete the locally saved access token, [you still need to revoke app permission manually](https://github.com/settings/applications)) |
| `:ThanksClearCache`   | Delete local cache of starred plugins                                                                                                                                                 |

## 🚧 Caveats

- When using `star_on_install` with `lazy.nvim` and lazy configuration `install.missing` is set to `true` (default), lazy will check and install new plugins when you open Neovim, unfortunately, this sync will happend before thanks.nvim is loaded, so any new plugins won't be starred at this point. Those new plugins will be starred next time you run `:Lazy sync` or `:ThanksAll`, so you can ignore this issue if you do not care about starring plugin instantly. If you do care, just set `star_on_startup` to `true`.  
- If you have `unstar_on_uninstall` set to `true`, the unstar process won't be done immediately, it will be done when Lazy clean the plugin or when you install a new plugin or when you run `:ThanksAll`, or restart neovim if you have `star_on_startup` set to `true`.
- If you have `unstar_on_uninstall` set to `true` and you uninstall thanks.nvim, it won't be able to unstar itself as plugin manager don't let plugins say their last words before deleting them.

## 🗑️ Uninstall

Uninstall the plugin as you normally would, if you want to clean everything, you can delete the cache file and the saved access token:

```sh
rm path/to/jsongerber-thanks.json
```

To find the path of this file, you can run the following command in neovim:

```vim
:lua vim.print(vim.fn.stdpath("data") .. "/jsongerber-thanks.json")
```

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 📝 TODO (will do if there is demand (open issue or PR))

-   [ ] Other plugin managers
-   [ ] Unstar on uninstall
-   [ ] Automatically detect plugin manager

## 📜 License

MIT © [jsongerber](https://github.com/jsongerber/thanks/blob/master/LICENSE)
