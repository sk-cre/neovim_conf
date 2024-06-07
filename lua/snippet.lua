local home_dir = vim.fn.expand("~/Documents/Compete")
local snip_dir = home_dir .. "/snippet"

function Write_snippet()
    local toml_path = snip_dir .. "/src/other_snippet.toml"
    local python_command =
    [[python3 -c "import sys, json, tomllib; print(json.dumps(tomllib.loads(sys.stdin.read()), indent=4))"]]
    local toml_content = vim.fn.system("cat " .. toml_path .. " | " .. python_command)
    local snippet_data = vim.json.decode(toml_content)
    vim.cmd("cd " .. snip_dir)
    local cargo_snippet_output = vim.fn.system("cargo snippet -t vscode")
    vim.cmd("cd -")
    local cargo_snippet_data = vim.json.decode(cargo_snippet_output)
    for k, v in pairs(cargo_snippet_data) do
        snippet_data[k] = v
    end
    local vscode_style = io.open(snip_dir .. "/vscode_style/rust.json", "w")
    vscode_style:write(vim.json.encode(snippet_data))
    vscode_style:close()
    vim.api.nvim_echo({ { "Snippet writing completed", "None" } }, false, {})
end

local cuc = vim.api.nvim_create_user_command
cuc("Snippet", function() vim.cmd("tabnew | lcd " .. snip_dir .. "/src/ | e .") end, {})
cuc("SnippetWrite", function() Write_snippet() end, {})
