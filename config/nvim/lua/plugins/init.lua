return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript",
        "python", "rust", "julia",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.pickers = opts.defaults.pickers or {}
      opts.defaults.pickers.find_files = { hidden = true }
      opts.defaults.pickers.live_grep = { grep_hidden = true }
      return opts
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      opts.filters.git_ignored = false
      return opts
    end,
  },
}
