local m = {}

m.jump_to_closest_block = function()
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_lua_row = current_row - 1 -- Adjust for 0-indexed Lua nodes

  local current_node = ts_utils.get_node_at_cursor()

  if not current_node then
    print 'No treesitter node at cursor.'
    return
  end

  local block_types = {
    'if_statement',
    'elif_clause',
    'else_clause',
    'function_definition',
    'class_definition',
    'for_statement',
    'while_statement',
    'try_statement',
    'with_statement',
    -- Add other statement types that define a new block
    -- E.g., for Go: 'function_declaration', 'if_statement', 'for_statement', 'type_declaration' (for struct/interface)
    -- E.g., for JS: 'function_declaration', 'class_declaration', 'if_statement', 'for_statement', 'while_statement', 'switch_statement'
  }

  local node_to_jump_to = nil
  local node = current_node

  -- Step 1: Determine the "reference" node to start searching from.
  -- If the current node is an expression *inside* a block (e.g., 'print("tanmay")'),
  -- we want to find its *containing* block-defining parent.
  -- If we're already at the start of a block, we want to skip it and go to its parent.

  local reference_node = current_node
  local current_node_start_row, current_node_start_col = current_node:start()

  -- Check if the current node itself is a block-defining type AND we are at its very start.
  local at_start_of_defining_block = false
  for _, block_type in ipairs(block_types) do
    if current_node:type() == block_type then
      if current_node_start_row == current_lua_row and current_node_start_col == current_col then
        at_start_of_defining_block = true
        break
      end
    end
  end

  if at_start_of_defining_block then
    -- If we are exactly at the start of a block-defining statement (e.g., 'if' keyword),
    -- we want to go to its *parent* block. So, start searching from its parent.
    reference_node = current_node:parent()
  else
    -- If we are *inside* a block (e.g., on 'print("tanmay")'),
    -- or if the current node is not a block-defining type,
    -- then we want to find the *first enclosing* block.
    -- We start searching from the current node itself.
    -- No change to reference_node, it remains current_node.
  end

  -- Step 2: Traverse upwards from the reference_node to find the first *enclosing* block of any of the specified types.
  node = reference_node
  while node do
    for _, block_type in ipairs(block_types) do
      if node:type() == block_type then
        node_to_jump_to = node
        goto found_block
      end
    end
    node = node:parent()
  end

  ::found_block:: -- Lua label for goto statement

  if node_to_jump_to then
    local start_row, start_col = node_to_jump_to:start()
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  else
    print 'No enclosing code block found.'
  end
end

return m
