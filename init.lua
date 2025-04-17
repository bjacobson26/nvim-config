-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set clipboard=unnamedplus")

-- set mapleader to space
vim.g.mapleader = " "

vim.opt.relativenumber = true
vim.opt.number = true

-- open tab using <C-M>
vim.api.nvim_set_keymap('n', '<C-M>', '<C-T>', { noremap = true, silent = true })

vim.opt.signcolumn = "yes"
vim.api.nvim_create_autocmd("FileType", {
  pattern = "ruby",
  callback = function()
    vim.lsp.start {
      name = "rubocop",
      cmd = { "bundle", "exec", "rubocop", "--lsp" },
    }
  end,
})

-- Trim trailing whitespace on save
vim.cmd [[autocmd BufWritePre * %s/\s\+$//e]]

-- Automatically remove multiple trailing newlines before saving
vim.cmd [[autocmd BufWritePre * silent! %s/\(\n\s*\)\+\%$//e]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd("colorscheme kanagawa")
    end
  },
  { 'numToStr/Comment.nvim' },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = {
      "nvim-lua/plenary.nvim"
    }
  },
  {
    "3rd/image.nvim",
    opts = {}
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        view = { adaptive_size = true }
      })
    end,
  },
  {
    "github/copilot.vim",
    version = "*"
  },
  {
    'f-person/git-blame.nvim'
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  { "mogulla3/rspec.nvim" },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  }
}

require("lazy").setup(plugins, {})

require('Comment').setup()

require('rspec').setup()

require("codecompanion").setup({
  strategies = {
    chat = { adapter = "copilot" },
    inline = { adapter = "copilot" }
  }
})

local codetime = require('codetime')
codetime.initialize()

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = {'encoding', 'fileformat', 'filetype', codetime.current_code_time },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "ruby", "typescript", "javascript", "json", "yaml", "html", "css" },
  highlight = {
    enable = true
  },
  fold = { enable = true }
}

-- Enable Treesitter-based folding
require'nvim-treesitter.configs'.setup {
  highlight = { enable = true },
  indent = { enable = true },
  fold = {
    enable = true,
  },
}

-- Set foldmethod to 'expr' for Treesitter folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- Disable auto-folding by default when opening files
vim.opt.foldlevelstart = 99  -- This ensures that all folds are open when you open a file

local telescope = require("telescope")
telescope.setup {
  defaults = {
    file_ignore_patterns = { ".git/" },
  },
  pickers = {
    find_files = {
      find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
    },
    grep_string = {
      additional_args = {'--hidden'}
    },
    live_grep = {
      additional_args = {'--hidden'}
    }
  }
}


-- Harpoon
local harpoon = require('harpoon')
harpoon:setup()
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- Telescope
local builtin = require("telescope.builtin")
-- find files
vim.keymap.set('n', '<leader>p', builtin.find_files, {})

-- search in files
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})

-- toggle nvim-tree
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeToggle<CR>', {noremap = true, silent = true})

-- find file in nvim-tree
vim.api.nvim_set_keymap('n', '<leader>m', ':NvimTreeFindFile<CR>', {noremap = true, silent = true})

-- copy file path to clipboard
vim.api.nvim_set_keymap('n', '<leader>l', [[:lua vim.fn.setreg('+', vim.fn.expand('%:p'))<CR>]], { noremap = true, silent = true })

-- open new file
vim.api.nvim_set_keymap('n', '<leader>nf', ':enew<CR>', { noremap = true, silent = true })

-- RSpec
vim.keymap.set("n", "<leader>rn", ":RSpecNearest<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rf", ":RSpecCurrentFile<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", ":RSpecRerun<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rF", ":RSpecOnlyFailures<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rs", ":RSpecShowLastResult<CR>", { noremap = true, silent = true })
