-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Hint: If in doubt about an option, press 'K' above it (in Normal mode) to open the documentation.

vim.opt.hidden = true

vim.opt.backup = false

-- Enable reading of modelines
vim.opt.modeline = true

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.nrformats:remove 'octal'

-- Remove extra comment delimiters when joining lines
vim.opt.formatoptions:append 'j'

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3

-- As much as possible of the last line in a window will be displayed.  "@@@" is put in the last columns of the last screen line to indicate the rest of the line is not displayed.
vim.opt.display:append 'lastline'

vim.opt.shiftround = true

vim.opt.linebreak = true
-- Always show a status line, even with only one window
vim.opt.laststatus = 2

-- Open buffers with no folds closed
-- See: http://vim.wikia.com/wiki/All_folds_open_when_opening_a_file
vim.opt.foldlevelstart = 99

vim.cmd.match { 'ErrorMsg', '"\\s\\+$"' }

vim.g.python3_host_prog = os.getenv 'HOME' .. '/.local/share/nvim/venv-py3/bin/python'

-- vim: ts=2 sts=2 sw=2 et
