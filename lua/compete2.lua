local home_dir = vim.fn.expand("~/Documents/Compete")
local atcoder_dir = home_dir .. "/atcoder"
local atcoder_url = "https://atcoder.jp/contests/"
local os = string.sub(vim.loop.os_uname().sysname, 1, 1)
local open_url = (os == "W" and "!start ") or (os == "D" and "!open -g ") or (os == "L" and "!exploler.exe ") or nil

function Get_contest()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
end

function Get_problem()
    return vim.fn.expand("%:t:r")
end

function Get_url(problem, skip)
    vim.cmd("35sp | e ./Cargo.toml")
    local line = vim.fn.search("alias = \"" .. (problem or "xxx") .. "\"")
    if line == 0 then
        line = vim.fn.search("package.metadata.cargo-compete.bin") + 1
    end
    line = line + (skip and 1 or 0)
    local problem_data = vim.split(vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1], "\"")
    vim.cmd("bd")
    return { problem_data[2], problem_data[4] }
end

function Watch_term(contest, problem)
    local now_e = Get_problem()
    vim.cmd("tabnew")
    local full = vim.fn.expand(atcoder_dir .. "/" .. contest)
    if vim.fn.isdirectory(full) == 0 then
        vim.cmd("lcd " .. atcoder_dir)
        local res = vim.fn.system("cargo compete new " .. contest)
        local exit_code = vim.v.shell_error
        if exit_code ~= 0 then
            print(res)
            vim.cmd("tabc")
            return 0
        end
        vim.cmd("lcd -")
    end
    vim.cmd("lcd " .. full)
    local problem, url = unpack(Get_url(current_problem, problem == nil))
    vim.cmd("silent " .. open_url .. url)
    vim.cmd("e ./src/bin/" .. problem .. ".rs | 40vs")
    vim.cmd(string.format("terminal cargo watch -x \"compete t %s\"", problem))
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("silent 5 | stopinsert")
end

function Floating_term(command)
    --vim.api.nvim_set_hl(0, "MyFloatingTerm", { guibg = "Olive" })
    vim.cmd("highlight MyFloatingTerm guibg=Olive")
    vim.o.termguicolors = true
    vim.o.pumblend = 20
    local orig_win = vim.api.nvim_get_current_win()  -- 元のウィンドウIDを保存
    local buf = vim.api.nvim_create_buf(false, true) -- バッファを作成
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        height = 35,
        width = 138,
        col = vim.o.columns - 138,
        row = vim.o.lines - 35 - 3,
        style = 'minimal',
    })
    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:MyFloatingTerm")
    vim.o.winblend = 20
    vim.cmd(command)
    if not string.match(command, "^term cargo compete s") then
        return
    end
    local bottom_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(win, { bottom_line, 0 })
    vim.api.nvim_set_current_win(orig_win)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', true)
    local orig_tab_id = vim.api.nvim_get_current_tabpage()
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            if orig_tab_id ~= vim.api.nvim_get_current_tabpage() then
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                for i, line in ipairs(lines) do
                    if line:find("Successfully submitted the code") then
                        local parts = vim.split(lines[i + 1] or " | Error |  | Error", " │ ", true)
                        vim.api.nvim_command('!osascript -e \'display notification "' ..
                            parts[2] .. '" with title "' .. parts[4] .. '"\'')
                    end
                end
                vim.api.nvim_win_close(win, true)
            end
        end
    })
end

local cuc = vim.api.nvim_create_user_command
cuc("NN", function(opts) Open_workspace(vim.split(opts.args, " ")[1], vim.split(opts.args, " ")[2] or "") end,
    { nargs = "+" })
cuc("Np", function(opts) Open_workspace(Get_contest(), opts.args ~= "" and opts.args or nil) end, { nargs = "?" })
cuc("Me", function() vim.cmd(open_url .. atcoder_url .. Get_contest() .. '/submissions/me') end, {})
cuc("Our",
    function()
        vim.cmd(open_url .. atcoder_url .. Get_contest() ..
            '/submissions?f.Task=' .. vim.fn.fnamemodify(Get_url(Get_problem(), false)[2], ":t") ..
            '&f.LanguageName=Rust&f.Status=AC&f.User=')
    end, {})
cuc("Size", function() vim.cmd(":!ls -lh %") end, {})
cuc("Rank", function() vim.cmd(open_url .. atcoder_url .. Get_contest() .. '/standings') end, {})
cuc("Open", function() vim.cmd(open_url .. Get_url(Get_problem(), false)[2]) end, {})
cuc("Watch", function() Floating_term("term cargo compete w submissions atcoder " .. Get_contest()) end, {})
cuc("Test", function() Floating_term('term cargo compete t ' .. Get_problem()) end, {})
cuc("TestR", function() Floating_term('term cargo compete t ' .. Get_problem() .. " --release") end, {})
cuc("Submit", function() Floating_term('term cargo compete s ' .. Get_problem()) end, {})
cuc("SubmitN", function() Floating_term('term cargo compete s ' .. Get_problem() .. " --no-test") end, {})
cuc("TestCase", function() vim.cmd('35sp|e testcases/' .. Get_problem() .. ".yml") end, {})

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
