local home_dir = vim.fn.expand("~/Documents/Compete")
local playground_dir = home_dir .. "/play_ground"

vim.api.nvim_create_user_command("Playground", function() Open_playground() end, {})

function Open_playground()
    vim.fn.system("[ ! -d " .. playground_dir .. " ] && cargo new " .. playground_dir)
    local template = { "fn main() {", "    println!(\"Hello World!\");", "}" }
    vim.cmd("tabnew | lcd " .. playground_dir .. "| e ./src/main.rs | %d _")
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, template)
    Set_Watch_Term("cargo run", 60)
    vim.cmd("silent 2 | stopinsert")
    vim.cmd(string.format("let t:custom_%s = '%s'", 'tabname', 'Playground'))
end
