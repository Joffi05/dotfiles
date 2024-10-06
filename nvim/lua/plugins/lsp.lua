-- ~/.config/nvim/lua/plugins/lsp.lua

return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',  -- Ensure you're using the correct branch
    dependencies = {
        -- LSP Support
        'neovim/nvim-lspconfig',  -- Required for LSP configurations

        -- Autocompletion
        'hrsh7th/nvim-cmp',       -- Completion plugin
        'hrsh7th/cmp-nvim-lsp',   -- LSP source for nvim-cmp
        'hrsh7th/cmp-buffer',     -- Buffer source for nvim-cmp
        'hrsh7th/cmp-path',       -- Path source for nvim-cmp
        'hrsh7th/cmp-cmdline',    -- Cmdline source for nvim-cmp

        -- Snippets (Optional but recommended)
        'L3MON4D3/LuaSnip',              -- Snippet engine
        'saadparwaiz1/cmp_luasnip',      -- Snippet completions for nvim-cmp
        'rafamadriz/friendly-snippets',  -- A collection of snippets (optional)
    },
    config = function()
        require("config.lsp")
    end,
}

