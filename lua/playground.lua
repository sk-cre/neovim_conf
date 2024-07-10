local home_dir = vim.fn.expand("~/Documents/Compete")
local playground_dir = home_dir .. "/play_ground"

vim.api.nvim_create_user_command("Playground", function() Open_playground() end, {})

function Open_playground()
    vim.fn.system("[ ! -d " .. playground_dir .. " ] && cargo new " .. playground_dir)
    local template = { "fn main() {", "    println!(\"Hello World!\");", "}" }
    vim.cmd("tabnew | lcd " .. playground_dir .. "| e ./src/main.rs | %d _")
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, template)
    vim.cmd("aboveleft 60vs | term")
    --vim.cmd("term cargo watch --watch-when-idle --poll -d 1 -w ./src/main.rs -x run")
    vim.api.nvim_chan_send(vim.b.terminal_job_id, "cargo run" .. "\n") -- Set_Watching用
    --vim.cmd("norm G")
    vim.cmd("wincmd l")
    local editor_buf = vim.api.nvim_get_current_buf() -- Set_Watching用
    vim.api.nvim_clear_autocmds({ buffer = editor_buf })
    vim.cmd("silent 2 | stopinsert")
    vim.cmd(string.format("let t:custom_%s = '%s'", 'tabname', 'Playground'))
    Set_Watching(editor_buf, "cargo run") -- Set_Watching用
end
