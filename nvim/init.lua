vim.cmd("syntax on")

-- Automatically open the file explorer when Neovim starts without arguments
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("Ranger")
		end
	end
})


require("config.lazy")
