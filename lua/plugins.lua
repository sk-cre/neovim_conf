local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    --{ 'neoclide/coc.nvim', branch = 'release', build = "cd /root/.local/share/nvim/lazy/coc.nvim/ && npm ci"},
    { 'neoclide/coc.nvim',       branch = 'release', build = "npm ci" },
    { 'honza/vim-snippets' },
    { 'nvim-lua/plenary.nvim' },
    { 'rust-lang/rust.vim' },
    { 'sainnhe/gruvbox-material' },
    { 'navarasu/onedark.nvim' },
    { "savq/melange-nvim" },
    {
        'nvim-treesitter/nvim-treesitter',
        event = { 'BufNewFile', 'BufRead' },
        build = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    "typescript", "javascript", "rust", "python", "go", "lua", "bash", "html", "css", "vue",
                    "vim", "yaml", "toml", "ini", "json", "dockerfile", "markdown", "diff", "gitignore"
                },
                highlight = {
                    enable = true,
                },
            }
        end
    },
})
vim.api.nvim_set_keymap('i', '<cr>',
    "pumvisible() ? coc#_select_confirm() : \"\\<C-g>u\\<CR>\\<c-r>=coc#on_enter()\\<CR>\"",
    { noremap = true, silent = true, expr = true })

vim.g.coc_global_extensions = {
    'coc-json', 'coc-pairs', 'coc-snippets', 'coc-ultisnips', 'coc-vimlsp',
    'coc-lua', 'coc-yaml', 'coc-toml', 'coc-rust-analyzer', 'coc-python',
}

vim.o.statusline = "%{coc#status()}" .. vim.o.statusline
