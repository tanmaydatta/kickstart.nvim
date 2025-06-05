return {
  setup = function()
    require('neoclip').setup({
      history = 100, -- Example history size
      enable_persistent_history = true,
      db_path = vim.fn.stdpath('data') .. '/neoclip.sqlite3', -- Standard path for data
      filter = nil,
      preview = true,
      default_register = '"',
      default_register_macros = 'qwertzuiopasdfghjklyxcvbnm',
      enable_macro_history = true,
      content_spec_column = false,
      on_paste = {
        set_reg = false,
      },
      on_replay = {
        set_reg = false,
      },
      keys = {
        telescope = {
          ['<cr>'] = require('neoclip.actions').paste_bytes_cr,
          ['<c-cr>'] = require('neoclip.actions').paste_bytes_close_telescope_cr,
          ['<esc>'] = require('neoclip.actions').close_telescope,
          ['<c-k>'] = require('neoclip.actions').move_selection_previous_from_telescope,
          ['<c-j>'] = require('neoclip.actions').move_selection_next_from_telescope,
          ['<c-q>'] = require('neoclip.actions').delete_entry_from_telescope,
          ['<c-p>'] = require('neoclip.actions').set_register_from_telescope,
        },
        fzf = {
          ['ctrl-x'] = require('neoclip.actions').delete_entry,
          ['ctrl-p'] = require('neoclip.actions').set_register,
          ['ctrl-v'] = require('neoclip.actions').paste_bytes,
          ['ctrl-c'] = require('neoclip.actions').close,
        }
      }
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>co', function()
      require('telescope').extensions.neoclip.default()
    end, { desc = 'Open Neoclip (Telescope)' })

    vim.keymap.set('n', '<leader>cp', '<Plug>(neoclip_paste_above)', { desc = 'Paste from Neoclip above' })
    vim.keymap.set('n', '<leader>cP', '<Plug>(neoclip_paste_below)', { desc = 'Paste from Neoclip below' })

  end,
}
