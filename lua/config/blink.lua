local M = {}

function M.setup()
  require('blink.cmp').setup({
    keymap = { preset = 'enter' },
    completion = {
      list = {
        selection = { preselect = false, auto_insert = false },
      },
      menu = {
        direction_priority = { 'n', 's' },
      },
    },
    snippets = { preset = 'default' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        snippets = {
          opts = {
            extended_filetypes = {
              javascript = { 'html', 'javascriptreact' },
            },
          },
        },
      },
    },
  })
end

return M

