local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    -- Keep completion active while recording a macro, but pause it during macro playback
    enabled = function()
        return vim.fn.reg_executing() == ""
    end,

    -- Hand snippet expansions off to LuaSnip
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    -- Insert-mode completion menu controls
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),

    -- Primary sources come first; buffer words only appear if primary sources return nothing
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
    }, {
        { name = "buffer", keyword_length = 3 },
    }),
})
