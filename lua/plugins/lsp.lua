-- lua/plugins/lsp.lua
-- Unified native LSP config (Neovim 0.11+)

-- Disable LSP logging to prevent lsp.log from filling up disk
vim.lsp.log.set_level(vim.log.levels.OFF)

---------------------------------------------------------------
-- Dependencies
---------------------------------------------------------------

local cmp_nvim_lsp = require("cmp_nvim_lsp")



---------------------------------------------------------------
-- Shared capabilities + on_attach
---------------------------------------------------------------

local capabilities = cmp_nvim_lsp.default_capabilities()

local on_attach = function(client, bufnr)
  -- inlay hints when supported
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------

local function root_with(markers)
  return function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      fname = vim.loop.cwd() or "."
    end
    local start = vim.fs.dirname(fname)
    local found = vim.fs.find(markers, { upward = true, path = start })[1]
    local root = found and vim.fs.dirname(found) or start
    on_dir(root)
  end
end

---------------------------------------------------------------
-- Diagnostic refresh on save
---------------------------------------------------------------



---------------------------------------------------------------
-- LSP servers (vim.lsp.config / vim.lsp.enable)
---------------------------------------------------------------

-- Go (gopls)
vim.lsp.config("gopls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = root_with({ "go.work", "go.mod", ".git" }),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})
vim.lsp.enable("gopls")

-- Python (pyright)
vim.lsp.config("pyright", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = root_with({
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  }),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})
vim.lsp.enable("pyright")

-- TypeScript / JavaScript (ts_ls)
vim.lsp.config("ts_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = root_with({ "package.json", "tsconfig.json", "jsconfig.json", ".git" }),
  init_options = {
    hostInfo = "neovim",
  },
})
vim.lsp.enable("ts_ls")

-- Lua (lua-language-server)
vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = root_with({
    ".emmyrc.json",
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  }),
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
      hint = {
        enable = true,
        semicolon = "Disable",
      },
      codeLens = {
        enable = true,
      },
    },
  },
})
vim.lsp.enable("lua_ls")

-- Bash (bashls)
vim.lsp.config("bashls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  root_dir = root_with({ ".git" }),
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
})
vim.lsp.enable("bashls")

-- Docker (dockerls)
vim.lsp.config("dockerls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  root_dir = root_with({ "Dockerfile", ".git" }),
})
vim.lsp.enable("dockerls")

-- YAML (yamlls)
vim.lsp.config("yamlls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
  root_dir = root_with({ ".git" }),
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = true },
    },
  },
})
vim.lsp.enable("yamlls")

-- JSON (jsonls)
vim.lsp.config("jsonls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_dir = root_with({ ".git" }),
  init_options = {
    provideFormatter = true,
  },
})
vim.lsp.enable("jsonls")

-- Rust (rust-analyzer, managed by rustup so it always matches the toolchain)
vim.lsp.config("rust_analyzer", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_dir = root_with({ "Cargo.toml", "rust-project.json", ".git" }),
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = { enable = true },
      check = {
        command = "check",
      },
      imports = { granularity = { group = "module" } },
      cargo = {
        autoreload = true,
        buildScripts = { enable = true },
      },
      procMacro = { enable = true },
    },
  },
})
vim.lsp.enable("rust_analyzer")

-- Reload rust-analyzer's workspace when the crate manifest changes, so newly
-- added dependencies get indexed instead of surfacing spurious
-- `unresolved-reference` diagnostics on external crate symbols.
local function reload_rust_workspace()
  for _, client in ipairs(vim.lsp.get_clients({ name = "rust_analyzer" })) do
    client.request("rust-analyzer/reloadWorkspace", nil, function() end, 0)
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("RustAnalyzerAutoReload", { clear = true }),
  pattern = { "Cargo.toml", "Cargo.lock", "rust-project.json" },
  callback = reload_rust_workspace,
})

---------------------------------------------------------------
-- Cap'n Proto: filetype + capnp_ls
---------------------------------------------------------------

vim.filetype.add({
  extension = { capnp = "capnp" },
})

vim.lsp.config("capnp_ls", {
  cmd = { "/home/kodr/capnp-ls/build/capnp-ls" },
  filetypes = { "capnp" },
  root_markers = { ".git", "capnp.toml", "capnp.json" },
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    capnp = {
      compilerPath = "/usr/local/bin/capnp",
      importPaths = { "." },
    },
  },
})
vim.lsp.enable("capnp_ls")

---------------------------------------------------------------
-- Markdown (marksman)
---------------------------------------------------------------
vim.lsp.config("marksman", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_dir = root_with({ ".git", ".marksman.toml" }),
})
vim.lsp.enable("marksman")

---------------------------------------------------------------
-- C / C++ (clangd)
---------------------------------------------------------------
vim.lsp.config("clangd", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = root_with({
    ".clangd",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
  }),
})
vim.lsp.enable("clangd")

---------------------------------------------------------------
-- HTML (html)
---------------------------------------------------------------
vim.lsp.config("html", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "temple" },
  root_dir = root_with({ ".git" }),
})
vim.lsp.enable("html")

---------------------------------------------------------------
-- CSS (cssls)
---------------------------------------------------------------
vim.lsp.config("cssls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_dir = root_with({ ".git" }),
})
vim.lsp.enable("cssls")

---------------------------------------------------------------
-- TOML (taplo)
---------------------------------------------------------------
vim.lsp.config("taplo", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_dir = root_with({ ".git" }),
})
vim.lsp.enable("taplo")

---------------------------------------------------------------
-- SQL (sqlls)
---------------------------------------------------------------
vim.lsp.config("sqlls", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "sql-language-server", "up", "--method", "stdio" },
  filetypes = { "sql", "mysql" },
  root_dir = root_with({ ".git" }),
})
vim.lsp.enable("sqlls")

