-- Basic settings
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.mapleader = " "

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Display settings
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:4"

-- Scrolling and UI settings
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.wrap = false
vim.opt.sidescrolloff = 32
vim.opt.scrolloff = 16

-- Persist undo (persists your undo history between sessions)
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

-- Tab stuff
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Search configuration
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

-- Open new split panes to right and below (as you probably expect)
vim.opt.splitright = true
vim.opt.splitbelow = true

-- LSP
vim.lsp.inlay_hint.enable(false)

-- fix eol on save
vim.opt.fixeol = false

local plugins = {
  { "nvim-lua/plenary.nvim" },                                       -- used by other plugins
  { "nvim-tree/nvim-web-devicons" },                                 -- used by other plugins
  { "Shatur/neovim-session-manager" },                               -- used by other plugins
  { "MunifTanjim/nui.nvim" },                                        -- used by other plugins

  { "nvim-neo-tree/neo-tree.nvim" },                                 -- file browser
  { "ibhagwan/fzf-lua" },                                            -- fzf
  { "nvim-treesitter/nvim-treesitter",        build = ":TSUpdate" }, -- treesitter
  { "nvim-treesitter/nvim-treesitter-context" },                     -- show context of current function at top of window

  { 'mason-org/mason.nvim' },                                        -- installs LSP servers
  { 'neovim/nvim-lspconfig' },                                       -- configures LSPs
  { 'mason-org/mason-lspconfig.nvim' },                              -- links the two above

  { "folke/which-key.nvim" },                                        -- Keymaps
  { "lewis6991/gitsigns.nvim" },                                     -- Gitsigns
  { "coffebar/neovim-project" },                                     -- Manage projects
  { "lukas-reineke/indent-blankline.nvim" },                         -- indent guides
  { "petertriho/nvim-scrollbar" },                                   -- scrollbar
  { "RRethy/vim-illuminate" },                                       -- highlight other uses of word under cursor
  { "nvim-mini/mini.statusline" },                                   -- statusline
  { "akinsho/toggleterm.nvim" },                                     -- terminal

  { "OXY2DEV/markview.nvim" },                                       -- markdown previewer

  { "rebelot/kanagawa.nvim" },                                       -- colorscheme
  { "sainnhe/gruvbox-material" },                                    -- colorscheme
  { "ClearAspect/onehalf" },                                         -- colorscheme

  -- Autocomplete engine (LSP, snippets etc)
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
      keymap = { preset = 'super-tab' },
      completion = { documentation = { auto_show = true } },
      cmdline = {
        keymap = { preset = 'inherit' },
        completion = { menu = { auto_show = true } },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- AI - Copilot autocomplete
  { "github/copilot.vim" },
}

-- Lazy package manager setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configurations
require("lazy").setup(plugins)
require("neo-tree").setup({ -- tree file browser
  -- add options here
  popup_border_style = "rounded",
  use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes instead of relying on nvim autocmd events.
  window = {
    position = "float",
  },
  filesystem = {
    filtered_items = {
      visible = true, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false, -- only works on Windows for hidden files/directories
    }
  }
})

require('fzf-lua').setup({
  grep = {
    -- append --ignorefile
    rg_opts =
    "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --ignore-file=$HOME/.rgglobalignore",
  }
})                                      -- fzf
require('fzf-lua').register_ui_select() -- use fzf for vim.ui.select
require("toggleterm").setup {
  direction = 'float',
  shell = vim.o.shell .. " -l"
}
require('mini.statusline').setup()
require('gitsigns').setup { sign_priority = 100 } -- gitsigns
require("scrollbar").setup()                      -- scrollbar
require("scrollbar.handlers.gitsigns").setup()    -- gitsigns integration for scrollbar
require("ibl").setup()                            -- indent guides
require("nvim-treesitter").setup({                -- treesitter
  ensure_installed = {
    "lua",
    "bash",
    "go",
    "yaml",
    "helm",
    "json",
    "markdown",
    "markdown_inline",
  },
  sync_install = false,
  auto_install = true,
  highlight = { enable = true, },
})
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls",
    "lua_ls",
    "yamlls",
    "bashls",
    "helm_ls",
  },
  handlers = {
    function(server_name)
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require('lspconfig')
      lspconfig[server_name].setup({ capabilities = capabilities })
    end,
    ["lua_ls"] = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      require('lspconfig')['lua_ls'].setup({
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
      })
    end,
  }
})
require("neovim-project").setup({
  projects = { -- define project roots
    "~/.config/nvim",
    "~/work/*",
    "~/.dotfiles",
  },
  per_branch_sessions = false, -- whether to have different sessions for each git branch
  picker = {
    type = "fzf-lua",          -- one of "telescope", "fzf-lua", or "snacks"
    preview = {
      enabled = true,          -- show directory structure in preview
      git_status = true,       -- show branch name, an ahead/behind counter, and the git status of each file/folder
      git_fetch = true,        -- fetch from remote, used to display the number of commits ahead/behind, requires git authorization
      show_hidden = false,     -- show hidden files/folders
    },
  },
})

require("markview").setup({
  preview = {
    icon_provider = "devicons", -- "mini" or "devicons"
  }
})

-- Keymap
local wk = require("which-key")
wk.add({
  -- Views
  ---- Splits
  { "<leader>s",  group = "split" },
  { "<leader>sl", "<cmd>vsplit<cr>",                                   desc = "Split Vertical" },
  { "<leader>sj", "<cmd>split<cr>",                                    desc = "Split Horizontal" },

  ---- Window navigation
  { "<leader>w",  proxy = "<c-w>",                                     group = "windows" }, -- proxy to window mappings

  ---- Explorer
  { "<leader>e",  "<cmd>:Neotree toggle<cr>",                          desc = "Open File Explorer",      mode = "n" },
  { "<leader>E",  "<cmd>:Neotree reveal<cr>",                          desc = "Reveal File in Explorer", mode = "n" },
  { "<leader>e",  group = "explorer" },

  ---- Navigate files
  { "<leader>f",  group = "files" },
  { "<leader>ff", "<cmd>:FzfLua files<cr>",                            desc = "Find Files",              mode = "n" },
  { "<leader>fg", "<cmd>:FzfLua live_grep<cr>",                        desc = "Grep for files",          mode = "n" },
  { "<leader>fc", "<cmd>:FzfLua grep_curbuf<cr>",                      desc = "Grep current buffer",     mode = "n" },
  { "<leader>f",  "<cmd>:FzfLua grep_visual<cr>",                      desc = "Grep visual selection",   mode = "v" },
  { "<leader>fw", "<cmd>:FzfLua grep_cword<cr>",                       desc = "Grep word",               mode = "n" },
  { "<leader>fr", "<cmd>:FzfLua lsp_references async=true<cr>",        desc = "LSP References",          mode = "n" },
  { "<leader>fR", "<cmd>:FzfLua resume<cr>",                           desc = "Resume Fzf",              mode = "n" },
  { "<leader>fe", "<cmd>:FzfLua lsp_definitions async=true<cr>",       desc = "LSP Definitions",         mode = "n" },

  { "<leader>fd", "<cmd>:FzfLua diagnostics_document async=true<cr>",  desc = "Doc diagnostics",         mode = "n" },
  { "<leader>fD", "<cmd>:FzfLua diagnostics_workspace async=true<cr>", desc = "Workspace diagnostics",   mode = "n" },

  { "<leader>b",  group = "buffers" },
  { "<leader>b",  "<cmd>:FzfLua buffers<cr>",                          desc = "Open buffer Explorer",    mode = "n" },

  ---- Open Project
  { "<leader>p",  group = "projects" },
  { "<leader>po", "<cmd>:NeovimProjectDiscover<cr>",                   desc = "Open Project",            mode = "n" },
  { "<leader>pr", "<cmd>:NeovimProjectLoadRecent<cr>",                 desc = "Open Previous Project",   mode = "n" },

  ---- Git
  { "<leader>g",  group = "git" },
  { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>",                      desc = "Git reset visual hunk" },
  { "<leader>gb", "<cmd>Gitsigns blame<cr>",                           desc = "Enable git blame" },
  { "<leader>gs", "<cmd>FzfLua git_status<cr>",                        desc = "FzfLua git status" },
  { "<leader>gp", "<cmd>!git pull<cr>",                                desc = "term: git pull" },
  { "<leader>gf", "<cmd>!git fetch<cr>",                               desc = "term: git fetch" },

  ---- Terminal
  { "<leader>t",  "<cmd>:ToggleTerm<cr>",                              desc = "Open Terminal",           mode = "n" },
  { "<esc>",      [[<C-\><C-n>]],                                      desc = "Exit term mode",           mode = "t" },

  ---- Tab to indent
  { "<TAB>",      ">>",                                                mode = "n" },
  { "<S-TAB>",    "<<",                                                mode = "n" },
  { "<TAB>",      ">gv",                                               mode = "v" },
  { "<S-TAB>",    "<gv",                                               mode = "v" },
})
-- LSP Keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    wk.add({
      buffer = ev.buf,
      -- Navigation (g = "go to")
      { "gd",         vim.lsp.buf.definition,      desc = "Go to Definition" },
      { "gD",         vim.lsp.buf.declaration,     desc = "Go to Declaration" },
      { "gi",         vim.lsp.buf.implementation,  desc = "Go to Implementation" },
      { "gy",         vim.lsp.buf.type_definition, desc = "Go to Type Definition" },

      -- Info
      { "K",          vim.lsp.buf.hover,           desc = "Hover",                mode = { "n", "v" } },
      { "<C-k>",      vim.lsp.buf.signature_help,  desc = "Signature Help",       mode = "i" },

      -- Diagnostics
      { "<leader>d",  group = "diagnostics" },
      { "<leader>d",  vim.diagnostic.open_float,   desc = "Line Diagnostics" },
      { "<leader>dn", vim.diagnostic.goto_next,    desc = "Next Diagnostic" },
      { "<leader>dp", vim.diagnostic.goto_prev,    desc = "Prev Diagnostic" },

      -- Code actions
      { "<leader>c",  group = "code" },
      { "<leader>ca", vim.lsp.buf.code_action,     desc = "Code Action",          mode = { "n", "v" } },
      { "<leader>cr", vim.lsp.buf.rename,          desc = "Rename Symbol" },
      { "<leader>cf", vim.lsp.buf.format,          desc = "Format Document" },
    })
  end
})

-- Copilot
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- Colorscheme
-- vim.g.gruvbox_material_backgroup = 'hard'
-- vim.g.gruvbox_material_better_performance = 1
vim.cmd.colorscheme("onehalfdark")

-- Gutter diagnostics signs
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    }
  }
})
