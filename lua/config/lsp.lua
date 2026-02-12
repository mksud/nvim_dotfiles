local M = {}

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
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
  -- Enable the following language servers
  -- Override the root dir detection and other settings
  local servers = {
    html = {},
    pyright = {},
    omnisharp = {},
    clangd = {},
    rust_analyzer = {},

    ts_ls = {
      root_dir = function(fname)

        return vim.fs.root(fname, {
          'jsconfig.json',
          'tsconfig.json',
          'package.json',
          '.git',
        })
      end,
    },

    eslint = {
      root_dir = function(fname)

        return vim.fs.root(fname, {
          '.eslintrc',
          '.eslintrc.js',
          '.eslintrc.cjs',
          '.eslintrc.yaml',
          '.eslintrc.yml',
          '.eslintrc.json',
          'package.json',
          '.git',
        })
      end,
    },
  }

  require('mason').setup()
  require('mason-lspconfig').setup { ensure_installed = vim.tbl_keys(servers) }

  -- blink.cmp supports additional completion capabilities
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  for name, opts in pairs(servers) do
    local server_config = vim.tbl_extend('force', {
      on_attach = on_attach,
      capabilities = capabilities,
    }, opts or {})
    -- Define / override the config
    vim.lsp.config[name] = server_config
    -- Enable so it activates for its filetypes
    vim.lsp.enable(name)
  end

  -- Turn on status information
  require('fidget').setup()
end

return M
