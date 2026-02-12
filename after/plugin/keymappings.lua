local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Visual line wraps
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", expr_opts)
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", expr_opts)

-- Better indent
keymap('v', '<', '<gv', default_opts)
keymap('v', '>', '>gv', default_opts)

-- plugin mappings
-- fuzzy finder
local fzf = require 'fzf-lua'

vim.keymap.set('n', '<leader><space>', fzf.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>ss', fzf.global, { desc = '[S]earch global' })
vim.keymap.set('n', '<leader>sf', function()
  fzf.files { winopts = { preview = { hidden = 'hidden' } } }
end, { desc = '[S]earch [F]iles' })

vim.keymap.set('n', '<leader>/', function()
  fzf.blines { winopts = { preview = { hidden = 'hidden' } } }
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
vim.keymap.set('v', '<leader>sw', fzf.grep_visual, { desc = '[S]earch [V]isual' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sq', fzf.quickfix, { desc = '[S]earch [Q]uickfix' })

vim.keymap.set({'n', 'v'}, '<leader>cc', function()
  require('codecompanion').toggle()
end, { desc = '[C]ode [C]ompanion Chat' })

-- Utility maps

-- Retab alternatives
vim.cmd [[command! -range=% -nargs=0 Tab2Space execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')']]
vim.cmd [[command! -range=% -nargs=0 Space2Tab execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')']]
