return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cmd = 'FzfLua',
  keys = {
    {
      '<leader>ff',
      function()
        require('fzf-lua').files()
      end,
      desc = 'Find files',
    },
    {
      '<C-p>',
      function()
        require('fzf-lua').files()
      end,
      desc = 'Find files',
    },
    {
      '<leader>fg',
      function()
        require('fzf-lua').live_grep()
      end,
      desc = 'Live grep',
    },
    {
      '<leader>fb',
      function()
        require('fzf-lua').buffers()
      end,
      desc = 'Find buffers',
    },
    {
      '<leader>fo',
      function()
        require('fzf-lua').oldfiles()
      end,
      desc = 'Find recent files',
    },
  },
  opts = function()
    return {
      'telescope',
      actions = { files = { true, ['ctrl-x'] = require('fzf-lua.actions').file_split } },
      grep = {
        hidden = true,
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob=!.git -e',
      },
      winopts = {
        height = 0.85,
        width = 0.85,
        row = 0.5,
        col = 0.5,
      },
    }
  end,
}
