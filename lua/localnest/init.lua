local M = {}

local config = require("localnest.config")
local fim = require("localnest.fim")
local chat = require("localnest.chat")
local backend = require("localnest.backend")
local keymaps = require("localnest.keymaps")

--- Main setup function
--- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  -- Merge user config
  config.setup(user_config or {})

  -- Setup highlight groups
  vim.api.nvim_set_hl(0, "LocalNestFimGhost", { fg = "#5c6370", italic = true, default = true })
  vim.api.nvim_set_hl(0, "LocalNestFimActive", { fg = "#98c379", italic = true, default = true })

  -- Setup auto-triggering
  fim.setup_autocmds()

  -- Setup keymaps
  keymaps.setup()

  -- Register commands
  vim.api.nvim_create_user_command("LocalNestFimManual", function()
    fim.trigger_manual()
  end, {})

  vim.api.nvim_create_user_command("LocalNestChatClear", function()
    chat.clear_history()
  end, {})

  vim.api.nvim_create_user_command("LocalNestSwitchBackend", function(opts)
    local backend_type = opts.args
    if backend_type == "" then
      -- Show backend selection UI
      vim.ui.select(
        { "local", "deepseek" },
        { prompt = "Select AI Backend:" },
        function(choice)
          if choice then
            backend.switch_backend(choice)
          end
        end
      )
    else
      backend.switch_backend(backend_type)
    end
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("LocalNestBackendStatus", function()
    local current = backend.get_current_backend()
    local name = backend.get_current_backend_name()
    local status = "Current backend: " .. name .. " (" .. current .. ")"
    
    -- Check API key status for DeepSeek
    if current == "deepseek" then
      local api_key = backend.get_api_key()
      if api_key then
        status = status .. " ✓ API key available"
      else
        status = status .. " ✗ API key missing"
      end
    end
    
    vim.notify(status, vim.log.levels.INFO)
  end, {})

  vim.notify("LocalNest AI plugin loaded (" .. backend.get_current_backend_name() .. ")", vim.log.levels.INFO)
end

-- Export modules for direct use from user config
M.fim = fim
M.chat = chat
M.config = config
M.backend = backend
M.keymaps = keymaps

return M
