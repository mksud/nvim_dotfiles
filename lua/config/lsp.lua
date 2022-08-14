local M = {}

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
  vim.api.nvim_create_user_command('Format', vim.lsp.buf.formatting, {})
end

function M.setup()
  -- LSP settings
  local lspconfig = require 'lspconfig'
  local lspconfig_util = require 'lspconfig.util'

  -- nvim-cmp supports additional completion capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  -- Enable the following language servers
  -- Override the root dir detection and other settings
  local servers = {
    ['html'] = {},
    ['pyright'] = {},
    ['omnisharp'] = {},
    ['tsserver'] = {
      root_dir = function(fname)
        return lspconfig_util.root_pattern('jsconfig.json', 'tsconfig.json')(fname) or lspconfig_util.root_pattern('package.json', '.git')(fname)
      end,
    },
    ['eslint'] = {
      root_dir = function(fname)
        return lspconfig_util.root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', '.eslintrc.json')(fname)
          or lspconfig_util.root_pattern('package.json', '.git')(fname)
      end,
    },
  }

  require('nvim-lsp-installer').setup { ensure_installed = vim.tbl_keys(servers) }

  for name, opts in pairs(servers) do
    local server_config = vim.tbl_extend('force', {
      on_attach = on_attach,
      capabilities = capabilities,
    }, opts or {})
    lspconfig[name].setup(server_config)
  end
end

return M
