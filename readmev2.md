# Neovim Config Documentation

> **Updated after a performance pass.** Startup time went from ~5519ms → ~216ms.
> Changes: moved several plugin configs out of `after/plugin/` (always eager) into
> `lua/config/` (loaded via `config = function()` in the plugin spec, with proper
> lazy triggers). Sections below are marked `✅ CURRENT`, `⚠️ DEPRECATED`, or
> `🆕 NEW` to track what changed.

---

## File Structure

```
📁 nvim/
│
├── init.lua                    # Entry point — first file Neovim loads
├── lazy-lock.json              # Auto-generated — locks plugin versions
│
├── 📁 lua/
│   └── 📁 config/
│       ├── lazy.lua            # Bootstraps lazy.nvim plugin manager
│       ├── keymaps.lua         # Global keymaps
│       ├── plugins.lua         # Plugin list and declarations
│       ├── treesitter.lua      # 🆕 NEW — treesitter setup, moved out of plugins.lua
│       ├── cmaketools.lua      # 🆕 NEW — cmake-tools setup, moved out of after/plugin/
│       └── clang_format.lua    # Custom clang-format formatter definition
│           (previously remap.lua, consider merging into keymaps.lua)
│
├── 📁 plugin/
│   └── floatterminal.lua       # Auto-loaded — floating terminal implementation
│
└── 📁 after/
    └── 📁 plugin/              # Auto-loaded AFTER plugins — remaining eager configs
            auto-save.lua
            catppuccin.lua
            clang_format.lua    # ← renamed from clang-format.lua (hyphens break require())
            cmp.lua
            conform.lua
            dap.lua
            fugitive.lua
            gitsigns.lua
            harpoon.lua
            lsp.lua
            lualine.lua
            telescope.lua
            tree.lua
            undotree.lua
            ⚠️ cmaketools.lua  — DEPRECATED, see lua/config/cmaketools.lua below.
                                  Delete this file, its logic now lives in lua/config/
                                  and is wired up via a lazy-loaded plugin spec.
```

---

## How Config Loading Works

```
Neovim starts
    │
    ├── reads init.lua                         (entry point)
    │       ├── require("config.lazy")         (sets up plugin manager)
    │       └── require("config.keymaps")      (global keymaps)
    │
    ├── lazy.nvim loads plugins.lua's spec table
    │       ├── plugins with no trigger         → loaded immediately (start phase)
    │       ├── plugins with ft/cmd/keys/event   → loaded on-demand
    │       │       └── their `config` function calls require("config.X")
    │       │           for anything moved out of after/plugin/
    │       └── plugins with `cond`              → skipped entirely if cond() is false
    │
    ├── auto-loads plugin/*.lua                (after init.lua, always eager)
    │       └── floatterminal.lua
    │
    └── auto-loads after/plugin/*.lua          (last — always eager, no exceptions)
            └── whatever hasn't been migrated to lua/config/ yet
```

### Key Rules
| Directory | Loaded by | When | Can be lazy? |
|---|---|---|---|
| `init.lua` | Neovim | First, always | No |
| `lua/` | Only when `require()`'d | Whenever something requires it | Yes — this is *how* lazy-loading works |
| `plugin/` | Neovim automatically | After init.lua | No — always eager, no exceptions |
| `after/plugin/` | Neovim automatically | After everything else | **No — always eager, no exceptions.** This was the root cause of most of the startup slowdown. There is no folder name or convention that makes files in here conditional — see `lua/config/plugins.lua` entries with `event`/`ft`/`cmd`/`keys`/`cond` for the actual mechanism that makes loading conditional. |

> **Why this matters:** every file that used to live in `after/plugin/` runs on
> *every* startup, for *every* filetype, whether or not you need that plugin in
> the current session. `lua/config/` files only run when something `require()`s
> them — which, if that `require()` call lives inside a plugin spec's `config`
> function, only happens once lazy.nvim actually loads that plugin (i.e. once
> its `event`/`ft`/`cmd`/`keys` trigger fires, or immediately if the spec has no
> trigger at all).

---

## Root Files

---

### `init.lua`
**Entry point of the entire config.**

```lua
require("config.lazy")     -- bootstraps lazy.nvim and loads all plugins
require("config.keymaps")  -- loads global keymaps
```

#### Responsibilities
- Loads plugin manager and keymaps via `require()`
- Sets core editor options via `vim.opt`
- Configures DAP (debugger) listeners and C++/C/Rust debug adapters
- Sets cursor behavior and terminal behavior

#### Key Settings
| Option | Value | Effect |
|---|---|---|
| `vim.opt.number` | `true` | Show line numbers |
| `vim.opt.relativenumber` | `true` | Show relative line numbers |
| `vim.opt.tabstop` | `4` | Tab width of 4 spaces |
| `vim.opt.shiftwidth` | `4` | Indent width of 4 spaces |
| `vim.opt.expandtab` | `true` | Convert tabs to spaces |
| `vim.opt.smartindent` | `true` | Smart code indentation |
| `vim.opt.autochdir` | `false` | Don't auto-change working directory |
| `vim.o.exrc` | `true` | Load project-local `.nvim.lua` config files |
| `vim.o.secure` | `true` | Sandbox exrc files for security |

#### DAP Listeners (Auto UI)
Opens/closes dapui automatically based on debug session state:
```
session attaches or launches → dapui.open()
session terminates or exits  → dapui.close()
```

#### C++ Debug Adapter
Registers `cppdbg` adapter using the `cpptools` binary installed by Mason. Also aliased to C and Rust:
```lua
dap.configurations.c    = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
```

---

### `lazy-lock.json`
**Auto-generated by lazy.nvim. Do not edit manually.**

Locks every plugin to a specific commit hash. Ensures reproducible installs across machines. Commit this file to version control.

---

## `lua/config/` Files

> These files are **never auto-loaded on their own**. They only run when
> explicitly `require()`'d — typically from inside a plugin spec's `config`
> function in `plugins.lua`, which means their execution timing is controlled
> by that plugin's lazy-load trigger (or immediately, if the plugin has none).

---

### `lua/config/lazy.lua`
**Bootstraps lazy.nvim and initializes the plugin system.**

#### What it does
1. Checks if lazy.nvim is installed at `vim.fn.stdpath("data")/lazy/lazy.nvim`
2. If missing, clones it from GitHub automatically
3. Sets `mapleader = " "` (spacebar) and `maplocalleader = "\\"`
4. Calls `require("lazy").setup()` with your plugin list

#### Important Note
`mapleader` must be set **before** lazy loads — otherwise keymaps defined inside plugin specs use the wrong leader key.

```lua
require("lazy").setup({
    spec             = require("config.plugins"),  -- your plugin list
    install          = { colorscheme = { "habamax" } },
    checker          = { enabled = true },          -- notify of plugin updates
})
```

---

### `lua/config/plugins.lua`
**Master list of all plugins. Returned as a table consumed by lazy.nvim.**

This file `return`s a table — lazy.nvim reads it via `spec = require("config.plugins")`.

#### Plugin List

| Plugin | Purpose | Load trigger |
|---|---|---|
| `folke/lazy.nvim` | Plugin manager (manages itself) | eager |
| `nvim-lualine/lualine.nvim` | Status bar | eager (candidate for `event = "VeryLazy"`, not yet done) |
| `nvim-tree/nvim-tree.lua` | File explorer sidebar | eager (candidate for `cmd`, not yet done) |
| `nvim-telescope/telescope.nvim` | Fuzzy finder | eager |
| `ThePrimeagen/harpoon` | Quick file bookmarks and navigation | eager |
| `mbbill/undotree` | Visual undo history tree | eager |
| `nvim-treesitter/nvim-treesitter` | Syntax parsing and highlighting | eager (`lazy = false`, intentional — see below) |
| `tpope/vim-fugitive` | Git client inside Neovim | eager |
| `VonHeikemen/lsp-zero.nvim` | LSP setup helper | eager |
| `neovim/nvim-lspconfig` | LSP server configuration | eager |
| `williamboman/mason.nvim` | Language server installer | eager |
| `williamboman/mason-lspconfig.nvim` | Bridges mason and lspconfig | eager |
| `hrsh7th/nvim-cmp` | Autocompletion engine | eager |
| `L3MON4D3/LuaSnip` | Snippet engine | eager |
| `catppuccin/nvim` | Colorscheme | eager, `priority = 1000` (must load first) |
| `pocco81/auto-save.nvim` | Automatic file saving | eager |
| `mfussenegger/nvim-dap` | Debug Adapter Protocol client | eager |
| `rcarriga/nvim-dap-ui` | Debug UI panels | eager |
| `theHamsta/nvim-dap-virtual-text` | Inline debug variable values | eager |
| `Civitasv/cmake-tools.nvim` | CMake integration | 🆕 `ft = {"cpp","c","cmake"}` + `cond` (project must contain `CMakeLists.txt`) |
| `stevearc/conform.nvim` | Code formatting | eager |
| `christoomey/vim-tmux-navigator` | Tmux/split navigation | `cmd`/`keys` (already scoped) |
| `lewis6991/gitsigns.nvim` | Git change indicators in sign column | eager |
| `kdheepak/lazygit.nvim` | Lazygit terminal UI inside Neovim | eager (candidate for `cmd = "LazyGit"`, not yet done) |
| `MeanderingProgrammer/render-markdown.nvim` | Rendered markdown preview | eager (candidate for `ft = "markdown"`, not yet done) |

#### ⚠️ DEPRECATED: Treesitter Config inline in plugins.lua
Previously configured directly inside the plugin spec via `config = function() ... end`
with the full setup table written in `plugins.lua` itself. **This has been moved**
to `lua/config/treesitter.lua` — see that section below for the current setup and
what changed. The `plugins.lua` entry is now just:

```lua
{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,   -- intentionally eager — treesitter is foundational (highlighting,
                    -- folding hooks, other plugins depend on its parsers), so
                    -- lazy-triggering it just moves the cost to first buffer open
                    -- with a visible flash of unhighlighted text. Not worth it.
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("config.treesitter")
    end,
},
```

#### 🆕 NEW: cmake-tools.nvim now conditionally loaded
```lua
{
    "Civitasv/cmake-tools.nvim",
    ft = { "cpp", "c", "cmake" },
    cond = function()
        return vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1
    end,
    config = function()
        require("config.cmaketools")
    end,
},
```
`cond` runs once at startup — if it returns `false`, lazy.nvim skips registering
the plugin entirely for that session (verified via `:Lazy`, shows as not loaded
in non-CMake projects like the Angular one). `ft` further restricts *when* it
loads within CMake projects — only once you open a `.c`/`.cpp`/`.cmake` file, not
at `start`.

> **Known caveat:** `cond` uses `vim.fn.getcwd()`, which is Neovim's current
> working directory, not "the directory of the file you opened." If Neovim is
> ever launched from a subfolder rather than the project root, this check will
> miss a `CMakeLists.txt` that exists further up the tree. Not yet hit in
> practice, but if it becomes a problem, switch to an upward search:
> `vim.fs.find("CMakeLists.txt", { upward = true, path = vim.fn.expand("%:p:h") })[1] ~= nil`

#### Catppuccin Config (still inline in plugins.lua — unchanged)
- `transparent_background = true` — shows terminal background
- `no_italic = true` — disables all italics
- Base colors overridden to pure black `#000000`

---

### `lua/config/keymaps.lua`
**Global keymaps not tied to any specific plugin.**

| Key | Mode | Action |
|---|---|---|
| `<C-CR>` | Normal | Insert blank line below without entering insert mode |
| `<leader>co` | Normal | Run `cmake -S . -B build` in a split terminal |
| `<leader>cb` | Normal | Run `cmake --build build` in a split terminal |
| `<leader>st` | Normal | Open a small terminal pane at the bottom (15 lines) |
| `<M-j>` | Normal | Open Telescope jumplist |
| `<M-h>` | Normal | Previous tab |
| `<M-l>` | Normal | Next tab |
| `<M-n>` | Normal | New tab |
| `<C-c>` | Visual | Copy selection to system clipboard |
| `<C-v>` | Visual | Paste from system clipboard |

> ⚠️ Still pending: `<A-w>` (window cycling) currently lives in `after/plugin/tree.lua`,
> gated behind nvim-tree loading. Should be moved here since it's unrelated to
> nvim-tree and shouldn't depend on the tree plugin having loaded first.

---

### 🆕 `lua/config/treesitter.lua`
**Treesitter setup — parsing, highlighting, textobjects, folding.**

Moved here from an inline config block in `plugins.lua`. Three real changes made
during the move, beyond just relocating the file:

1. **Fixed API name.** Was `require("nvim-treesitter.config")` (singular) —
   likely an incorrect module name that may have silently failed to apply the
   whole `.setup()` call. Corrected to `require("nvim-treesitter.configs")`
   (plural), which is the actual module.

2. **Removed unconditional C/Rust highlight disable.** The original `disable`
   function had `if lang == "c" or lang == "rust" then return true end` before
   the size check — meaning C and Rust files *never* got treesitter highlighting,
   regardless of file size, intentional or not. Confirmed with the user this was
   unwanted; removed. Highlighting is now disabled only based on file size
   (>100KB), for any language.

3. **Folding changed from `expr` to `manual`.** Original set
   `foldmethod = "expr"` + `foldexpr = "nvim_treesitter#foldexpr()"` globally,
   for every buffer. This recomputes fold levels by walking the treesitter
   syntax tree on scroll, redraw, and edit — a real ongoing cost, especially on
   large files. Since folding wasn't actually being used, switched to
   `foldmethod = "manual"`, which does zero background computation — folds only
   exist if explicitly created with `zf{motion}`. This isn't a large-file-only
   guard; it removes the cost entirely, for every file.

```lua
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "c", "cpp", "javascript", "typescript", "lua", "vim", "vimdoc",
        "query", "markdown", "markdown_inline", "html"
    },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        disable = function(lang, buf)
            local max_filesize = 100 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        additional_vim_regex_highlighting = false,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
            },
        },
    },
})

-- Angular HTML fix
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.component.html",
    callback = function()
        vim.bo.filetype = "html"
    end,
})

-- Folding: manual, since folds aren't used — see item 3 above
vim.o.foldmethod = "manual"
```

---

### 🆕 `lua/config/cmaketools.lua`
**CMake integration setup — moved here from `after/plugin/cmaketools.lua`.**

Content unchanged from the original — no logic was modified, only relocated.
Still contains the full `cmake-tools` setup: build directory macros, compile
commands linking, DAP debug config for `codelldb`, executor/runner settings for
quickfix/toggleterm/overseer/terminal, and notification spinner config.

The only functional change is *when* this file runs — see the `cmake-tools.nvim`
entry under `lua/config/plugins.lua` above for the `ft` + `cond` gating that now
controls it. Previously this ran on every single startup via `after/plugin/`;
now it only runs when opening a C/C++/CMake file inside a project that actually
has a `CMakeLists.txt`.

---

### `lua/config/clang_format.lua`
**Custom formatter definition consumed by conform.nvim.**

> This file is `require()`'d by `conform.lua` — it is NOT auto-loaded.
> It must `return` a table because the caller needs the value.

```lua
return {
    command = "clang-format",
    args    = function(ctx) ... end,  -- dynamic args, supports range formatting
    stdin   = true,
}
```

#### Style Config (via `--style` arg)
| Option | Value | Effect |
|---|---|---|
| `BasedOnStyle` | `Google` | Start from Google C++ style |
| `BreakBeforeBraces` | `Allman` | Opening `{` on its own line |
| `AllowShortFunctionsOnASingleLine` | `None` | Never collapse functions |
| `AllowShortIfStatementsOnASingleLine` | `Never` | Never collapse if statements |
| `AllowShortLoopsOnASingleLine` | `false` | Never collapse loops |

#### Range Formatting
When you format a visual selection instead of the whole file, `ctx.range` is populated. The config converts the selection to byte offsets and passes `--offset` and `--length` to clang-format so only that portion is formatted.

---

## `plugin/` Files

> Auto-loaded by Neovim after `init.lua`. No `require()` needed.

---

### `plugin/floatterminal.lua`
**Implements a toggleable floating terminal window.**

#### Keymaps
| Key | Mode | Action |
|---|---|---|
| `<leader>fj` | Normal | Toggle the floating terminal |
| `<Esc><Esc>` | Terminal | Exit terminal mode back to normal mode |

#### How It Works
Maintains a persistent state table:
```lua
local state = {
    floating = { buf = -1, win = -1 }
}
```

On toggle:
- If window is **not valid** → create a new floating window, reuse the existing buffer if valid, start a terminal if not
- If window **is valid** → hide it (buffer stays alive in background)

This means the terminal **persists between toggles** — your shell session, history, and running processes survive closing the float.

#### Window Properties
- Size: 80% of editor width and height
- Position: centered
- Style: minimal with rounded border

---

## `after/plugin/` Files

> All files here are auto-loaded by Neovim last, after all plugins are loaded —
> **unconditionally, on every startup, regardless of filetype or project.**
> This is the performance-sensitive part of the config. Files listed below are
> still in this state; migrating them to `lua/config/` (like treesitter and
> cmake-tools already have been) is the main remaining lever for further startup
> improvements. Current remaining cost, from the last profile: `lualine.lua`
> (~32ms) and `lsp.lua` (~29ms) are the biggest, followed by `cmp.lua`,
> `catppuccin.lua`, `cmp_nvim_lua.lua`, and `harpoon.lua` in the single-digit-ms
> range each. Not yet migrated — deferred by choice, not forgotten.

---

### `after/plugin/auto-save.lua`
**Automatically saves files after you stop typing.**

#### How It Works
```
you stop typing
    → 1000ms debounce timer fires
        → condition() checks pass?
            → conform formats the buffer first
                → file is saved to disk
```

#### Config
| Option | Value | Effect |
|---|---|---|
| `debounce_delay` | `1000` | Wait 1 second after last keystroke before saving |
| `condition` | function | Only save if buffer has a filetype, is modifiable, and has unsaved changes |
| `before_saving` | function | Runs `conform.format()` synchronously before saving |

#### Integration with conform.lua
`auto-save` triggers formatting. `conform` does the formatting. They are intentionally decoupled — auto-save handles **when**, conform handles **how**.

---

### `after/plugin/catppuccin.lua`
**Applies the Catppuccin colorscheme and custom highlight overrides.**

#### Setup Options
| Option | Value | Effect |
|---|---|---|
| `transparent_background` | `true` | No background, shows terminal bg |
| `no_italic` | `true` | Disable all italic text |
| `term_colors` | `true` | Catppuccin controls terminal colors |
| `styles` | all `{}` | No bold/italic on any syntax element |

#### Color Overrides (Mocha variant)
| Color | Override |
|---|---|
| `base` | `#000000` |
| `mantle` | `#000000` |
| `crust` | `#000000` |

Pure black backgrounds instead of Catppuccin's default dark purple-gray.

#### Plugin Integrations
- **Telescope**: enabled with `nvchad` style
- **Dropbar**: enabled with color mode

#### Custom Highlights (applied AFTER colorscheme)
```lua
-- Must come after vim.cmd.colorscheme or catppuccin overwrites them
vim.api.nvim_set_hl(0, "Cursor",     { fg = "#c8bddc", bg = "#c8bddc" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1a1a1a" })
```

#### Cursor Shape Per Mode
| Mode | Shape |
|---|---|
| Normal / Visual / Command | Full block |
| Insert / Command-Insert | Vertical bar (25% width) |
| Replace / Operator | Horizontal bar (20% height) |

---

### `after/plugin/clang_format.lua`

> ⚠️ This file currently exists but is effectively unused via auto-loading.
> It is loaded explicitly via `require("config.clang_format")` from `conform.lua`.
> See `lua/config/clang_format.lua` documentation above.

---

### `after/plugin/conform.lua`
**Configures code formatting across all filetypes.**

#### Formatters
| Name | Command | Used For |
|---|---|---|
| `clang_format` | `clang-format` | C, C++ |
| `prettierd` | `prettierd` | JS, TS, HTML, CSS, SCSS |
| `prettier` | `prettier` | Fallback if prettierd fails |

#### Formatter Routing
```lua
-- JS/TS: tries prettierd first, falls back to prettier
typescript = { "prettierd", "prettier", stop_after_first = true }

-- C/C++: clang_format only
cpp = { "clang_format" }
c   = { "clang_format" }
```

#### `format_on_save = false`
Intentionally disabled — auto-save.lua already triggers `conform.format()` before saving. Enabling this would cause double formatting.

#### Manual Format Command
```
:Format        → formats current buffer
<leader>f      → keymap shortcut for :Format
```

Uses `lsp_fallback = true` — falls back to LSP formatter if no conform formatter is registered for the current filetype.

---

### `after/plugin/cmp.lua`
**Configures the autocompletion dropdown.**

#### Architecture
```
nvim-cmp    → the engine (shows dropdown, handles selection)
luasnip     → the snippet expander (cmp delegates snippet expansion to it)
```

#### Snippet Expansion
```lua
expand = function(args)
    luasnip.lsp_expand(args.body)
end
```
When a snippet completion is confirmed, cmp hands the raw snippet body to luasnip for interactive expansion.

#### Keymaps
| Key | Action |
|---|---|
| `<C-Space>` | Manually trigger completion menu |
| `<CR>` | Confirm selection (auto-selects first if nothing highlighted) |
| `<Tab>` | Next item in list |
| `<S-Tab>` | Previous item in list |

#### Completion Sources (priority order)
| Source | Provides |
|---|---|
| `nvim_lsp` | Language server completions (functions, types, methods) |
| `luasnip` | Snippet completions |
| `buffer` | Words from open buffers |
| `path` | File system paths |

> **Migration candidate:** would benefit from `event = "InsertEnter"` in
> `plugins.lua` — no reason to load the completion engine before you're
> actually typing. Not yet done.

---

### `after/plugin/dap.lua`
**Configures the debugger for C++ and JavaScript/TypeScript.**

#### Architecture
```
nvim-dap     → DAP protocol client (core engine)
nvim-dap-ui  → visual panels (variables, stack, breakpoints)
cpptools     → debug adapter for C/C++ (installed via mason)
js-debug     → debug adapter for Node/JS (installed via mason)
```

#### C++ Debugging
- Adapter: `cppdbg` using `OpenDebugAD7` from cpptools
- Adapter type: `executable` (nvim-dap spawns it as a subprocess)
- Launch config: prompts for executable path at debug time
- `stopAtEntry = true` — pauses at `main()` automatically
- Pretty printing enabled for STL types
- Aliased to C and Rust: `dap.configurations.c = dap.configurations.cpp`

#### JavaScript/Node Debugging
- Adapter: `pwa-node`
- Adapter type: `server` (runs as local server on a dynamic port, unlike C++)
- Configs available: Launch file, Launch custom entry, Attach to process, Attach to port, Launch via NPM

#### Keymaps
| Key | Action |
|---|---|
| `<leader>dt` | Toggle breakpoint |
| `<leader>dc` | Continue / Start debugging |

#### Auto UI
```
session starts (attach/launch) → dapui.open()
session ends (terminated/exited) → dapui.close()
```

> **Migration note:** this file sets up both the C++ (codelldb) and JS
> (pwa-node) adapters unconditionally in one config function — meaning even in
> an Angular project, if dap loads for JS debugging, it still registers the
> C++ adapter pointlessly. Cheap, but sloppy. Worth splitting into two files,
> loaded independently based on project type, using the same `ft`/`cond`
> pattern as cmake-tools. Not yet done.

---

### `after/plugin/fugitive.lua`
**Git client inside Neovim.**

```lua
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
```

`<leader>gs` opens the interactive Git status window. From there use standard Vim motions:
- `s` — stage file
- `u` — unstage file
- `cc` — commit
- `dd` — diff
- `<CR>` — open file

---

### `after/plugin/gitsigns.lua`
**Shows git change indicators in the sign column.**

#### Sign Symbols
| Symbol | Meaning |
|---|---|
| `┃` | Added or changed line |
| `_` | Deleted line |
| `‾` | Deletion at top of block |
| `~` | Changed then deleted |
| `┆` | Untracked file |

Both `signs` (unstaged) and `signs_staged` (staged) use identical symbols.

#### Display Options
| Option | Value | Effect |
|---|---|---|
| `signcolumn` | `true` | Show symbols in sign column |
| `numhl` | `false` | Don't colorize line numbers |
| `linehl` | `false` | Don't colorize line backgrounds |
| `word_diff` | `false` | Don't highlight individual changed words |

#### Behavior
| Option | Value | Effect |
|---|---|---|
| `auto_attach` | `true` | Activates automatically in any git repo |
| `attach_to_untracked` | `false` | No signs on files not added to git yet |
| `update_debounce` | `100ms` | Waits 100ms after typing to update signs |
| `max_file_length` | `40000` | Disables on files over 40k lines |
| `watch_gitdir.follow_files` | `true` | Tracks renamed/moved files |

#### Git Blame (currently disabled)
Toggle with `:Gitsigns toggle_current_line_blame`

When enabled shows inline ghost text on current line:
```
local x = getValue()   -- John, 2 hours ago - fix null check
```

---

### `after/plugin/harpoon.lua`
**Quick file bookmarking for instant navigation.**

#### Concept
Telescope is great for finding files you don't know. Harpoon is for files you **are actively working on** and need to jump between constantly without searching.

#### Keymaps
| Key | Action |
|---|---|
| `<leader>a` | Add current file to Harpoon list |
| `<C-e>` | Toggle Harpoon quick menu |
| `<M-i>` | Jump to file 1 |
| `<M-t>` | Jump to file 2 |
| `<M-f>` | Jump to file 3 |
| `<M-s>` | Jump to file 4 |

#### The Menu
The Harpoon menu opened by `<C-e>` is a **regular Neovim buffer**:
- Delete a line (`dd`) to remove a file from the list
- Reorder lines to change jump positions
- Save and close to apply changes

#### Typical Workflow
```
1. Find files via Telescope
2. Press <leader>a on the 3-4 files you're actively working on
3. Stop using Telescope for those files
4. Alt+i, Alt+t, Alt+f, Alt+s to jump between them instantly
```

> **Migration note:** discussed moving this to `event = "VeryLazy"` since it's
> used in every project regardless of stack — `VeryLazy` gets it out of the
> `start` phase without the "first keypress has a hitch" tradeoff that a
> `keys`-based trigger would introduce. Not yet applied.

---

### `after/plugin/lsp.lua`
**Core LSP setup — language servers, keymaps, diagnostics.**

> **Biggest remaining migration target.** ~29ms on the last profile, and likely
> the main contributor to editing-time lag on large files too (see Known Issues).

#### Plugin Chain
```
mason            → installs language server binaries
mason-lspconfig  → auto-connects mason installs to lspconfig
lspconfig        → configures each server
lsp-zero         → provides sensible defaults for all three
```

#### Installed Servers (auto-installed via mason)
| Server | Language |
|---|---|
| `clangd` | C / C++ |
| `ts_ls` | TypeScript / JavaScript |
| `eslint` | JS/TS linting |
| `lua_ls` | Lua |
| `rust_analyzer` | Rust |
| `html` | HTML |
| `angularls` | Angular |
| `emmet_ls` | HTML/CSS expansion |

#### LSP Keymaps (active only in buffers with LSP attached)
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>vws` | Search workspace symbols |
| `<leader>vd` | Open diagnostic float popup |
| `[d` | Go to next diagnostic ⚠️ (swapped — see note) |
| `]d` | Go to previous diagnostic ⚠️ (swapped — see note) |
| `<leader>re` | Code actions (quick fixes, imports) |
| `<leader>vrr` | Find all references |
| `<leader>vrn` | Rename symbol across project |
| `<C-h>` (insert) | Signature help |

> ⚠️ `[d` and `]d` are swapped vs Neovim convention. `[` should go **prev**, `]` should go **next**. Consider fixing.

#### Sign Icons
| Type | Icon |
|---|---|
| Error | `✘` |
| Warning | `▲` |
| Hint | `⚑` |
| Info | `»` |

#### Emmet Custom Handler
Emmet needs a custom handler because the default setup only attaches to `html`. Extended to also work in: CSS, JS, JSX, TSX, Vue, Svelte, Blade.

Also explicitly sets `cmp_nvim_lsp` capabilities — required for proper completion integration when using a custom handler.

#### Diagnostic Display
| Option | Value | Effect |
|---|---|---|
| `virtual_text` | `prefix = "●"` | Ghost text at end of line with ● prefix |
| `signs` | `true` | Show icons in sign column |
| `underline` | `true` | Underline problematic code |
| `update_in_insert` | `false` | Don't flash errors while typing |

> **Not yet applied — planned fix for large-file editing lag:** add a buffer
> line-count guard (e.g. `vim.diagnostic.disable(bufnr)` or a full LSP client
> detach) for buffers over ~8000 lines, since diagnostics recomputing on every
> keystroke is the most likely cause of the hang on the 30k-line legacy files,
> separate from the startup-time cost this file also carries.

---

### `after/plugin/lualine.lua`
**Status bar at the bottom (and optionally top) of Neovim.**

> **Second-biggest remaining migration target.** ~32ms on the last profile —
> currently the single highest `after/plugin/` cost.

#### Statusline Layout (active window)
```
┃ NORMAL ┃ branch  diff  diagnostics ┃ filename ┃     ┃ encoding  format  type ┃ 45% ┃ 12:34 ┃
    a              b                      c                      x                  y      z
```

| Section | Content |
|---|---|
| `a` | Current mode (NORMAL/INSERT/VISUAL etc) |
| `b` | Git branch + diff counts (from gitsigns) + diagnostic counts (from LSP) |
| `c` | Current filename |
| `x` | File encoding + line ending format + filetype |
| `y` | Scroll percentage through file |
| `z` | Line:Column |

#### Inactive Windows
Only shows `filename` and `location` — reduces noise in unfocused splits.

#### Refresh
- Updates immediately on: mode change, cursor move, file save, buffer switch, resize
- 1000ms fallback timer for non-event-based updates
- ~60fps render cap via `refresh_time = 16`

#### Tabline
Currently empty `{}`. To enable a tab bar at the top:
```lua
tabline = {
    lualine_a = {{ 'tabs', mode = 2, use_mode_colors = true }}
}
```

> **Migration note:** discussed `event = "VeryLazy"` for this too, same
> reasoning as harpoon — statusline is safe to appear slightly after first
> frame. Not yet applied.

---

### `after/plugin/telescope.lua`
**Fuzzy finder keymaps.**

| Key | Searches | Notes |
|---|---|---|
| `<leader>pf` | All files in project | Includes untracked files |
| `<leader>ff` | Open buffers | Quick switcher for loaded files |
| `<leader>ss` | LSP workspace symbols | Find functions/classes by name across project |
| `<C-p>` | Git tracked files only | Faster — respects .gitignore |
| `<leader>ps` | Text content (grep) | Prompts for search term first |

#### `<leader>ps` Detail
```lua
builtin.grep_string({ search = vim.fn.input("Grep > ") })
```
Wrapped in a function (not a direct reference) because it needs to call `vim.fn.input()` to ask for the search term before executing.

---

### `after/plugin/tree.lua`
**File explorer sidebar.**

> **Explicitly deferred — not worth migrating.** Cost (~5ms) is low enough that
> the effort of restructuring it (moving `vim.g.loaded_netrw` lines to
> `init.lua`, switching to `cmd`-based lazy loading since the keymap lives
> inside the config file rather than the spec's `keys` table) wasn't judged
> worth it relative to the return. Left as-is by choice.

#### Config
| Option | Value | Effect |
|---|---|---|
| `update_focused_file.enable` | `true` | Auto-highlights current file in tree when switching buffers |
| `sort.sorter` | `case_sensitive` | Case-sensitive file sorting |
| `view.width` | `30` | Panel width in columns |
| `renderer.group_empty` | `true` | Collapse single-child folders into one line |
| `filters.dotfiles` | `false` | Show dotfiles (`.env`, `.gitignore` etc) |
| `git.enable` | `true` | Show git status icons |
| `git.ignore` | `false` | Show gitignored files (with different icon) |
| `git.timeout` | `500ms` | Skip git status if response takes too long |

#### Keymaps
| Key | Action |
|---|---|
| `<leader>te` | Toggle file tree |
| `<A-w>` | Cycle between split windows |

> ⚠️ `<A-w>` is unrelated to NvimTree — belongs in `keymaps.lua`

> ⚠️ `vim.g.loaded_netrw = 1` lines technically should be in `init.lua` per NvimTree docs — they need to be set before anything loads.

---

### `after/plugin/undotree.lua`
**Visual undo history browser.**

```lua
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
```

Neovim maintains a **tree** (not a linear list) of all changes. Undotree visualizes this tree so you can recover any state from any branch of your edit history — even after you've made new changes on a different branch.

---

## Known Issues / Improvements

| File | Issue | Status |
|---|---|---|
| `after/plugin/tree.lua` | `vim.g.loaded_netrw` lines should be in `init.lua` | Open — deferred by choice, low cost |
| `after/plugin/tree.lua` | `require("nvim-tree").setup()` called twice — remove the empty first call | Open |
| `after/plugin/tree.lua` | `<A-w>` keymap belongs in `keymaps.lua` | Open |
| `after/plugin/lsp.lua` | `[d` and `]d` are swapped — `[` should be prev, `]` should be next | Open |
| `after/plugin/lsp.lua` | No large-file guard on LSP diagnostics — likely cause of editing-time lag on 30k-line files | Open — planned next |
| `after/plugin/dap.lua` | Registers both C++ and JS adapters unconditionally regardless of project type | Open |
| `lua/config/remap.lua` | Overlaps with `keymaps.lua` — consider merging | Open |
| ~~`plugins.lua` inline treesitter~~ | ~~`require("nvim-treesitter.config")` — likely wrong module name~~ | ✅ Fixed — moved to `lua/config/treesitter.lua`, corrected to `.configs` |
| ~~`plugins.lua` inline treesitter~~ | ~~C/Rust highlighting unconditionally disabled~~ | ✅ Fixed — removed, confirmed unwanted |
| ~~`plugins.lua` inline treesitter~~ | ~~`foldmethod=expr` running on every buffer, every scroll/edit~~ | ✅ Fixed — switched to `foldmethod=manual` (folding wasn't used) |
| ~~`after/plugin/cmaketools.lua`~~ | ~~Loaded unconditionally on every startup, every filetype, even in non-CMake projects~~ | ✅ Fixed — moved to `lua/config/cmaketools.lua`, gated by `ft` + `cond` |

---

*Documentation generated based on full config review — covers every file, every option, and how all plugins connect to each other. Updated to reflect the performance pass (startup ~5519ms → ~216ms) covering treesitter and cmake-tools migrations.*
