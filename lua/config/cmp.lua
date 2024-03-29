local M = {}

function M.setup()
  -- luasnip setup
  local luasnip = require 'luasnip'
  luasnip.filetype_extend('javascript', { 'html' })
  luasnip.filetype_extend('javascript', { 'javascriptreact' })
  require('luasnip.loaders.from_vscode').lazy_load()

  -- nvim-cmp setup
  local cmp = require 'cmp'
  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false, -- only explicitly selected with tab
      },
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
    },
  }
end

return M
