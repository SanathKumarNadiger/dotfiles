vim.g.mapleader = ' '
vim.g.rust_recommended_style = 0
vim.g.netrw_winsize = 10
-- show tabs and spaces
vim.o.list = true
vim.o.listchars='eol:,tab:> ,trail:●,extends:…,precedes:…'
vim.o.sidescrolloff=20

vim.o.tabstop=4
vim.o.softtabstop=4
vim.o.shiftwidth=4
vim.o.number = true
vim.o.foldmethod="indent"
vim.o.foldnestmax=2
vim.o.scrolloff=10
vim.o.textwidth=0
vim.o.undodir= vim.fn.stdpath("cache") .. "/undodir"
vim.o.inccommand="nosplit"
vim.o.timeoutlen=1000
vim.o.updatetime=1500                       -- for this interval file is not written to disk(incase of swap file)
vim.o.clipboard="unnamed"
vim.o.linebreak  = false
vim.o.wrap = false
vim.o.foldenable = false
vim.o.swapfile = false
vim.o.backup = false
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.relativenumber = true
vim.o.number = true
vim.o.incsearch = true
vim.o.undofile = true
vim.o.showmatch = true
vim.o.showcmd = true
vim.o.autowrite = true
vim.o.autoread = true
vim.o.ttyfast = true
vim.o.termguicolors = true
vim.o.wildmenu = true
vim.bo.autoindent = false                  -- use treesitter indentation
vim.bo.smartindent = false
vim.o.hlsearch = true
vim.o.signcolumn = "number"
vim.o.numberwidth = 3

vim.opt.spell = false
vim.opt.spelllang = { 'en_us' }

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

