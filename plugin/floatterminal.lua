vim.keymap.set("t", "<leader>ti", "<c-\\><c-n>")
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")
vim.keymap.set("n", "<leader>fj", ":Floatterminal<CR>")

local state = {
    floating = {
        buf = -1,
        win = -1,
    }
}

local function create_floating_window(opts)
    opts = opts or {}

    -- Get editor dimensions
    local columns = vim.o.columns
    local lines = vim.o.lines

    -- Default to 80% of screen
    local width = opts.width or math.floor(columns * 0.8)
    local height = opts.height or math.floor(lines * 0.8)

    -- Center position
    local col = math.floor((columns - width) / 2)
    local row = math.floor((lines - height) / 2)

    -- Create buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end


    -- Window options
    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = opts.border or "rounded",
    }

    -- Open window
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    return { buf = buf, win = win }
end

vim.api.nvim_create_user_command("Floatterminal", function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = create_floating_window { buf = state.floating.buf }
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            vim.cmd.terminal()
        end
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end, {})
