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
-- telescope

vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sf', function()
  require('telescope.builtin').find_files { previewer = false, path_display = { 'truncate' } }
end, { desc = '[S]earch [F]iles' })

vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find { previewer = false }
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sq', require('telescope.builtin').quickfix, { desc = '[S]earch [Q]uickfix' })

vim.keymap.set({'n', 'v'}, '<leader>cc', function()
  require('codecompanion').toggle()
end, { desc = '[C]ode [C]ompanion Chat' })

-- Utility maps

local function copy_to_system_clipboard(text)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
end

local function current_file_path()
  return vim.fn.expand('%:.')
end

local function exit_visual_mode()
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
end

local function current_visual_mode()
  local mode = vim.fn.mode()

  if mode == 'v' or mode == 'V' or mode == '\022' then
    return mode
  end

  return vim.fn.visualmode()
end

local function current_visual_region()
  local mode = current_visual_mode()
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getpos('.')
  local region = vim.fn.getregionpos(start_pos, end_pos, { type = mode, eol = true })

  return region, mode
end

local function visual_selection_bounds(region)
  if vim.tbl_isempty(region) then
    return nil
  end

  local start_pos = region[1][1]
  local end_pos = region[#region][2]

  return {
    start_line = start_pos[2],
    end_line = end_pos[2],
  }
end

local function format_line_range(start_line, end_line)
  if start_line == end_line then
    return tostring(start_line)
  end

  return string.format('%d-%d', start_line, end_line)
end

local function copy_visual_context(include_content)
  local region, mode = current_visual_region()
  local selection = visual_selection_bounds(region)
  if not selection then
    return
  end

  local location = string.format('%s:%s', current_file_path(), format_line_range(selection.start_line, selection.end_line))

  if not include_content then
    copy_to_system_clipboard(location)
    exit_visual_mode()
    return
  end

  local saved_register = vim.fn.getreg('z')
  local saved_register_type = vim.fn.getregtype('z')
  vim.cmd.normal({ args = { '"zy' }, bang = true })
  local selection_text = vim.fn.getreg('z')
  vim.fn.setreg('z', saved_register, saved_register_type)
  local payload = table.concat({ location, '', selection_text }, '\n')
  copy_to_system_clipboard(payload)
end

local function copy_current_line_context()
  local location = string.format('%s:%d', current_file_path(), vim.fn.line('.'))
  copy_to_system_clipboard(location)
end

vim.keymap.set('v', '<leader>ay', function()
  copy_visual_context(true)
end, { desc = '[A]I [Y]ank selection with context' })

vim.keymap.set('v', '<leader>al', function()
  copy_visual_context(false)
end, { desc = '[A]I copy [L]ocation' })

vim.keymap.set('n', '<leader>al', copy_current_line_context, { desc = '[A]I copy [L]ocation' })

-- Retab alternatives
vim.cmd [[command! -range=% -nargs=0 Tab2Space execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')']]
vim.cmd [[command! -range=% -nargs=0 Space2Tab execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')']]
