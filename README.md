# nvim_dotfiles

Neovim 0.12 configuration built around a single [`init.lua`](init.lua), with small mapping helpers in [`after/plugin/keymappings.lua`](after/plugin/keymappings.lua) and [`after/ftplugin`](after/ftplugin).

## Requirements

- Neovim 0.12
- `git` for `vim.pack`
- `rg` (`ripgrep`) for:
  - `grepprg`
  - `:Find` file completion
- `make` is useful if `tree-sitter-cli` needs to build anything locally
