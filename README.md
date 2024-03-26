# thanks.nvim

> Never forget to star a repo

A Neovim plugin written in lua to convert px to rem as you type. It also provide commands and keymaps to convert px to rem and a virtual text to visualize your rem values.

## ⚡️ Features

-   Easily convert px to rem as you type (require [nvim-cmp](https://github.com/hrsh7th/nvim-cmp))
-   Convert px to rem on a single value or a whole line
-   Visualize your rem values in a virtual text

## 📋 Installation

-   With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'jsongerber/nvim-px-to-rem',
    config = function()
        require('nvim-px-to-rem').setup()
    end
}
```

-   With [vim-plug](https://github.com/junegunn/vim-plug)

```lua
Plug 'jsongerber/nvim-px-to-rem

" Somewhere after plug#end()
lua require('nvim-px-to-rem').setup()
```

-   With [folke/lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
{
    'jsongerber/nvim-px-to-rem',
    config = true,
    --If you need to set some options replace the line above with:
    -- config = function()
    --     require('nvim-px-to-rem').setup()
    -- end,
}
```

## ⚙ Configuration

```lua
-- Those are the default values and can be ommited
require("nvim-px-to-rem").setup({
    root_font_size = 16,
    decimal_count = 4,
    show_virtual_text = true,
    add_cmp_source = true,
    disable_keymaps = false,
    filetypes = {
        "css",
        "scss",
        "sass",
    },
})
```

| Option              | Description                                                                                                      | Default value             |
| ------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `root_font_size`    | The font size used to convert px to rem                                                                          | `16`                      |
| `decimal_count`     | The number of decimal to keep when converting px to rem                                                          | `4`                       |
| `show_virtual_text` | Show the rem value converted in px in a virtual text                                                             | `true`                    |
| `add_cmp_source`    | Add a nvim-cmp source to convert px to rem as you type (require [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)) | `true`                    |
| `disable_keymaps`   | Disable the default keymaps                                                                                      | `false`                   |
| `filetypes`         | The filetypes to enable the plugin on                                                                            | `{"css", "scss", "sass"}` |

### nvim-cmp integration

If you want to be able to convert px to rem as you type you need to install [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and add the plugin to your cmp sources:

```lua
require("cmp").setup({
    -- other config
    sources = cmp.config.sources({
        { name = "nvim_px_to_rem" },
        -- other sources
    }),
})
```

## 🧰 Commands

| Command          | Description                         |
| ---------------- | ----------------------------------- |
| `:PxToRemCursor` | Convert px to rem under cursor      |
| `:PxToRemLine`   | Convert px to rem on the whole line |

## 📚 Keymaps

| Keymap        | Description                         |
| ------------- | ----------------------------------- |
| `<leader>px`  | Convert px to rem under cursor      |
| `<leader>pxl` | Convert px to rem on the whole line |

You can disable the default keymaps by setting `disable_keymaps` to `true` and then create your own:

```lua
-- Those are the default keymaps, you can change them to whatever you want
vim.api.nvim_set_keymap("n", "<leader>px", ":PxToRemCursor<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>pxl", ":PxToRemLine<CR>", {noremap = true})
```

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🎭 Motivations

Inspired by the VS Code plugin [px to rem & rpx & vw (cssrem)](https://marketplace.visualstudio.com/items?itemName=cipchk.cssrem).  
There is two vim plugin to convert px to \(r\)em but those were missing some feature I wanted such as the virtual text and the nvim-cmp integration:

-   [vim-px-to-em](https://github.com/chiedo/vim-px-to-em)
-   [vim-px-to-rem](https://github.com/Oldenborg/vim-px-to-rem)

## 📝 TODO

-   [ ] Use Treesitter
-   [ ] Write tests
-   [ ] Write documentation

## 📜 License

MIT © [jsongerber](https://github.com/jsongerber/nvim-px-to-rem/blob/master/LICENSE)
