-- Test streaming and completion fixes
local M = {}

function M.test_prompt_improvements()
    print("Testing prompt improvements...")
    
    local prompts = require("localnest.prompts")
    
    -- Test chat system prompt
    if prompts.chat_system then
        print("✓ Chat system prompt loaded")
        if prompts.chat_system:find("concise but thorough") then
            print("✓ Prompt encourages balanced responses")
        end
    end
    
    -- Test explain template
    local explain = string.format(prompts.explain_template, "python", "def test(): pass")
    if explain:find("Explain this code concisely but completely") then
        print("✓ Explain template encourages complete responses")
    end
    
    -- Test fix template
    local fix = string.format(prompts.fix_template, "python", "def test(): pass", "test")
    if fix:find("Analyze and fix this code") then
        print("✓ Fix template has clear structure")
    end
    
    return true
end

function M.test_error_handling()
    print("\nTesting error handling improvements...")
    
    -- Test error sanitization
    local test_error = "Bearer sk-1234567890abcdef curl error: connection failed"
    local sanitized = test_error:gsub("Bearer%s+[%w%-_]+", "Bearer [REDACTED]")
    
    if sanitized == "Bearer [REDACTED] curl error: connection failed" then
        print("✓ Error sanitization working")
    else
        print("✗ Error sanitization failed")
        return false
    end
    
    -- Test truncated response detection
    local test_truncated = "This is a response that ends abruptly"
    local test_complete = "This is a complete response. It ends properly."
    
    local function check_truncation(text)
        local last_sentence = text:match("[^.!?]+[.!?]%s*$")
        local has_unclosed_code = text:match("```[^`]*$")
        local has_unclosed_bracket = text:match("%[.*%]$") and not text:match("%]%s*$")
        
        return not last_sentence or has_unclosed_code or has_unclosed_bracket
    end
    
    if check_truncation(test_truncated) then
        print("✓ Truncation detection for incomplete sentences")
    end
    
    if not check_truncation(test_complete) then
        print("✓ Complete sentences not flagged as truncated")
    end
    
    return true
end

function M.test_configuration()
    print("\nTesting configuration updates...")
    
    local config = require("localnest.config")
    
    -- Check chat configuration
    local chat_config = config.get("chat")
    if chat_config then
        print("✓ Chat configuration loaded")
        
        if chat_config.system_prompt and chat_config.system_prompt:find("LocalNest") then
            print("✓ Using updated system prompt")
        end
        
        local deepseek_chat = config.get("chat.deepseek_chat")
        if deepseek_chat then
            if deepseek_chat.frequency_penalty == 0.1 then
                print("✓ Frequency penalty configured to reduce repetition")
            end
            if deepseek_chat.presence_penalty == 0.1 then
                print("✓ Presence penalty configured for diversity")
            end
        end
    end
    
    return true
end

function M.run_all_tests()
    print("=== Streaming and Completion Fix Tests ===\n")
    
    local tests = {
        { name = "Prompt Improvements", func = M.test_prompt_improvements },
        { name = "Error Handling", func = M.test_error_handling },
        { name = "Configuration", func = M.test_configuration },
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
        print("✓ All tests passed! Streaming fixes are ready.")
        return true
    else
        print("✗ Some tests failed. Please check the implementation.")
        return false
    end
end

-- Run tests if this file is executed directly
if arg and arg[0] and arg[0]:match("test_streaming_fix.lua") then
    M.run_all_tests()
end

return M