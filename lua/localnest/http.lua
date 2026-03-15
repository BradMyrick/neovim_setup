-- nvim/lua/localnest/http.lua

local M = {}

--- POST request with optional streaming using curl CLI
--- @param url string
--- @param body table
--- @param callback function(err, response) Called once for non-stream, or for each chunk/event if stream=true
--- @param opts table|nil
function M.post(url, body, callback, opts)
    opts = opts or {}
    local timeout = opts.timeout or 30000
    local stream = body.stream or false
    local headers = opts.headers or { "Content-Type: application/json" }

    local buffer = ""
    local full_response = ""

    -- Build curl command with headers
    local curl_cmd = { "curl", "-sN", "-X", "POST", url }
    for _, header in ipairs(headers) do
        table.insert(curl_cmd, "-H")
        table.insert(curl_cmd, header)
    end
    table.insert(curl_cmd, "-d")
    table.insert(curl_cmd, "@-")
    table.insert(curl_cmd, "--max-time")
    table.insert(curl_cmd, tostring(timeout / 1000))

    local job_id = vim.fn.jobstart(curl_cmd, {
        on_stdout = function(_, data)
            if not data then
                return
            end
            if not stream then
                full_response = full_response .. table.concat(data, "\n")
                return
            end

            -- Streaming logic
            for i, chunk in ipairs(data) do
                buffer = buffer .. chunk
                if i < #data then
                    -- We hit a newline
                    local line = vim.trim(buffer)
                    if line ~= "" then
                        local json_str = line:match("^data: (.*)$") or line
                        if json_str == "[DONE]" then
                            vim.schedule(function() callback(nil, nil) end)
                        else
                            local ok, decoded = pcall(vim.json.decode, json_str)
                            if ok then
                                vim.schedule(function() callback(nil, decoded) end)
                            end
                        end
                    end
                    buffer = ""
                end
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 then
                local error_msg = table.concat(data, "\n")
                -- Sanitize any API keys in error messages
                error_msg = error_msg:gsub("Bearer%s+[%w%-_]+", "Bearer [REDACTED]")
                vim.schedule(function() callback("curl error: " .. error_msg, nil) end)
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                vim.schedule(function() callback("curl exited with code: " .. exit_code, nil) end)
                return
            end
            
            if not stream then
                if full_response ~= "" then
                    local ok, decoded = pcall(vim.json.decode, full_response)
                    if ok then
                        vim.schedule(function() callback(nil, decoded) end)
                    else
                        -- Sanitize error messages to avoid leaking API keys
                        local sanitized_response = full_response:gsub("Bearer%s+[%w%-_]+", "Bearer [REDACTED]")
                        vim.schedule(function() callback("Failed to decode JSON response: " .. sanitized_response, nil) end)
                    end
                else
                    vim.schedule(function() callback("Empty response received", nil) end)
                end
            else
                -- Drain remaining buffer if any
                local line = vim.trim(buffer)
                if line ~= "" then
                    local json_str = line:match("^data:%s*(.*)$") or line
                    if json_str ~= "[DONE]" and json_str ~= "" then
                        local ok, decoded = pcall(vim.json.decode, json_str)
                        if ok then
                            vim.schedule(function() callback(nil, decoded) end)
                        end
                    end
                end
                -- Signal end of stream
                vim.schedule(function() callback(nil, nil) end)
            end
        end
    })

    if job_id > 0 then
        vim.fn.chansend(job_id, vim.json.encode(body))
        vim.fn.chanclose(job_id, "stdin")
    else
        callback("Failed to start curl", nil)
    end
end

return M
