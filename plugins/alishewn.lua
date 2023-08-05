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
    }, {
        { ---
            "m-demare/hlargs.nvim",
            opts = {},
            event = "User AstroFile"
        }
    }, {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {"andymass/vim-matchup"},
        init = function()
            vim.g.matchup_matchparen_offscreen = {
                method = "popup",
                fullwidth = 1,
                highlight = "Normal",
                syntax_hl = 1
            }
            vim.g.matchup_matchparen_deferred = 1
        end,
        opts = {matchup = {enable = true}}
    }, {
        "Pocco81/HighStr.nvim",
        opts = {
            verbosity = 0,
            saving_path = "/tmp/highstr/",
            highlight_colors = {
                -- color_id = {"bg_hex_code",<"fg_hex_code"/"smart">}
                color_0 = {"#0c0d0e", "smart"}, -- Cosmic charcoal
                color_1 = {"#e5c07b", "smart"}, -- Pastel yellow
                color_2 = {"#7FFFD4", "smart"}, -- Aqua menthe
                color_3 = {"#8A2BE2", "smart"}, -- Proton purple
                color_4 = {"#FF4500", "smart"}, -- Orange red
                color_5 = {"#008000", "smart"}, -- Office green
                color_6 = {"#0000FF", "smart"}, -- Just blue
                color_7 = {"#FFC0CB", "smart"}, -- Blush pink
                color_8 = {"#FFF9E3", "smart"}, -- Cosmic latte
                color_9 = {"#7d5c34", "smart"} -- Fallow brown
            }
        }
    }, {"matze/vim-move", event = "BufEnter"}, {
        "gbprod/yanky.nvim",
        dependencies = {
            {"kkharji/sqlite.lua", enabled = not jit.os:find "Windows"}
        },
        opts = function()
            local mapping = require "yanky.telescope.mapping"
            local mappings = mapping.get_defaults()
            mappings.i["<c-p>"] = nil
            return {
                highlight = {timer = 200},
                ring = {storage = jit.os:find "Windows" and "shada" or "sqlite"},
                picker = {
                    telescope = {
                        use_default_mappings = false,
                        mappings = mappings
                    }
                }
            }
        end,
        keys = {
            {
                "<leader>p",
                function()
                    require("telescope").extensions.yank_history.yank_history {}
                end,
                desc = "Open Yank History"
            },
            {"y", "<Plug>(YankyYank)", mode = {"n", "x"}, desc = "Yank text"},
            {
                "p",
                "<Plug>(YankyPutAfter)",
                mode = {"n", "x"},
                desc = "Put yanked text after cursor"
            }, {
                "P",
                "<Plug>(YankyPutBefore)",
                mode = {"n", "x"},
                desc = "Put yanked text before cursor"
            }, {
                "gp",
                "<Plug>(YankyGPutAfter)",
                mode = {"n", "x"},
                desc = "Put yanked text after selection"
            }, {
                "gP",
                "<Plug>(YankyGPutBefore)",
                mode = {"n", "x"},
                desc = "Put yanked text before selection"
            }, {
                "[y",
                "<Plug>(YankyCycleForward)",
                desc = "Cycle forward through yank history"
            }, {
                "]y",
                "<Plug>(YankyCycleBackward)",
                desc = "Cycle backward through yank history"
            }, {
                "]p",
                "<Plug>(YankyPutIndentAfterLinewise)",
                desc = "Put indented after cursor (linewise)"
            }, {
                "[p",
                "<Plug>(YankyPutIndentBeforeLinewise)",
                desc = "Put indented before cursor (linewise)"
            }, {
                "]P",
                "<Plug>(YankyPutIndentAfterLinewise)",
                desc = "Put indented after cursor (linewise)"
            }, {
                "[P",
                "<Plug>(YankyPutIndentBeforeLinewise)",
                desc = "Put indented before cursor (linewise)"
            },
            {
                ">p",
                "<Plug>(YankyPutIndentAfterShiftRight)",
                desc = "Put and indent right"
            },
            {
                "<p",
                "<Plug>(YankyPutIndentAfterShiftLeft)",
                desc = "Put and indent left"
            }, {
                ">P",
                "<Plug>(YankyPutIndentBeforeShiftRight)",
                desc = "Put before and indent right"
            }, {
                "<P",
                "<Plug>(YankyPutIndentBeforeShiftLeft)",
                desc = "Put before and indent left"
            },
            {
                "=p",
                "<Plug>(YankyPutAfterFilter)",
                desc = "Put after applying a filter"
            },
            {
                "=P",
                "<Plug>(YankyPutBeforeFilter)",
                desc = "Put before applying a filter"
            }
        }
    }, {"jabirali/vim-tmux-yank", event = "User AstroFile"},
    {"willothy/flatten.nvim", opts = {}, lazy = false, priority = 1001},
    {"SmiteshP/nvim-navic", dependencies = "neovim/nvim-lspconfig"}
}
