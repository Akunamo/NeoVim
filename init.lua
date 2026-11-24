require("config.lazy")   -- loads lua/config/lazy.lua (your bootstrap)
require("config.keymap") -- loads lua/config/keymaps.lua
require("config.remap")  -- loads lua/config/remap.lua

-- === Basic editor settings ===
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.linebreak = true
vim.opt.breakindent = true

vim.opt.tabstop = 4        -- how tabs appear visually
vim.opt.shiftwidth = 4     -- indentation size
vim.opt.expandtab = true   -- convert tabs to spaces
vim.opt.autoindent = true  -- copy indent from current line
vim.opt.smartindent = true -- smarter indent for code
vim.opt.cindent = true     -- C-style indent (optional)

vim.opt.ignorecase = true  -- makes / case-insensitive
vim.opt.smartcase = true   -- but if your search has an uppercase letter, it becomes case-sensitive again

-- === Hide numbers in terminal ===
vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

vim.opt.clipboard = "unnamedplus"

-- === New small terminal pane ===


vim.opt.autochdir = false;
vim.o.exrc = true
vim.o.secure = true

local dap = require('dap')
local dapui = require("dapui")
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end
dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = vim.fn.stdpath("data") .. '/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
}

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
        setupCommands = {
            {
                text = '-enable-pretty-printing',
                description = 'Enable pretty printing',
                ignoreFailures = false
            }
        },
    },
}

-- Alias for C and Rust
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
