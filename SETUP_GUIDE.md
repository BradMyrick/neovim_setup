# LocalNest AI Setup Guide

## Overview

This guide will help you set up a highly polished, secure, and accurate AI-assisted coding environment in Neovim using DeepSeek API.

## Fixed Issues

1. **API Key Security**: Fixed potential API key leakage in error messages
2. **Proper FIM Implementation**: Now uses DeepSeek's official FIM endpoint instead of chat completions
3. **Improved Configuration**: Better model and parameter configuration
4. **Enhanced Keymaps**: Intuitive keybindings for all AI features

## Setup Instructions

### 1. Environment Variables

Set your DeepSeek API key as an environment variable:

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export DEEPSEEK_API_KEY="your-api-key-here"
```

### 2. Neovim Configuration

Add the following to your Neovim configuration (e.g., `~/.config/nvim/init.lua`):

```lua
-- Configure LocalNest AI
require('localnest').setup({
  -- Backend configuration
  backend = {
    type = "deepseek",  -- or "local" for local llama.cpp server
    
    deepseek = {
      api_key_env = "DEEPSEEK_API_KEY",
      models = {
        chat = "deepseek-chat",      -- For chat conversations
        fim = "deepseek-coder",      -- For code completion
        reasoning = "deepseek-reasoner", -- For complex reasoning
      },
      timeout = 30000,  -- 30 seconds
    },
  },
  
  -- FIM (Fill-in-the-Middle) configuration
  fim = {
    enabled = true,
    auto_trigger = true,
    max_tokens = 128,
    temperature = 0.0,  -- Lower temperature for more deterministic code completion
    
    -- Filetypes where FIM is enabled
    code_filetypes = {
      "lua", "rust", "python", "go", "typescript", "javascript",
      "java", "c", "cpp", "csharp", "php", "ruby", "swift", "kotlin", "scala"
    },
    
    -- DeepSeek specific FIM settings
    deepseek_fim = {
      max_tokens = 256,
      temperature = 0.1,
      top_p = 0.95,
    },
  },
  
  -- Chat configuration
  chat = {
    enabled = true,
    max_tokens = 4096,
    temperature = 0.7,
    
    system_prompt = "You are a highly skilled coding assistant. Provide accurate, concise, and helpful responses. Focus on code quality, best practices, and practical solutions.",
    
    -- DeepSeek specific chat settings
    deepseek_chat = {
      max_tokens = 8192,
      temperature = 0.7,
      frequency_penalty = 0.0,
      presence_penalty = 0.0,
    },
  },
})
```

### 3. Key Bindings

The following key bindings are available:

#### FIM (Code Completion)
- `Ctrl+Space` (Insert mode) - Trigger manual FIM completion
- `<leader>af` (Normal mode) - Trigger manual FIM completion
- `Tab` (Insert mode) - Accept FIM suggestion
- `Esc` (Insert mode) - Dismiss FIM suggestion
- `<leader>at` - Toggle FIM auto-completion

#### Chat Interface
- `<leader>ac` - Open chat prompt
- `<leader>ac` (Visual mode) - Chat about selected text
- `<leader>af` - Chat about current file

#### Slash Commands
- `<leader>ae` - `/explain` - Explain selected code
- `<leader>ax` - `/fix` - Fix issues in selected code
- `<leader>ar` - `/refactor` - Refactor selected code
- `<leader>at` - `/test` - Generate tests for selected code

#### Backend Management
- `<leader>ab` - Switch between local and DeepSeek backends
- `<leader>as` - Show current backend status
- `<leader>ah` - Clear chat history

### 4. Commands

- `:LocalNestFIM` - Trigger FIM completion
- `:LocalNestChat [question]` - Open chat with optional question
- `:LocalNestExplain` - Explain current code
- `:LocalNestFix` - Fix issues in current code
- `:LocalNestRefactor` - Refactor current code
- `:LocalNestTest` - Generate tests for current code
- `:LocalNestSwitchBackend [local|deepseek]` - Switch AI backend
- `:LocalNestBackendStatus` - Show backend status
- `:LocalNestToggleFIM` - Toggle FIM auto-completion

## Usage Examples

### 1. Code Completion (FIM)

1. Start typing code
2. Press `Ctrl+Space` to get AI suggestions
3. Press `Tab` to accept or `Esc` to dismiss

### 2. Chat with AI

```vim
:LocalNestChat "How do I implement a binary search in Python?"
```

Or use the keybinding: `<leader>ac`

### 3. Explain Code

Select code in visual mode and press `<leader>ae`

### 4. Switch Backends

```vim
:LocalNestSwitchBackend deepseek
:LocalNestSwitchBackend local
```

## Troubleshooting

### API Key Issues

1. **Check environment variable**:
   ```bash
   echo $DEEPSEEK_API_KEY
   ```

2. **Verify in Neovim**:
   ```vim
   :LocalNestBackendStatus
   ```

### FIM Not Working

1. Ensure you're in a supported filetype
2. Check if FIM is enabled:
   ```vim
   :LocalNestToggleFIM  # Toggles FIM on/off
   ```

3. Try manual trigger: `Ctrl+Space`

### Performance Issues

1. Reduce `max_tokens` in FIM configuration
2. Increase timeout values if experiencing timeouts
3. Consider using local backend for faster responses

## Security Notes

- API keys are never logged or displayed in error messages
- All API calls use HTTPS
- Error messages are sanitized to prevent information leakage
- Consider using environment variables or secure credential managers

## Advanced Configuration

### Custom System Prompts

```lua
require('localnest').setup({
  chat = {
    system_prompt = "You are an expert in [your domain]. Focus on [specific requirements].",
  },
})
```

### Model Selection

```lua
require('localnest').setup({
  backend = {
    deepseek = {
      models = {
        chat = "deepseek-reasoner",  -- Use reasoning model for complex tasks
        fim = "deepseek-coder",      -- Best for code completion
      },
    },
  },
})
```

### Temperature Settings

- **FIM**: Lower temperature (0.0-0.2) for deterministic code
- **Chat**: Medium temperature (0.5-0.8) for creative responses
- **Reasoning**: Higher temperature (0.7-1.0) for exploratory thinking

## Support

For issues or feature requests, please check the repository or create an issue.