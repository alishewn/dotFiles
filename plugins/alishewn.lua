return {
    {"onsails/lspkind.nvim", event = "VeryLazy", opts = {}},
    {"gfanto/fzf-lsp.nvim", event = "VeryLazy", opts = {}},
    {"simrat39/symbols-outline.nvim", event = "VeryLazy", opts = {}},
    {"rmagatti/goto-preview", event = "VeryLazy", opts = {}}, --
    {
        "roobert/search-replace.nvim",
        config = function()
            require("search-replace").setup({
                -- optionally override defaults
                default_replace_single_buffer_options = "gcI",
                default_replace_multi_buffer_options = "egcI"
            })
        end
    }, --
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    }, --
    {"AckslD/muren.nvim", config = true}, --
    {"danielpieper/telescope-tmuxinator.nvim", opts = {}}, --
    {
        "sudormrfbin/cheatsheet.nvim",
        opts = {},
        dependencies = {
            "nvim-telescope/telescope.nvim", "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim"
        }
    }, --
    {
        "andrewferrier/debugprint.nvim",
        opts = {...},
        -- Dependency only needed for NeoVim 0.8
        dependencies = {"nvim-treesitter/nvim-treesitter"},
        -- Remove the following line to use development versions,
        -- not just the formal releases
        version = "*"
    },
    {
        "aserowy/tmux.nvim",
        config = function() return require("tmux").setup() end
    }, --
    {
        {
            'axkirillov/hbac.nvim',
            dependencies = {
                -- these are optional, add them, if you want the telescope module
                'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim',
                'nvim-tree/nvim-web-devicons'
            },
            config = function() require("hbac").setup() end
        }
    }, ---
    {
        'tomasky/bookmarks.nvim',
        event = "VimEnter",
        config = function() require('bookmarks').setup() end
    }, {
        {
            'akinsho/git-conflict.nvim',
            version = "*",
            config = true,
            opts = {default_mappings = false}
        }
    }

}
