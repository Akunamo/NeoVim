# Neovim Configuration

Cross-platform Neovim setup (Windows, Linux, macOS) using `lazy.nvim`, Mason, LSP, Treesitter, Conform, and DAP.

---

## Folder Structure

```text
nvim/
├── init.lua                # Entry point: disables netrw, loads lazy + keymaps, core vim.opt
├── lazy-lock.json          # Auto-generated plugin version lockfile (keep in Git)
├── ftplugin/
│   └── java.lua            # Auto-runs on .java files to start nvim-jdtls
├── plugin/
│   └── floatterminal.lua   # Auto-runs at startup: persistent floating terminal (<leader>fj)
└── lua/
    └── config/             # All configs (loaded only when require()'d)
        ├── lazy.lua        # Bootstraps lazy.nvim and sets <Space> as leader
        ├── plugins.lua     # Master plugin list and lazy-loading triggers
        ├── keymap.lua      # Global keymaps, terminal splits, Angular file switcher
        ├── lsp.lua         # Mason + language servers + LSP keymaps
        ├── cmp.lua         # Autocomplete menu & snippets (loads on InsertEnter)
        ├── treesitter.lua  # Syntax highlighting & textobjects (vaf, vif, etc.)
        ├── conform.lua     # Code formatting (<leader>f)
        ├── clang_format.lua# Custom 4-space Allman clang-format rules (imported by conform)
        ├── auto_save.lua   # 3s debounce auto-save + format before save
        ├── dap.lua         # C/C++/Rust & JS/TS debugger (<leader>dt, <leader>dc)
        ├── cmaketools.lua  # CMake integration (loads only when CMakeLists.txt exists)
        ├── catppuccin.lua  # Mocha colorscheme
        ├── lualine.lua     # Statusline & tabline
        ├── telescope.lua   # Fuzzy finder & diagnostics picker
        ├── tree.lua        # File explorer sidebar (<leader>te / <leader>pv)
        ├── harpoon.lua     # File bookmarks (<leader>a, <C-e>)
        └── gitsigns.lua    # Git gutter signs & blame
