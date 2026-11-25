local lsp_zero = require("lsp-zero")

-- Buffer-local LSP shortcuts (only active in files where a language server is attached)
lsp_zero.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "<leader>re", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

-- Icons shown in the left gutter for errors, warnings, hints, and info
lsp_zero.set_sign_icons({
    error = "✘",
    warn = "▲",
    hint = "⚑",
    info = "»",
})

-- Pass nvim-cmp completion capabilities to every server managed by lsp-zero
lsp_zero.extend_lspconfig({
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- Start Mason (external tool installer) and auto-connect installed language servers
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "clangd", "jdtls", "ts_ls", "eslint", "lua_ls",
        "rust_analyzer", "html", "angularls", "emmet_ls",
    },
    handlers = {
        -- Default setup for all servers that don't have a custom handler below
        lsp_zero.default_setup,

        -- Skip jdtls here because ftplugin/java.lua launches it with nvim-jdtls instead
        jdtls = function() end,

        -- Tell lua_ls that Neovim's global `vim` variable is valid
        ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            })
        end,

        -- Custom setup for C/C++ (clangd)
        ["clangd"] = function()
            local clangd_cmd = { "clangd" }

            -- On Windows, point clangd to the MSYS2 g++ compiler so it finds standard library headers
            if vim.fn.has("win32") == 1 then
                table.insert(clangd_cmd, "--query-driver=C:/msys64/ucrt64/bin/g++.exe")
            end

            require("lspconfig").clangd.setup({
                cmd = clangd_cmd,
                -- Tell clangd that nvim-cmp handles autocompletion
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
        end,

        -- Custom setup for Emmet across web and Angular templates
        ["emmet_ls"] = function()
            require("lspconfig").emmet_ls.setup({
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                filetypes = {
                    "html", "css", "javascript", "javascriptreact",
                    "typescriptreact", "vue", "svelte", "blade", "htmlangular",
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

-- Control how diagnostics (errors/warnings) appear in the editor
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
})
