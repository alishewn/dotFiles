return {
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
    { -- tab bar settings
        {
            "rebelot/heirline.nvim",
            enabled = false,
            optional = true,
            tabline = nil,
            winbar = nil,
            statusline = nil
        }, -- {"Bekaboo/dropbar.nvim", event = "VeryLazy", opts = {}}, -- 
        -- {
        --     "utilyre/barbecue.nvim",
        --     name = "barbecue",
        --     version = "*",
        --     dependencies = {
        --         "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" -- optional dependency
        --     },
        --     opts = {
        --         -- configurations go here
        --     }
        -- }, 
        {
            'romgrk/barbar.nvim',
            event = "VeryLazy",
            dependencies = {
                'lewis6991/gitsigns.nvim', 'nvim-tree/nvim-web-devicons'
            },
            opts = {
                animation = true,
                -- auto_hide = true,
                tabpages = true,
                focus_on_close = 'left',
                insert_at_start = true,
                sidebar_filetypes = {
                    ['neo-tree'] = {
                        event = 'BufWipeout',
                        text = '        File Explorer'
                    }
                },
                icons = {
                    diagnostics = {
                        [vim.diagnostic.severity.ERROR] = {
                            enabled = true,
                            icon = 'ﬀ'
                        },
                        [vim.diagnostic.severity.WARN] = {enabled = false},
                        [vim.diagnostic.severity.INFO] = {enabled = false},
                        [vim.diagnostic.severity.HINT] = {enabled = true}
                    }
                    -- gitsigns = {
                    --     added = {enabled = true, icon = '+'},
                    --     changed = {enabled = true, icon = '~'},
                    --     deleted = {enabled = true, icon = '-'}
                    -- }
                },
                maximum_length = 25,
                no_name_title = nil
            }
        }
    }, -- tab bar settings
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
    { -- status bar settings
        {"archibate/lualine-time", event = "VeryLazy", opts = {}}, {}, {
            "nvim-lualine/lualine.nvim",
            dependencies = {
                "nvim-tree/nvim-web-devicons", "meuter/lualine-so-fancy.nvim"
            },
            opts = {
                options = {
                    component_separators = {left = "│", right = "│"},
                    section_separators = {left = "", right = ""},
                    globalstatus = true,
                    refresh = {statusline = 100}
                },
                sections = {
                    lualine_a = {{"fancy_mode", width = 3}},
                    lualine_b = {{"branch", icon = ""}, {"fancy_diff"}},
                    lualine_c = {{"fancy_cwd", substitute_home = true}},
                    lualine_x = {{"fancy_lsp_servers"}},
                    lualine_y = {
                        {"fancy_filetype", ts_icon = ""}, {"fancy_macro"},
                        {"fancy_diagnostics"}, {"fancy_searchcount"},
                        {"location"}, {"ctime"}
                    },
                    lualine_z = {}
                }
            }
        }
    }, -- status bar settings
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
    { -- other ui settings
        { -- disable noisy notify plugin
            "rcarriga/nvim-notify",
            -- enabled = false
            opts = {
                timeout = 1000,
                render = "compact",
                fps = 30,
                stages = "fade",
                level = "ERROR"
            }
        } -- disable noisy notify plugin
        --------------------------------------------
        -- { -- use tmux instead of internal term
        --     "akinsho/toggleterm.nvim",
        --     enabled = false
        -- } -- use tmux instead of internal term
    }, -- other ui settings
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
    { -- things about highlight
        {
            "RRethy/vim-illuminate",
            event = "User AstroFile",
            opts = {},
            config = function(_, opts)
                require("illuminate").configure(opts)
            end
        },
        -----------------------------------------------------------------------------------
        {
            "azabiong/vim-highlighter",
            lazy = false, -- Not Lazy by default
            keys = {
                {"f<Enter>", desc = "Highlight"},
                {"f<BS>", desc = "Remove Highlight"},
                {"f<C-L>", desc = "Clear Highlight"},
                {"f<Tab>", desc = "Find Highlight (similar to Telescope grep)"}
                -- {"nn", "<cmd>Hi><CR>", desc = "Next Recently Set Highlight"},
                -- {"ng", "<cmd>Hi<<CR>", desc = "Previous Recently Set Highlight"},
                -- {"n[", "<cmd>Hi{<CR>", desc = "Next Nearest Highlight"},
                -- {"n]", "<cmd>Hi}<CR>", desc = "Previous Nearest Highlight"}
            }
        }
    }, -- things about highlight
    {
        "jinzhongjia/LspUI.nvim",
        event = "VeryLazy",
        config = function() require("LspUI").setup() end
    },
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
    { -- settings about astronvim theme
        "AstroNvim/astrotheme",
        opts = {
            style = {
                italic_comments = false,
                inactive = false,
                border = true,
                neotree = false,
                title_invert = false,
                terminal_color = false,
                termguicolors = false
                -- float = false,
                -- popup = false
            },
            palettes = {astrodark = {ui = {base = "#15171a"}}}
        }

    }, -- settings about astronvim theme
    {
        "nvim-neo-tree/neo-tree.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            return require("astronvim.utils").extend_tbl(opts, {
                close_if_last_window = true,
                enable_diagnostics = true,
                sources = {"filesystem", "git_status"},
                window = {width = 35},
                source_selector = {
                    winbar = false,
                    sources = {{source = "filesystem"}}
                },
                filesystem = {
                    bind_to_cwd = true,
                    filtered_items = {
                        always_show = {".github", ".gitignore", ".git"},
                        hide_dotfiles = false,
                        hide_gitignored = false,
                        hide_by_name = {"node_modules", ".cache"},
                        never_show = {".DS_Store", "thumbs.db"}
                    }
                }
            })
        end
    }, {
        -- {
        --     "levouh/tint.nvim",
        --     event = "User AstroFile",
        --     opts = {
        --         highlight_ignore_patterns = {
        --             "WinSeparator", "neo-tree", "Status.*"
        --         },
        --         tint = -70, -- Darken colors, use a positive value to brighten
        --         saturation = 0.6 -- Saturation to preserve
        --     }
        -- }
    }, {
        "goolord/alpha-nvim",
        opts = function(_, opts)
            -- customize the dashboard header
            opts.section.header.val = {
                "                                                         ",
                " ██╗   ██╗███████╗     ██████╗ ██████╗ ██████╗ ███████╗  ",
                " ██║   ██║██╔════╝    ██╔════╝██╔═══██╗██╔══██╗██╔════╝  ",
                " ██║   ██║███████╗    ██║     ██║   ██║██║  ██║█████╗    ",
                " ╚██╗ ██╔╝╚════██║    ██║     ██║   ██║██║  ██║██╔══╝    ",
                "  ╚████╔╝ ███████║    ╚██████╗╚██████╔╝██████╔╝███████╗  ",
                "   ╚═══╝  ╚══════╝     ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝  ",
                "                                                         "
            }
            opts.config.opts.noautocmd = false
            local button = require("astronvim.utils").alpha_button
            opts.section.buttons.val = {
                button("LDR n  ", "  New File  "),
                button("LDR f p", "  Find Project  "),
                button("LDR f f", "  Find File  "),
                button("LDR f o", "󰈙  Recents  "),
                button("LDR f w", "󰈭  Find Word  "),
                button("LDR S f", "  Find Session  "),
                button("LDR f '", "  Bookmarks  "),
                button("LDR S l", "  Last Session  ")
            }
            return opts
        end
    }, {"aserowy/tmux.nvim", event = "VeryLazy", opts = {}}
}
