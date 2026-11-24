require("auto-save").setup({
    debounce_delay = 3000,
    condition = function(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
            return false
        end
        return vim.bo[buf].filetype ~= "" and vim.bo[buf].modifiable and vim.bo[buf].modified
    end,
    callbacks = {
        before_saving = function()
            -- Format the buffer BEFORE saving
            require("conform").format({ async = false, lsp_fallback = true })
            -- This is a *normal* buffer change and keeps undo history
        end,
    },
})
