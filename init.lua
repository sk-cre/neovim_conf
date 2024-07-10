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

vim.api.nvim_create_user_command('PP', function() vim.cmd('%d _ | normal! p') end, {})

require("plugins")
require("playground")
require("compete")
require("snippet")
require("colorscheme")
require("tabline")

function _G.Set_Watch_Term(command, width)
    local editor_buf = vim.api.nvim_get_current_buf()
    vim.cmd("aboveleft " .. width .. "vs")
    vim.cmd("term")
    vim.api.nvim_chan_send(vim.b.terminal_job_id, command .. "\n")
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = editor_buf,
        callback = function()
            local editor_win = vim.api.nvim_get_current_win()

            -- 現在のタブ内のすべてのウィンドウを取得
            local tabnr = vim.api.nvim_win_get_tabpage(editor_win)
            local wins = vim.api.nvim_tabpage_list_wins(tabnr)

            -- ターミナルバッファを持つウィンドウを探す
            for _, win in ipairs(wins) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].buftype == "terminal" then
                    vim.api.nvim_set_current_win(win)
                    vim.api.nvim_chan_send(vim.b.terminal_job_id, "\n") -- Ctrl+C を送信
                    vim.api.nvim_chan_send(vim.b.terminal_job_id, command .. "\n")
                    vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
                    vim.api.nvim_set_current_win(editor_win)
                    break
                end
            end
        end
    })
end
