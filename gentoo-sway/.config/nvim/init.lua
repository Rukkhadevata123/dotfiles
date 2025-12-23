-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keymaps
vim.keymap.set("n", "<leader>nh", ":nohl<CR>") -- Clear search highlights
vim.keymap.set("n", "<leader>sv", "<C-w>v")    -- Split vertical
vim.keymap.set("n", "<leader>sh", "<C-w>s")    -- Split horizontal

-- Options
local opt = vim.opt

opt.compatible = false               -- Disable compatibility with vi
opt.spell = true                     -- Enable spell check
opt.spelllang = { 'en_us' }          -- Spell check language
opt.showmatch = true                 -- Show matching brackets
opt.ignorecase = true                -- Ignore case in search
opt.smartcase = true                 -- Smart case search
opt.hlsearch = true                  -- Highlight search results
opt.incsearch = true                 -- Incremental search
opt.mouse = "a"                      -- Enable mouse support

opt.tabstop = 4                      -- Tab width
opt.softtabstop = 4                  -- Soft tab width
opt.shiftwidth = 4                   -- Shift width
opt.expandtab = true                 -- Use spaces instead of tabs
opt.autoindent = true                -- Auto indent

opt.number = true                    -- Show line numbers
opt.relativenumber = true            -- Relative line numbers
opt.splitright = true                -- Split windows to the right
opt.splitbelow = true                -- Split windows below
opt.cursorline = true                -- Highlight current line
opt.wrap = false                     -- Disable line wrapping
opt.termguicolors = true             -- True color support
opt.signcolumn = "yes"               -- Always show sign column

opt.clipboard = "unnamedplus"        -- Use system clipboard

vim.cmd("filetype plugin indent on") -- Enable filetype detection


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here

    -- buffer line
    {
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = function(_, opts)
        vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'Next buffer', silent = true })
        vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Previous buffer', silent = true })
      end,
    },

    -- toggleterm
    {
      'akinsho/toggleterm.nvim',
      version = "*",
      opts = function(_, opts)
        function _G.set_terminal_keymaps()
          local opts = { buffer = 0 }
          vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        end

        vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

        local keymap = vim.keymap.set

        keymap('n', '<c-t>', '<cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })
        keymap('n', '<leader>tf', '<cmd>ToggleTerm direction=float<CR>', { desc = 'Float terminal' })
        keymap('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<CR>', { desc = 'Horizontal terminal' })
        keymap('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical size=80<CR>', { desc = 'Vertical terminal' })
      end,
    },

    -- colorscheme plugin
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
      config = function()
        vim.cmd([[colorscheme tokyonight-storm]])
      end,
    },

    -- startup screen
    {
      "goolord/alpha-nvim",
      config = function()
        require("alpha").setup(require("alpha.themes.dashboard").config)
      end,
    },

    -- gitsigns
    {
      "lewis6991/gitsigns.nvim",
      opts = {},
    },

    -- completion
    {
      "hrsh7th/nvim-cmp",
      event = { "InsertEnter", "CmdlineEnter" },
      dependencies = {
        "hrsh7th/cmp-buffer",  -- word source for buffer
        "hrsh7th/cmp-path",    -- path sources
        "hrsh7th/cmp-cmdline", -- cmdline source
      },
      config = function()
        local cmp = require("cmp")

        cmp.setup({
          -- Keymaps
          mapping = cmp.mapping.preset.insert({
            ["<C-k>"] = cmp.mapping.select_prev_item(),        -- previous suggestions
            ["<C-j>"] = cmp.mapping.select_next_item(),        -- next suggestions
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),           -- scroll up docs
            ["<C-f>"] = cmp.mapping.scroll_docs(4),            -- scroll down docs
            ["<C-Space>"] = cmp.mapping.complete(),            -- manually trigger completion
            ["<C-e>"] = cmp.mapping.abort(),                   -- close completion window
            ["<CR>"] = cmp.mapping.confirm({ select = true }), -- confirm selection
          }),
          -- Sources for insert mode
          sources = cmp.config.sources({
            { name = "path" },   -- path source first
          }, {
            { name = "buffer" }, -- then buffer source
          }),
        })

        -- Search mode configuration (using buffer content)
        cmp.setup.cmdline({ "/", "?" }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" }
          }
        })

        -- Command line mode configuration (using path and cmdline)
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" }
          }, {
            { name = "cmdline" }
          }),
          matching = { disallow_symbol_nonprefix_matching = false }
        })
      end,
    },

    -- indent
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      ---@module "ibl"
      ---@type ibl.config
      opts = {},
    },

    -- markdown rendering
    {
      'MeanderingProgrammer/render-markdown.nvim',
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {},
    },

    -- lualine
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
      opts = { options = { theme = 'gruvbox' } }
    },

    -- telescope
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
      },
      config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        telescope.setup({
          extensions = {
            ["ui-select"] = {
              require("telescope.themes").get_dropdown()
            }
          }
        })

        telescope.load_extension("ui-select")

        local keymap = vim.keymap.set

        keymap('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
        keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
        keymap('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
        keymap('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })

        keymap('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
        keymap('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
        keymap('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
        keymap('n', '<leader>fs', builtin.grep_string, { desc = 'Grep string under cursor' })

        keymap('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
        keymap('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
        keymap('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })

        keymap('n', '<leader>lr', builtin.lsp_references, { desc = 'LSP references' })
        keymap('n', '<leader>ld', builtin.lsp_definitions, { desc = 'LSP definitions' })
        keymap('n', '<leader>ls', builtin.lsp_document_symbols, { desc = 'Document symbols' })
        keymap('n', '<leader>lw', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })
      end,
    },

    -- tree
    {
      "nvim-tree/nvim-tree.lua",
      opts = function(_, opts)
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
        vim.keymap.set('n', '<leader>ef', '<cmd>NvimTreeFindFile<CR>', { desc = 'Find current file in tree' })
        vim.keymap.set('n', '<leader>er', '<cmd>NvimTreeRefresh<CR>', { desc = 'Refresh file tree' })
        vim.keymap.set('n', '<leader>ec', '<cmd>NvimTreeCollapse<CR>', { desc = 'Collapse file tree' })
      end,
    },

    -- treesitter

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      branch = 'master',
      lazy = false,
      opts = {
        ensure_installed = {
          "java", "cpp", "c", "lua", "go", "bash", "python", "rust",
          "javascript", "typescript", "html", "css", "json", "yaml",
          "markdown", "cmake", "ruby", "php", "vimdoc", "kotlin", "perl",
          "r", "dart", "scala", "haskell", "elixir", "erlang",
          "markdown_inline", "query", "regex", "tsx", "vim", "dockerfile",
          "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes",
          "gomod", "gowork", "gosum", "json5", "c_sharp"
        },
        auto_install = true,
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter-context",
      opts = {
        enable = true,
      },
    },


    -- notify
    {
      "rcarriga/nvim-notify",
      opts = {},
      config = function()
        vim.notify = require("notify")
      end,
    },

    -- illuminate
    {
      "RRethy/vim-illuminate",
    },

    -- auto pairs
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true
      -- use opts = {} for passing setup options
      -- this is equivalent to setup({}) function
    },

  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
