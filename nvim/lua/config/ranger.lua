require("ranger-nvim").setup({
	enable_cmds = true,
	replace_netrw = true,
	ui = {
		border="single",
		height=0.5,
		width=0.5,
		x = 0.5,
		y = 0.5,
	}
})
vim.api.nvim_set_keymap("n", "<leader>ef", "", {
	noremap = true,
	callback = function()
		require("ranger-nvim").open(true)
	end,
})
