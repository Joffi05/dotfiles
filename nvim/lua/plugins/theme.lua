return {
	"ntk148v/habamax.nvim", 
	dependencies={ "rktjmp/lush.nvim" },
	lazy = false,
	priority = 1000,
	config = function() 
		require("config.theme")
	end,
}
