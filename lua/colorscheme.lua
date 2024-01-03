function _G.change_color()
    math.randomseed(os.time())
    local rand = math.random(1, 9)
    if rand == 1 then
        if vim.fn.has('termguicolors') then
            vim.opt.termguicolors = true
        end
        vim.opt.background = "dark"
        vim.g.gruvbox_material_background = 'soft'
        vim.g.gruvbox_material_better_performance = 1
        vim.g.gruvbox_material_disable_italic_comment = 1
        vim.cmd "colorscheme gruvbox-material"
    elseif rand == 2 then
        if vim.fn.has('termguicolors') then
            vim.opt.termguicolors = true
        end
        vim.opt.background = "dark"
        vim.g.gruvbox_material_better_performance = 1
        vim.g.gruvbox_material_disable_italic_comment = 1
        vim.cmd "colorscheme gruvbox-material"
    elseif rand == 3 then
        vim.opt.termguicolors = true
        vim.cmd.colorscheme 'melange'
    elseif rand <= 9 then
        local themes = { "dark", "darker", "cool", "deep", "warm", "warmer" }
        require('onedark').setup {
            style = themes[rand - 3]
        }
        require('onedark').load()
    end
end

vim.api.nvim_create_autocmd("TabNew", {
    pattern = "*",
    callback = function()
        _G.change_color()
    end,
})

_G.change_color()
