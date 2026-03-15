-- nvim/lua/localnest/keymaps.lua
-- Key mappings for LocalNest AI features

local M = {}

local function setup_keymaps()
    local opts = { noremap = true, silent = true }
    
    -- FIM (Fill-in-the-Middle) completion
    vim.keymap.set("i", "<C-Space>", function()
        require("localnest.fim").trigger_manual()
    end, opts)
    
    vim.keymap.set("n", "<leader>af", function()
        require("localnest.fim").trigger_manual()
    end, { desc = "AI FIM completion" })
    
    -- Toggle FIM auto-completion
    vim.keymap.set("n", "<leader>at", function()
        require("localnest.fim").toggle()
    end, { desc = "Toggle AI FIM auto-completion" })
    
    -- Accept FIM suggestion
    vim.keymap.set("i", "<Tab>", function()
        local fim = require("localnest.fim")
        if fim.state and fim.state.bufnr and vim.api.nvim_buf_is_valid(fim.state.bufnr) then
            fim.accept()
            return
        end
        -- Fallback to normal Tab behavior
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
    end, opts)
    
    -- Dismiss FIM suggestion
    vim.keymap.set("i", "<Esc>", function()
        local fim = require("localnest.fim")
        if fim.state and fim.state.bufnr and vim.api.nvim_buf_is_valid(fim.state.bufnr) then
            fim.dismiss()
            return
        end
        -- Fallback to normal Esc behavior
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end, opts)
    
    -- Chat interface
    vim.keymap.set("n", "<leader>ac", function()
        vim.ui.input({ prompt = "Ask LocalNest AI: " }, function(input)
            if input and input ~= "" then
                require("localnest.chat").ask(input)
            end
        end)
    end, { desc = "AI Chat" })
    
    -- Chat with selected text
    vim.keymap.set("v", "<leader>ac", function()
        require("localnest.chat").ask_on_selection()
    end, { desc = "AI Chat with selection" })
    
    -- Chat about current file
    vim.keymap.set("n", "<leader>af", function()
        require("localnest.chat").ask_on_file()
    end, { desc = "AI Chat about file" })
    
    -- Slash commands
    vim.keymap.set("n", "<leader>ae", function()
        require("localnest.chat").slash("explain")
    end, { desc = "AI Explain code" })
    
    vim.keymap.set("n", "<leader>ax", function()
        require("localnest.chat").slash("fix")
    end, { desc = "AI Fix code" })
    
    vim.keymap.set("n", "<leader>ar", function()
        require("localnest.chat").slash("refactor")
    end, { desc = "AI Refactor code" })
    
    vim.keymap.set("n", "<leader>at", function()
        require("localnest.chat").slash("test")
    end, { desc = "AI Generate tests" })
    
    -- Backend management
    vim.keymap.set("n", "<leader>ab", function()
        vim.cmd("LocalNestSwitchBackend")
    end, { desc = "Switch AI backend" })
    
    vim.keymap.set("n", "<leader>as", function()
        vim.cmd("LocalNestBackendStatus")
    end, { desc = "Show AI backend status" })
    
    -- Clear chat history
    vim.keymap.set("n", "<leader>ah", function()
        require("localnest.chat").clear_history()
    end, { desc = "Clear AI chat history" })
end

function M.setup()
    setup_keymaps()
    
    -- Create user commands for easier access
    vim.api.nvim_create_user_command("LocalNestFIM", function()
        require("localnest.fim").trigger_manual()
    end, {})
    
    vim.api.nvim_create_user_command("LocalNestChat", function(opts)
        if opts.args and opts.args ~= "" then
            require("localnest.chat").ask(opts.args)
        else
            vim.ui.input({ prompt = "Ask LocalNest AI: " }, function(input)
                if input and input ~= "" then
                    require("localnest.chat").ask(input)
                end
            end)
        end
    end, { nargs = "?" })
    
    vim.api.nvim_create_user_command("LocalNestExplain", function()
        require("localnest.chat").slash("explain")
    end, {})
    
    vim.api.nvim_create_user_command("LocalNestFix", function()
        require("localnest.chat").slash("fix")
    end, {})
    
    vim.api.nvim_create_user_command("LocalNestRefactor", function()
        require("localnest.chat").slash("refactor")
    end, {})
    
    vim.api.nvim_create_user_command("LocalNestTest", function()
        require("localnest.chat").slash("test")
    end, {})
    
    vim.api.nvim_create_user_command("LocalNestToggleFIM", function()
        require("localnest.fim").toggle()
    end, {})
end

return M