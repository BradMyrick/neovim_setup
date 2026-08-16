# Streamlined Neovim Setup

A clean, human-centric Neovim configuration focused on manual code review, precise code writing, and debugging. This setup eliminates AI noise and predictive text while providing rich language intelligence (LSP), strict 80-column formatting across all languages (including Markdown), and focused autocompletion for object properties and path paths.

## Installation

Clone the repo into `~/.config/nvim`, then install the language servers and formatters natively (no Mason):

```sh
git clone https://github.com/BradMyrick/neovim_stuff.git ~/.config/nvim
cd ~/.config/nvim && ./install-tools.sh
```

`install-tools.sh` installs each tool via its own package manager (rustup, go, npm, pip, cargo, apt) so it stays in sync with its toolchain — `rustup component add rust-analyzer` keeps rust-analyzer version-matched to your rustc/cargo. It is idempotent and safe to re-run.

## Features

- **Comprehensive LSP Coverage**: Native LSP integration for Go (`gopls`), Python (`pyright`), Rust (`rust-analyzer`), TypeScript/JavaScript (`ts_ls`), Lua (`lua-language-server`), C/C++ (`clangd`), Markdown (`marksman`), HTML (`html`), CSS (`cssls`), TOML (`taplo`), SQL (`sqlls`), Bash (`bashls`), YAML (`yamlls`), JSON (`jsonls`), Docker (`dockerls`), and Cap'n Proto (`capnp_ls`).
- **Strict 80-Column Formatting**: Integrated [`conform.nvim`](https://github.com/stevearc/conform.nvim) for deterministic 80-character line wrapping across all major languages (Markdown, Python, Lua, C/C++, Rust, Go, JS/TS, HTML/CSS, TOML, JSON, YAML). Native `textwidth=80` and `colorcolumn=80` for Markdown buffers.
- **Focused Completion (No AI / Predictive Text)**: Pure LSP member/method completion (`object.`) and path completion via `nvim-cmp`. No AI suggestions or predictive text interruptions.
- **Markdown Studio**: Crisp rendered Markdown headings, callouts, tables, and blockquotes with `render-markdown.nvim` and full `marksman` LSP symbol navigation.
- **Debugging (DAP)**: Built-in DAP configuration for stepping through code and debugging directly from Neovim.
- **Testing**: Integrated `neotest` for running unit tests quickly from the editor.
- **Git Integration**: Full Git support via `vim-fugitive` and inline diffs via `gitsigns.nvim`.

## Keybindings

### Engineering & Formatting Tools (`<leader>`)
| Shortcut | Action |
| --- | --- |
| `<leader>f` | Format File / Selection (Strict 80-Column Width) |
| `<leader>ca` | LSP Code Actions |
| `<leader>rn` | Rename Symbol |
| `<leader>db` | Toggle Breakpoint |
| `<leader>ds` | Debug Start/Continue |
| `<leader>dd` | Step Over |
| `<leader>du` | Toggle Debug UI |
| `<leader>Tt` | Run Nearest Test |
| `<leader>Tf` | Run Current File |
| `<leader>Ts` | Stop Test |
| `<leader>To` | Show Test Output |
| `<leader>o` | Toggle Code Outline |

### Navigation & Diagnostics
| Shortcut | Action |
| --- | --- |
| `gd` | Go to Definition |
| `gr` | Go to References |
| `K` | Show Hover Information |
| `[d` / `]d` | Previous / Next Diagnostic |
| `<leader>0` | Show Floating Diagnostic |
| `<S-h>` / `<S-l>` | Switch Buffer Tabs |
| `<leader>bp` / `<leader>bn` | Previous / Next Buffer |
| `<leader>bc` | Close Buffer |

## Requirements

- Neovim 0.11+
