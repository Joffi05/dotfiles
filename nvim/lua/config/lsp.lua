local lsp = require('lsp-zero')

-- Initialize lsp-zero with recommended presets

local lsp_attach = function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
end

lsp.extend_lspconfig({
	lsp_attach = lsp_attach,
})
-- Ensure LSP servers are installed manually
-- Since we're not using mason.nvim, you need to install LSP servers manually
-- For example, install clangd via your system's package manager

-- Define the servers you want to set up
local servers = { 'clangd', 'rust_analyzer', "texlab" }

-- init lua lang server
require('lspconfig').lua_ls.setup({
	on_init = function(client)
		lsp.nvim_lua_settings(client, {})
	end,
})

-- Loop through the servers and set them up
for _, server in ipairs(servers) do
	require('lspconfig')[server].setup {}
end

-- Define LSP keybindings and attach functions
lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr }

	-- LSP Keybindings
	vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end, opts)
	vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
	vim.keymap.set('n', 'go', function() vim.lsp.buf.type_definition() end, opts)
	vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, opts)
	vim.keymap.set('n', 'gs', function() vim.lsp.buf.signature_help() end, opts)
	vim.keymap.set('n', '<F2>', function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
	vim.keymap.set('n', '<F4>', function() vim.lsp.buf.code_action() end, opts)

	-- Enable buffer autoformatting if desired
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		})
	end
end)

-- Configure nvim-cmp
local cmp = require('cmp')

local cmp_mappings = {
	['<C-p>'] = cmp.mapping.select_prev_item(),
	['<C-n>'] = cmp.mapping.select_next_item(),
	['<C-y>'] = cmp.mapping.confirm({ select = true }),
	['<C-Space>'] = cmp.mapping.complete(),
}

cmp.setup({
	mapping = cmp_mappings,
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },
		{ name = 'cmdline' },
		{ name = 'luasnip' },
	},
	formatting = {
		fields = { "menu", "abbr", "kind" },
		format = function(entry, vim_item)
			-- Customize menu labels
			local menu = {
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				path = "[Path]",
				cmdline = "[Cmd]",
				luasnip = "[Snippet]",
			}
			vim_item.menu = menu[entry.source.name]
			return vim_item
		end,
	},
})


-- Setup LSP servers
lsp.setup()
