local home_dir = vim.fn.expand("~/Documents/Compete")
local atcoder_dir = home_dir .. "/atcoder"
local snip_dir = home_dir .. "/snippet"
local playground_dir = home_dir .. "/play_ground"

local atcoder_url = "https://atcoder.jp/contests/"
local os = string.sub(vim.loop.os_uname().sysname, 1, 1)
local open_url = (os == "W" and "!start ") or (os == "D" and "!open -g ") or (os == "L" and "!exploler.exe ") or nil

function Open_playground()
    vim.fn.system("[ ! -d " .. playground_dir .. " ] && cargo new " .. playground_dir)
    local template = { "fn main() {", "    println!(\"Hello World!\");", "}" }
    vim.cmd("tabnew | lcd " .. playground_dir .. " | e ./src/main.rs | %d ")
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, template)
    vim.cmd("silent w | 60vs")
    vim.cmd("term cargo watch -x run")
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("silent 2 | stopinsert")
end

function Write_snippet()
    local toml_path = snip_dir .. "/src/other_snippet.toml"
    local python_command =
    [[python3 -c "import sys, json, tomllib; print(json.dumps(tomllib.loads(sys.stdin.read()), indent=4))"]]
    vim.fn.system("cat " .. toml_path .. " | " .. python_command .. " > " .. "~/Documents/Compete/snippet/test.json")
    vim.cmd("tabnew | lcd " .. snip_dir .. " | e ./vscode_style/rust.json | %d")
    vim.cmd("r! cargo snippet -t vscode")
    vim.cmd("w")
    local a_file = io.open("./vscode_style/rust.json", "r")
    local a_data = vim.json.decode(a_file:read("*a"))
    a_file:close()
    local b_file = io.open("./test.json", "r")
    local b_data = vim.json.decode(b_file:read("*a"))
    b_file:close()
    for k, v in pairs(b_data) do
        a_data[k] = v
    end
    local a_file_write = io.open("./vscode_style/rust.json", "w")
    a_file_write:write(vim.json.encode(a_data))
    a_file_write:close()
end

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
    vim.cmd("e ./src/bin/" .. problem .. ".rs | 40vs")
    vim.cmd(string.format("terminal cargo watch -x \"compete t %s\"", problem))
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("silent 5 | stopinsert")
end

function Floating_term(command)
    --vim.api.nvim_set_hl(0, "MyFloatingTerm", { guibg = "Olive" })
    --vim.api.nvim_set_hl(0, "MyFloatingTerm", { guibg = "#808000" })
    vim.cmd("highlight MyFloatingTerm guibg=Olive")
    vim.cmd("highlight MyFloatingTermUnfocused guibg=Grey")
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
    vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:MyFloatingTerm,NormalFloatNC:MyFloatingTermUnfocused")
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
                if result.Status == 1 then -- 正答の場合
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

    for _, task in ipairs(tasks) do
        print(task:sub(8, 8) ..
            "  " ..
            (total_correct[task] or 0) ..
            "/" .. (total_submissions[task] or
                0) .. " (" .. (filtered_correct[task] or 0) .. "/" .. (filtered_submissions[task] or 0) .. ")")
    end

    print("\n順位: " .. my_rank)
end

function Fetch_atcoder_standings()
    local cookie_file_path = vim.fn.expand("~/Library/Application Support/cargo-compete/cookies.jsonl")
    for line in io.lines(cookie_file_path) do
        local cookie = vim.fn.json_decode(line)
        if cookie.raw_cookie and cookie.domain.HostOnly == "atcoder.jp" then
            local username = string.match(cookie.raw_cookie, "UserScreenName:(%w+)")
            local url = 'https://atcoder.jp/contests/' .. Get_contest() .. '/standings/json'
            local handle = io.popen('curl -s -b "' .. cookie.raw_cookie .. '" "' .. url .. '"')
            local result = handle:read("*a")
            handle:close()
            local data = vim.fn.json_decode(result)
            Process_atcoder_data(data, username)
            return
        end
    end
end

local cuc = vim.api.nvim_create_user_command
cuc("NN", function(opts) Open_workspace(vim.split(opts.args, " ")[1], vim.split(opts.args, " ")[2] or "") end,
    { nargs = "+" })
cuc("Np", function(opts) Open_workspace(Get_contest(), opts.args ~= "" and opts.args or nil) end, { nargs = "?" })
cuc("Playground", function() Open_playground() end, {})
cuc("Snippet", function() vim.cmd("tabnew | lcd " .. snip_dir .. "/src/ | e .") end, {})
cuc("SnippetWrite", function() Write_snippet() end, {})
cuc("Watch", function() Floating_term(":term cargo compete w submissions atcoder " .. Get_contest()) end, {})
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
