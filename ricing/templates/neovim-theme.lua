local c = {
    bg = "#@bg@",
    bg_alt = "#@bg_alt@",
    fg = "#@fg@",
    fg_dim = "#@fg_dim@",
    border = "#@border@",
    accent = "#@accent@",
    accent_fg = "#@accent_fg@",
    red = "#@red@",
    green = "#@green@",
    yellow = "#@yellow@",
    blue = "#@blue@",
    magenta = "#@magenta@",
    cyan = "#@cyan@",
    black = "#@black@",
    white = "#@white@",
}

vim.g.colors_name = "@theme@"

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

hi("Normal", { fg = c.fg, bg = c.bg })
hi("CursorLine", { bg = c.bg_alt })
hi("CursorLineNr", { fg = c.accent })
hi("LineNr", { fg = c.fg_dim })
hi("Comment", { fg = c.fg_dim, italic = true })
hi("Statement", { fg = c.magenta })
hi("Keyword", { fg = c.magenta })
hi("Function", { fg = c.blue })
hi("String", { fg = c.green })
hi("Number", { fg = c.yellow })
hi("Constant", { fg = c.yellow })
hi("Type", { fg = c.cyan })
hi("Identifier", { fg = c.fg })
hi("Boolean", { fg = c.red })
hi("Special", { fg = c.cyan })
hi("PreProc", { fg = c.magenta })
hi("Operator", { fg = c.fg })
hi("Visual", { bg = c.border })
hi("Search", { fg = c.accent_fg, bg = c.accent })
hi("IncSearch", { fg = c.accent_fg, bg = c.accent })
hi("StatusLine", { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.fg_dim, bg = c.bg_alt })
hi("VertSplit", { fg = c.border })
hi("Pmenu", { bg = c.bg_alt })
hi("PmenuSel", { fg = c.accent_fg, bg = c.accent })
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn", { fg = c.yellow })
hi("DiagnosticInfo", { fg = c.blue })
hi("DiagnosticHint", { fg = c.cyan })
