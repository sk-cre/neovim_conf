local home_dir = vim.fn.expand("~/Documents/Compete")
local playground_dir = home_dir .. "/play_ground"

function Open_playground()
    vim.fn.system("[ ! -d " .. playground_dir .. " ] && cargo new " .. playground_dir)
    local template = { "fn main() {", "    println!(\"Hello World!\");", "}" }
    vim.cmd("tabnew | lcd " .. playground_dir .. " | e ./src/main.rs | %d ")
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, template)
    vim.cmd("silent w | aboveleft 60vs")
    vim.cmd("term cargo watch -w src -w Cargo.toml -x run --why")
    vim.cmd("norm G")
    vim.cmd("wincmd l")
    vim.cmd("silent 2 | stopinsert")
end

vim.api.nvim_create_user_command("Playground", function() Open_playground() end, {})
