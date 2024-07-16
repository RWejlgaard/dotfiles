-- Bootstrap packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
                                  install_path})
end

vim.api.nvim_set_keymap('n', '<leader>\\', '<Plug>(easymotion-s)', {
    noremap = true,
    silent = true
})

-- plugins
local use = require('packer').use
require('packer').startup(function()
    use {'Xuyuanp/nerdtree-git-plugin'}
    use {'airblade/vim-gitgutter'}
    -- use { 'airblade/vim-rooter' }
    use {'antoinemadec/FixCursorHold.nvim'}
    use {'easymotion/vim-easymotion'}
    use {'hashivim/vim-terraform'}
    use {
        'junegunn/fzf',
        run = 'fzf#install()'
    }
    use {'junegunn/fzf.vim'}
    use { 'EdenEast/nightfox.nvim' }
    use {'morhetz/gruvbox'}
    use {'nvim-treesitter/nvim-treesitter'}
    use {'scrooloose/nerdcommenter'}
    -- use { 'scrooloose/nerdtree' }
    use {'tpope/vim-fugitive'}
    use {'tpope/vim-surround'}
    -- use { 'vim-airline/vim-airline' }
    use {'itchyny/lightline.vim'}
    use {'josa42/nvim-lightline-lsp'}
    use {'wookayin/fzf-ripgrep.vim'}
    use {'yuki-yano/fzf-preview.vim'}
    use {'wbthomason/packer.nvim'}
    use {'godlygeek/tabular'}
    use {'fatih/vim-go'}
    use {'folke/tokyonight.nvim'}
    use {'Yazeed1s/oh-lucy.nvim'}
    use {"ellisonleao/glow.nvim"}
    use {"nvim-lua/lsp-status.nvim"}
    use {'nvim-lua/plenary.nvim'}
    use {'MunifTanjim/nui.nvim'}
    use {'dpayne/CodeGPT.nvim'}
    use {'towolf/vim-helm'}
    use {'onsails/lspkind.nvim'}
    use {'zbirenbaum/copilot.lua'}
    use {
        "zbirenbaum/copilot-cmp",
        after = {"copilot.lua"},
        config = function()
            require("copilot_cmp").setup()
        end
    }
    use { 'zbirenbaum/copilot.lua' }
    use { 'nvim-lua/plenary.nvim' }
    use { 'CopilotC-Nvim/CopilotChat.nvim' }
    use {
        "iamcco/markdown-preview.nvim",
        requires = {"zhaozg/vim-diagram", "aklt/plantuml-syntax"}
    }
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
        requires = {'kyazdani42/nvim-web-devicons'}
    }
    use({
        "catppuccin/nvim",
        as = "catppuccin"
    })
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'}
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
        end
    }
    use {"williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig"}
    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = { -- LSP Support
        {'neovim/nvim-lspconfig'}, {'williamboman/nvim-lsp-installer'}, -- Autocompletion
        {'hrsh7th/nvim-cmp'}, {'hrsh7th/cmp-buffer'}, {'hrsh7th/cmp-path'}, {'saadparwaiz1/cmp_luasnip'},
        {'hrsh7th/cmp-nvim-lsp'}, {'hrsh7th/cmp-nvim-lua'}, -- Snippets
        {'L3MON4D3/LuaSnip'}, {'rafamadriz/friendly-snippets'}}
    }
end)

-- settings
vim.opt.termguicolors = true
vim.api.nvim_set_option('guifont', 'FiraCode Nerd Font:h12')
-- vim.api.nvim_set_option('NERDTreeChDirMode', 2)
vim.api.nvim_set_option('number', true)
vim.api.nvim_set_option('smarttab', true)
vim.api.nvim_set_option('tabstop', 8)
vim.api.nvim_set_option('softtabstop', 0)
vim.api.nvim_set_option('expandtab', true)
vim.api.nvim_set_option('shiftwidth', 4)
vim.api.nvim_set_option('backspace', '2')
vim.api.nvim_set_option('laststatus', 2)
vim.api.nvim_set_option('mouse', 'a')
vim.api.nvim_set_option('clipboard', 'unnamed')
vim.api.nvim_set_option('scrolloff', 17)
vim.cmd('set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab')
vim.opt.number = true
vim.opt.colorcolumn = '80'
vim.g.terraform_fmt_on_save = true

-- keybindings
local opts = {
    noremap = true,
    silent = true
}
vim.api.nvim_set_keymap('n', 'nt', ':NvimTreeToggle<CR>', opts)
vim.api.nvim_set_keymap('n', 'qqq', ':qall<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-f>', ':Files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>/', ':Rg<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>\\', '<Plug>(easymotion-s)', opts)

vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', ':split<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':Buffers<CR>', opts)
vim.api.nvim_set_keymap('t', '<leader><ESC>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', ':Trouble diagnostics toggle<CR>', opts)
vim.api.nvim_set_keymap('n', 'd', '"_d', opts)
vim.api.nvim_set_keymap('v', 'd', '"_d', opts)
vim.api.nvim_set_keymap('n', 'c', '"_c', opts)
vim.api.nvim_set_keymap('v', 'c', '"_c', opts)

-- plugins setup
require("CopilotChat").setup {}

require("copilot").setup({
    suggestion = {
        enabled = false
    },
    panel = {
        enabled = false
    }
})

require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive"
    },
    view = {
        width = 50
    },
    renderer = {
        group_empty = true
    },
    filters = {
        dotfiles = true
    },
    actions = {
        open_file = {
            quit_on_open = true,
        },
    },
})

require("nvim-lsp-installer").setup {}

-- Language Server
local lsp_zero = require('lsp-zero')
local cmp = require('cmp')

lsp_zero.on_attach(function(client, bufnr)
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
        'terraformls'
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
lspkind.init({
    symbol_map = {
        Copilot = ""
    }
})
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {
    fg = "#6CC644"
})

cmp.setup({
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as 
            -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
                -- do some customizations ...
                return vim_item
            end
        })
    },
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
        end
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({
            select = true
        }) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({{
        name = 'copilot'
    }, {
        name = 'nvim_lsp'
    }, {
        name = 'nvim_lua'
    }, {
        name = 'path'
    } -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
    }, {{
        name = 'buffer'
    }})
})

-- enable diagnostics for showing in-line
vim.g.diagnostics_active = true
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true
}

vim.cmd('colorscheme carbonfox')
vim.api.nvim_set_keymap('n', '<leader>\\', '<Plug>(easymotion-s)', opts)
