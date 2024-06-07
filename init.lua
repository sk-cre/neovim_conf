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

vim.opt.termguicolors = true

vim.o.laststatus = 2
vim.opt.scrolloff = 7

vim.g.rustfmt_autosave = 1
vim.cmd("autocmd TermOpen * startinsert | setlocal nonumber norelativenumber")

vim.api.nvim_create_user_command('Rc', 'e $MYVIMRC', { nargs = 0 })
vim.api.nvim_create_user_command('RRc', 'source $MYVIMRC', { nargs = 0 })
vim.api.nvim_create_user_command('RcC', "e " .. vim.fn.stdpath("config") .. "/lua/compete.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcG', "e " .. vim.fn.stdpath("config") .. "/lua/playground.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcN', "e " .. vim.fn.stdpath("config") .. "/lua/snippet.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcP', "e " .. vim.fn.stdpath("config") .. "/lua/plugins.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcS', "e " .. vim.fn.stdpath("config") .. "/lua/colorscheme.lua", { nargs = 0 })
vim.api.nvim_create_user_command('RcT', "e " .. vim.fn.stdpath("config") .. "/lua/tabline.lua", { nargs = 0 })

require("plugins")
require("playground")
require("compete")
require("snippet")
require("colorscheme")
require("tabline")

--Function to scroll a terminal buffer if it's visible and not focused
function _G.terminal_scroll()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
            vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
        end
    end
end

vim.api.nvim_create_autocmd("BufWritePost", { pattern = "*", callback = function() _G.terminal_scroll() end, })

vim.api.nvim_create_autocmd("WinEnter", {
    pattern = "*",
    callback = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "terminal" and (vim.api.nvim_buf_get_lines(0, -2, -1, false)[1] or ""):find("~") then
            vim.api.nvim_command('startinsert')
        end
    end
})
--vim.cmd([[autocmd WinLeave * if &buftype == 'terminal' | norm G | endif]])
