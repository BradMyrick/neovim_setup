-- Example LocalNest configuration for Neovim
-- Copy this to your Neovim config (e.g., ~/.config/nvim/lua/plugins/ai.lua)

return {
  -- LocalNest AI Assistant
  {
    dir = vim.fn.stdpath('config') .. '/lua/localnest',
    config = function()
      require('localnest').setup({
        -- Backend configuration
        backend = {
          type = "deepseek",  -- Switch to "local" for local llama.cpp server
          
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
          
          system_prompt = [[You are a highly skilled coding assistant. Provide accurate, concise, and helpful responses. Focus on code quality, best practices, and practical solutions. When explaining code, be thorough but avoid unnecessary verbosity.]],
          
          -- DeepSeek specific chat settings
          deepseek_chat = {
            max_tokens = 8192,
            temperature = 0.7,
            frequency_penalty = 0.0,
            presence_penalty = 0.0,
          },
        },
      })
    end,
  },
}