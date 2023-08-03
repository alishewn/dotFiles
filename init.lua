return {
    options = {
        g = {
            diagnostics_mode = 3,
            inlay_hints_enabled = false,
            riscv_asm_all_enable = 1
            -- autoformat_enabled = false
        },
        b = {inlay_hints_enabled = false},
        opt = {relativenumber = false, foldcolumn = "0"}
    },
    icons = {
        VimIcon = "",
        ScrollText = "",
        GitBranch = "",
        GitAdd = "",
        GitChange = "",
        GitDelete = ""
    },
    lazy = {
        git = {
            timeout = 30
            -- url_format = 'https://hub.gitmirror.com/https://github.com/%s.git'
        }
    }
    -- barbar = {utils = {hl = {attributes = {italic = false}}}},
    -- vim.api.nvim_create_autocmd('Colorscheme', {
    --     group = vim.api.nvim_create_augroup('config_custom_highlights', {}),
    --     callback = function()
    --         vim.api.nvim_set_hl(0, 'BufferCurrentADDED',
    --                             {fg = '#7EA662', italic = false})
    --         vim.api.nvim_set_hl(0, 'BufferCurrentCHANGED',
    --                             {fg = '#4FA6ED', italic = false})
    --         vim.api.nvim_set_hl(0, 'BufferCurrentDELETED',
    --                             {fg = '#E55561', italic = false})
    --     end
    -- })
}
