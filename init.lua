-- Set mapleader FIRST before anything else
vim.g.mapleader = ' '

-- Load core configurations first
require('core.options')
require('core.plugins')
require('core.keymaps')

-- Load plugin configurations AFTER plugins are loaded

vim.schedule(function()
    require('nvim-web-devicons').setup()
    require('plugins.dashboard')
    require('plugins.diagnostics')
    require('plugins.cmp')
    require('plugins.lsp')
    require('plugins.telescope')
    require('plugins.treesitter')
    require('plugins.dap')
    require('plugins.aerial')
    require('plugins.bufferline')
    require('plugins.neotest')
    require('plugins.conform')
    -- Theme
    vim.cmd [[colorscheme tokyonight]]
end)

vim.opt.clipboard = "unnamedplus"
