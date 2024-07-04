# thanks.nvim

> Never forget to star a repo

Automatically star all the Neovim plugins you use.

> [!NOTE]  
> Only works with [lazy.nvim](https://github.com/folke/lazy.nvim) and [packer](https://github.com/wbthomason/packer.nvim).  
> Please open an issue or PR if you want to use it with another plugin manager.

See :h thanks if you are in Neovim.

## 🚀 Usage

After installing thanks.nvim, you must first log in to GitHub using the `:ThanksGithubAuth` command. This step is necessary only once.

Once you're authenticated, you can star all the installed plugins using the `:ThanksAll` command.  
If you have `unstar_on_uninstall` set to `true`, it will also unstar the plugins that are not installed anymore.  

The initial run may take a minute if you have a lot of plugins, but next runs will be faster due to the utilization of a local cache.  
The local cache can be deleted using the `:ThanksClearCache` command. It will be recreated the next time you execute `:ThanksAll`.

With the default configuration, every time a new plugin is installed, `:ThanksAll` will be automatically executed (set `star_on_startup` to `true` if you want to check on each Neovim startup, see [caveat](#-caveats)).

## 🔧 Requirements and dependencies

-   A plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) or [packer](https://github.com/wbthomason/packer.nvim)
-   Linux or MacOs: not tested on Windows but maybe work, please let me know if you try it.
-   cURL: if you don't have curl installed, use your favorite package manager to install it.

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
	star_on_install = true,
	star_on_startup = false,
	ignore_repos = {},
	ignore_authors = {},
	unstar_on_uninstall = false,
	ask_before_unstarring = false,
})
```

| Option            | Type    | Description                                                                                                                                            | Default value |
| ----------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| `star_on_install` | Boolean | Automatically run on **install**, so you can forget about it and it will automatically star your new plugins | `true`        |
| `star_on_startup` | Boolean | Same that `star_on_install`, but run on **startup** so it check if you have any new plugins everytime you open Neovim. <br>Set to `true` if beeing always up to date is important to you (see [caveat](#-caveats)). <br>Default is `false` so you startup time maniacs won't be disapointed, but if you don't care a file read on startup it is recommended to have it to `true`                                      | `false`       |
| `ignore_repos`    | Table   | Repos you wish to ignore when starring/unstarring eg: `{ "author/repo" }`                                                                             | `{}`          |
| `ignore_authors`  | Table   | Authors you wish to ignore when starring/unstarring (e.g. if you don't want to star you own repos: `{ "author" }`)                                  | `{}`          |
| `unstar_on_uninstall` | Boolean | Unstar plugins when they are uninstalled | `false` |
| `ask_before_unstarring` | Boolean | Ask before unstarring a plugin (unstar the plugin if the prompt is dismissed without `n`) | `false` |

## 🧰 Commands

| Command               | Description                                                                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `:ThanksAll`          | Star all the plugins you have installed (and unstar if `unstar_on_uninstall` is set to `true`)                                                                                                                                               |
| `:ThanksGithubAuth`   | Authenticate with your GitHub account                                                                                                                                                 |
| `:ThanksGithubLogout` | Logout of your GitHub account (this command only delete the locally saved access token, [you still need to revoke app permission manually](https://github.com/settings/applications)) |
| `:ThanksClearCache`   | Delete local cache of starred plugins                                                                                                                                                 |

## 🚧 Caveats

- If your plugin manager sync plugins on Neovim startup (default on Lazy.nvim, unsure about Packer), there's a good chance it does before thanks.nvim is loaded and therefor cannot star/unstar the plugins directly.  Thoses new plugins will be starred/unstarred on the next sync that does not happen on startup or if you call `:ThanksAll` manually, if you want to always be up to date with your stars, set `star_on_startup` to `true`.
- If you have `unstar_on_uninstall` set to `true` and you uninstall thanks.nvim, it won't be able to unstar itself as plugin manager don't let plugins say their last words before deleting them.
- thanks.nvim knows which repos it already starred, but doesn't check if you manually starred/unstarred a repo, if you manually star a repo on github.com and then install it, it will tell you that you just starred it, even though it was already starred.

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

## 📝 TODO

Will do if there is demand (open issue or PR)  
-   [x] Other plugin managers
-   [x] Unstar on uninstall
-   [x] Automatically detect plugin manager
-   [ ] Command to star/unstar a single plugin
-   [ ] Command to uninstall thanks.nvim

## 📜 License

## Shameless plug

See my other plugins:
- [telescope-ssh-config](https://github.com/jsongerber/telescope-ssh-config): A plugin to list and connect to ssh hosts with telescope.nvim.
- [nvim-px-to-rem](https://github.com/jsongerber/nvim-px-to-rem): A plugin to convert px to rem in Neovim.

MIT © [jsongerber](https://github.com/jsongerber/thanks/blob/master/LICENSE)
