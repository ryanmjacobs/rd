""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Personal .vimrc file
"
" Maintained By: Ryan Jacobs <ryan.mjacobs@gmail.com>
"  Last Updated: March 18, 2014
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable 256 colors if the terminal supports it
if $COLORTERM == 'gnome-terminal' || $TERM == 'xterm-256color'
  set t_Co=256
endif

" Highlight column 80
set colorcolumn=80

" Default color scheme
colorscheme molokai

" Enable syntax highlighting, auto-indentation, and a default tab of 4 spaces
" that convert to spaces
syntax on
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab

" Ban the use of arrow keys (hjkl is more efficient anyways)
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Map F1 Key to escape when in insert mode,
" otherwise, map it to help.
inoremap <F1> <Esc>
noremap <F1> :call MapF1()<CR>
function! MapF1()
    if &buftype == "help"
        exec 'quit'
    else
        exec 'help'
    endif
endfunction

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
    let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>
