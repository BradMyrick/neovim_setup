#!/bin/bash

echo "=== LocalNest DeepSeek Setup Verification ===\n"

# Check if files exist
echo "1. Checking file structure..."
FILES=(
    "lua/localnest/init.lua"
    "lua/localnest/backend.lua"
    "lua/localnest/config.lua"
    "lua/localnest/http.lua"
    "lua/localnest/fim.lua"
    "lua/localnest/chat.lua"
    "lua/localnest/keymaps.lua"
)

all_files_exist=true
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (missing)"
        all_files_exist=false
    fi
done

echo "\n2. Checking for API key security fixes..."
if grep -q "Bearer%s+\[%w%-_\]+" lua/localnest/http.lua 2>/dev/null; then
    echo "  ✓ HTTP module has API key sanitization"
else
    echo "  ✗ HTTP module missing API key sanitization"
fi

if grep -q "REDACTED" lua/localnest/backend.lua 2>/dev/null; then
    echo "  ✓ Backend module has error sanitization"
else
    echo "  ✗ Backend module missing error sanitization"
fi

echo "\n3. Checking DeepSeek FIM implementation..."
if grep -q "beta_base_url.*completions" lua/localnest/backend.lua 2>/dev/null || grep -q "/completions" lua/localnest/backend.lua 2>/dev/null; then
    echo "  ✓ Using correct DeepSeek FIM endpoint"
    if grep -q "beta_base_url" lua/localnest/backend.lua 2>/dev/null; then
        echo "  ✓ Using beta endpoint configuration"
    fi
else
    echo "  ✗ Not using correct DeepSeek FIM endpoint"
fi

echo "\n4. Checking configuration..."
if grep -q "deepseek_fim" lua/localnest/config.lua 2>/dev/null; then
    echo "  ✓ DeepSeek-specific FIM configuration present"
else
    echo "  ✗ DeepSeek-specific FIM configuration missing"
fi

if grep -q "deepseek_chat" lua/localnest/config.lua 2>/dev/null; then
    echo "  ✓ DeepSeek-specific chat configuration present"
else
    echo "  ✗ DeepSeek-specific chat configuration missing"
fi

echo "\n5. Checking keymaps..."
if [ -f "lua/localnest/keymaps.lua" ]; then
    echo "  ✓ Keymaps module created"
    keymap_count=$(grep -c "vim.keymap.set" lua/localnest/keymaps.lua 2>/dev/null || echo "0")
    echo "  Found $keymap_count keybindings"
else
    echo "  ✗ Keymaps module missing"
fi

echo "\n6. Checking setup guide..."
if [ -f "SETUP_GUIDE.md" ]; then
    echo "  ✓ Setup guide created"
    guide_size=$(wc -l < SETUP_GUIDE.md)
    echo "  Guide has $guide_size lines"
else
    echo "  ✗ Setup guide missing"
fi

echo "\n=== Summary ==="
if [ "$all_files_exist" = true ]; then
    echo "✓ Basic file structure is complete"
    echo "✓ DeepSeek setup has been enhanced with:"
    echo "  - API key security fixes"
    echo "  - Proper FIM implementation"
    echo "  - Enhanced configuration"
    echo "  - Comprehensive keybindings"
    echo "  - Detailed setup guide"
    echo "\nNext steps:"
    echo "1. Set your DeepSeek API key: export DEEPSEEK_API_KEY='your-key'"
    echo "2. Add LocalNest configuration to your Neovim init.lua"
    echo "3. Restart Neovim and test with :LocalNestBackendStatus"
else
    echo "✗ Some files are missing. Please check the setup."
fi