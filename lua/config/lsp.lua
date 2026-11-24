local lsp_zero = require("lsp-zero")

-- v3.x: Remove lsp.preset(), lsp.set_preferences(), and lsp.setup()

-- Set up your keymaps
lsp_zero.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "<leader>re", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

-- Optional: configure signs if you want them (replaces lsp.set_preferences)
lsp_zero.set_sign_icons({
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { 
        'clangd','jdtls', 'ts_ls', 'eslint', 'lua_ls', 
        'rust_analyzer', 'html', 'angularls', 'emmet_ls',
    },
    handlers = {
        -- Default handler for installed servers
        lsp_zero.default_setup,
           -- ✅ Add this custom handler for clangd
        jdtls = function() end,
        ["clangd"] = function()
            require("lspconfig").clangd.setup({
                cmd = {
                    "clangd",
                    "--query-driver=C:/msys64/ucrt64/bin/g++.exe",  -- ⚠️ change this!
                },
            })
        end,
        
        -- Custom handler for emmet_ls
        ["emmet_ls"] = function()
            require("lspconfig").emmet_ls.setup({
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                filetypes = {
                    "html", "css", "javascript", "javascriptreact", 
                    "typescriptreact", "vue", "svelte", "blade","htmlangular",
                },
                init_options = {
                    html = {
                        options = {
                            ["bem.enabled"] = true,
                        },
                    },
                },
            })
        end,
    },
})

-- MUST be outside of the setup table
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
})
