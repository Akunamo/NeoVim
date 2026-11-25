# Neovim Configuration

Cross-platform Neovim configuration (Windows, Linux, macOS) built with `lazy.nvim`, Mason, LSP, Treesitter (`main` branch), Conform, and DAP.

---

## 1. Architecture Mind Map

```text
Neovim Startup (init.lua)
│
├── 1. PLUGIN MANAGER (lazy.nvim)
│   └── Downloads, locks, and lazy-loads plugins from GitHub (:Lazy)
│
├── 2. LANGUAGE INTELLIGENCE (The "Brain")
│   ├── mason.nvim ─────────────── Installs external tools & servers (:Mason)
│   ├── mason-lspconfig / lsp-zero ── Connects servers (clangd, ts_ls, lua_ls, etc.)
│   ├── nvim-jdtls ─────────────── Standalone Java launcher (ftplugin/java.lua)
│   └── nvim-treesitter ────────── Syntax highlighting & code textobjects (vaf, vif)
│
├── 3. AUTOCOMPLETE & TYPING (The "Hands")
│   ├── nvim-cmp ───────────────── Completion menu (:CmpStatus, loads on InsertEnter)
│   │   ├── nvim_lsp ───────────── Suggestions from your LSP brain
│   │   ├── LuaSnip ────────────── Code snippets (friendly-snippets)
│   │   ├── path ───────────────── File paths
│   │   └── buffer ─────────────── Fallback words (only if primary sources return 0)
│   ├── nvim-autopairs ─────────── Auto-closes (), {}, "", ''
│   └── auto-save.nvim ─────────── Auto-saves after 3s idle (formats via Conform first)
│
├── 4. FORMATTING (The "Cleaner")
│   └── conform.nvim (<leader>f) ── Runs external formatters (:ConformInfo)
│       ├── clang-format ───────── C, C++, Java (4-space indent, Allman braces)
│       └── prettierd / prettier ── JS, TS, HTML, CSS, SCSS
│
└── 5. WORKFLOW, UI & TOOLS (The "Workspace")
    ├── Navigation ─────────────── telescope, harpoon, nvim-tree, vim-tmux-navigator
    ├── Git ────────────────────── gitsigns, lazygit, vim-fugitive
    ├── Debugging & Build ──────── nvim-dap (+ dap-ui, virtual-text), cmake-tools
    └── Visuals & History ──────── catppuccin (mocha), lualine, undotree, floatterminal
```

---

## 2. Folder Structure & How Loading Works

Neovim treats each top-level folder differently at startup:

| Folder / File | Auto-runs? | When it runs | Role in this config |
| :--- | :--- | :--- | :--- |
| **`init.lua`** | Yes | Very first | Disables `netrw`, loads `lazy` + `keymap`, sets core `vim.opt` options |
| **`plugin/`** | Yes | Right after `init.lua` | Standalone scripts that always load (`floatterminal.lua`) |
| **`lua/config/`** | **No** | Only when `require()`'d | All plugin configs—loaded on demand by `lazy.nvim` triggers |
| **`ftplugin/`** | Yes | On matching filetype | Per-language launchers (`java.lua` runs when opening `.java` files) |


```text
nvim/
├── init.lua                 # Entry point: disables netrw, boots lazy + keymaps, core options
├── lazy-lock.json           # Auto-generated plugin version lockfile (commit to Git)
├── ftplugin/
│   └── java.lua             # Launches nvim-jdtls when opening .java files (cross-platform)
├── plugin/
│   └── floatterminal.lua    # Persistent floating terminal (<leader>fj)
└── lua/
    └── config/              # Dormant until require("config.<name>") is called
        ├── lazy.lua         # Bootstraps lazy.nvim and sets <Space> as leader
        ├── plugins.lua      # Master plugin list + lazy-loading triggers
        ├── keymap.lua       # Global shortcuts, terminals, tabs, Angular file switcher
        ├── lsp.lua          # Mason + language servers + LSP buffer keymaps
        ├── cmp.lua          # Autocomplete menu & snippets (loads on InsertEnter)
        ├── treesitter.lua   # Syntax highlighting, 100KB guard, textobjects, manual folds
        ├── conform.lua      # Formatter routing (<leader>f / :Format)
        ├── clang_format.lua # Custom 4-space Allman clang-format rules (used by conform)
        ├── auto_save.lua    # 3s debounce auto-save; runs conform.format() before saving
        ├── dap.lua          # C/C++/Rust (cppdbg) & JS/TS (pwa-node) debug adapters
        ├── cmaketools.lua   # CMake integration (loads only when CMakeLists.txt exists)
        ├── catppuccin.lua   # Catppuccin Mocha colorscheme
        ├── lualine.lua      # Statusline & tabline (loads on VeryLazy)
        ├── telescope.lua    # Fuzzy finder & LSP diagnostic pickers
        ├── tree.lua         # File explorer sidebar (<leader>te / <leader>pv)
        ├── harpoon.lua      # File bookmarks (<leader>a, <C-e>)
        └── gitsigns.lua     # Git gutter signs & optional inline blame
```

### How `lazy.nvim` Triggers Work
* **Immediate (`priority = 1000` / `lazy = false`):** `catppuccin`, `nvim-treesitter`.
* **`VeryLazy` (right after startup frame):** `lualine`, `nvim-tree`, `telescope`, `harpoon`.
* **`BufReadPre` / `BufNewFile` (when opening a file):** `lsp-zero` (+ Mason/LSPs), `gitsigns`, `conform`, `auto-save`.
* **`InsertEnter` (when you start typing):** `nvim-cmp`, `nvim-autopairs`.
* **On-demand (`keys` / `cmd` / `ft` / `cond`):** `nvim-dap` (`<leader>dt`/`dc`), `undotree` (`<leader>u`), `vim-fugitive` (`<leader>gs`), `lazygit` (`<leader>lg`), `vim-tmux-navigator`, `cmake-tools` (C/C++/CMake + `CMakeLists.txt`), `render-markdown` (`.md`).

---

## 3. Troubleshooting & Diagnostics Cheatsheet

When something acts up, find the symptom below to jump straight to the right layer:

| Symptom | Responsible Layer | What to Run / Check First |
| :--- | :--- | :--- |
| **Lualine shows warnings/errors (`⚠ 3`)** | LSP Diagnostics | Press `<leader>td` (current file) or `<leader>tD` (workspace), or jump with `]d` / `[d` and inspect with `<leader>vd` |
| **Plugin fails or prompts for GitHub login** | `lazy.nvim` / Git | Run `:Lazy`, inspect the failing plugin for a repo typo, or clear stale Git Credential Manager tokens |
| **Red squiggles or missing LSP features** | LSP / Mason | Check `:Mason`, or run `:lua print(vim.inspect(vim.lsp.get_clients({ bufnr = 0 })))` |
| **Java (`System.out`) cannot be resolved** | `nvim-jdtls` | Check `ftplugin/java.lua` and verify `:echo $JAVA_HOME` points to JDK 17 or 21 (`lsp.lua` skips `jdtls` intentionally) |
| **Autocomplete menu doesn't appear** | `nvim-cmp` | Enter Insert mode and run `:CmpStatus` to verify `nvim_lsp` is listed as ready |
| **Formatting doesn't match style rules** | `conform.nvim` | Run `:ConformInfo` to confirm `clang_format` or `prettierd` is ready (not falling back to LSP) and check for a local `.clang-format` |
| **Treesitter highlighting/textobjects missing** | `nvim-treesitter` | Place cursor on a keyword and run `:Inspect` (look for `@keyword` etc.), or run `:TSUpdate` |
| **`tree-sitter build` fails on Windows (`cl.exe`)** | System `CC` / CLI | Confirm `tree-sitter --version` and `gcc --version` work, and `:lua print(vim.inspect(vim.env.CC))` prints `"gcc"` |

---

## 4. Keymaps Reference

`<leader>` is **Space**.

### General & Editing
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<C-CR>` | Normal | Insert blank line below without entering Insert mode |
| `<leader>w` | Normal | Toggle line wrap |
| `<C-o>` / `<C-i>` | Normal | Jump back / forward and center cursor (`zz`) |
| `<C-c>` / `<C-v>` | Visual | Copy / paste with system clipboard |
| `<leader>f` | Normal | Format current buffer via Conform (`:Format`) |
| `<leader>u` | Normal | Toggle Undotree visual undo history |

### Windows, Tabs & File Explorer
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<A-w>` | Normal | Cycle split windows |
| `<C-h/j/k/l/\>` | Normal | Navigate splits / Tmux panes (`vim-tmux-navigator`) |
| `<M-h>` / `<M-l>` | Normal | Previous / next tab |
| `<M-n>` / `<M-o>` | Normal | New tab / close all other tabs (`:tabonly`) |
| `<M-q>` | Normal | Force close current buffer (`:bd!`) |
| `<leader>te` / `<leader>pv` | Normal | Toggle NvimTree file explorer |

### Terminals
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<leader>fj` | Normal | Toggle persistent 80% floating terminal (`plugin/floatterminal.lua`) |
| `<leader>st` | Normal | Open 15-line terminal split at bottom |
| `<C-t>` | Normal | Open terminal in current window & enter Terminal mode |
| `<Esc><Esc>` / `<leader>ti` | Terminal | Exit Terminal mode back to Normal mode |

### Telescope & Harpoon
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<leader>fo` | Normal | Find all files in project |
| `<leader>ff` | Normal | Find files in current buffer's directory |
| `<C-p>` | Normal | Find Git-tracked files |
| `<leader>ps` | Normal | Live grep across project (requires `ripgrep`) |
| `<leader>tf` | Normal | Search open buffers |
| `<leader>ts` / `<leader>tws` | Normal | LSP document symbols / workspace symbols |
| `<leader>td` / `<leader>tD` | Normal | LSP diagnostics in current file / entire workspace |
| `<M-j>` | Normal | Telescope jumplist |
| `<leader>a` / `<C-e>` | Normal | Harpoon: bookmark current file / open quick menu |
| `<M-i>` / `<M-t>` / `<M-f>` / `<M-s>` | Normal | Harpoon: jump to bookmarked file 1 / 2 / 3 / 4 |

### LSP & Autocomplete
| Key | Mode | Action |
| :--- | :--- | :--- |
| `gd` / `K` | Normal | Go to definition / hover documentation |
| `<leader>re` | Normal | Code actions (quick fixes, imports) |
| `<leader>vrr` / `<leader>vrn` | Normal | Find references / rename symbol across project |
| `[d` / `]d` | Normal | Previous / next diagnostic |
| `<leader>vd` | Normal | Open floating diagnostic popup for current line |
| `<C-h>` | Insert | LSP signature help |
| `<C-Space>` / `<CR>` / `<Tab>` / `<S-Tab>` | Insert | Trigger completion / confirm / next / previous item |

### Treesitter Textobjects
Combine with `v` (select), `d` (delete), `c` (change), or `y` (yank) — e.g. `vaf`, `dif`, `yac`:
| Object | Selects |
| :--- | :--- |
| `af` / `if` | Outer / inner function |
| `ac` / `ic` | Outer / inner class |
| `ab` / `ib` | Outer / inner code block |

### Git, Debugging, CMake & Angular
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<leader>gs` | Normal | Open Fugitive Git status (`:Git`) |
| `<leader>lg` | Normal | Open LazyGit (`:LazyGit`) |
| `<leader>dt` / `<leader>dc` | Normal | DAP: toggle breakpoint / start or continue debugging |
| `<leader>co` / `<leader>cb` | Normal | CMake configure (`-S . -B build`) / build (`--build build`) |
| `<leader>lt` / `<leader>lh` / `<leader>ls` / `<leader>le` | Normal | Angular switcher: `.ts` / `.html` / `.scss` or `.css` / `.spec.ts` |

---

## 5. System Prerequisites vs. Inside Neovim

### Install Separately on Each Machine (OS Level)
Neovim calls these external binaries—install them before first launch:

| Tool | Required For | Windows (Winget / Manual) | Linux / macOS |
| :--- | :--- | :--- | :--- |
| **Neovim (0.10+)** | Editor core | `winget install Neovim.Neovim` | `brew install neovim` / distro pkg |
| **Git** | `lazy.nvim`, Fugitive, Gitsigns | `winget install Git.Git` | `brew install git` / `apt install git` |
| **C Compiler (`gcc` / `clang`)** | Compiling Treesitter parsers | MSYS2 (`ucrt64`) or WinLibs + set `CC=gcc` | `xcode-select --install` / `build-essential` |
| **tree-sitter CLI** | Building Treesitter parsers (`main` branch) | `winget install tree-sitter.tree-sitter-cli` | `brew install tree-sitter-cli` / `npm i -g tree-sitter-cli` |
| **Ripgrep (`rg`)** | Telescope live grep (`<leader>ps`) | `winget install BurntSushi.ripgrep.MSVC` | `brew install ripgrep` / `apt install ripgrep` |
| **Node.js & npm** | `ts_ls`, `angularls`, `eslint`, `prettierd`, JS DAP | `winget install OpenJS.NodeJS.LTS` | `brew install node` / `nvm` |
| **Java JDK (17 or 21)** | `jdtls` (requires `JAVA_HOME`) | `winget install EclipseAdoptium.Temurin.21.JDK` | `brew install openjdk@21` / distro pkg |
| **LazyGit** | `<leader>lg` Git UI | `winget install JesseDuffield.lazygit` | `brew install lazygit` |
| **CMake** | `cmake-tools.nvim`, `<leader>co` / `<leader>cb` | `winget install Kitware.CMake` | `brew install cmake` / `apt install cmake` |
| **Nerd Font** | Icons in Lualine, NvimTree, Gitsigns | Install e.g. JetBrainsMono Nerd Font & set in terminal | Same |

### Auto-Installed Inside Neovim (First Launch)
1. **Plugins (`lazy.nvim`):** Bootstraps itself and clones all plugins in `lua/config/plugins.lua` pinned to `lazy-lock.json`.
2. **LSP Servers (`mason-lspconfig`):** Auto-installs `clangd`, `jdtls`, `ts_ls`, `eslint`, `lua_ls`, `rust_analyzer`, `html`, `angularls`, and `emmet_ls`.
3. **Treesitter Parsers (`nvim-treesitter`):** Auto-compiles parsers for `c`, `cpp`, `java`, `javascript`, `typescript`, `lua`, `vim`, `vimdoc`, `query`, `markdown`, `markdown_inline`, and `html`.

### One-Time Manual Install Inside Neovim (Formatters & Debuggers)
`mason-lspconfig` only auto-installs language servers. Run this once inside Neovim on a new machine to install formatters and debug adapters:

```vim
:MasonInstall clang-format prettierd prettier cpptools js-debug-adapter
```

---

## 6. Fresh Machine Setup Checklist

1. Install the OS prerequisites above.
   * **Windows only:** Set User Environment Variables `CC=gcc` (with `gcc.exe` on `PATH`) and `JAVA_HOME` pointing to your JDK folder, then open a fresh PowerShell window.
2. Clone this repo into your Neovim config folder:
   * **Windows (PowerShell):** `git clone <your-repo-url> "$env:LOCALAPPDATA\nvim"`
   * **Linux / macOS:** `git clone <your-repo-url> ~/.config/nvim`
3. Launch `nvim` and wait for `lazy.nvim`, Mason LSPs, and Treesitter parsers to finish installing.
4. Run `:MasonInstall clang-format prettierd prettier cpptools js-debug-adapter`.
5. Restart `nvim` and run `:checkhealth` to confirm everything is healthy.
