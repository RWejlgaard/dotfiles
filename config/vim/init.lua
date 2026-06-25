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
    {
        'okuuva/auto-save.nvim',             -- auto-save buffers on changes
        event = { 'InsertLeave', 'TextChanged' },
        opts = {},
    },
    {
        'vimwiki/vimwiki',                   -- personal wiki with markdown syntax
        init = function()
            vim.g.vimwiki_list = {
                {
                    path = '~/vimwiki/',
                    syntax = 'markdown',
                    ext = '.md',
                },
            }
            vim.g.vimwiki_global_ext = 0
            -- vimwiki's InsertLeave table auto-formatter mutates the buffer
            -- and clobbers markview's extmarks, breaking the preview
            vim.g.vimwiki_table_auto_fmt = 0
            -- treesitter has no vimwiki parser; route vimwiki buffers
            -- through the markdown parser so markview can re-render
            vim.treesitter.language.register('markdown', 'vimwiki')
        end,
    },
    { 'lewis6991/gitsigns.nvim' },            -- show git changes in the gutter
    { 'hashivim/vim-terraform' },            -- terraform syntax highlighting
    {
        'junegunn/fzf',
        run = 'fzf#install()'
    },
    { 'junegunn/fzf.vim' },
    { 'EdenEast/nightfox.nvim' },            -- nightfox theme
    {
        'nvim-treesitter/nvim-treesitter',   -- treesitter, makes syntax highlighting better
        build = ':TSUpdate',
        main = 'nvim-treesitter.config',
        opts = {
            ensure_installed = { 'make', 'go', 'python', 'bash', 'json', 'yaml', 'lua' },
            auto_install = true,
            highlight = { enable = true },
        },
    },
    { 'numToStr/Comment.nvim' },             -- easy commenting
    { 'tpope/vim-fugitive' },                -- git integration with :G{git cmd}
    { 'itchyny/lightline.vim' },             -- statusline
    { 'wookayin/fzf-ripgrep.vim' },          -- fzf ripgrep integration, for "<leader>/"
    { 'yuki-yano/fzf-preview.vim' },         -- fzf preview
    { 'fatih/vim-go' },                      -- go syntax highlighting
    {                                        -- markdown preview in-buffer
        'OXY2DEV/markview.nvim',
        ft = { 'markdown', 'yaml', 'vimwiki' },
        opts = {
            preview = {
                filetypes = { 'markdown', 'quarto', 'rmd', 'typst', 'vimwiki' },
            },
            yaml = { enable = true },
        },
    },
    { 'folke/flash.nvim', opts = {} },       -- fast motion/jump anywhere on screen
    { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
    {
        'stevearc/aerial.nvim',              -- symbol outline panel
        opts = { open_automatic = true },
    },
    { 'rhysd/git-messenger.vim' },           -- Show git messages under cursor
    {
        'kdheepak/lazygit.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    { 'onsails/lspkind.nvim' },              -- lsp kind, makes autocomplete look better
    { 'hrsh7th/vim-vsnip' },
    { 'nvim-lua/plenary.nvim' },             -- lua utility functions
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
    { 'stevearc/conform.nvim' },
    { 'lukas-reineke/indent-blankline.nvim' },
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "ccntrq/autoreload.nvim",
        opts = {}, -- make sure setup is called with defaults
    },
    {                                       -- adds file bars along the top similar to vscode
        'romgrk/barbar.nvim',
        dependencies = { 'kyazdani42/nvim-web-devicons' }
    },
    {                                       -- adds a file explorer similar to vscode
        'nvim-tree/nvim-tree.lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
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
    {                                       -- mason: install & manage LSP servers
        'mason-org/mason.nvim',
        opts = {},
    },
    {                                       -- bridge mason <-> lspconfig; auto-enables installed servers
        'mason-org/mason-lspconfig.nvim',
        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
        },
        opts = {
            ensure_installed = { 'bashls', 'dockerls', 'gopls', 'jsonls', 'yamlls', 'pyright', 'lua_ls' },
        },
    },
    {                                       -- autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-nvim-lua',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip', 'rafamadriz/friendly-snippets',
        },
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
vim.opt.signcolumn = 'yes'
vim.g.terraform_fmt_on_save = true

-- keybindings
local opts = {
    noremap = true,
    silent = true
}
vim.api.nvim_set_keymap('n', 't', ':NvimTreeToggle<CR>', opts)
vim.api.nvim_set_keymap('n', 'qqq', ':qall<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-f>', ':Telescope find_files<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>/', ':Rg<CR>', opts)

vim.api.nvim_set_keymap('n', '<leader>v', ':vsplit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', ':split<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':Buffers<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>[', ':bprev<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>]', ':bnext<CR>', opts)
vim.api.nvim_set_keymap('t', '<leader><ESC>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', ':Trouble diagnostics toggle<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>g', ':GitMessenger<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>lg', ':LazyGit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>a', ':AerialToggle<CR>', opts)
vim.keymap.set({'n', 'x', 'o'}, '<leader>s', function() require('flash').jump() end)
vim.keymap.set({'n', 'x', 'o'}, '<leader>S', function() require('flash').treesitter() end)
vim.api.nvim_set_keymap('n', 'd', '"_d', opts)
vim.api.nvim_set_keymap('v', 'd', '"_d', opts)
vim.api.nvim_set_keymap('n', 'c', '"_c', opts)
vim.api.nvim_set_keymap('v', 'c', '"_c', opts)

-- plugins setup
require('gitsigns').setup()
require('telescope').setup()
require('telescope').load_extension('fzf')
require('ibl').setup()
require('Comment').setup({
    toggler = { line = '<leader>c<space>' },
    opleader = { line = '<leader>c<space>' },
})
require('todo-comments').setup()

require('conform').setup({
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
    formatters_by_ft = {
        go = { 'gofmt' },
        python = { 'black' },
        terraform = { 'terraform_fmt' },
        sh = { 'shfmt' },
        json = { 'jq' },
        yaml = { 'prettier' },
    },
})

vim.api.nvim_create_autocmd('BufEnter', {
    nested = true,
    callback = function()
        if #vim.api.nvim_list_wins() == 1 and require('nvim-tree.utils').is_nvim_tree_buf() then
            vim.cmd('quit')
        end
    end
})

require('nvim-tree').setup({
    view = {
        width = 40,
        side = 'left',
    },
    hijack_netrw = true,
    actions = {
        open_file = {
            quit_on_open = false,
        }
    }
})

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

-- Language Server (native LSP, Neovim 0.11+)
-- mason-lspconfig auto-enables the servers it installs; we only supply the
-- shared completion capabilities and the lua_ls runtime settings here.
local cmp = require('cmp')

vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Teach lua_ls about the Neovim runtime and the `vim` global.
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
})

-- Buffer-local LSP keymaps (replaces lsp-zero's default_keymaps).
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'x' }, '<F4>', vim.lsp.buf.code_action, opts)
    end,
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

vim.cmd('colorscheme carbonfox')
