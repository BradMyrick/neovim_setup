-- nvim/lua/localnest/config.lua

local M = {}

local defaults = {
  -- Backend configuration
  backend = {
    type = "local",  -- "local" or "deepseek"
    deepseek = {
      api_key_env = "DEEPSEEK_API_KEY",
      models = {
        chat = "deepseek-chat",
        fim = "deepseek-coder",
        reasoning = "deepseek-reasoner",
      },
      base_url = "https://api.deepseek.com",
      beta_base_url = "https://api.deepseek.com/beta",
      timeout = 30000,
    },
  },

  llama_server = {
    host = "localnest",
    port = 8888,
    timeout = 30000,  -- ms
  },

  fim = {
    enabled = true,
    auto_trigger = true,
    max_tokens = 128,
    temperature = 0.0,
    top_p = 0.9,
    top_k = 40,
    repeat_penalty = 1.1,
    stop_sequences = { "```", "\n\n" },
    -- Constraints
    only_in_code = true,
    code_filetypes = { "lua", "rust", "python", "go", "typescript", "javascript", "java", "c", "cpp", "csharp", "php", "ruby", "swift", "kotlin", "scala" },
    min_prefix_len = 3,
    reject_short_results = true,
    -- DeepSeek specific FIM settings
    deepseek_fim = {
      max_tokens = 256,
      temperature = 0.1,
      top_p = 0.95,
    },
  },

  chat = {
    enabled = true,
    max_tokens = 4096,
    temperature = 0.7,
    system_prompt = require("localnest.prompts").chat_system,
    show_tool_calls = true,
    -- DeepSeek specific chat settings
    deepseek_chat = {
      max_tokens = 8192,
      temperature = 0.7,
      frequency_penalty = 0.1,  -- Slight frequency penalty to reduce repetition
      presence_penalty = 0.1,   -- Slight presence penalty for more diverse responses
    },
  },

  tools = {
    enabled = true,
    n8n_endpoint = "http://localhost:5678/webhook/localnest",
  },
}

M.config = {}

--- Merge user config with defaults
local function merge_tables(base, user)
  local result = vim.deepcopy(base)
  if user then
    for k, v in pairs(user) do
      if type(v) == "table" and type(result[k]) == "table" then
        result[k] = merge_tables(result[k], v)
      else
        result[k] = v
      end
    end
  end
  return result
end

--- Setup function called by user
function M.setup(user_config)
  M.config = merge_tables(defaults, user_config or {})
end

--- Get config value
function M.get(key)
  local parts = vim.split(key, ".", { plain = true })
  local result = M.config
  for _, part in ipairs(parts) do
    if result == nil then
      return nil
    end
    result = result[part]
  end
  return result
end

-- Initialize with defaults
M.setup({})

return M
