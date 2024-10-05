
local M = {}

function M.setup()
	require('ranger-nvim').setup({
		-- Ranger.nvim options
		-- For example, you can set the keybinding to open Ranger
		replace_netrw = true,  -- Ensure Ranger replaces netrw
		respect_buf_cwd = true, -- Ranger will respect the current buffer's working directory
		show_hidden = true,
	})

	-- Set up keybindings
	-- Here, <leader>e will open Ranger
	vim.api.nvim_set_keymap("n", "<leader>ef", "", {
		noremap = true,
		callback = function()
			require("ranger-nvim").open(true)
		end,
	})

	-- Ensure terminal buffer settings allow command visibility
	vim.cmd([[
	autocmd TermOpen * setlocal norelativenumber
	autocmd TermOpen * setlocal nonumber
	autocmd TermOpen * setlocal wrap
	]])
end

return M

