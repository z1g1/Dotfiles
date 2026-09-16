"----Color Scheme (terminal is white background / black text)
    set background=light
    set notermguicolors   " use the terminal's palette, not 24-bit colors
    syntax on
"----Line Numbering
    set number          " Turn on line numbers
    set numberwidth=5   " Allow fof numbers up to 99999
"----No File Backups
    set nobackup        " no backup files
    set nowritebackup   " only in case you don't want a backup file while editing
    set noswapfile      " no swap file
"----size of a hard tabstop
    set tabstop=4
"----size of an "indent"
    set shiftwidth=4
"----a combination of spaces and tabs are used to simulate tab stops at a width other than the (hard)tabstop
    set softtabstop=4
"----Background Color
" NONE = use the terminal's own default bg/fg, so Vim never paints a
" palette color (e.g. "white" = color 7/15, which many themes render gray).
" Re-applied on ColorScheme so a :colorscheme can't bring the gray back.
    function! s:TerminalColors()
        highlight Normal     ctermfg=NONE ctermbg=NONE guifg=black guibg=white
        highlight NonText    ctermbg=NONE
        highlight EndOfBuffer ctermbg=NONE
        highlight LineNr     ctermfg=darkgray ctermbg=NONE
        highlight SignColumn ctermbg=NONE
    endfunction
    augroup TerminalColors
        autocmd!
        autocmd ColorScheme * call s:TerminalColors()
    augroup END
    call s:TerminalColors()
