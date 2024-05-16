-- Set options
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

-- Key mappings
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.api.nvim_set_keymap('n', '<leader>y', ':%y+<CR>', { noremap = true, silent = true })

-- Clipboard settings
vim.opt.clipboard:append('unnamedplus')

-- GUI Font setting
vim.opt.guifont = 'JetBrains Mono:h12'

-- Map <leader>d to delete all lines
vim.api.nvim_set_keymap('n', '<leader>d', ':%d<CR>', { noremap = true, silent = true })
