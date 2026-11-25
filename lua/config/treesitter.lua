-- Initialize nvim-treesitter with default install directory
require("nvim-treesitter").setup()

-- Ensure parsers are installed for your languages
require("nvim-treesitter").install({
    "c", "java", "cpp", "javascript", "typescript", "lua", "vim", "vimdoc",
    "query", "markdown", "markdown_inline", "html",
})

-- Start Treesitter highlighting whenever a file opens, skipping files larger than 100KB
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local max_filesize = 100 * 1024
        local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > max_filesize then
            return
        end
        pcall(vim.treesitter.start, args.buf)
    end,
})

-- Enable smart syntax-aware textobjects (e.g. vaf to select a function, dif to delete inside it)
require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true, -- jump forward to the next matching textobject if cursor isn't inside one
    },
})

local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
local textobject_maps = {
    ["af"] = "@function.outer",
    ["if"] = "@function.inner",
    ["ac"] = "@class.outer",
    ["ic"] = "@class.inner",
    ["ab"] = "@block.outer",
    ["ib"] = "@block.inner",
}

for key, query in pairs(textobject_maps) do
    vim.keymap.set({ "x", "o" }, key, function()
        select_textobject(query, "textobjects")
    end, { desc = "Treesitter select " .. query })
end

-- Treat Angular template files as standard HTML
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.component.html",
    callback = function()
        vim.bo.filetype = "html"
    end,
})

-- Keep folding manual so Neovim never recalculates fold trees in the background
vim.o.foldmethod = "manual"
