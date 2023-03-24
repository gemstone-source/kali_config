"Setting numbers
set number

"Set syntax on codes
syntax on

" Set tab space
set expandtab shiftwidth=3 softtabstop=3

"Enable auto indent
set autoindent

"autocompletion of () and {}
inoremap ( ()<ESC>i
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap { {}<ESC>i
inoremap } <c-r>=ClosePair('}')<CR>

function! ClosePair(char)
  if getline('.')[col('.') - 1] == a:char
    return "\<Right>"
  else
    return a:char
  endif
endfunction

"Set dollar sign at the end of the line 
set list
