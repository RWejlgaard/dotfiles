set nocompatible
set shell=bash
filetype off

if has('nvim')
    let s:editor_root=expand("~/.nvim")
else
    let s:editor_root=expand("~/.vim")
endif

let g:python_host_prog="/usr/local/bin/python3"

set termguicolors

"LOAD PLUGS
source $HOME/.config/nvim/plug.vim

autocmd FileType python setlocal completeopt-=preview

syntax enable
set nonumber
set nu
set ts=4
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab " bind tab to use spaces, sue me
set backspace=2
set laststatus=2
set showbreak=\\ "
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set encoding=utf-8
set mouse+=a
set clipboard=unnamed
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

" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tffilter_plan = 1
let g:terraform_completion_keys = 1
let g:terraform_registry_module_completion = 1
let g:terraform_fmt_on_save = 1
let g:terraform_align = 0

nnoremap nt :NERDTreeToggle<CR>
nnoremap qqq :qall<CR>
nnoremap <C-f> :Files<CR>
nnoremap <C-_> :Rg<CR>

nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>
nnoremap <leader>sc :SyntasticCheck<CR>

nnoremap <C-Down> :resize -1<CR>
nnoremap <C-Up> :resize +1<CR>
nnoremap <C-Right> :vertical resize +1<CR>
nnoremap <C-Left> :vertical resize -1<CR>

nnoremap <C-j> :resize -1<CR>
nnoremap <C-k> :resize +1<CR>
nnoremap <C-l> :vertical resize +1<CR>
nnoremap <C-h> :vertical resize -1<CR>

nnoremap <M-Up> :m .-2<CR>==
nnoremap <M-Down> :m .+1<CR>==
inoremap <M-Up> <Esc>:m .-2<CR>==gi
inoremap <M-Down> <Esc>:m .+1<CR>==gi

"inoremap <C-Space> coc#refresh()
inoremap <silent><expr><C-@> coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()

nnoremap <leader>b :Buffers<CR>

nnoremap <M-h> :wincmd h<CR>
nnoremap <M-j> :wincmd j<CR>
nnoremap <M-k> :wincmd k<CR>
nnoremap <M-l> :wincmd l<CR>

nnoremap <M-t> :tabnew<CR>
nnoremap <M-q> :tabclose<CR>

source $HOME/.config/nvim/plug.vim

let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap \\ <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
""" Need one more keystroke, but on average, it may be more comfortable.


" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" (Optional)Remove Info(Preview) window
set completeopt-=preview

" (Optional)Hide Info(Preview) window after completions
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"autocmd TextChanged,TextChangedI <buffer> silent write
"autocmd TextChanged,TextChangedI <buffer> silent write

colorscheme gruvbox

