noremap <Down> <Nop>
noremap <Up> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Down> <Nop>
inoremap <Up> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>


set number
set shiftwidth=4
set tabstop=4 
set expandtab
set clipboard=unnamed
set mouse=
set scrolloff=7
set statusline^=%{coc#status()}

let g:rustfmt_autosave = 1
autocmd TermOpen * startinsert
autocmd TermOpen * setlocal nonumber norelativenumber

let s:pb = expand('%:t:r')
let s:codefolder = expand('~/Documents/codefolder/')
let s:home = expand('~/Documents/codefolder/atcoder/')
let s:snip_d= expand('~/Documents/codefolder/atcoder/snippet/')
let s:url = 'https://atcoder.jp/contests/'
command! Rc :e $MYVIMRC
command! RRc :source $MYVIMRC
command! Watch   execute ':terminal cargo compete w submissions atcoder' split(expand('%:p:h'), '\')[6]
command! Me      execute ':!start ' . s:url . split(expand('%:p:h'),'\')[6] . '/submissions/me'
command! Open    execute ':!start ' . s:url . split(expand('%:p:h'),'\')[6] . '/tasks/' . split(expand('%:p:h'),'\')[6] . '_' . s:pb
command! Rank    execute ':!start ' . s:url . split(expand('%:p:h'),'\')[6] . '/standings'
command! Test    execute ':terminal cargo compete t' s:pb
command! TestR   execute ':terminal cargo compete t' s:pb "--release"
command! Submit  execute ':terminal cargo compete s' s:pb
command! SubmitN execute ':terminal cargo compete s' s:pb "--no-test"
command! TestCase execute ':e testcases\' . s:pb . '.yml'
command! PG call s:pg()
function! s:pg()
        execute ':e ' . s:codefolder . '\play_ground\src\template.rs'
        execute ':w! ' . s:codefolder . '\play_ground\src\main.rs'
        execute ':bd!'
        execute ':!@wt -w 0 nt -d ' .s:codefolder. '\play_ground -V cargo watch -i target/ -x "run"'
        execute ':!@wt -w 0 sp -s 0.6 --title PlayGround -d ' . s:codefolder . 'play_ground\src\ nvim main.rs'
        execute ':!wt -w 0 ft mf right'
endfunction

command! Snippet execute ':!wt -w 0 nt -d ' . s:home . 'Snippet/src/ -c nvim .'
command! SnippetW call s:snippet_write()
function! s:snippet_write()
        execute ':cd ' . s:snip_d
        execute ':e ~/AppData/Roaming/Code/User/snippets/rust.json'
        execute ':%d'
        execute ':r! cargo snippet -t vscode'
        execute ':w'
        execute ':e ~/AppData/Local/coc/ultisnips/rust.snippets'
        execute ':%d'
        execute ':r! cargo snippet -t ultisnips'
        execute ':r ~/Documents/codefolder/atcoder/snippet/src/other.snippets'
        execute ':w'
        execute ':cd -'
endfunction
command! -nargs=1 Np execute 'NN' split(expand('%:p:h'), '\')[6] <f-args>
command! -nargs=+ NN call s:newcontest(<f-args>)
function! s:newcontest(...)
        let s:contest = a:1
        let s:problem = 'a'
        if a:0 == 2
                let s:problem = a:2
        endif
        let s:full = expand(s:home . s:contest)
        let s:title = s:contest . ' ' . s:problem
        if !isdirectory(s:full)
                execute ':cd ' . s:home
                execute ':!cargo compete new' s:contest
        endif
        execute ':!wt -w 0 nt -d ' s:full ' cargo watch -x "compete t ' . s:problem . '"'
        execute ':!wt -w 0 sp -V -s 0.7 --title "' . s:title . '"' " -d " s:full " nvim .\\src\\bin\\" . s:problem . ".rs +5"
        execute ':!wt -w 0 ft mf right'
        execute ':!start https://atcoder.jp/contests/' . s:contest . '/tasks/' . s:contest . '_' . s:problem
endfunction

command! -nargs=1 Sep call s:separate(<f-args>)
function! s:separate(...)
        let s:problem = a:1
        execute ':vs +terminal'
        execute ':terminal cargo watch -x "compete t ' . s:problem . '"'
endfunction

syntax on
let g:python3_host_prog = '~\AppData\Local\Programs\Python\Python311\python.exe'
call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'rust-lang/rust.vim'
Plug 'sainnhe/gruvbox-material'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'honza/vim-snippets'
Plug 'ntk148v/vim-horizon'
call plug#end()
if has('termguicolors')
        set termguicolors
endif
set background=dark
let g:gruvbox_material_background = 'soft'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_disable_italic_comment = 1
colorscheme gruvbox-material

let g:coc_global_extensions = [
      \'coc-json', 
      \'coc-pairs', 
      \'coc-snippets', 
      \'coc-ultisnips', 
      \'coc-vimlsp', 
      \'coc-lua', 
      \'coc-yaml', 
      \'coc-toml', 
      \'coc-rust-analyzer', 
      \'coc-python', 
\]
