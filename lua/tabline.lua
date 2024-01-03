vim.opt.tabline = '%!v:lua.custom_tabline()'

function custom_tabline()
    local s = ''
    for i = 1, vim.fn.tabpagenr('$') do
        local buflist = vim.fn.tabpagebuflist(i)
        local bufnr = buflist[vim.fn.tabpagewinnr(i)]
        local bufname = vim.fn.bufname(bufnr)
        local bufpath = vim.fn.fnamemodify(bufname, ':p')
        local tab_label
        if string.match(bufpath, '/Documents/Compete/atcoder/') then
            local contest_name = vim.fn.fnamemodify(bufpath, ':p:h:h:h:t')
            local problem_name = vim.fn.fnamemodify(bufname, ':t:r')
            tab_label = contest_name .. ' ' .. problem_name
        else
            tab_label = vim.fn.fnamemodify(bufname, ':t')
        end
        s = s .. '%' .. i .. 'T'
        s = s .. (i == vim.fn.tabpagenr() and '%#TabLineSel#' or '%#TabLine#')
        s = s .. ' ' .. tab_label .. ' '  -- [ ] を削除
    end
    s = s .. '%T%#TabLineFill#%='
    return s
end
