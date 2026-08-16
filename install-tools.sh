#!/usr/bin/env bash
# install-tools.sh — bootstrap all LSP servers + formatters for this Neovim config.
#
# This config intentionally does NOT use Mason. Each tool is installed via its
# native package manager so it stays in lockstep with its own toolchain
# (e.g. rust-analyzer via `rustup` so it always matches your rustc/cargo).
#
# Idempotent: re-running it only installs what's missing. Targets Debian/Ubuntu
# (Linux). Run once per machine after cloning this repo:
#
#   ./install-tools.sh
#
set -euo pipefail

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$BIN_DIR"

have() { command -v "$1" >/dev/null 2>&1; }
say()  { printf '==> %s\n' "$*"; }
warn() { printf '!! %s\n' "$*" >&2; }

# --- apt (Debian/Ubuntu): clangd + clang-format -------------------------------
if have apt-get; then
  apt_pkgs=()
  have clangd       || apt_pkgs+=(clangd)
  have clang-format || apt_pkgs+=(clang-format)
  if ((${#apt_pkgs[@]} > 0)); then
    say "Installing ${apt_pkgs[*]} via apt (may prompt for sudo)"
    sudo apt-get install -y "${apt_pkgs[@]}"
  fi
fi

# --- Rust: rust-analyzer via rustup (tracks your toolchain) ------------------
if have rustup; then
  say "Installing rustup components: rust-analyzer, rust-src"
  rustup component add rust-analyzer rust-src
elif have cargo; then
  warn "rustup not found — install it first (https://rustup.rs), then re-run."
fi

# --- Rust tools via cargo -----------------------------------------------------
if have cargo; then
  have taplo  || cargo install taplo-cli --locked
  have stylua || cargo install stylua --locked
fi

# --- Go tools -----------------------------------------------------------------
if have go; then
  have gopls   || go install golang.org/x/tools/gopls@latest
  have gofumpt || go install mvdan.cc/gofumpt@latest
  have shfmt   || go install mvdan.cc/sh/v3/cmd/shfmt@latest
fi

# --- Node servers + prettier --------------------------------------------------
if have npm; then
  missing=0
  for b in typescript-language-server pyright-langserver bash-language-server \
           docker-langserver yaml-language-server vscode-json-language-server \
           vscode-html-language-server vscode-css-language-server \
           sql-language-server prettier; do
    have "$b" || missing=1
  done
  if ((missing)); then
    say "Installing Node-based language servers + prettier"
    npm install -g \
      typescript-language-server typescript \
      pyright \
      bash-language-server \
      dockerfile-language-server-nodejs \
      yaml-language-server \
      vscode-langservers-extracted \
      sql-language-server \
      prettier
  fi
fi

# --- Python: black ------------------------------------------------------------
if have python3 && ! have black; then
  say "Installing black"
  python3 -m pip install --user --break-system-packages black \
    || python3 -m pip install --user black
fi

# --- GitHub-release binaries (lua-language-server, marksman) ------------------
download_gh() { # download_gh <repo> <asset-substring> <dest-name> [extract-dir]
  local repo="$1" needle="$2" name="$3" extract="${4:-}"
  local url
  url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -oE '"browser_download_url": *"[^"]+"' \
    | cut -d'"' -f4 \
    | grep "$needle" | grep -v musl | head -n1)"
  [ -n "$url" ] || { warn "no release asset matching '$needle' for $repo"; return 1; }
  say "Downloading $name from $repo"
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/$name.dl"
  if [ -n "$extract" ]; then
    tar -xzf "$tmp/$name.dl" -C "$tmp"
    find "$tmp" -name "$name" -type f -exec install -m755 {} "$BIN_DIR/$name" \; -quit
  else
    install -m755 "$tmp/$name.dl" "$BIN_DIR/$name"
  fi
  rm -rf "$tmp"
}

if ! have lua-language-server; then
  download_gh "LuaLS/lua-language-server" "linux-x64.tar.gz" "lua-language-server" extract
fi

if ! have marksman; then
  download_gh "artempyanykh/marksman" "marksman-linux-x64" "marksman"
fi

# --- Final report -------------------------------------------------------------
say "Done. Verify with:"
printf '  rust-analyzer --version\n'
printf '  gopls version\n'
printf '  typescript-language-server --version\n'
printf '  clangd --version\n'
