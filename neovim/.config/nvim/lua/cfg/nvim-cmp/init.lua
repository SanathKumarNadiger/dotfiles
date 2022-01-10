local mod = {}

mod.setup = function()
	local status, ls = pcall(require, "luasnip")
	if not status then
		print("luasnip is not installed")
		return
	end
	local cmp = require("cmp")
	local lspkind = require("lspkind")
	cmp.setup({
		snippet = {
			expand = function(args)
				ls.lsp_expand(args.body)
			end,
		},
		preselect = cmp.PreselectMode.None,
		mapping = {
			["<C-j>"] = cmp.mapping.scroll_docs(-4),
			["<C-k>"] = cmp.mapping.scroll_docs(4),
			["<C-s>"] = cmp.mapping.confirm({ select = true }),
			["<C-n>"] = cmp.mapping(
				function(fallback) -- if completion available go to next,else if snippets available next item
					if cmp.visible() then
						cmp.select_next_item()
					elseif ls.jumpable(1) then
						ls.jump(1)
					else
						fallback()
					end
				end
			),
			["<C-p>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif ls.jumpable(-1) then
					ls.jump(-1)
				else
					fallback()
				end
			end),
			["<C-e>"] = cmp.mapping.close(),
		},

		sources = {
			{ name = "nvim_lsp", max_item_count = 8 },
			{ name = "nvim_lua" },
			{ name = "luasnip", max_item_count = 4 },
			{ name = "neorg" },
			{ name = "git" },
			{ name = "path" },
			{ name = "spell" },
			{ name = "buffer", keyword_length = 4 },
		},
		formatting = {
			format = lspkind.cmp_format(),
		},
		experimental = {
			native_menu = false,
			ghost_text = true,
		},
	})
end

return mod
