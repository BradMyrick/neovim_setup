-- nvim/lua/localnest/prompts.lua
-- System prompts and template builders

local M = {}

M.chat_system = [[You are LocalNest, an elite, hyper-concise Neovim coding assistant.
Your primary directives:
- Output only valid, production-ready code.
- Omit conversational filler (e.g., "Here is the code", "Let me know if you need help").
- When asked to explain, focus strictly on core logic, edge cases, and performance.
- Use standard markdown for code blocks with the correct language tags.
- If a conversation is continued after a cutoff, resume exactly where you left off.

If tool execution is required, output ONLY the following format and nothing else:
<tool_call>
{"name": "tool_name", "arguments": {"arg1": "val1"}}
</tool_call>]]

M.explain_template = [[Explain this code with maximum brevity. Highlight MUST-KNOW logic and potential bugs/bottlenecks.

```%s
%s
```]]

M.fix_template = [[Identify the bugs in the following code and provide the corrected version. 
Return ONLY the fixed code block and a 1-2 sentence explanation of the fix.

```%s
%s
```

Context/Error:
%s]]

M.refactor_template = [[Refactor the following code for maximum readability, efficiency, and idiomatic practices.
Return ONLY the refactored code block and a bulleted list of the specific changes made.

```%s
%s
```]]

M.unit_test_template = [[Generate concise, comprehensive unit tests covering standard and edge cases for the following code.
Return ONLY the test code block.

```%s
%s
```]]

M.file_context_template = [[
Here is the full file context:

```%s
%s
```

Question: %s]]

--- Build a chat prompt with system and messages
function M.build_chat_prompt(system_prompt, messages)
  return {
    system = system_prompt,
    messages = messages,
  }
end

--- Build a FIM prompt with prefix/suffix (PSM Format)
function M.build_fim_prompt(prefix, suffix)
  -- Standard PSM (Prefix-Suffix-Middle) token structure for Qwen/StarCoder/Llama
  local fim_prefix = "<|fim_prefix|>"
  local fim_middle = "<|fim_middle|>"
  local fim_suffix = "<|fim_suffix|>"

  -- The model receives the prefix, then the suffix, and is prompted to generate the middle.
  return fim_prefix .. prefix .. fim_suffix .. suffix .. fim_middle
end

return M
