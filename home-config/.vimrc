" ╔══════════════════════════════════════════════════════════════════════════════╗
" ║ 1. BASICS & INDENTATION                                                    ║
" ╚══════════════════════════════════════════════════════════════════════════════╝
syntax on
set number
set smartindent
set splitbelow
filetype plugin indent on

" Enable hybrid line numbers (Relative in normal, Absolute in insert)
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END


" ╔══════════════════════════════════════════════════════════════════════════════╗
" ║ 2. CLIPBOARD & KEYMAPS                                                     ║
" ╚══════════════════════════════════════════════════════════════════════════════╝
" Use system clipboard by default
set clipboard=unnamedplus

" Map Ctrl+c to copy in Visual mode
vnoremap <C-c> "+y
" Map Ctrl+x to cut in Visual mode
vnoremap <C-x> "+x
" Map Ctrl+v to paste in Normal/Insert mode
nnoremap <C-v> "+p
inoremap <C-v> <C-r>+

" Quick yank to system clipboard
vnoremap Y "+y


" ╔══════════════════════════════════════════════════════════════════════════════╗
" ║ 3. TERMINAL & CURSOR FIXES                                                 ║
" ╚══════════════════════════════════════════════════════════════════════════════╝
" Prevent delay after pressing ESC
set noesckeys

" Cursor shaping (Block in Normal, Beam in Insert)
autocmd VimEnter * silent exec "! echo -ne '\e[1 q'"
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
autocmd VimLeave * silent exec "! echo -ne '\e[5 q'"

" Advanced Auto-Paste Detection (fixes indentation issues when pasting)
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction


" ╔══════════════════════════════════════════════════════════════════════════════╗
" ║ 4. THEMES & VISUALS                                                        ║
" ╚══════════════════════════════════════════════════════════════════════════════╝
set termguicolors
set colorcolumn=80

" Default Colorscheme
colorscheme synthwave84
" colorscheme onedark

" Enable transparency
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE


" ╔══════════════════════════════════════════════════════════════════════════════╗
" ║ 5. MACHINE LOCAL OVERRIDES                                                 ║
" ╚══════════════════════════════════════════════════════════════════════════════╝
" Load local config for machine-specific themes or settings
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
