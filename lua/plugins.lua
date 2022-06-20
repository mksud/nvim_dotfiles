local M = {}

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false

  -- packer.nvim configuration
  local conf = {
    display = {
      open_fn = function()
        return require('packer.util').float { border = 'rounded' }
      end,
    },
  }

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path,
      }
      vim.cmd [[packadd packer.nvim]]
    end
    vim.cmd 'autocmd BufWritePost plugins.lua source <afile> | PackerCompile'
  end

  -- Plugins
  local function plugins(use)
    use { 'wbthomason/packer.nvim' }

    -- LSP
    use {
      {
        'williamboman/nvim-lsp-installer',
      },
      {
        'neovim/nvim-lspconfig',
        after = 'nvim-lsp-installer',
        config = function()
          require('config.lsp').setup()
        end,
      },
    }

    -- Completion
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

    -- Surround
    use {
      'tpope/vim-surround',
      keys = { 'c', 'd', 'y' },
      -- make sure to change the value of `timeoutlen` if it's not triggering correctly, see https://github.com/tpope/vim-surround/issues/117
      --   -- setup = function()
      --       --  vim.o.timeoutlen = 500
      --         -- end
      --         },
      --
    }

    -- Git helper
    use {
      'tpope/vim-fugitive',
      cmd = {
        'G',
        'Git',
        'Gdiffsplit',
        'Gvdiffsplit',
        'Gread',
        'Gwrite',
        'Ggrep',
        'GMove',
        'GDelete',
        'GBrowse',
        'GRemove',
        'GRename',
        'Glgrep',
        'Gedit',
      },
      ft = { 'fugitive' },
    }

    -- Comment helper
    use {
      'tpope/vim-commentary',
      keys = 'gc',
    }

    -- Treesitter
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

    -- Telescope
    use {
      'nvim-telescope/telescope.nvim',
      config = function()
        require('telescope').setup()
      end,
      requires = { 'nvim-lua/plenary.nvim' },
    }

    use {
      'nvim-telescope/telescope-fzf-native.nvim',
      requires = { 'nvim-telescope/telescope.nvim' },
      run = 'make',
    }

    -- Colorscheme
    -- use {
    --   'RRethy/nvim-base16',
    --   config = function()
    --     vim.opt.background = 'light'
    --     vim.cmd 'colorscheme base16-one-light'
    --   end,
    -- }
    -- use {
    --   'sainnhe/edge',
    --   config = function()
    --     vim.opt.background = 'light'
    --     vim.cmd 'colorscheme edge'
    --   end,
    -- }
    -- use 'NLKNguyen/papercolor-theme'
    -- use{
    --   "catppuccin/nvim",
    --   as = "catppuccin",
    --   config = function()
    --     vim.opt.background = 'light'
    --     vim.cmd 'colorscheme catppuccin'
    --   end,
    -- }

    use {
      'Mofiqul/vscode.nvim',
      config = function()
        vim.opt.background = 'light'
        vim.cmd 'colorscheme vscode'
      end,
    }

    -- Status line at the bottom
    use {
      'nvim-lualine/lualine.nvim',
      config = function()
        require('lualine').setup()
      end,
      -- options = {
      --   icons_enabled = false,
      --   theme = 'base16',
      -- },
      -- requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    if packer_bootstrap then
      print 'Restart Neovim required after installation!'
      require('packer').sync()
    end
  end

  packer_init()

  local packer = require 'packer'
  packer.init(conf)
  packer.startup(plugins)
end

return M
