local home = vim.fn.expand('~/Documents/codefolder/atcoder/')
local snip = vim.fn.expand("~/Documents/codefolder/atcoder/snippet/")

local vscode_snip = vim.fn.expand("~/AppData/Roaming/Code/User/snippets/rust.json")
local ulti_snip = vim.fn.expand("~/AppData/Local/coc/ultisnips/rust.snippets")
local playground = vim.fn.expand("~/Documents/codefolder/play_ground/")
local url = 'https://atcoder.jp/contests/'

function pg()
    vim.fn.execute(":e " .. playground .. "src/template.rs")
    vim.fn.execute(":w! " .. playground .. "src/main.rs")
    vim.fn.execute(":bd!")
    vim.fn.execute(string.format(":!wt -w 0 nt -d %s -V cargo watch -x \"run\"",playground))
    vim.fn.execute(string.format(":!wt -w 0 sp -s 0.6 --title \"PlayGround\" -d %s nvim .\\src\\main.rs +2",playground))
    vim.fn.execute(":!wt -w 0 ft mf right")
end

function write_snippet()
    vim.fn.execute(":cd "..snip)
    vim.fn.execute(":e " .. ulti_snip)
    vim.fn.execute(":%d")
    vim.fn.execute(":r! cargo snippet -t ultisnips")
    vim.fn.execute(':r ./src/other.snippets')
    vim.fn.execute(":w")
    vim.fn.execute(":cd -")
    vim.fn.execute(":bd")
end

function open_snippet()
    vim.fn.execute(":35sp")
    vim.fn.execute(":lcd " .. snip .. "/src/")
    vim.fn.execute(":e ." )
end

function get_contest()
    local contest= vim.fn.split(vim.fn.expand("%:p:h"),"\\")
    return contest[7]
end

function open_contest(contest,problem)
    local contest = contest or get_contest()
    local problem = problem or "a"
    local full = vim.fn.expand(home .. contest)
    if vim.fn.isdirectory(full) == 0 then
        vim.fn.execute(":cd " .. home)
        vim.fn.execute(":! cargo compete new " .. contest)
        vim.fn.execute(":cd -")
    end
    vim.fn.execute(":cd " .. full)
    vim.fn.execute(string.format(":!wt -w 0 nt -d %s%s -v cargo watch -x \"compete t %s\"",home,contest,problem))
    vim.fn.execute(string.format(":!wt -w 0 sp -s 0.7 --title \"%s %s\" -d %s nvim .\\src\\bin\\%s.rs +5",contest,problem,full,problem))
    vim.fn.execute(":!wt -w 0 ft mf right")
    vim.fn.execute(":!cargo compete open --bin "..problem)
    vim.fn.execute(":cd -")
end

function get_problem()
    local problem = vim.fn.expand("%:t:r")
    return problem
end

function watch_term(contest,problem)
    local contest = contest or get_contest()
    local problem = problem or "a"
    if vim.fn.winnr('$') > 1 then
        vim.cmd("only")
    end
    local full = vim.fn.expand(home .. contest)
    if vim.fn.isdirectory(full) == 0 then
        vim.fn.execute(":cd " .. home)
        vim.fn.execute(":! cargo compete new " .. contest)
        vim.fn.execute(":cd -")
    end
    vim.fn.execute(":cd " .. full)
    vim.fn.execute(":!cargo compete open --bin "..problem)
    vim.fn.execute(":e ./src/bin/" .. problem .. ".rs")
    vim.fn.execute(":40vs")
    vim.fn.execute(string.format(":terminal cargo watch -x \"compete t %s\"", problem)) 
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("5")
    vim.cmd("stopinsert")
end

function floating_term(command)
    vim.cmd("set termguicolors")
    vim.cmd("set pumblend=10")
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(buf, true, {
        relative = "win",
        height = vim.o.lines,
        width = vim.o.columns,
        col = 1,
        row = 1
    })
    vim.cmd("set winblend=30")
    vim.fn.execute(command)
end

vim.api.nvim_create_user_command("Playground",function()pg()end,{})
vim.api.nvim_create_user_command("Snippet",function()open_snippet()end,{})
vim.api.nvim_create_user_command("SnippetWrite",function()write_snippet()end,{})
vim.api.nvim_create_user_command("NNwt",function(opts)open_contest(vim.fn.split(opts.args," ")[1],vim.fn.split(opts.args," ")[2])end,{nargs = "+"})
vim.api.nvim_create_user_command("NN",function(opts)watch_term(vim.fn.split(opts.args," ")[1],vim.fn.split(opts.args," ")[2])end,{nargs = "+"})
vim.api.nvim_create_user_command("Np",function(opts)watch_term(nil,opts.args)end,{nargs = "+"})
vim.api.nvim_create_user_command("Npwt",function(opts)open_contest(nil,opts.args)end,{nargs = "+"})
vim.api.nvim_create_user_command("Watch",function()floating_term(":term cargo compete w submissions atcoder " .. get_contest())end , {} )

vim.api.nvim_create_user_command("WT",function()watch_term()end,{})
vim.api.nvim_create_user_command("Me", function()vim.fn.execute(':!start ' .. url .. get_contest() .. '/submissions/me')end,{})
vim.api.nvim_create_user_command("Rank", function()vim.fn.execute(':!start ' .. url .. get_contest() .. '/standings')end,{})
vim.api.nvim_create_user_command("Open", function()floating_term(':!cargo compete open --bin ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("Test", function()floating_term(':term cargo compete t ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("TestR", function()floating_term(':term cargo compete t ' .. get_problem() .." --release")end,{})
vim.api.nvim_create_user_command("Submit", function()floating_term(':term cargo compete s ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("SubmitN", function()floating_term(':term cargo compete s ' .. get_problem().."--no-test" )end,{})
vim.api.nvim_create_user_command("TestCase", function()vim.fn.execute(':e testcases/' .. get_problem()..".yml" )end,{})





