-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true


-- OR setup with some options
require("nvim-tree").setup({
    update_focused_file = {
        enable = true,
    },
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 30,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = false,
    },
    git = {
        enable = true,
        ignore = false, -- extra safety
        timeout = 500,
    },

    filesystem_watchers = {
        enable = true,
        ignore_dirs = function(path)
            return path:match("/dist/")
                or path:match("/node_modules/")
                or path:match("/%.angular/")
                or path:match("/coverage/")
        end,
    }

})
vim.keymap.set("n", "<leader>te", vim.cmd.NvimTreeToggle)


vim.keymap.set('n', '<A-w>', '<C-w>w', { noremap = true, silent = true })
