-- nvim/lua/localnest/backend.lua
-- Backend abstraction layer for AI providers

local M = {}

local config = require("localnest.config")
local http = require("localnest.http")

-- Backend types
M.BACKEND_TYPES = {
    LOCAL = "local",
    DEEPSEEK = "deepseek",
}

-- Current backend state
M.current_backend = M.BACKEND_TYPES.LOCAL
M.backend_config = {
    [M.BACKEND_TYPES.LOCAL] = {
        name = "Local Llama",
        description = "Local llama.cpp server",
        requires_api_key = false,
    },
    [M.BACKEND_TYPES.DEEPSEEK] = {
        name = "DeepSeek API",
        description = "DeepSeek remote API",
        requires_api_key = true,
        api_key_env = config.get("backend.deepseek.api_key_env") or "DEEPSEEK_API_KEY",
    },
}

-- Initialize backend from config or environment
function M.init()
    local saved_backend = config.get("backend.type")
    if saved_backend and M.BACKEND_TYPES[saved_backend:upper()] then
        -- Validate DeepSeek API key if saved backend is DeepSeek
        if saved_backend == M.BACKEND_TYPES.DEEPSEEK then
            local api_key = os.getenv(M.backend_config[M.BACKEND_TYPES.DEEPSEEK].api_key_env)
            if not api_key or api_key == "" then
                vim.notify("DeepSeek API key not found in DEEPSEEK_API_KEY", vim.log.levels.WARN)
                vim.notify("Falling back to local backend", vim.log.levels.INFO)
                M.current_backend = M.BACKEND_TYPES.LOCAL
            else
                M.current_backend = saved_backend
            end
        else
            M.current_backend = saved_backend
        end
    else
        -- Default to local if not configured
        M.current_backend = M.BACKEND_TYPES.LOCAL
    end
    
    return M.current_backend
end

-- Get current backend name for display
function M.get_current_backend_name()
    return M.backend_config[M.current_backend].name
end

-- Get current backend type
function M.get_current_backend()
    return M.current_backend
end

-- Switch backend
function M.switch_backend(backend_type)
    if not M.BACKEND_TYPES[backend_type:upper()] then
        vim.notify("Invalid backend type: " .. backend_type, vim.log.levels.ERROR)
        return false
    end
    
    -- Validate DeepSeek API key if switching to it
    if backend_type == M.BACKEND_TYPES.DEEPSEEK then
        local api_key = os.getenv(M.backend_config[M.BACKEND_TYPES.DEEPSEEK].api_key_env)
        if not api_key or api_key == "" then
            vim.notify("Cannot switch to DeepSeek: API key not found in DEEPSEEK_API_KEY", vim.log.levels.ERROR)
            vim.notify("Set DEEPSEEK_API_KEY environment variable to use DeepSeek backend", vim.log.levels.WARN)
            return false
        end
    end
    
    M.current_backend = backend_type
    
    -- Save to config
    local current_config = config.config or {}
    current_config.backend = current_config.backend or {}
    current_config.backend.type = backend_type
    config.config = current_config
    
    vim.notify("Switched to " .. M.backend_config[backend_type].name .. " backend", vim.log.levels.INFO)
    return true
end

-- Get API key for current backend (if needed)
function M.get_api_key()
    if M.current_backend == M.BACKEND_TYPES.DEEPSEEK then
        return os.getenv(M.backend_config[M.BACKEND_TYPES.DEEPSEEK].api_key_env)
    end
    return nil
end

-- Backend-agnostic FIM completion
function M.fim_complete(prefix, suffix, callback, opts)
    opts = opts or {}
    
    if M.current_backend == M.BACKEND_TYPES.LOCAL then
        return M._local_fim_complete(prefix, suffix, callback, opts)
    elseif M.current_backend == M.BACKEND_TYPES.DEEPSEEK then
        return M._deepseek_fim_complete(prefix, suffix, callback, opts)
    else
        callback("Unknown backend: " .. M.current_backend, nil)
    end
end

-- Backend-agnostic chat completion
function M.chat_complete(messages, callback, opts)
    opts = opts or {}
    local stream = opts.stream or true
    
    if M.current_backend == M.BACKEND_TYPES.LOCAL then
        return M._local_chat_complete(messages, callback, opts)
    elseif M.current_backend == M.BACKEND_TYPES.DEEPSEEK then
        return M._deepseek_chat_complete(messages, callback, opts)
    else
        callback("Unknown backend: " .. M.current_backend, nil)
    end
end

-- Local llama FIM implementation
function M._local_fim_complete(prefix, suffix, callback, opts)
    local url = string.format(
        "http://%s:%d/infill",
        config.get("llama_server.host"),
        config.get("llama_server.port")
    )

    local body = {
        prompt         = "",
        input_prefix   = prefix or "",
        input_suffix   = suffix or "",
        n_predict      = opts.max_tokens or config.get("fim.max_tokens") or 64,
        temperature    = opts.temperature or config.get("fim.temperature") or 0.0,
        top_p          = opts.top_p or config.get("fim.top_p") or 0.9,
        top_k          = opts.top_k or config.get("fim.top_k") or 40,
        repeat_penalty = opts.repeat_penalty or config.get("fim.repeat_penalty") or 1.1,
        stop           = opts.stop or config.get("fim.stop_sequences") or { "```" },
        model          = config.get("models.fim"),
    }

    http.post(url, body, function(err, response)
        if err then
            callback(err, nil)
            return
        end

        if type(response) ~= "table" then
            callback("Invalid response type: " .. type(response), nil)
            return
        end

        local text = response.content
        if type(text) ~= "string" or text == "" then
            callback(nil, "")
            return
        end
        callback(nil, text)
    end)
end

-- DeepSeek FIM implementation using proper FIM endpoint
function M._deepseek_fim_complete(prefix, suffix, callback, opts)
    local api_key = M.get_api_key()
    if not api_key then
        callback("DeepSeek API key not available", nil)
        return
    end

    -- Use the beta endpoint for FIM completion
    local base_url = config.get("backend.deepseek.beta_base_url") or "https://api.deepseek.com/beta"
    local url = base_url .. "/completions"
    
    local body = {
        model = config.get("backend.deepseek.models.fim") or "deepseek-coder",
        prompt = prefix,
        suffix = suffix,
        max_tokens = opts.max_tokens or config.get("fim.deepseek_fim.max_tokens") or config.get("fim.max_tokens") or 64,
        temperature = opts.temperature or config.get("fim.deepseek_fim.temperature") or config.get("fim.temperature") or 0.0,
        top_p = opts.top_p or config.get("fim.deepseek_fim.top_p") or config.get("fim.top_p") or 0.9,
        stream = false,
    }

    local headers = {
        "Authorization: Bearer " .. api_key,
        "Content-Type: application/json",
    }

    http.post(url, body, function(err, response)
        if err then
            callback(err, nil)
            return
        end

        if type(response) ~= "table" then
            callback("Invalid response type: " .. type(response), nil)
            return
        end

        if response.error then
            callback("DeepSeek API error: " .. (response.error.message or "Unknown error"), nil)
            return
        end

        local text = ""
        if response.choices and response.choices[1] then
            text = response.choices[1].text or ""
        end

        -- Clean up the response - remove any markdown code blocks and trim whitespace
        text = text:gsub("^```[%w]*\n", ""):gsub("\n```$", "")
        text = text:gsub("^`", ""):gsub("`$", "")
        text = text:gsub("^%s+", ""):gsub("%s+$", "")
        
        callback(nil, text)
    end, { headers = headers })
end

-- Local llama chat implementation
function M._local_chat_complete(messages, callback, opts)
    local url = string.format(
        "http://%s:%d/v1/chat/completions",
        config.get("llama_server.host"),
        config.get("llama_server.port")
    )

    local body = {
        messages = messages,
        max_tokens = opts.max_tokens or config.get("chat.max_tokens") or 512,
        temperature = opts.temperature or config.get("chat.temperature") or 0.7,
        model = config.get("models.chat"),
        stream = opts.stream or true,
    }

    http.post(url, body, callback)
end

-- DeepSeek chat implementation
function M._deepseek_chat_complete(messages, callback, opts)
    local api_key = M.get_api_key()
    if not api_key then
        callback("DeepSeek API key not available", nil)
        return
    end

    local base_url = config.get("backend.deepseek.base_url") or "https://api.deepseek.com"
    local url = base_url .. "/v1/chat/completions"

    local body = {
        model = config.get("backend.deepseek.models.chat") or "deepseek-chat",
        messages = messages,
        max_tokens = opts.max_tokens or config.get("chat.deepseek_chat.max_tokens") or config.get("chat.max_tokens") or 4096,
        temperature = opts.temperature or config.get("chat.deepseek_chat.temperature") or config.get("chat.temperature") or 0.7,
        frequency_penalty = config.get("chat.deepseek_chat.frequency_penalty") or 0.1,
        presence_penalty = config.get("chat.deepseek_chat.presence_penalty") or 0.1,
        stream = opts.stream or true,
    }

    local headers = {
        "Authorization: Bearer " .. api_key,
        "Content-Type: application/json",
    }

    http.post(url, body, function(err, response)
        if err then
            -- Sanitize error messages
            local sanitized_err = err:gsub("Bearer%s+[%w%-_]+", "Bearer [REDACTED]")
            callback(sanitized_err, nil)
            return
        end
        
        callback(nil, response)
    end, { headers = headers, timeout = config.get("backend.deepseek.timeout") or 30000 })
end

-- Initialize on module load
M.init()

return M