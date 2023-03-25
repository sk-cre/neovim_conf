local opts = { noremap = true, silent = true }

--path
local home = vim.fn.expand('~/Documents/codefolder/atcoder/')
local snip = vim.fn.expand("~/Documents/codefolder/atcoder/snippet/")

local vscode_snip = vim.fn.expand("~/AppData/Roaming/Code/User/snippets/rust.json")
local ulti_snip = vim.fn.expand("~/AppData/Local/coc/ultisnips/rust.snippets")
local playground = vim.fn.expand("~/Documents/codefolder/play_ground/")
local url = 'https://atcoder.jp/contests/'

function pg()
    vim.fn.execute(":30sp")
    vim.fn.execute(":lcd "..playground)
    vim.fn.execute(":e ./src/template.rs")
    vim.fn.execute(":sav! ./src/main.rs")
    vim.fn.execute("set noswapfile")
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

function open_contest(contest,problem)
    local problem = problem or "a"
    vim.fn.execute(":cd "..home)
    if vim.fn.isdirectory(contest) == 0 then
        vim.fn.execute(":! cargo compete new " .. contest)
    end
    vim.fn.execute(":cd " .. contest)
    vim.fn.execute(":e ./src/bin/"..problem..".rs")
    vim.fn.execute(":!cargo compete open --bin "..problem)
end

function get_contest()
    local contest= vim.fn.split(vim.fn.expand("%:p:h"),"\\")
    return contest[7]
end

function get_problem()
    local problem = vim.fn.expand("%:t:r")
    return problem
end


vim.api.nvim_create_user_command("Playground",function()pg()end,{})
vim.api.nvim_create_user_command("Snippet",function()open_snippet()end,{})
vim.api.nvim_create_user_command("SnippetWrite",function()write_snippet()end,{})
vim.api.nvim_create_user_command("OC",function(opts)open_contest(vim.fn.split(opts.args," ")[1],vim.fn.split(opts.args," ")[2])end,{nargs = "+"})
vim.api.nvim_create_user_command("Watch",function()vim.fn.execute(":terminal cargo compete w submissions atcoder " .. get_contest())end , {} )

vim.api.nvim_create_user_command("Me", function()vim.fn.execute(':!start ' .. url .. get_contest() .. '/submissions/me')end,{})
vim.api.nvim_create_user_command("Rank", function()vim.fn.execute(':!start ' .. url .. get_contest() .. '/standings')end,{})
vim.api.nvim_create_user_command("Open", function()vim.fn.execute(':!cargo compete open --bin ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("Test", function()vim.fn.execute(':terminal cargo compete t ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("TestR", function()vim.fn.execute(':terminal cargo compete t ' .. get_problem() .." --release")end,{})
vim.api.nvim_create_user_command("Submit", function()vim.fn.execute(':terminal cargo compete s ' .. get_problem() )end,{})
vim.api.nvim_create_user_command("SubmitN", function()vim.fn.execute(':terminal cargo compete s ' .. get_problem().."--no-test" )end,{})
vim.api.nvim_create_user_command("TestCase", function()vim.fn.execute(':e testcases/' .. get_problem()..".yml" )end,{})





