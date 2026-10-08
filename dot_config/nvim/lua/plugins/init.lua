return {
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- Install only the binary, without changing shell configuration.
      { "junegunn/fzf", build = "./install --bin" },
    },
    opts = {
      fzf_bin = vim.fn.stdpath("data") .. "/lazy/fzf/bin/fzf",
    },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Search text" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "NeogitOrg/neogit",
    dependencies = { "ibhagwan/fzf-lua" },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    },
    opts = { integrations = { fzf_lua = true } },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "auto", icons_enabled = true },
      tabline = {
        lualine_a = { "buffers" },
        lualine_z = { "tabs" },
      },
    },
  },
}
