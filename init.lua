vim.api.nvim_set_keymap("n", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Right>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Right>", "<Nop>", { noremap = true, silent = true })

vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamed"
--vim.opt.mouse = ""
vim.o.statusline = '%F%m%r%h%w%y[%{&filetype}]%=%-14.(%l,%c%V%)%<%P'
vim.o.laststatus = 2
vim.opt.scrolloff = 7
vim.fn.execute("set statusline^=%{coc#status()}")

vim.g.rustfmt_autosave = 1
vim.cmd("autocmd TermOpen * startinsert")
vim.cmd("autocmd TermOpen * setlocal nonumber norelativenumber")

vim.api.nvim_create_user_command('Rc', ':e $MYVIMRC',{nargs = 0})
vim.api.nvim_create_user_command('RRc', ':source $MYVIMRC',{nargs = 0})
vim.api.nvim_create_user_command('Conf', ":e " .. vim.fn.stdpath("config"),{nargs = 0})
vim.api.nvim_create_user_command('RcC', ":e " .. vim.fn.stdpath("config") .. "/lua/compete.lua",{nargs = 0})
vim.api.nvim_create_user_command('RcP', ":e " .. vim.fn.stdpath("config") .. "/lua/plugins.lua",{nargs = 0})

require ("plugins")
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})
if vim.fn.has('termguicolors') then
	vim.opt.termguicolors = true
end
vim.opt.background="dark"
vim.g.gruvbox_material_background = 'soft'
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_disable_italic_comment = 1
vim.cmd "colorscheme gruvbox-material"

vim.g.coc_global_extensions = {
      'coc-json', 
      'coc-pairs', 
      'coc-snippets', 
      'coc-ultisnips', 
      'coc-vimlsp', 
      'coc-lua', 
      'coc-yaml', 
      'coc-toml', 
      'coc-rust-analyzer', 
      'coc-python', 
}
require("compete")
