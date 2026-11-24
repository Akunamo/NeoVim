local jdtls = require('jdtls')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local config = {
    -- Add .cmd for Windows
    cmd = { 'jdtls.cmd' },
    
    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]) or vim.fn.getcwd(),
    capabilities = capabilities,
}

jdtls.start_or_attach(config)
