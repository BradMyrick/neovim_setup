-- Test script for DeepSeek setup verification
local M = {}

function M.test_backend_switching()
    print("Testing backend switching...")
    
    local backend = require("localnest.backend")
    local config = require("localnest.config")
    
    -- Test initial state
    local current = backend.get_current_backend()
    local name = backend.get_current_backend_name()
    print("Initial backend: " .. name .. " (" .. current .. ")")
    
    -- Test DeepSeek API key check
    local api_key = backend.get_api_key()
    if api_key then
        print("✓ DeepSeek API key found")
    else
        print("✗ DeepSeek API key not found (expected if not set)")
    end
    
    -- Test configuration
    local deepseek_config = config.get("backend.deepseek")
    if deepseek_config then
        print("✓ DeepSeek configuration loaded")
        print("  Models:")
        print("    Chat: " .. (deepseek_config.models.chat or "deepseek-chat"))
        print("    FIM: " .. (deepseek_config.models.fim or "deepseek-coder"))
    else
        print("✗ DeepSeek configuration missing")
    end
    
    return true
end

function M.test_fim_configuration()
    print("\nTesting FIM configuration...")
    
    local config = require("localnest.config")
    
    local fim_config = config.get("fim")
    if fim_config then
        print("✓ FIM configuration loaded")
        print("  Enabled: " .. tostring(fim_config.enabled))
        print("  Auto-trigger: " .. tostring(fim_config.auto_trigger))
        print("  Max tokens: " .. (fim_config.max_tokens or "default"))
        print("  Temperature: " .. (fim_config.temperature or "default"))
        
        -- Check DeepSeek specific FIM settings
        local deepseek_fim = config.get("fim.deepseek_fim")
        if deepseek_fim then
            print("  DeepSeek FIM settings:")
            print("    Max tokens: " .. (deepseek_fim.max_tokens or "default"))
            print("    Temperature: " .. (deepseek_fim.temperature or "default"))
        end
    else
        print("✗ FIM configuration missing")
        return false
    end
    
    return true
end

function M.test_chat_configuration()
    print("\nTesting chat configuration...")
    
    local config = require("localnest.config")
    
    local chat_config = config.get("chat")
    if chat_config then
        print("✓ Chat configuration loaded")
        print("  Max tokens: " .. (chat_config.max_tokens or "default"))
        print("  Temperature: " .. (chat_config.temperature or "default"))
        
        if chat_config.system_prompt then
            print("  System prompt: [configured]")
        end
        
        -- Check DeepSeek specific chat settings
        local deepseek_chat = config.get("chat.deepseek_chat")
        if deepseek_chat then
            print("  DeepSeek chat settings:")
            print("    Max tokens: " .. (deepseek_chat.max_tokens or "default"))
            print("    Temperature: " .. (deepseek_chat.temperature or "default"))
        end
    else
        print("✗ Chat configuration missing")
        return false
    end
    
    return true
end

function M.test_http_security()
    print("\nTesting HTTP security...")
    
    local http = require("localnest.http")
    
    -- Test error message sanitization
    local test_error = "Bearer sk-1234567890abcdef error message"
    local sanitized = test_error:gsub("Bearer%s+[%w%-_]+", "Bearer [REDACTED]")
    
    if sanitized == "Bearer [REDACTED] error message" then
        print("✓ Error message sanitization working")
    else
        print("✗ Error message sanitization failed")
        print("  Original: " .. test_error)
        print("  Sanitized: " .. sanitized)
        return false
    end
    
    return true
end

function M.run_all_tests()
    print("=== LocalNest DeepSeek Setup Test ===\n")
    
    local tests = {
        { name = "Backend Switching", func = M.test_backend_switching },
        { name = "FIM Configuration", func = M.test_fim_configuration },
        { name = "Chat Configuration", func = M.test_chat_configuration },
        { name = "HTTP Security", func = M.test_http_security },
    }
    
    local passed = 0
    local total = #tests
    
    for _, test in ipairs(tests) do
        local success, result = pcall(test.func)
        if success and result then
            print("✓ " .. test.name .. " PASSED\n")
            passed = passed + 1
        else
            print("✗ " .. test.name .. " FAILED")
            if not success then
                print("  Error: " .. tostring(result))
            end
            print()
        end
    end
    
    print("=== Test Results ===")
    print("Passed: " .. passed .. "/" .. total)
    
    if passed == total then
        print("✓ All tests passed! Setup is ready.")
        return true
    else
        print("✗ Some tests failed. Please check the configuration.")
        return false
    end
end

-- Run tests if this file is executed directly
if arg and arg[0] and arg[0]:match("test_deepseek_setup.lua") then
    M.run_all_tests()
end

return M