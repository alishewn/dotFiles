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
        dependecies = {
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
    -- {
    --     "okuuva/auto-save.nvim",
    --     cmd = "ASToggle", -- optional for lazy loading on command
    --     event = {"InsertLeave", "TextChanged"}, -- optional for lazy loading on trigger events
    --     opts = {
    --         -- your config goes here
    --         -- or just leave it empty :)
    --     }
    -- }, 
    {
        {
            "folke/flash.nvim",
            event = "VeryLazy",
            ---@type Flash.Config
            opts = {},
            -- stylua: ignore
            keys = {
                {
                    "s",
                    mode = {"n", "x", "o"},
                    function() require("flash").jump() end,
                    desc = "Flash"
                }, {
                    "S",
                    mode = {"n", "o", "x"},
                    function() require("flash").treesitter() end,
                    desc = "Flash Treesitter"
                }, {
                    "r",
                    mode = "o",
                    function() require("flash").remote() end,
                    desc = "Remote Flash"
                }, {
                    "R",
                    mode = {"o", "x"},
                    function()
                        require("flash").treesitter_search()
                    end,
                    desc = "Treesitter Search"
                }, {
                    "<c-s>",
                    mode = {"c"},
                    function() require("flash").toggle() end,
                    desc = "Toggle Flash Search"
                }
            }
        }
    }, -----
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
        after = "telescope.nvim",
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
