
vim.keymap.set('n', '<C-CR>', ':put _<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lg', ':LazyGit<CR>', { noremap = true, silent = true })

-- Toggle wrap with <leader>w
vim.keymap.set('n', '<leader>w', ':set wrap!<CR>', { silent = true, desc = 'Toggle Line Wrap' })

require("config.lazy")

-- === Build / Terminal keymaps ===
vim.keymap.set("n", "<leader>co", ":belowright split | terminal cmake -S . -B build<CR>")
vim.keymap.set("n", "<leader>cb", ":belowright split | terminal cmake --build build<CR>")


vim.keymap.set("n", "<leader>st", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
end)

vim.keymap.set('n','<M-j>','<Cmd>Telescope jumplist<CR>')

-- === TAB NAVIGATION (Alt + h / Alt + l) ===
vim.keymap.set('n', '<M-h>', '<Cmd>tabprevious<CR>', { silent = true, desc = 'Previous tab' })
vim.keymap.set('n', '<M-l>', '<Cmd>tabnext<CR>', { silent = true, desc = 'Next tab' })

-- (Optional) new / close tab shortcuts
vim.keymap.set('n', '<M-n>', '<Cmd>tabnew<CR>', { silent = true, desc = 'New tab' })
vim.keymap.set('n', '<M-q>', ':bd!<CR>', { silent = true, desc = 'Close tab' })
vim.keymap.set('n', '<M-o>', ':<Cmd>tabonly<CR>', { silent = true, desc = 'Close tab' })
-- vim.keymap.set('n', '<M-n>', '<Cmd>tabclose<CR>', { silent = true, desc = 'Close tab' })




vim.keymap.set('v','<C-c>', '"+y', {desc = 'Copied to clipboard!'})
vim.keymap.set('v','<C-v>', '"+p', {desc = 'Copied to clipboard!'})

-- Enter terminal mode in current buffer
vim.keymap.set('n', '<C-t>', function()
    vim.cmd.term()          -- Turns current window into a terminal
    vim.cmd.startinsert()   -- Immediately enters Insert/Terminal mode
end, { desc = 'Terminal in current window' })





local function switch_to(ext)
    local current = vim.api.nvim_buf_get_name(0)

    -- Remove the current extension
    local base = current:gsub("%.spec%.ts$", "")
    base = base:gsub("%.ts$", "")
    base = base:gsub("%.html$", "")
    base = base:gsub("%.scss$", "")
    base = base:gsub("%.css$", "")           -- ← added

    local target

    if ext == "spec.ts" then
        target = base .. ".spec.ts"
    elseif ext == "style" then               -- ← new: resolve style dynamically
        local scss = base .. ".scss"
        local css  = base .. ".css"
        if vim.fn.filereadable(scss) == 1 then
            target = scss
        else
            target = css
        end
    else
        target = base .. "." .. ext
    end

    if vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
    else
        print("File not found: " .. target)
    end
end

vim.keymap.set("n", "<leader>lt", function()
    switch_to("ts")
end, { desc = "Angular TS" })

vim.keymap.set("n", "<leader>lh", function()
    switch_to("html")
end, { desc = "Angular HTML" })

vim.keymap.set("n", "<leader>ls", function()
    switch_to("style")                       -- ← changed from "scss"
end, { desc = "Angular Style" })

vim.keymap.set("n", "<leader>le", function()
    switch_to("spec.ts")
end, { desc = "Angular Spec" })


vim.keymap.set("n", "<C-o>", "<C-o>zz", { noremap = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true })
