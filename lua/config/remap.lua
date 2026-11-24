vim.g.mapleader = " "

if vim.fn.has("win32") == 1 then
  vim.keymap.set("n", "<leader>pv", ":NvimTreeToggle<CR>")
else
  vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
end
