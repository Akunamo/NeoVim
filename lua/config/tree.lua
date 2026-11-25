require("nvim-tree").setup({
    -- Automatically highlight the active file in the sidebar when switching buffers
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
        -- Collapse single-child folder chains onto one line
        group_empty = true,
    },
    filters = {
        -- Keep hidden dotfiles (.env, .gitignore) visible
        dotfiles = false,
    },
    git = {
        enable = true,
        ignore = false,
        timeout = 500,
    },
    filesystem_watchers = {
        enable = true,
        -- Skip heavy build/dependency folders (normalized so it works on both Windows and Linux/macOS)
        ignore_dirs = function(path)
            local normalized = path:gsub("\\", "/")
            return normalized:match("/dist/")
                or normalized:match("/node_modules/")
                or normalized:match("/%.angular/")
                or normalized:match("/coverage/")
        end,
    },
})

-- Toggle the file explorer sidebar
vim.keymap.set("n", "<leader>te", vim.cmd.NvimTreeToggle, { desc = "Toggle NvimTree" })
