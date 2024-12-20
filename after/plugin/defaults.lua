local opt = vim.opt
local cmd = vim.cmd

opt.shiftwidth = 4
opt.tabstop = 4
opt.background = 'light'
opt.number = true --Make line numbers default
opt.ignorecase = true --Case insensitive searching unless /C or capital in search
opt.wildignorecase = true
opt.smartcase = true -- Smart case
opt.updatetime = 250 --Decrease update time
opt.signcolumn = 'number' -- Always show sign column
opt.showmode = false -- Do not need to show the mode. We use the statusline instead.
opt.scrolloff = 5 -- Lines of context
opt.smartindent = true --Smart indent
opt.breakindent = true --Wrapped lines indent
opt.shortmess:append 'c' -- disable insert completion menu
opt.termguicolors = true -- Enable colors in terminal

if vim.fn.executable 'rg' == 1 then
  opt.grepprg = 'rg --vimgrep --smart-case'
  opt.grepformat:prepend '%f:%l:%c:%m'
  opt.grepformat:append '%f'
end

-- Treesitter based folding
cmd [[
  set foldlevel=20
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
]]
