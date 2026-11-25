-- Configure Catppuccin theme options before applying the colorscheme
require("catppuccin").setup({
    flavour = "mocha",
    transparent_background = false,
    integrations = {
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = {
            enabled = true,
        },
    },
})

-- Activate the colorscheme
vim.cmd.colorscheme("catppuccin-mocha")
