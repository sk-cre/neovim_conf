local home_dir = vim.fn.expand("~/Documents/Compete")
local atcoder_dir = home_dir .. "/atcoder"
local snip_dir = home_dir .. "/snippet"
local playground_dir = home_dir .. "/play_ground"

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

function Open_workspace(contest, problem)
    local current_problem = Get_problem()
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
    local problem, url = unpack(Get_url(problem or current_problem, problem == nil))
    vim.cmd("silent " .. open_url .. url)
    vim.cmd("e ./src/bin/" .. problem .. ".rs | aboveleft 40vs")
    vim.cmd(string.format("terminal cargo watch -x \"compete t %s\"", problem))
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("silent 5 | stopinsert")
end

function Floating_term(command)
    vim.cmd("highlight MyFloatingTerm guibg=Olive")         -- フローティングウィンドウの背景色をOliveに設定
    vim.cmd("highlight MyFloatingTermUnfocused guibg=Grey") -- フォーカスが外れた場合の背景色をGreyに設定
    vim.o.termguicolors = true                              -- GUIカラースキームを使用
    vim.o.pumblend = 20                                     -- ポップアップメニューの透明度を設定

    local orig_win = vim.api.nvim_get_current_win()         -- 現在のウィンドウIDを保存
    local buf = vim.api.nvim_create_buf(false, true)        -- 新しいバッファを作成
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",                                   -- 現在のウィンドウを基準に位置を設定
        height = 35,                                        -- フローティングウィンドウの高さ
        width = 138,                                        -- フローティングウィンドウの幅
        col = vim.o.columns - 138,                          -- ウィンドウの列位置
        row = vim.o.lines - 35 - 3,                         -- ウィンドウの行位置
        style = 'minimal',                                  -- 最小限の装飾でウィンドウを開く
    })
    -- フローティングウィンドウのハイライト設定
    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:MyFloatingTerm")
    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:MyFloatingTerm,NormalFloatNC:MyFloatingTermUnfocused")
    vim.o.winblend = 20 -- ウィンドウの透明度を設定

    vim.cmd(command)    -- コマンドを実行

    return orig_win, buf, win
end

function Submit(test)
    local orig_win, buf, win
    if test then
        orig_win, buf, win = Floating_term("term cargo compete s " .. Get_problem())
    else
        orig_win, buf, win = Floating_term("term cargo compete s " .. Get_problem() .. "--no-test")
    end

    local bottom_line = vim.api.nvim_buf_line_count(buf) -- バッファの行数を取得
    -- Enterキーが押されたときにウィンドウを閉じるマッピングを設定
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '<cmd>close<CR>', { noremap = true, silent = true })
    vim.api.nvim_win_set_cursor(win, { bottom_line, 0 }) -- カーソルをバッファの最後の行に設定
    vim.api.nvim_set_current_win(orig_win)               -- 元のウィンドウに戻る
    -- Escキーを押したように見せかける
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', true)

    local orig_tab_id = vim.api.nvim_get_current_tabpage() -- 現在のタブページIDを保存
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,                                      -- バッファを指定
        once = true,                                       -- この自動コマンドは一度だけ実行される
        callback = function()
            -- 現在のタブページが元のタブページと異なる場合
            if orig_tab_id ~= vim.api.nvim_get_current_tabpage() then
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false) -- バッファの全行を取得
                for i, line in ipairs(lines) do
                    -- "Successfully submitted the code" を含む行が見つかった場合
                    if line:find("Successfully submitted the code") then
                        local parts = vim.split(lines[i + 1] or " | Error |  | Error", " │ ", true)
                        -- macOSの通知センターに通知を表示
                        vim.api.nvim_command('!osascript -e \'display notification "' ..
                            parts[2] .. '" with title "' .. parts[4] .. '"\'')
                    end
                end
                vim.api.nvim_win_close(win, true) -- フローティングウィンドウを閉じる
            end
        end
    })
end

function Process_atcoder_data(data, username)
    local my_rank = 1
    local my_rating = 1200

    for _, participant in ipairs(data.StandingsData) do
        if participant.UserScreenName == username then
            my_rank = participant.Rank
            my_rating = participant.Rating
            break
        end
    end

    local total_submissions = {}
    local total_correct = {}
    local filtered_submissions = {}
    local filtered_correct = {}

    local tasks = {}
    for _, task_info in ipairs(data.TaskInfo) do
        table.insert(tasks, task_info.TaskScreenName)
    end
    table.sort(tasks)

    for _, participant in ipairs(data.StandingsData) do
        local is_within_range = my_rating and math.abs(participant.Rating - my_rating) <= 200
        for _, task in ipairs(tasks) do
            local result = participant.TaskResults[task]
            if result then
                total_submissions[task] = (total_submissions[task] or 0) + result.Count
                if result.Status == 1 then
                    total_correct[task] = (total_correct[task] or 0) + 1
                end
                if is_within_range then
                    filtered_submissions[task] = (filtered_submissions[task] or 0) + result.Count
                    if result.Status == 1 then
                        filtered_correct[task] = (filtered_correct[task] or 0) + 1
                    end
                end
            end
        end
    end
    local opts = {
        style = "minimal",
        relative = "editor",
        width = 33,
        height = 11,
        row = 38,
        col = 140
    }
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_win_set_option(win, 'cursorline', false)
    vim.api.nvim_win_set_option(win, 'cursorcolumn', false)
    local lines = {}
    table.insert(lines, "")
    for _, task in ipairs(tasks) do
        local total_correct_formatted = string.format("%5d", total_correct[task] or 0)
        local total_submissions_formatted = string.format("%5d", total_submissions[task] or 0)
        local filtered_correct_formatted = string.format("%4d", filtered_correct[task] or 0)
        local filtered_submissions_formatted = string.format("%4d", filtered_submissions[task] or 0)

        table.insert(lines, "   " .. task:sub(8, 8) ..
            "  " ..
            total_correct_formatted ..
            "/" .. total_submissions_formatted ..
            " (" .. filtered_correct_formatted .. "/" .. filtered_submissions_formatted .. ")")
    end
    table.insert(lines, "")
    table.insert(lines, "   Rank: " .. my_rank)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_win_set_option(win, 'cursorline', false)
    vim.api.nvim_win_set_option(win, 'cursorcolumn', false)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '<cmd>close<CR>', { noremap = true, silent = true })
end

function Fetch_atcoder_standings()
    local cookie_file_path = vim.fn.expand("~/Library/Application Support/cargo-compete/cookies.jsonl")
    for line in io.lines(cookie_file_path) do
        local cookie = vim.fn.json_decode(line)
        if cookie.raw_cookie and cookie.domain.HostOnly == "atcoder.jp" then
            local username = string.match(cookie.raw_cookie, "UserScreenName%%3A(.-)%%00")
            local url = 'https://atcoder.jp/contests/' .. Get_contest() .. '/standings/json'
            local handle = io.popen('curl -s -b "' .. cookie.raw_cookie .. '" "' .. url .. '"')
            local result = handle:read("*a")
            handle:close()
            Process_atcoder_data(vim.fn.json_decode(result), username)
            return
        end
    end
    print("error")
end

local cuc = vim.api.nvim_create_user_command
cuc("NN", function(opts) Open_workspace(vim.split(opts.args, " ")[1], vim.split(opts.args, " ")[2] or "") end,
    { nargs = "+" })
cuc("Np", function(opts) Open_workspace(Get_contest(), opts.args ~= "" and opts.args or nil) end, { nargs = "?" })
--cuc("Snippet", function() vim.cmd("tabnew | lcd " .. snip_dir .. "/src/ | e .") end, {})
--cuc("Playground", function() Open_playground() end, {})
--cuc("SnippetWrite", function() Write_snippet() end, {})
cuc("Me", function() vim.cmd(open_url .. atcoder_url .. Get_contest() .. '/submissions/me') end, {})
cuc("Our",
    function()
        vim.cmd(open_url .. "\"" .. atcoder_url .. Get_contest() ..
            '/submissions?f.Task=' .. vim.fn.fnamemodify(Get_url(Get_problem(), false)[2], ":t") ..
            '&f.LanguageName=Rust&f.Status=AC&f.User="')
    end, {})
cuc("Size", function() vim.cmd(":!ls -lh %") end, {})
cuc("Rank", function() vim.cmd(open_url .. atcoder_url .. Get_contest() .. '/standings') end, {})
cuc("Open", function() vim.cmd(open_url .. Get_url(Get_problem(), false)[2]) end, {})
cuc("Watch", function() Floating_term("term cargo compete w submissions atcoder " .. Get_contest()) end, {})
cuc("Test", function() Floating_term('term cargo compete t ' .. Get_problem()) end, {})
cuc("TestR", function() Floating_term('term cargo compete t ' .. Get_problem() .. " --release") end, {})
cuc("Submit", function() Submit(true) end, {})
cuc("SubmitN", function() Submit(false) end, {})
cuc("SubmitN", function() Floating_term('term cargo compete s ' .. Get_problem() .. " --no-test") end, {})
cuc("TestCase", function() vim.cmd('35sp|e testcases/' .. Get_problem() .. ".yml") end, {})
cuc('FetchAtCoderStandings', Fetch_atcoder_standings, {})
