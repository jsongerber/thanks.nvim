# thanks.nvim

> Never forget to star a repo

Automatically star all the Neovim plugins you use.readml

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
-   Linux or MacOs: not tested on Windows but should **NOT** work, PRs are welcome.
-   cURL: if you don't have curl installed, use your favorite package manager to install it.

## 📋 Installation

-   With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
{
    'jsongerber/thanks.nvim',
    opts = {
        plugin_manager = "lazy",
    }
}
```

-   With [packer](https://github.com/wbthomason/packer.nvim)

```lua
use({
    'jsongerber/thanks.nvim',
    config = function()
        require("thanks").setup({
            plugin_manager = "packer",
        })
    end,
})
```

## ⚙ Configuration

```lua
-- Those are the default values and can be ommited (except plugin_manager)
require("thanks").setup({
    plugin_manager = "",
    star_on_startup = false,
    star_on_install = true,
    ignore_repos = {},
    ignore_authors = {},
})
```

| Option            | Type    | Description                                                                                                                                            | Default value |
| ----------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `plugin_manager`  | String  | Mandatory: The plugin manager you use (only support Lazy and Packer for now)                                                                           |               |
| `star_on_install` | Boolean | Automatically run on **install**, so you can forget about it and it will automatically star your new plugins (a cache is used to speed up the process) | `true`        |
| `star_on_startup` | Boolean | Same that `star_on_install`, but run on startup so it check if you have any new plugins everytime you open Neovim                                      | `false`       |
| `ignore_repos`    | Table   | Repos you wish to ignore when calling `:ThanksAll` eg: `{ "author/repo" }`                                                                             | `{}`          |
| `ignore_authors`  | Table   | Authors you wish to ignore when calling `:ThanksAll` (e.g. if you don't want to star you own repo) eg: `{ "author" }`                                  | `{}`          |

## 🧰 Commands

| Command               | Description                                                                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `:ThanksAll`          | Star all the plugins you have installed                                                                                                                                               |
| `:ThanksGithubAuth`   | Authenticate with your GitHub account                                                                                                                                                 |
| `:ThanksGithubLogout` | Logout of your GitHub account (this command only delete the locally saved access token, [you still need to revoke app permission manually](https://github.com/settings/applications)) |
| `:ThanksClearCache`   | Delete local cache of starred plugins                                                                                                                                                 |

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
-   [x] Unstar on uninstall
-   [ ] Automatically detect plugin manager
-   [ ] Option to star external packages (LSPs, formatters, linters)

## 📜 License

MIT © [jsongerber](https://github.com/jsongerber/thanks/blob/master/LICENSE)
