-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  'tpope/vim-fugitive', -- Git helper
  'tpope/vim-surround', -- nice keymaps to surround
  'tpope/vim-commentary', -- comment helper
  'tpope/vim-sleuth', -- autodetect tab setting and indentatio
  'github/copilot.vim', -- copilot
  'mksud/vim-log-syntax', --log file highlighting

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {}, tag = 'legacy' },
    },
    config = function()
      require('config.lsp').setup()
    end,
  },

  { -- Code completion
    'hrsh7th/nvim-cmp',
    config = function()
      require('config.cmp').setup()
    end,
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
  },

  { -- colorscheme
    'projekt0n/github-nvim-theme',
    config = function()
      vim.opt.background = 'light'
      vim.cmd 'colorscheme github_light'
    end,
  },

  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        -- theme = 'base16',
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 4,
          },
        },
      },
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          path_display = { 'smart' },
        },
      }
      require('telescope').load_extension 'fzf'
    end,
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      pcall(require('config.treesitter').setup)
    end,
    build = ':TSUpdate',
  },

  { -- Annotation support
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    -- config = true,
    opts = { snippet_engine = 'luasnip' },
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
  { 'echasnovski/mini.pairs', opts = {}, version = false },

  --Load custom plugins from `lua/custom/plugins/*.lua`
  --For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --{ import = 'custom.plugins' },
}, {})
