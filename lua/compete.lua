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
    vim.cmd("e ./src/bin/" .. problem .. ".rs")
    local command = string.format("cargo compete t %s", problem)
    Set_Watch_Term(command, 50)
    vim.cmd("silent 5 | stopinsert")
    vim.cmd(string.format("let t:custom_%s = '%s %s'", 'tabname', contest, problem))
end

function Setup_floating_window_highlight(win_id)
    -- ウィンドウのハイライトを設定する関数を定義
    local function set_win_highlight(focused)
        -- ウィンドウが有効かどうかをチェック
        if not vim.api.nvim_win_is_valid(win_id) then
            return
        end
        local hl = focused and "MyFloatingTerm" or "MyFloatingTermUnfocused"
        local border_hl = focused and "MyFloatingTermBorder" or "MyFloatingTermBorderUnfocused"
        pcall(vim.api.nvim_win_set_option, win_id, "winhighlight", "NormalFloat:" .. hl .. ",FloatBorder:" .. border_hl)
    end

    -- 初期状態でフォーカスされているのでアクティブなハイライトを設定
    set_win_highlight(true)

    -- フォーカスの変更を監視するオートコマンドを作成
    local augroup_name = "FloatingTermHighlight" .. win_id
    local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })
    vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
        group = augroup,
        callback = function(ev)
            if not vim.api.nvim_win_is_valid(win_id) then
                -- ウィンドウが無効になった場合、オートコマンドを削除
                vim.api.nvim_del_augroup_by_name(augroup_name)
                return
            end
            local current_win = vim.api.nvim_get_current_win()
            if ev.event == "WinEnter" then
                set_win_highlight(current_win == win_id)
            elseif ev.event == "WinLeave" and current_win == win_id then
                set_win_highlight(false)
            end
        end
    })
end

function Floating_term(command)
    -- 既存の色の組み合わせを定義
    local color_name = { "MyFloatingTerm", "MyFloatingTermUnfocused", "MyFloatingTermBorder",
        "MyFloatingTermBorderUnfocused" }
    local color_sets = {
        {
            main = "#228B22",            -- Forest Green
            unfocused = "#354f35",       -- Darker Green
            border = "#8FBC8F",          -- Dark Sea Green
            unfocused_border = "#2F4F4F" -- Dark Slate Gray
        },
        {
            main = "Olive",
            unfocused = "Grey",
            border = "Olive",
            unfocused_border = "Grey"
        },
        {
            main = "#000080",            -- Navy Blue
            unfocused = "#191970",       -- Midnight Blue
            border = "#87CEEB",          -- Sky Blue
            unfocused_border = "#4682B4" -- Steel Blue
        }
    }

    -- ランダムに色の組み合わせを選択
    local selected_set = color_sets[math.random(#color_sets)]

    -- 選択された色でハイライトを設定
    vim.api.nvim_set_hl(0, "MyFloatingTerm", { bg = selected_set.main })
    vim.api.nvim_set_hl(0, "MyFloatingTermUnfocused", { bg = selected_set.unfocused })
    vim.api.nvim_set_hl(0, "MyFloatingTermBorder", { fg = selected_set.border, bg = selected_set.border })
    vim.api.nvim_set_hl(0, "MyFloatingTermBorderUnfocused",
        { fg = selected_set.unfocused_border, bg = selected_set.unfocused_border })

    vim.o.termguicolors = true
    vim.o.pumblend = 20
    local orig_win = vim.api.nvim_get_current_win()  -- 元のウィンドウIDを保存
    local buf = vim.api.nvim_create_buf(false, true) -- バッファを作成
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        height = math.floor(vim.o.lines / 5 * 2),
        width = vim.o.columns - 20,
        col = 10,
        row = math.floor(vim.o.lines / 5 * 3) - 2,
        style = 'minimal',
        border = 'none',
    })
    vim.api.nvim_win_set_option(win, "winhighlight",
        "NormalFloat:MyFloatingTerm,NormalFloatNC:MyFloatingTermUnfocused,FloatBorder:MyFloatingTermBorder")
    Setup_floating_window_highlight(win)
    vim.o.winblend = 20
    vim.cmd(command)
    if not string.match(command, "^term cargo compete s") then
        return
    end
    local bottom_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '<cmd>close<CR>', { noremap = true, silent = true })
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
cuc("Submit", function() Floating_term('term cargo compete s ' .. Get_problem()) end, {})
cuc("SubmitN", function() Floating_term('term cargo compete s ' .. Get_problem() .. " --no-test") end, {})
cuc("TestCase", function() vim.cmd('35sp|e testcases/' .. Get_problem() .. ".yml") end, {})
cuc('FetchAtCoderStandings', Fetch_atcoder_standings, {})
