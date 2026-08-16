-- after/ftplugin/markdown.lua
-- Buffer-local settings for Markdown files to enforce 80-character width

vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = "80"
vim.opt_local.wrap = true
vim.opt_local.breakindent = true

-- Ensure auto-wrapping text as you type in Markdown
vim.opt_local.formatoptions:append("t")
