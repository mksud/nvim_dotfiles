local M = {}

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
  vim.keymap.set({ 'v', 'n' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = '[C]ode [A]ction' })

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

function M.setup()
  -- LSP settings
  local lspconfig = require 'lspconfig'
  local lspconfig_util = require 'lspconfig.util'

  -- Enable the following language servers
  -- Override the root dir detection and other settings
  local servers = {
    ['html'] = {},
    ['pyright'] = {},
    ['omnisharp'] = {},
    ['clangd'] = {},
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

  require('mason').setup()
  require('mason-lspconfig').setup { ensure_installed = vim.tbl_keys(servers) }

  -- nvim-cmp supports additional completion capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  for name, opts in pairs(servers) do
    local server_config = vim.tbl_extend('force', {
      on_attach = on_attach,
      capabilities = capabilities,
    }, opts or {})
    lspconfig[name].setup(server_config)
  end

  -- Turn on status information
  require('fidget').setup()
end

return M
