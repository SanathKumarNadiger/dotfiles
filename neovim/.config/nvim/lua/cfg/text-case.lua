local mod = {}

local function setup_keymaps()
    vim.keymap.set('n', '<leader>to', '<cmd>TextCaseOpenTelescope<CR>', { desc = "TextCase convert" })
end

mod.setup = function()
    require("textcase").setup({default_keymappings_enabled = true, prefix = "<leader>o"})
    require("telescope").load_extension("textcase")
    setup_keymaps()
end

return mod
