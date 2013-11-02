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

"----Line Highlighting
"    set cursorcolumn    " Highlight the current column
"    set cursorline      " Highlight the current line

"----Import Vim Pathogen
	call pathogen#infect() 

"---Import Plasticboy vim-Markdown
	let g:vim_markdown_folding_disabled=1	"Disable Folding
	let g:vim_markdown_initial_foldlevel=1	"Set initial Fold Level

"----vim plugins
	"Plasticboy https://github.com/plasticboy/vim-markdown
