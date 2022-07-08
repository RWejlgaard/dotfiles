-- Bootstrap packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
        install_path })
end

-- plugins
local use = require('packer').use
require('packer').startup(function()
    use { 'Xuyuanp/nerdtree-git-plugin' }
    use { 'airblade/vim-gitgutter' }
    use { 'airblade/vim-rooter' }
    use { 'antoinemadec/FixCursorHold.nvim' }
    use { 'easymotion/vim-easymotion' }
    use { 'hashivim/vim-terraform' }
    use { 'junegunn/fzf', run = 'fzf#install()' }
    use { 'junegunn/fzf.vim' }
    use { 'morhetz/gruvbox' }
    use { 'nvim-treesitter/nvim-treesitter' }
    use { 'scrooloose/nerdcommenter' }
    --use { 'scrooloose/nerdtree' }
    use { 'tpope/vim-fugitive' }
    use { 'tpope/vim-surround' }
    --use { 'vim-airline/vim-airline' }
    use { 'itchyny/lightline.vim' }
    use { 'josa42/nvim-lightline-lsp' }
    use { 'wookayin/fzf-ripgrep.vim' }
    use { 'yuki-yano/fzf-preview.vim' }
    use { 'wbthomason/packer.nvim' }
    use { 'godlygeek/tabular' }
    use { 'nvim-lua/lsp-status.nvim' }
    use { 'folke/tokyonight.nvim' }
    use {
        "folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    }
    use {
        'romgrk/barbar.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use({
        "catppuccin/nvim",
        as = "catppuccin"
    })
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {
            'kyazdani42/nvim-web-devicons',
        },
    }
    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {}
        end
    }
    use {
        's1n7ax/nvim-terminal',
        config = function()
            vim.o.hidden = true
            require('nvim-terminal').setup()
        end,
    }
    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/nvim-lsp-installer' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }
end)

-- settings
vim.opt.termguicolors = true
vim.api.nvim_set_option('guifont', 'SauceCodePro NF:h12')
vim.api.nvim_set_option('number', true)
vim.api.nvim_set_option('smarttab', true)
vim.api.nvim_set_option('tabstop', 8)
vim.api.nvim_set_option('softtabstop', 0)
vim.api.nvim_set_option('expandtab', true)
vim.api.nvim_set_option('shiftwidth', 4)
vim.api.nvim_set_option('backspace', '2')
vim.api.nvim_set_option('laststatus', 2)
vim.cmd('set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab')

vim.api.nvim_set_option('mouse', 'a')
vim.api.nvim_set_option('clipboard', 'unnamed')
vim.api.nvim_set_option('scrolloff', 17)
vim.opt.number = true
vim.opt.colorcolumn = '101'

vim.g.terraform_fmt_on_save = true
vim.g.diagnostics_active = true
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
}

-- keybindings
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'nt', ':NvimTreeToggle<CR>', opts)
vim.api.nvim_set_keymap('n', 'qqq', ':qall<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-f>', ':Files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>/', ':Rg<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', ':split<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':Buffers<CR>', opts)
vim.api.nvim_set_keymap('i', '<C-Space>', '<C-e>', opts)
vim.api.nvim_set_keymap('n', '<C-]>', ':BufferLineCycleNext<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-[>', ':BufferLineCyclePrev<CR>', opts)
vim.api.nvim_set_keymap('t', '<leader><ESC>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', ':TroubleToggle<CR>', opts)
vim.api.nvim_set_keymap('n', 'd', '"_d', opts)
vim.api.nvim_set_keymap('v', 'd', '"_d', opts)
vim.api.nvim_set_keymap('n', 'c', '"_c', opts)
vim.api.nvim_set_keymap('v', 'c', '"_c', opts)

require("nvim-tree").setup()

-- Language Server
local lsp = require('lsp-zero')
lsp.preset('recommended')
local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings()

cmp_mappings['<C-Space>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
        cmp.close()
        fallback()
    else
        cmp.complete()
    end
end),

    lsp.setup_nvim_cmp({
        mapping = cmp_mappings
    })

lsp.setup()

-- enable diagnostics for showing in-line
vim.g.diagnostics_active = true
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
}

vim.cmd('colorscheme gruvbox')
