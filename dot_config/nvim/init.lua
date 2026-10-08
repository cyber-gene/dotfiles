-- Show line numbers.
vim.opt.number = true

-- Set leaders before loading plugin keymaps.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Commenting uses Neovim's built-in gc/gcc mappings.
require("config.lazy")
