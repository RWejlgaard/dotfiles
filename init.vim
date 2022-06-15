set nocompatible
set shell=bash
filetype off

" check if running in vim
if has('nvim')
    let s:editor_root=expand("~/.nvim")
else
    let s:editor_root=expand("~/.vim")
endif

" set python path
let g:python_host_prog="/usr/local/bin/python3"

" COLORS!
set termguicolors

" load plugins from seperate file since there's a lot of them
source $HOME/.config/nvim/plug.vim

" remove vim-jedi nag pane
autocmd FileType python setlocal completeopt-=preview
set completeopt-=preview

" hide info (preview) window after completions
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" enable highlighting
syntax enable

" enable line numbers
set nonumber
set nu

" setup formatting
set ts=4
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab " bind tab to use spaces, sue me
set backspace=2
set laststatus=2
set showbreak=\\ "
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set encoding=utf-8

" enable mouse input
set mouse+=a

" set clipboard to be shared with OS
set clipboard=unnamed

" add line at 101 chars line length
set colorcolumn=101

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_loc_list_height = 5
let g:syntastic_shell = "/bin/sh"
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_jump = 0
let g:Powerline_symbols = 'fancy'

" enable cool bar to see where you are in a file
let g:airline#extensions#scrollbar#enabled = 1

" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" terraform settings
let g:syntastic_terraform_tffilter_plan = 1
let g:terraform_completion_keys = 1
let g:terraform_registry_module_completion = 1
let g:terraform_fmt_on_save = 1
let g:terraform_align = 0

"" Keybindings

" file browser
nnoremap nt :NERDTreeToggle<CR>
" panic quit
nnoremap qqq :qall<CR>
" fuzzy find
nnoremap <C-f> :Files<CR>
" fuzzy ripgrep all files in directory
nnoremap <leader>/ :Rg<CR>

" splits
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>

" syntastic
nnoremap <leader>sc :SyntasticCheck<CR>

" resize panes
nnoremap <C-Down> :resize -1<CR>
nnoremap <C-Up> :resize +1<CR>
nnoremap <C-Right> :vertical resize +1<CR>
nnoremap <C-Left> :vertical resize -1<CR>
nnoremap <C-j> :resize -1<CR>
nnoremap <C-k> :resize +1<CR>
nnoremap <C-l> :vertical resize +1<CR>
nnoremap <C-h> :vertical resize -1<CR>

" hacky fix for CTRL-SPC autocompletion
inoremap <silent><expr><C-@> coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()

" fuzzy find active buffers
nnoremap <leader>b :Buffers<CR>

" tab management
nnoremap <M-t> :tabnew<CR>
nnoremap <M-q> :tabclose<CR>

" easymotion - bind \\ to jump to a specific character
let g:EasyMotion_do_mapping = 0 " Disable default mappings
nmap \\ <Plug>(easymotion-overwin-f)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" copilot all the things
let g:copilot_filetypes = {'*': v:true}

" I ❤️ gruvbox
colorscheme gruvbox

