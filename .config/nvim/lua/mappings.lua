require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>cf", "<cmd>next ~/.config/nvim/lua/*.lua<CR>", { desc = "Edit Config" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
