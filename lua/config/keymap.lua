-- General editing
vim.keymap.set("n", "<C-CR>", ":put _<CR>", { noremap = true, silent = true, desc = "Insert blank line below" })
vim.keymap.set("n", "<leader>w", ":set wrap!<CR>", { silent = true, desc = "Toggle line wrap" })
vim.keymap.set("n", "<leader>lg", ":LazyGit<CR>", { noremap = true, silent = true, desc = "Open LazyGit" })

-- Keep cursor centered when jumping back and forward through jump history
vim.keymap.set("n", "<C-o>", "<C-o>zz", { noremap = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true })

-- Copy and paste with the Windows clipboard in Visual mode
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Paste from system clipboard" })

-- Window & file explorer navigation
vim.keymap.set("n", "<A-w>", "<C-w>w", { noremap = true, silent = true, desc = "Cycle split windows" })
vim.keymap.set("n", "<leader>pv", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Tab & buffer navigation
vim.keymap.set("n", "<M-h>", "<Cmd>tabprevious<CR>", { silent = true, desc = "Previous tab" })
vim.keymap.set("n", "<M-l>", "<Cmd>tabnext<CR>", { silent = true, desc = "Next tab" })
vim.keymap.set("n", "<M-n>", "<Cmd>tabnew<CR>", { silent = true, desc = "New tab" })
vim.keymap.set("n", "<M-q>", ":bd!<CR>", { silent = true, desc = "Force close current buffer" })
vim.keymap.set("n", "<M-o>", "<Cmd>tabonly<CR>", { silent = true, desc = "Close all other tabs" })
vim.keymap.set("n", "<M-j>", "<Cmd>Telescope jumplist<CR>", { desc = "Search jump list" })

-- CMake & terminal shortcuts
vim.keymap.set("n", "<leader>co", ":belowright split | terminal cmake -S . -B build<CR>", { desc = "CMake configure" })
vim.keymap.set("n", "<leader>cb", ":belowright split | terminal cmake --build build<CR>", { desc = "CMake build" })

-- Open a 15-line terminal split across the bottom of the screen
vim.keymap.set("n", "<leader>st", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
end, { desc = "Small bottom terminal" })

-- Open a terminal in the current window and enter terminal mode immediately
vim.keymap.set("n", "<C-t>", function()
    vim.cmd.term()
    vim.cmd.startinsert()
end, { desc = "Terminal in current window" })

-- Angular component switcher (switches between .ts, .html, .scss/.css, and .spec.ts)
local function switch_to(ext)
    local current = vim.api.nvim_buf_get_name(0)

    local base = current:gsub("%.spec%.ts$", "")
    base = base:gsub("%.ts$", "")
    base = base:gsub("%.html$", "")
    base = base:gsub("%.scss$", "")
    base = base:gsub("%.css$", "")

    local target
    if ext == "spec.ts" then
        target = base .. ".spec.ts"
    elseif ext == "style" then
        local scss = base .. ".scss"
        local css  = base .. ".css"
        target = (vim.fn.filereadable(scss) == 1) and scss or css
    else
        target = base .. "." .. ext
    end

    if vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
    else
        print("File not found: " .. target)
    end
end

vim.keymap.set("n", "<leader>lt", function() switch_to("ts") end, { desc = "Angular TS" })
vim.keymap.set("n", "<leader>lh", function() switch_to("html") end, { desc = "Angular HTML" })
vim.keymap.set("n", "<leader>ls", function() switch_to("style") end, { desc = "Angular Style" })
vim.keymap.set("n", "<leader>le", function() switch_to("spec.ts") end, { desc = "Angular Spec" })
