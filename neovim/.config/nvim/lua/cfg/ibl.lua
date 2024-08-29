local mod = {}

mod.setup = function()
  require("ibl").setup({
    indent = {char = "|"},
    scope = {},
  })
end

return mod
