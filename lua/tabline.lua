vim.opt.tabline = '%!v:lua.Custom_tabline()'

function Custom_tabline()
    local s = ''
    for i = 1, vim.fn.tabpagenr('$') do
        local tabname = vim.fn.gettabvar(i, 'custom_' .. 'tabname')

        s = s .. '%' .. i .. 'T'
        s = s .. (i == vim.fn.tabpagenr() and '%#TabLineSel#' or '%#TabLine#')

        if tabname and tabname ~= '' then
            s = s .. ' ' .. tabname .. ' '
        else
            local buflist = vim.fn.tabpagebuflist(i)
            local winnr = vim.fn.tabpagewinnr(i)
            local bufnr = buflist[winnr]
            local bufname = vim.fn.bufname(bufnr)
            local filename = vim.fn.fnamemodify(bufname, ':t')
            s = s .. ' ' .. (filename ~= '' and filename or '[No Name]') .. ' '
        end
    end
    s = s .. '%T%#TabLineFill#%='
    return s
end
