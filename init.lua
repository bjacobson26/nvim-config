-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.termguicolors = true

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set colorcolumn=120")
vim.cmd("set clipboard=unnamedplus")
vim.g.mapleader = ","

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
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" }
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
      require("nvim-tree").setup({})
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rspec")
        },
        ouput = { enabled = true, open_on_run = true },
      })
    end
  },
  {
    "github/copilot.vim",
    version = "*"
  },
  {
    'f-person/git-blame.nvim'
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  { 'shaunsingh/nord.nvim' },
  {
    "xero/miasma.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme miasma")
    end
  },
  { 'rktjmp/lush.nvim' }
}

require("lazy").setup(plugins, {})

require("codetime").initialize()

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "ruby", "typescript", "javascript", "json", "yaml", "html", "css" },
  highlight = {
    enable = true
  }
}

local telescope = require("telescope")
telescope.setup {
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

local builtin = require("telescope.builtin")

-- find files
vim.keymap.set('n', '<C-p>', builtin.find_files, {})

-- search in files
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})

-- toggle nvim-tree
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeToggle<CR>', {noremap = true, silent = true})

-- run tests with neotest
vim.api.nvim_set_keymap('n', '<leader>t', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', {noremap = true, silent = true})

-- pretty print json with :%!jq
vim.api.nvim_set_keymap('n', '<leader>j', ':%!jq<CR>', {noremap = true, silent = true})

-- find file in nvim-tree
vim.api.nvim_set_keymap('n', '<leader>m', ':NvimTreeFindFile<CR>', {noremap = true, silent = true})

-- copy file path to clipboard
vim.api.nvim_set_keymap('n', '<leader>l', [[:lua vim.fn.setreg('+', vim.fn.expand('%:p'))<CR>]], { noremap = true, silent = true })

-- run rspec in terminal
vim.api.nvim_set_keymap('n', '<leader>p', ':terminal bundle exec rspec %<CR>', {noremap = true})
