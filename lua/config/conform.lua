-- ~/.config/nvim/after/plugin/conform.lua
local clang_format_config =  require("config.clang_format");

require("conform").setup({
    formatters = {
        -- Register your custom clang-format formatter
        clang_format = clang_format_config,
        
        -- Prettier formatters
        prettierd = {
            command = "prettierd",
            args = { "--stdin-filepath", "$FILENAME" },
            stdin = true,
        },
        prettier = {
            command = "prettier",
            args = { "--stdin-filepath", "$FILENAME" },
            stdin = true,
        },
    },
    formatters_by_ft = {
        -- TypeScript/JavaScript
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        
        -- C/C++
        cpp = { "clang_format" },
        c = { "clang_format" },
        java = { "clang_format" },
    },
    format_on_save = false,
})

vim.api.nvim_create_user_command("Format", function()
    require("conform").format({
        bufnr = vim.api.nvim_get_current_buf(),
        lsp_fallback = true,
        timeout_ms = 1000,
    })
end, {})

vim.keymap.set("n", "<leader>f", ":Format<CR>", { noremap = true, silent = true })
