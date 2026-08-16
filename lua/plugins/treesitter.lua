require('nvim-treesitter').setup {
    modules = {},
    sync_install = false,
    auto_install = false,
    ignore_install = {},
    ensure_installed = {
        'lua', 'python', 'go', 'rust', 'capnp', 'json', 'jsonc',
        'markdown', 'markdown_inline', 'c', 'cpp', 'html', 'css',
        'toml', 'sql', 'bash', 'yaml', 'dockerfile'
    },
    highlight = {enable = true},
    indent = {enable = true},
  }
