-- Disable Neovim's built-in file explorer (netrw) so nvim-tree can handle directories cleanly
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Boot plugin manager and global shortcuts
require("config.lazy")   -- sets leader key and loads plugins from lua/config/plugins.lua
require("config.keymap") -- loads global keymaps from lua/config/keymap.lua

-- Display & colors
vim.opt.termguicolors = true -- enable 24-bit RGB colors in the terminal
vim.opt.number = true        -- show absolute line number on current line
vim.opt.relativenumber = true -- show relative line numbers for easier jumping

-- Line wrapping
vim.opt.linebreak = true     -- wrap lines at word boundaries instead of mid-word
vim.opt.breakindent = true   -- preserve indentation on wrapped lines

-- Indentation (4 spaces)
vim.opt.tabstop = 4          -- visual width of a tab character
vim.opt.shiftwidth = 4       -- spaces used for each indent step
vim.opt.expandtab = true     -- insert spaces instead of tab characters
vim.opt.autoindent = true    -- copy indent from current line when starting a new line
vim.opt.smartindent = true   -- auto-indent after braces and code blocks
vim.opt.cindent = true       -- C-style indentation rules

-- Search
vim.opt.ignorecase = true    -- make / searches case-insensitive by default
vim.opt.smartcase = true     -- switch to case-sensitive if search includes an uppercase letter

-- System & project behavior
vim.opt.clipboard = "unnamedplus" -- sync Neovim yank/paste with the Windows clipboard
vim.opt.autochdir = false         -- keep working directory fixed at project root
vim.o.exrc = true                 -- load project-local .nvim.lua configs if present
vim.o.secure = true               -- restrict unsafe commands inside project-local configs

-- Hide line numbers inside built-in terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})
