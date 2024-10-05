
return {
	"kevinhwang91/rnvimr", -- Correct repository name for rnvimr
	--config = function()
	--	require("config.rnvimr") -- Points to the rnvimr configuration file
	--end,
	cmd = { "RnvimrToggle" }, -- Load the plugin when this command is used
	keys = {
		{ "<leader>ef", ":RnvimrToggle<CR>", desc = "Toggle Ranger" },
	},
}

