return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = { enabled = true, view = "cmdline_popup" },
      popupmenu = { enabled = false },
      messages = { enabled = false },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
      },
      presets = { bottom_search = true, command_palette = true },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "lua" },
      cmdline = {
        keymap = { preset = "inherit" },
        completion = {
          menu = {
            auto_show = function()
              return vim.fn.getcmdtype() == ":"
            end,
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = { vim.env.VIMRUNTIME },
              checkThirdParty = false,
            },
          },
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "jsonls", "yamlls", "pyright", "bashls" },
        automatic_enable = { "lua_ls", "jsonls", "yamlls", "pyright", "bashls" },
      })
    end,
    keys = {
      {
        "<leader>cf",
        function()
          vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
        end,
        desc = "Format buffer",
      },
    },
  },
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
