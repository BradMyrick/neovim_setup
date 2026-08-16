require('telescope').setup {
    defaults = {
      prompt_prefix = '🔍 ',
      selection_caret = '➤ ',
      path_display = {'smart'},
      mappings = {
        i = {
          ['<C-j>'] = require('telescope.actions').move_selection_next,
          ['<C-k>'] = require('telescope.actions').move_selection_previous,
        },
      },
    },
  }
  
  -- Load Telescope extensions
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('projects')
  