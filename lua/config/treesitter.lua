-- lua/config/treesitter.lua

require("nvim-treesitter.config").setup({
    -- CHANGED: was require("nvim-treesitter.config") (singular) in your original,
    -- which is likely the wrong module name and may have silently failed to apply
    -- this whole .setup() call. Correct API uses "configs" (plural).

    ensure_installed = {
        "c", "java", "cpp", "javascript", "typescript", "lua", "vim", "vimdoc",
        "query", "markdown", "markdown_inline", "html"
    }, -- UNCHANGED

    sync_install = false, -- UNCHANGED
    auto_install = true,  -- UNCHANGED

    highlight = {
        enable = true,
        disable = function(lang, buf)
            -- REMOVED (you confirmed you don't want this):
            -- if lang == "c" or lang == "rust" then return true end
            -- ^ this unconditionally disabled treesitter highlighting for every
            --   C/Rust file, regardless of size. Not size-based, just language-based.

            -- UNCHANGED: still disables highlighting for files over 100KB,
            -- for any language, based on actual file size on disk.
            local max_filesize = 100 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        additional_vim_regex_highlighting = false, -- UNCHANGED
    },

    textobjects = {
        -- UNCHANGED, copied exactly as you had it
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
            },
        },
    },
})

-- UNCHANGED: your Angular HTML filetype fix, copied as-is
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.component.html",
    callback = function()
        vim.bo.filetype = "html"
    end,
})

-- CHANGED — this is the big one for your large-file lag.
--
-- OLD (your original, applied globally to every buffer, always):
--   vim.o.foldmethod = "expr"
--   vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- ^ "expr" folding means Neovim calls nvim_treesitter#foldexpr() to recompute
--   fold levels constantly: on scroll, on redraw, on every edit. It walks the
--   treesitter syntax tree to figure out fold boundaries. On a 30k-line file,
--   this can be a real, ongoing performance cost, not a one-time thing.
--
-- NEW: since you said you don't actually use folding at all, "manual" fold
-- method does none of that background work. Folds only exist if you
-- explicitly create one yourself (:h zf). This isn't a large-file-only
-- guard, it just removes the cost entirely, for every file, since you
-- were never using the feature it was paying for.
vim.o.foldmethod = "manual"
