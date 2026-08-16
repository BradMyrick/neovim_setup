-- lua/plugins/diagnostics.lua
-- Unified modern diagnostic settings for Neovim

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "if_many",
  },
  float = {
    source = true,
    border = "rounded",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "🔥",
      [vim.diagnostic.severity.WARN] = "⚠️",
      [vim.diagnostic.severity.HINT] = "💡",
      [vim.diagnostic.severity.INFO] = "ℹ️",
    },
  },
  underline = true,
  update_in_insert = true, -- Update and clear diagnostics immediately as you type & edit!
  severity_sort = true,
})

require('trouble').setup({
  icons = false,
  signs = {
    error = "🔥",
    warning = "⚠️",
    hint = "💡",
    information = "ℹ️"
  }
})

-- Force diagnostic redraw on InsertLeave & BufWritePost
vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("DiagnosticAutoRefresh", { clear = true }),
  callback = function(args)
    vim.diagnostic.show(nil, args.buf)
  end,
})
