-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "gruvbox",

  -- hl_override = {
  -- 	Comment = { italic = true },
  -- 	["@comment"] = { italic = true },
  -- },
}

M.nvdash = {
  load_on_startup = true,

  buttons = {
    { txt = "  Find File", keys = "Spc f f", cmd = "Telescope find_files" },
    { txt = "󰈚  Recent Files", keys = "Spc f o", cmd = "Telescope oldfiles" },
    { txt = "󰁯  Find Session", keys = "Spc f s", cmd = "SessionSearch" },
    { txt = "󰈭  Find Word", keys = "Spc f w", cmd = "Telescope live_grep" },
    { txt = "  Find Command", keys = "Spc f c", cmd = "Telescope builtin" },
    { txt = "  Bookmarks", keys = "Spc m a", cmd = "Telescope marks" },
    { txt = "  Themes", keys = "Spc t h", cmd = "lua require('nvchad.themes').open()" },
    { txt = "  Config", keys = "Spc c f", cmd = "next ~/dotfiles/.config/nvim/" },
    { txt = "  Mappings", keys = "Spc c h", cmd = "NvCheatsheet" },

    { txt = "─", hl = "NvDashLazy", no_gap = true, rep = true },

    {
      txt = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime) .. " ms"
        return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
      end,
      hl = "NvDashLazy",
      no_gap = true,
    },

    { txt = "─", hl = "NvDashLazy", no_gap = true, rep = true },
  },
}

M.mason = {
  cmd = true,
  pkgs = {
    "lua-language-server",
    "stylua",
    "css-lsp",
    "html-lsp",
    "emmet-language-server",
    -- "typescript-language-server",
    "prettier",
    "json-lsp",
    -- "tailwindcss-language-server",
    "shfmt",
    "shellcheck",
    "bash-language-server",
    -- "clangd",
    -- "clang-format",
  },
}

-- Workaround
--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    vim.cmd "Nvdash"
--  end,
--})

-- Keyboard users
vim.keymap.set("n", "<C-t>", function()
  require("menu").open "default"
end, {})

return M
