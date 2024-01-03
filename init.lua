vim.api.nvim_set_keymap("n", "<Up>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Down>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Left>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Right>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Up>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Down>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Left>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<Right>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true })
vim.api.nvim_set_keymap('i', 'JK', '<ESC>', { noremap = true })
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamed"
vim.opt.cmdheight = 0

vim.o.laststatus = 2
vim.opt.scrolloff = 7

vim.g.rustfmt_autosave = 1
vim.cmd("autocmd TermOpen * startinsert | setlocal nonumber norelativenumber")
--vim.api.nvim_create_autocmd("TermOpen", {
--pattern = "*",
--callback = function()
--vim.api.nvim_buf_set_option(0, 'number', false)
--vim.api.nvim_buf_set_option(0, 'relativenumber', false)
--vim.cmd('startinsert')
--end
--})

vim.api.nvim_create_user_command('Rc', 'e $MYVIMRC', { nargs = 0 })
vim.api.nvim_create_user_command('RRc', 'source $MYVIMRC', { nargs = 0 })
vim.api.nvim_create_user_command('RcC', "e " .. vim.fn.stdpath("config") .. "/lua/compete.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcP', "e " .. vim.fn.stdpath("config") .. "/lua/plugins.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcS', "e " .. vim.fn.stdpath("config") .. "/lua/colorscheme.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcT', "e " .. vim.fn.stdpath("config") .. "/lua/tabline.lua", { nargs = 0 })

require("plugins")
require("compete")
require("colorscheme")
require("tabline")
-- フォーカスがあるときの色
vim.api.nvim_command('highlight FocusedFloatingWindow guibg=Olive')
-- フォーカスがないときの色
vim.api.nvim_command('highlight UnfocusedFloatingWindow guibg=DarkGrey')

-- フォーカスが移動したときのイベントハンドラー
function onWinEnter()
    if vim.api.nvim_win_get_config(0).relative ~= '' then
        vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:FocusedFloatingWindow')
    end
end

function onWinLeave()
    if vim.api.nvim_win_get_config(0).relative ~= '' then
        vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:UnfocusedFloatingWindow')
    end
end

-- Autocmdの設定
vim.api.nvim_create_autocmd('WinEnter', { callback = onWinEnter })
vim.api.nvim_create_autocmd('WinLeave', { callback = onWinLeave })
