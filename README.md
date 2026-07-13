# Nvim Code Review Setup

A clean, streamlined Neovim configuration focused on manual code review, debugging, and precise code editing. This setup eliminates unnecessary AI plugins to provide a fast and focused environment.

## Features

- **Code Review**: Fast and precise code navigation and reading.
- **Language Support (LSP)**: Integrated LSP for code intelligence, definition jumping, and formatting.
- **Debugging (DAP)**: Built-in DAP configuration for stepping through code and debugging directly from Neovim.
- **Testing**: Integrated `neotest` for running unit tests quickly from the editor.
- **Git Integration**: Full Git support via `vim-fugitive` and inline diffs via `gitsigns.nvim`.

## Keybindings

### Engineering Tools (`<leader>`)
| Shortcut | Action |
| --- | --- |
| `<leader>db` | Toggle Breakpoint |
| `<leader>ds` | Debug Start/Continue |
| `<leader>dd` | Step Over |
| `<leader>du` | Toggle Debug UI |
| `<leader>tt` | Run Nearest Test |
| `<leader>tf` | Run Current File |
| `<leader>to` | Show Test Output |
| `<leader>o` | Toggle Code Outline |

### Buffer Navigation
| Shortcut | Action |
| --- | --- |
| `<S-h>` | Previous Buffer (Tab) |
| `<S-l>` | Next Buffer (Tab) |
| `<leader>bp` | Previous Buffer |
| `<leader>bn` | Next Buffer |
| `<leader>bc` | Close Buffer |

## Quality of Life Tweaks
- **Buffer Navigation**: Fast tab switching with `<Shift-h/l>`.
- **System Clipboard**: Unified copy/paste with `Ctrl-c` and `Ctrl-v`.
- **Smooth Interaction**: Hardware-accelerated scrolling with `neoscroll.nvim`.
- **Persistent History**: Global undo history saved across restarts.

## Requirements

- Neovim 0.10+
