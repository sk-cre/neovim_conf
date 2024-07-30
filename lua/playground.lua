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

vim.api.nvim_create_user_command("Javaterm", function() Open_java_term() end, {})

function Open_java_term()
    local file_name = vim.fn.expand('%:t')
    local file_name_without_extension = vim.fn.expand('%:t:r')
    Set_Watch_Term("javac " .. file_name .. " && java " .. file_name_without_extension, 60)
    vim.cmd(string.format("let t:custom_tabname = '%s'", file_name_without_extension))
end

vim.api.nvim_create_user_command("PJavaterm", function() Open_java_playground() end, {})

function Open_java_playground()
    local template = { "public class test {", "    public static void main(String[] args) {",
        "        System.out.println(\"Hello World\");", "    }", "}" }
    vim.cmd("tabnew | lcd " .. playground_dir .. "| e test.java | %d _")
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, template)
    Set_Watch_Term("javac test.java && java test", 60)
    vim.cmd(string.format("let t:custom_tabname = '%s'", "PGJava"))
end
