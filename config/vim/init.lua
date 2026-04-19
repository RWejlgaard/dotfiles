-- ignorance is bliss - silence deprecation warnings on startup
vim.deprecate = function () end

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
    { 'airblade/vim-gitgutter' },            -- show git changes in the gutter
    { 'hashivim/vim-terraform' },            -- terraform syntax highlighting
    {
        'junegunn/fzf',
        run = 'fzf#install()'
    },
    {'junegunn/fzf.vim'},
    { 'EdenEast/nightfox.nvim' },            -- nightfox theme
    { 'nvim-treesitter/nvim-treesitter' },   -- treesitter, makes syntax highlighting better
    { 'scrooloose/nerdcommenter' },          -- easy commenting
    { 'tpope/vim-fugitive' },                -- git integration with :G{git cmd}
    { 'itchyny/lightline.vim' },             -- statusline
    { 'wookayin/fzf-ripgrep.vim' },          -- fzf ripgrep integration, for "<leader>/"
    { 'yuki-yano/fzf-preview.vim' },         -- fzf preview
    { 'fatih/vim-go' },                      -- go syntax highlighting
    { "ellisonleao/glow.nvim" },             -- markdown preview using :Glow
    { 'rhysd/git-messenger.vim' },           -- Show git messages under cursor
    { 'onsails/lspkind.nvim' },              -- lsp kind, makes autocomplete look better
    { 'hrsh7th/vim-vsnip' },
    { 'nvim-lua/plenary.nvim' },             -- lua utility functions
    {
        "ccntrq/autoreload.nvim",
        opts = {}, -- make sure setup is called with defaults
    },
    {                                       -- adds file bars along the top similar to vscode
        'romgrk/barbar.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons' }
    },
    {                                       -- adds a file explorer similar to vscode
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    },
    {                                       -- adds diagnostics for files
        "folke/trouble.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {}
        end
    },
    {                                       -- better terminal
        's1n7ax/nvim-terminal',
        config = function()
            vim.o.hidden = true
            require('nvim-terminal').setup()
        end
    },
    {                                       -- mason, easy download and install of LSPs
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig"
    },
    {                                       -- LSP
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {                                                    -- LSP Support
            { 'neovim/nvim-lspconfig' }, { 'williamboman/nvim-lsp-installer' }, -- Autocompletion
            { 'hrsh7th/nvim-cmp' }, { 'hrsh7th/cmp-buffer' }, { 'hrsh7th/cmp-path' }, { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' }, { 'hrsh7th/cmp-nvim-lua' },     -- Snippets
            { 'L3MON4D3/LuaSnip' }, { 'rafamadriz/friendly-snippets' } }
    },
})

-- settings
vim.opt.termguicolors = true
vim.opt.guifont = 'FiraCode Nerd Font:h12'
vim.opt.number = true
vim.opt.smarttab = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.backspace = '2'
vim.opt.laststatus = 2
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamed'
vim.opt.scrolloff = 17
vim.opt.colorcolumn = '80'
vim.g.terraform_fmt_on_save = true

-- keybindings
local opts = {
    noremap = true,
    silent = true
}
vim.api.nvim_set_keymap('n', '<leader>t', ':Neotree toggle<CR>', opts)
vim.api.nvim_set_keymap('n', 'qqq', ':qall<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-f>', ':Files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>/', ':Rg<CR>', opts)

vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', ':split<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':Buffers<CR>', opts)
vim.api.nvim_set_keymap('t', '<leader><ESC>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', ':Trouble diagnostics toggle<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>g', ':GitMessenger<CR>', opts)
vim.api.nvim_set_keymap('n', 'd', '"_d', opts)
vim.api.nvim_set_keymap('v', 'd', '"_d', opts)
vim.api.nvim_set_keymap('n', 'c', '"_c', opts)
vim.api.nvim_set_keymap('v', 'c', '"_c', opts)

-- plugins setup
require("nvim-lsp-installer").setup {}

require("neo-tree").setup {
    close_on_open = false,
    close_if_last_window = true,
    window = {
        width = 40,
        side = "left",
        auto_resize = true,
        mappings = {
            ["o"] = "open"
        }
    },
    filesystem = {
        hijack_netrw_behavior = "open_current"
    }
}

-- Auto reload files when they change
require("autoreload").setup({
  autoread = true,
  events = { "BufEnter", "FocusGained" },
  timer = {
    enabled = true,
    interval_ms = 3000,
    start_delay_ms = 0,
  },
  notify = {
    on_conflict = true,
    on_reload = true,
  },
})

-- Language Server
local lsp_zero = require('lsp-zero')
local cmp = require('cmp')

lsp_zero.on_attach(function(_, bufnr)
    lsp_zero.default_keymaps({
        buffer = bufnr
    })
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'bashls',
        'dockerls',
        'gopls',
        'jsonls',
        'yamlls',
        'pyright',
    },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end
    }
})

local lspkind = require('lspkind')
lspkind.init({})

cmp.setup({
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol',
            maxwidth = 70,
            ellipsis_char = '...',
            show_labelDetails = true,
        })
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    window = {},
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true })
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'path' },
    }, {
        { name = 'buffer' },
    })
})

-- enable diagnostics for showing in-line
vim.g.diagnostics_active = true
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true
}

vim.cmd('colorscheme murphy')
