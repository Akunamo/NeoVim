local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>fo", function()
  require("telescope.builtin").find_files()
end, { desc = "Files files" })

vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.expand("%:p:h"),
  })
end, { desc = "Files in current directory" })

vim.keymap.set('n', '<leader>tf', "<Cmd>Telescope buffers<CR>")
vim.keymap.set('n', '<leader>tws', "<Cmd>Telescope lsp_workspace_symbols<CR>")
vim.keymap.set('n', '<leader>ts', "<Cmd>Telescope lsp_document_symbols<CR>")
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope find git project files' })
vim.keymap.set('n', '<leader>ps', "<Cmd>Telescope live_grep<CR>")
-- vim.keymap.set('n', '<leader>ps', function()
--     builtin.grep_string({ search = vim.fn.input("Grep > ") });
-- end)
