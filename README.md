# NvimTex40000

A lightweight Neovim plugin to preview .tex files in zathura

## Features
- Made to run in i3-wm using zathura
- Auto-compile on save 
- Opens pdf on launch 

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    Nikola-Blazevski/NvimTex40000
    ft = "tex",
    config = function()
      require("plugins.NvimTex40000").setup()
    end
}
