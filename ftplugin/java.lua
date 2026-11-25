local jdtls = require("jdtls")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Pick the right launcher binary for the current OS (Windows uses .cmd, Linux/macOS do not)
local jdtls_cmd = vim.fn.has("win32") == 1 and "jdtls.cmd" or "jdtls"

local config = {
    cmd = { jdtls_cmd },

    -- Search upward for a project marker; fall back to current directory for standalone .java files
    root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]) or vim.fn.getcwd(),

    -- Tell jdtls that nvim-cmp handles autocompletion
    capabilities = capabilities,
}

jdtls.start_or_attach(config)
