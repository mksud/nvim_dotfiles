vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.background = 'light'
vim.o.number = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildignorecase = true
vim.opt.wildoptions:append 'fuzzy'
vim.opt.wildmode:prepend { 'noselect:lastused' }
vim.o.updatetime = 250
vim.o.signcolumn = 'yes'
vim.o.scrolloff = 5
vim.o.smartindent = true
vim.o.breakindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.clipboard = 'unnamedplus'
vim.o.completeopt = 'fuzzy,menu,menuone,noselect,popup'
vim.o.termguicolors = true
vim.o.grepprg = 'rg --vimgrep --smart-case'
vim.opt.grepformat:append '%f'
vim.opt.errorformat:append '%f'
-- require('vim._core.ui2').enable({})

vim.pack.add {
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-surround',
  'https://github.com/tpope/vim-sleuth',
  'https://github.com/echasnovski/mini.pairs',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/github/copilot.vim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/mksud/vim-log-syntax',
}

require('mini.pairs').setup()

local servers = {
  clangd = {},
  eslint = {},
  html = {},
  omnisharp = {},
  pyright = {},
  rust_analyzer = {},
  ts_ls = {},
}

local mason_packages = {
  'clangd',
  'eslint-lsp',
  'html-lsp',
  'omnisharp',
  'pyright',
  'rust-analyzer',
  'typescript-language-server',
  'tree-sitter-cli',
}

require('mason').setup()
require('mason-tool-installer').setup { ensure_installed = mason_packages }

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('dotfiles-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, client.id, event.buf, {
        autotrigger = true,
      })

      vim.keymap.set('i', '<C-j>', function()
        vim.lsp.completion.get()
      end, { buffer = event.buf, silent = true, desc = 'LSP completion' })
    end

    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, silent = true, desc = desc })
    end

    map('gD', vim.lsp.buf.declaration, 'LSP declaration')
    map('<leader>ws', vim.lsp.buf.workspace_symbol, 'Workspace symbols')
    map('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Workspace add folder')
    map('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Workspace remove folder')
    map('<leader>wl', function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, 'Workspace list folders')

    vim.api.nvim_buf_create_user_command(event.buf, 'Format', function()
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

local function ensure_treesitter_parsers()
  local ensure_installed = {
    'bash',
    'c',
    'c_sharp',
    'cpp',
    'css',
    'diff',
    'html',
    'java',
    'javascript',
    'json',
    'lua',
    'luadoc',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'rust',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
  }

  local installed = require('nvim-treesitter').get_installed 'parsers'
  local missing = vim
    .iter(ensure_installed)
    :filter(function(parser)
      return not vim.tbl_contains(installed, parser)
    end)
    :totable()

  if #missing > 0 then
    require('nvim-treesitter').install(missing)
  end
end

if vim.fn.executable 'tree-sitter' == 1 then
  ensure_treesitter_parsers()
end

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then
      return
    end

    local installed = require('nvim-treesitter').get_installed 'parsers'
    if not vim.tbl_contains(installed, language) then
      return
    end

    vim.treesitter.start(args.buf, language)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].foldmethod = 'expr'
    vim.wo[win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[win].foldlevel = 4
  end,
})
