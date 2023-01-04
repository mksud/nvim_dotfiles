local M = {}

function M.setup()
  -- Install packer
  local is_bootstrap = false

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
      is_bootstrap = true
      vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
      vim.cmd [[packadd packer.nvim]]
    end
    vim.cmd 'autocmd BufWritePost plugins.lua source <afile> | PackerCompile'
  end
  -- Plugins
  local function plugins(use)
    use { 'wbthomason/packer.nvim' }

    use { -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      requires = {
        -- Automatically install LSPs to stdpath for neovim
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',

        -- Useful status updates for LSP
        'j-hui/fidget.nvim',
      },
      config = function()
        require('config.lsp').setup()
      end,
    }

    -- Code Completion
    use {
      'hrsh7th/nvim-cmp',
      config = function()
        require('config.cmp').setup()
      end,
      requires = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
      },
    }

    -- Surround shortcuts
    use {
      'tpope/vim-surround',
      keys = { 'c', 'd', 'y' },
      -- make sure to change the value of `timeoutlen` if it's not triggering correctly, see https://github.com/tpope/vim-surround/issues/117
      -- setup = function()
      --  vim.o.timeoutlen = 500
      -- end
    }

    -- Git helper
    use {
      'tpope/vim-fugitive',
      cmd = { 'G', 'Git', 'Gdiffsplit', 'Gvdiffsplit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GDelete', 'GBrowse', 'GRemove', 'GRename', 'Glgrep', 'Gedit' },
      ft = { 'fugitive' },
    }

    -- Comment helper
    use {
      'tpope/vim-commentary',
    }

    -- Treesitter for syntax highlighting, navigating
    use {
      'nvim-treesitter/nvim-treesitter',
      opt = true,
      event = 'BufReadPre',
      run = ':TSUpdate',
      config = function()
        require('config.treesitter').setup()
      end,
      requires = {
        { 'nvim-treesitter/nvim-treesitter-textobjects', event = 'BufReadPre' },
        { 'JoosepAlviste/nvim-ts-context-commentstring', event = 'BufReadPre' },
      },
    }

    -- Auto detect indentation of an opened file
    use {
      'tpope/vim-sleuth',
      opt = true,
      event = 'BufReadPre',
    }

    -- Telescope for fuzzy searching
    -- Fuzzy Finder (files, lsp, etc)
    use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }

    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

    -- other Colorschemes
    -- use 'Mofiqul/vscode.nvim'
    -- use 'NLKNguyen/papercolor-theme'
    -- use 'catppuccin/nvim'
    -- use 'RRethy/nvim-base16'
    -- use 'sainnhe/edge'
    -- use 'folke/tokyonight.nvim'
    -- use 'EdenEast/nightfox.nvim'

    -- Colorscheme
    use {
      'projekt0n/github-nvim-theme',
      config = function()
        vim.opt.background = 'light'
        vim.cmd 'colorscheme github_light'
      end,
    }

    -- Status line at the bottom
    use {
      'nvim-lualine/lualine.nvim',
      config = function()
        require('lualine').setup {
          options = {
            icons_enabled = false,
            -- theme = 'base16',
          },
        }
      end,
      -- requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    if is_bootstrap then
      print 'Restart Neovim required after installation!'
      require('packer').sync()
    end
  end

  packer_init()

  local packer = require 'packer'
  packer.startup(plugins)
end

return M
