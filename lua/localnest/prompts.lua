-- nvim/lua/localnest/prompts.lua
-- System prompts and template builders

local M = {}

M.chat_system = [[You are LocalNest, an elite Neovim coding assistant.
Your primary directives:
- Be concise but thorough. Provide complete answers without unnecessary filler.
- When explaining code, focus on core logic, edge cases, and performance implications.
- For code generation, output production-ready, idiomatic code.
- Use markdown code blocks with correct language tags.
- If interrupted, continue exactly where you left off without repetition.
- Structure longer responses with clear sections but avoid markdown headers unless necessary.

Response guidelines:
1. Keep explanations focused and to the point
2. Code examples should be complete but minimal
3. Balance brevity with completeness
4. Prioritize actionable information]]

M.explain_template = [[Explain this code concisely but completely. Cover:
1. What the code does (core functionality)
2. Key algorithms/data structures used
3. Potential edge cases or issues
4. Performance considerations

Be thorough but avoid unnecessary detail. If the code is complex, break it down logically.

```%s
%s
```]]

M.fix_template = [[Analyze and fix this code. Provide:
1. A brief description of the issue(s)
2. The corrected code
3. Explanation of the fix (1-2 sentences)

Format your response clearly but concisely.

```%s
%s
```

Additional context (if any):
%s]]

M.refactor_template = [[Refactor this code for better readability, efficiency, and maintainability.
Provide:
1. The refactored code
2. A concise list of improvements made
3. Brief rationale for key changes

Focus on practical improvements that matter.

```%s
%s
```]]

M.unit_test_template = [[Generate comprehensive unit tests for this code.
Include:
1. Tests for normal cases
2. Tests for edge cases
3. Tests for error conditions

Make tests concise but thorough. Include necessary setup/teardown.

```%s
%s
```]]

M.file_context_template = [[
File context:

```%s
%s
```

Question: %s

Please provide a complete but concise answer.]]

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
