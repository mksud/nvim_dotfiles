# nvim_dotfiles

Neovim 0.12 configuration built around a single [`init.lua`](init.lua), with small mapping helpers in [`after/plugin/keymappings.lua`](after/plugin/keymappings.lua) and [`after/ftplugin`](after/ftplugin).

## Requirements

- Neovim 0.12
- `git` for `vim.pack`
- `rg` (`ripgrep`) for:
  - `grepprg`
  - `:Find` file completion
- Tree-sitter parser builds:
  - Linux: `make` and basic C/C++ development tools are required
  - Windows:
    - either install a Visual Studio/MSVC toolchain
    - or install GCC via MSYS2:
      - `winget install MSYS2.MSYS2`
      - in the MSYS2 `UCRT64` shell:
        - `pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain`
      - add `C:\msys64\ucrt64\bin` to `PATH`
