local function copy_to_system_clipboard(text)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
end

local function exit_visual_mode()
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
end

local function open_scratch_split()
  vim.cmd 'vertical topleft vnew'
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
end

local function run_command_in_scratch(command)
  if not command or command == '' then
    return
  end

  open_scratch_split()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(command))
end

local function prompt_command_in_scratch(default)
  vim.ui.input({ prompt = '*! ', default = default or '' }, function(command)
    run_command_in_scratch(command)
  end)
end

local function start_cmdline_completion(prefix)
  vim.api.nvim_feedkeys(prefix, 'n', false)
  vim.schedule(vim.fn.wildtrigger)
end

local find_files_cache

local function rg_find_files(arglead)
  if not find_files_cache then
    find_files_cache = vim.fn.systemlist { 'rg', '--files', '--color=never' }
    if vim.v.shell_error ~= 0 then
      find_files_cache = {}
    end
  end

  if arglead == '' then
    return find_files_cache
  end

  return vim.fn.matchfuzzy(find_files_cache, arglead)
end

vim.api.nvim_create_user_command('Find', function(opts)
  if opts.args == '' then
    return
  end

  if vim.fn.filereadable(opts.args) == 0 then
    return
  end

  vim.cmd.edit {
    args = { vim.fn.fnameescape(opts.args) },
    mods = opts.smods,
  }
end, {
  nargs = '?',
  bar = true,
  complete = function(arglead)
    return rg_find_files(arglead)
  end,
})

vim.api.nvim_create_autocmd('CmdlineLeave', {
  callback = function()
    if find_files_cache then
      find_files_cache = nil
    end
  end,
})

local function copy_visual_context(include_content)
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\022' then
    mode = vim.fn.visualmode()
  end

  local start_pos = vim.fn.getpos 'v'
  local end_pos = vim.fn.getpos '.'
  local region = vim.fn.getregion(start_pos, end_pos, { type = mode, eol = true })
  if vim.tbl_isempty(region) then
    return
  end

  local start_line = math.min(start_pos[2], end_pos[2])
  local end_line = math.max(start_pos[2], end_pos[2])
  local line_range = start_line == end_line and tostring(start_line) or string.format('%d-%d', start_line, end_line)
  local location = string.format('%s:%s', vim.fn.expand '%:.', line_range)

  if not include_content then
    copy_to_system_clipboard(location)
    exit_visual_mode()
    return
  end

  local selection_text = table.concat(region, '\n')
  local payload = table.concat({ location, '', selection_text }, '\n')
  copy_to_system_clipboard(payload)
  exit_visual_mode()
end

local function copy_current_line_context()
  local location = string.format('%s:%d', vim.fn.expand '%:.', vim.fn.line '.')
  copy_to_system_clipboard(location)
end

local function copy_full_file_path()
  copy_to_system_clipboard(vim.fn.expand '%:p')
end

local function prime_current_word_search()
  local cword = vim.fn.expand '<cword>'
  if cword == '' then
    return nil
  end

  vim.fn.setreg('/', cword)
  vim.o.hlsearch = true
  vim.fn.search(cword, 'cw')
  return cword
end

local function grep_current_word(flag)
  local cword = prime_current_word_search()
  if not cword then
    return
  end

  vim.cmd(string.format('silent grep! %s %s', flag, cword))
  vim.cmd.copen()
end

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')
vim.keymap.set('n', 'k', function()
  return vim.v.count == 0 and 'gk' or 'k'
end, { expr = true })
vim.keymap.set('n', 'j', function()
  return vim.v.count == 0 and 'gj' or 'j'
end, { expr = true })
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('n', '<leader><space>', function()
  start_cmdline_completion ':b '
end, { silent = true, desc = 'Switch buffers' })
vim.keymap.set('n', '<leader>c', prompt_command_in_scratch, { desc = 'Run command in scratch split' })
vim.keymap.set('n', '<leader>sw', function()
  grep_current_word '-s'
end, { silent = true, desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sl', function()
  grep_current_word '-l'
end, { silent = true, desc = '[S]earch with rg -[L]' })
vim.keymap.set('n', '<leader>sf', function()
  start_cmdline_completion ':Find '
end, { silent = true, desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', open_scratch_split, { desc = 'Open empty scratch split' })

vim.keymap.set('v', '<leader>ay', function()
  copy_visual_context(true)
end, { desc = '[A]I [Y]ank selection with context' })
vim.keymap.set('n', '<leader>al', copy_current_line_context, { desc = '[A]I copy [L]ocation' })
vim.keymap.set('v', '<leader>al', function()
  copy_visual_context(false)
end, { desc = '[A]I copy [L]ocation' })
vim.keymap.set('n', '<leader>ap', copy_full_file_path, { desc = '[A]I copy full [P]ath' })
