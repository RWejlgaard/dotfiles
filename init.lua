-- Bootstrap packer, if it's not installed (first run)
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    Packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
        install_path })
end

-- plugins
local use = require('packer').use
require('packer').startup(function()
    use { 'airblade/vim-gitgutter' }            -- show git changes in the gutter
    use { 'hashivim/vim-terraform' }            -- terraform syntax highlighting
    use {
        'junegunn/fzf',
        run = 'fzf#install()'
    }
    use {'junegunn/fzf.vim'}
    use { 'EdenEast/nightfox.nvim' }            -- nightfox theme
    use { 'nvim-treesitter/nvim-treesitter' }   -- treesitter, makes syntax highlighting better
    use { 'scrooloose/nerdcommenter' }          -- easy commenting
    use { 'tpope/vim-fugitive' }                -- git integration with :G{git cmd}
    use { 'itchyny/lightline.vim' }             -- statusline
    use { 'wookayin/fzf-ripgrep.vim' }          -- fzf ripgrep integration, for "<leader>/"
    use { 'yuki-yano/fzf-preview.vim' }         -- fzf preview
    use { 'wbthomason/packer.nvim' }            -- package manager
    use { 'fatih/vim-go' }                      -- go syntax highlighting
    use { "ellisonleao/glow.nvim" }             -- markdown preview using :Glow
    use { 'rhysd/git-messenger.vim' }           -- Show git messages under cursor
    use { 'onsails/lspkind.nvim' }              -- lsp kind, makes autocomplete look better
    use { 'zbirenbaum/copilot.lua' }            -- copilot
    use {                                       -- copilot addon for cmp
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end
    }
    use { 'nvim-lua/plenary.nvim' }             -- lua utility functions
    use { 'CopilotC-Nvim/CopilotChat.nvim' }    -- copilot chat
    use {                                       -- adds file bars along the top similar to vscode
        'romgrk/barbar.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use {                                       -- adds a file explorer similar to vscode
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    }
    use {                                       -- adds diagnostics for files
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {}
        end
    }
    use {                                       -- better terminal
        's1n7ax/nvim-terminal',
        config = function()
            vim.o.hidden = true
            require('nvim-terminal').setup()
        end
    }
    use {                                       -- mason, easy download and install of LSPs
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig"
    }
    use {                                       -- LSP
        'VonHeikemen/lsp-zero.nvim',
        requires = {                                                    -- LSP Support
            { 'neovim/nvim-lspconfig' }, { 'williamboman/nvim-lsp-installer' }, -- Autocompletion
            { 'hrsh7th/nvim-cmp' }, { 'hrsh7th/cmp-buffer' }, { 'hrsh7th/cmp-path' }, { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' }, { 'hrsh7th/cmp-nvim-lua' },     -- Snippets
            { 'L3MON4D3/LuaSnip' }, { 'rafamadriz/friendly-snippets' } }
    }
end)

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
vim.cmd('set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab')
vim.opt.number = true
vim.opt.colorcolumn = '80'
vim.g.terraform_fmt_on_save = true

-- keybindings
local opts = {
    noremap = true,
    silent = true
}
vim.api.nvim_set_keymap('n', 'nt', ':Neotree toggle<CR>', opts)
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
require("CopilotChat").setup {}

require("copilot").setup({
    suggestion = {
        enabled = false
    },
    panel = {
        enabled = false
    }
})

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

-- Open NeoTree on startup when no file is specified
--vim.api.nvim_create_augroup('NeoTreeOnStartup', { clear = true })
--vim.api.nvim_create_autocmd('VimEnter', {
  --group = 'NeoTreeOnStartup',
  --callback = function()
    --if vim.fn.argc() == 0 then
      --vim.cmd('Neotree toggle')
    --end
  --end
--})

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
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { -- 
    fg = "#6CC644"
})

cmp.setup({
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 70,   -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as
            -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
            ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(_, vim_item)
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
    sources = cmp.config.sources({ {
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
    }, { {
        name = 'buffer'
    } })
})

-- enable diagnostics for showing in-line
vim.g.diagnostics_active = true
vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true
}

vim.cmd('colorscheme carbonfox')
