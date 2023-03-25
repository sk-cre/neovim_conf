local home = vim.fn.expand('~/Documents/codefolder/atcoder')
local snip = vim.fn.expand("~/Documents/codefolder/atcoder/snippet")
local playground = vim.fn.expand("~/Documents/codefolder/play_ground")
--local vscode_snip = vim.fn.expand("~/AppData/Roaming/Code/User/snippets/rust.json")
vim.g.coc_snippet_root = vim.fn.expand(snip.."/coc-snippets")
local aturl = "https://atcoder.jp/contests/"
local osname = vim.loop.os_uname().sysname
local open_url = (osname == "Windows_NT" or osname == "Darwin") and "!start " or (osname == "Linux" and "!exploler.exe " or nil)

function pg()
    vim.cmd("tabnew Playground")
    vim.cmd("lcd " .. playground)
    vim.cmd("e ./src/main.rs | %d | r ./src/template.rs | w")
    vim.cmd("60vs")
    vim.cmd("terminal cargo watch -x \"run\"") 
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("2 | stopinsert")
end

function write_snippet()
    local ulti_snip = vim.fn.expand(string.sub(vim.fn.stdpath("config"), 1, -6) .. "/coc/ultisnips/rust.snippets")
    vim.cmd("cd "..snip)
    vim.cmd("e " .. ulti_snip .. " | %d")
    vim.cmd("r! cargo snippet -t ultisnips")
    local f = io.open("./src/other.snippets","r")
    if f ~= nil then
        io.close(f)
        vim.cmd("r ./src/other.snippets")
    end
    vim.cmd("w")
    vim.cmd("cd -")
    vim.cmd("bd")
end

function open_snippet()
    vim.cmd("tabnew snippet")
    vim.cmd("lcd " .. snip .. "/src/")
    vim.cmd("e ." )
end

function get_contest()
    local contest = vim.split(string.gsub(vim.loop.cwd(), "\\", "/"),"/")
    return contest[#contest] or ""
end

function get_problem()
    local problem = vim.fn.expand("%:t:r")
    return problem
end

function get_problem_url(problem)
    local problem = problem or get_problem()
    vim.cmd("35sp")
    vim.cmd("e ./Cargo.toml")
    vim.cmd("/alias = \"" .. problem .. "\"")
    local problem_url = vim.split(vim.api.nvim_get_current_line(), "\"")[4]
    vim.cmd("bd")
    return problem_url
end

function watch_term(contest,problem)
    local problem = problem or "a"
    vim.cmd("tabnew ".. contest .. " " .. problem)
    --if vim.fn.winnr('$') > 1 then
        --vim.cmd("only")
    --end
    local full = vim.fn.expand(home .. "/" .. contest)
    if vim.fn.isdirectory(full) == 0 then
        vim.cmd("lcd " .. home)
        vim.cmd("!cargo compete new " .. contest)
        vim.cmd("lcd -")
    end
    vim.cmd("lcd " .. full)
    vim.cmd("e ./src/bin/" .. problem .. ".rs")
    vim.cmd(open_url .. get_problem_url(problem))
    vim.cmd("40vs")
    vim.cmd(string.format("terminal cargo watch -x \"compete t %s\"", problem)) 
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("5 | stopinsert")
end

local bg_color = "Olive" -- 任意の背景色を設定
vim.cmd("highlight MyFloatingTerm guibg=" .. bg_color)
function floating_term(command)
    vim.cmd("set termguicolors")
    vim.cmd("set pumblend=20")
    local buf = vim.api.nvim_create_buf(true, false)
    local buf2 = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        height = vim.o.lines,
        width = vim.o.columns,
        col = 1,
        row = 1
    })
    vim.api.nvim_win_set_option(buf2, "winhighlight", "NormalFloat:MyFloatingTerm")
    vim.cmd("set winblend=10")
    vim.cmd(command)
end

vim.api.nvim_create_user_command("Playground",function()pg()end,{})
vim.api.nvim_create_user_command("Snippet",function()open_snippet()end,{})
vim.api.nvim_create_user_command("SnippetWrite",function()write_snippet()end,{})
vim.api.nvim_create_user_command("NN",function(opts)watch_term(vim.split(opts.args," ")[1],vim.split(opts.args," ")[2])end,{nargs = "+"})
vim.api.nvim_create_user_command("Np",function(opts)watch_term(get_contest(),opts.args)end,{nargs = 1})
vim.api.nvim_create_user_command("Watch",function()floating_term(":term cargo compete w submissions atcoder " .. get_contest())end , {} )

vim.api.nvim_create_user_command("Me", function()vim.cmd(open_url .. aturl .. get_contest() .. '/submissions/me')end,{})
vim.api.nvim_create_user_command("Rank", function()vim.cmd(open_url .. aturl .. get_contest() .. '/standings')end,{})
vim.api.nvim_create_user_command("Open", function()vim.cmd(open_url .. get_problem_url() )end,{})
vim.api.nvim_create_user_command("Test", function()floating_term('term cargo compete t ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("TestR", function()floating_term('term cargo compete t ' .. get_problem() .." --release")end,{})
vim.api.nvim_create_user_command("Submit", function()floating_term('term cargo compete s ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("SubmitN", function()floating_term('term cargo compete s ' .. get_problem().." --no-test" )end,{})
vim.api.nvim_create_user_command("TestCase", function()vim.cmd('35sp|e testcases/' .. get_problem()..".yml" )end,{})
