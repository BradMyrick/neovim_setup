-- lua/plugins/conform.lua
-- Strict 80-character formatting for all major languages

local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    bash = { "shfmt" },
    sh = { "shfmt" },
    toml = { "taplo" },
    go = { "gofumpt", "gofmt" },
    rust = { "rustfmt" },
  },
  formatters = {
    prettier = {
      prepend_args = { "--print-width", "80", "--prose-wrap", "always" },
    },
    black = {
      prepend_args = { "--line-length", "80" },
    },
    stylua = {
      prepend_args = { "--column-width", "80" },
    },
    ["clang-format"] = {
      prepend_args = { "--style={BasedOnStyle: LLVM, ColumnLimit: 80}" },
    },
    shfmt = {
      prepend_args = { "-i", "4" },
    },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },
})

-- Keymap to format manually
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  conform.format({
    async = false,
    timeout_ms = 1000,
    lsp_fallback = true,
  })
end, { desc = "Format file or range with strict 80-char width" })
