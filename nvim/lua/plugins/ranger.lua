return {
	"kelly-lin/ranger.nvim",
	dependencies = { 'nvim-lua/plenary.nvim' },  
	config = function()
		require('config.ranger').setup()
	end,
}
