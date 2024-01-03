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
    vim.cmd("tabnew | lcd " .. snip_dir .. " | e ./vscode_style/rust.json | %d")
    vim.cmd("r! cargo snippet -t vscode")
    vim.cmd("w")
    local f = io.open("./src/other.json", "r")
    if f ~= nil then
        vim.cmd("$d | norm G")
        vim.cmd("norm A,")
        io.close(f)
        local lines = vim.fn.readfile(snip_dir .. "/src/other.json")
        for i = 2, #lines do
            vim.cmd("call append('$', '" .. lines[i] .. "')")
        end
    end
    vim.cmd("w | tabc")
end

function Write_snippet2()
    vim.cmd("tabnew | lcd " .. snip_dir .. " | e unused.rs")
    vim.cmd("CocCommand snippets.editSnippets")
    vim.cmd("sleep 1500m")
    vim.cmd("%d")
    vim.cmd("r! cargo snippet -t ultisnips")
    local f = io.open("./src/other.snippets", "r")
    if f ~= nil then
        io.close(f)
        vim.cmd("r ./src/other.snippets")
    end
    vim.cmd("w | tabc")
end

function Get_contest()
    local contest = vim.split(string.gsub(vim.loop.cwd(), "\\", "/"), "/")
    return contest[#contest] or ""
end

function Get_problem()
    local problem = vim.fn.expand("%:t:r")
    return problem
end

function Get_next_problem_and_url(n_problem, now_e)
    local problem = n_problem
    if problem == "" then
        problem = now_e
    end
    vim.cmd("35sp | e ./Cargo.toml")
    local result = vim.fn.search("alias = \"" .. (problem or "xxx") .. "\"")
    if result == 0 then
        result = vim.fn.search("package.metadata.cargo-compete.bin") + 1
    elseif n_problem == "" then
        result = result + 1
    end
    vim.cmd("norm!" .. result .. "G")
    local problem_data = vim.split(vim.api.nvim_get_current_line(), "\"")
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
    local problem, problem_url = unpack(Get_next_problem_and_url(problem, now_e))
    vim.cmd("silent " .. open_url .. problem_url)
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
    local win = vim.api.nvim_open_win(buf, true,
        {
            relative = "win",
            height = 35,
            width = 138,
            col = vim.o.columns - 138,
            row = vim.o.lines - 35 - 3,
            style =
            'minimal',
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
                        local script = 'osascript -e \'display notification "' ..
                            parts[2] .. '" with title "' .. parts[4] .. '"\''
                        vim.api.nvim_command('!' .. script)
                    end
                end
                vim.api.nvim_win_close(win, true)
            end
        end
    })
end

local cuc = vim.api.nvim_create_user_command
cuc("NN", function(opts) Watch_term(vim.split(opts.args, " ")[1], vim.split(opts.args, " ")[2]) end, { nargs = "+" })
cuc("Np", function(opts) Watch_term(Get_contest(), opts.args) end, { nargs = "?" })
cuc("Playground", function() Open_playground() end, {})
cuc("Snippet", "silent tabnew | silent lcd " .. snip_dir .. "/src/ | e .", {})
cuc("SnippetWrite", function() Write_snippet2() end, {})
cuc("Watch", function() Floating_term("term cargo compete w submissions atcoder " .. Get_contest()) end, {})
cuc("Me", function() vim.cmd(open_url .. atcoder_url .. Get_contest() .. '/submissions/me') end, {})
cuc("Our",
    function()
        vim.cmd(open_url ..
            '"' ..
            atcoder_url ..
            Get_contest() ..
            '/submissions?f.Task=' ..
            vim.split(tostring(Get_next_problem_and_url(Get_problem(), nil)[2]), "/")[7] ..
            '&f.LanguageName=Rust&f.Status=AC&f.User="')
    end, {})
cuc("Size", function() vim.cmd(":!ls -lh %") end, {})
cuc("Rank", function() vim.cmd(open_url .. atcoder_url .. Get_contest() .. '/standings') end, {})
cuc("Open", function() vim.cmd(open_url .. Get_next_problem_and_url(Get_problem(), nil)[2]) end, {})
cuc("Test", function() Floating_term('term cargo compete t ' .. Get_problem()) end, {})
cuc("TestR", function() Floating_term('term cargo compete t ' .. Get_problem() .. " --release") end, {})
cuc("Submit", function() Floating_term('term cargo compete s ' .. Get_problem()) end, {})
cuc("SubmitN", function() Floating_term('term cargo compete s ' .. Get_problem() .. " --no-test") end, {})
cuc("TestCase", function() vim.cmd('35sp|e testcases/' .. Get_problem() .. ".yml") end, {})

--Function to scroll a terminal buffer if it's visible and not focused
function _G.terminal_scroll()
    local current_win = vim.api.nvim_get_current_win()

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')

        if buf_type == 'terminal' and win ~= current_win then
            local bottom_line = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_win_set_cursor(win, { bottom_line, 0 })
        end
    end
end

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = function()
        _G.terminal_scroll()
    end,
})

vim.api.nvim_create_autocmd("WinEnter", {
    pattern = "*",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_option(bufnr, 'buftype') == 'terminal' then
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname:match("zsh$") then -- バッファ名が zsh で終わる場合
                vim.cmd("startinsert")
            end
        end
    end
})
--vim.cmd([[autocmd WinLeave * if &buftype == 'terminal' | norm G | endif]])
