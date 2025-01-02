local M = {}

function M.setup()
  require('nvim-treesitter.configs').setup {
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = {
      'c',
      'lua',
      'cpp',
      'c_sharp',
      'css',
      'html',
      'java',
      'json',
      'make',
      'python',
      'javascript',
      'typescript',
      'vim',
      'yaml',
      'rust',
    },

    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,

    highlight = {
      -- `false` will disable the whole extension
      enable = true,
    },

    -- For incremental selection based on syntax
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '(',
        node_incremental = '(',
        scope_incremental = '<leader>(',
        node_decremental = ')',
      },
    },

    -- nvim-treesitter-textobjects
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },

      swap = {
        enable = true,
        swap_next = {
          ['<leader>cx'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>cX'] = '@parameter.inner',
        },
      },

      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },

      lsp_interop = {
        enable = true,
        border = 'none',
        peek_definition_code = {
          ['<leader>cf'] = '@function.outer',
          ['<leader>cF'] = '@class.outer',
        },
      },
    },
  }
end

return M
