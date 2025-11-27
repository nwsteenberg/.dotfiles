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
vim.opt.signcolumn = "yes:2"

-- Scrolling and UI settings
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

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
vim.lsp.inlay_hint.enable(true)

-- fix eol on save
vim.opt.fixeol = false

local plugins = {
  { "nvim-lua/plenary.nvim" },                                -- used by other plugins
  { "nvim-tree/nvim-web-devicons" },                          -- used by other plugins
  { "Shatur/neovim-session-manager" },                        -- used by other plugins
  { "MunifTanjim/nui.nvim" },                                 -- used by other plugins

  { "nvim-lualine/lualine.nvim" },                            -- status line
  { "nvim-neo-tree/neo-tree.nvim" },                          -- file browser
  { "nvim-telescope/telescope.nvim" },                        -- telescope
  { "nvim-treesitter/nvim-treesitter",    build = ":TSUpdate" }, -- treesitter
  { 'mason-org/mason.nvim' },                                 -- installs LSP servers
  { 'neovim/nvim-lspconfig' },                                -- configures LSPs
  { 'mason-org/mason-lspconfig.nvim' },                       -- links the two above
  { "rebelot/kanagawa.nvim" },                                -- colorscheme
  { "folke/which-key.nvim" },                                 -- Keymaps
  { "lewis6991/gitsigns.nvim" },                              -- Gitsigns
  { "coffebar/neovim-project" },                              -- Manage projects
  { "github/copilot.vim" },                                   -- Copilot
  { "lukas-reineke/indent-blankline.nvim" },                  -- indent guides

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
require("lualine").setup()       -- status line
require("neo-tree").setup({      -- tree file browser
  -- add options here
  use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes instead of relying on nvim autocmd events.
  window = {
    position = "float",
  },
  filesystem = {
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false, -- only works on Windows for hidden files/directories
    }
  }
})

require("telescope").setup() -- navigate files
require('gitsigns').setup {

}
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "bash",
    "go",
    "yaml",
    "json"
  },
  sync_install = false,
  auto_install = true,
  highlight = { enable = true, },
})
require("ibl").setup()
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls",
    "lua_ls",
    "yamlls",
    "jsonls",
    "bashls"
  },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local lspconfig = require('lspconfig')

    lspconfig['gopls_ls'].setup({ capabilities = capabilities })
    lspconfig['lua_ls'].setup {
      capabilities = capabilities,
      settings = {
        Lua = { diagnostics = { globals = { 'vim' } } }
      }
    }
    lspconfig['yamlls'].setup({ capabilities = capabilities })
    lspconfig['jsonls'].setup({ capabilities = capabilities })
    lspconfig['bashls'].setup({ capabilities = capabilities })
  end
})
require("neovim-project").setup({
  projects = { -- define project roots
    "/mnt/c/Users/nws/Synergy/*",
    "/mnt/c/Users/nws/Synergy",
    "~/devel/*",
    "~/devel/.dotfiles",
  },
  picker = {
    type = "telescope",    -- one of "telescope", "fzf-lua", or "snacks"
    preview = {
      enabled = true,      -- show directory structure in Telescope preview
      git_status = false,  -- show branch name, an ahead/behind counter, and the git status of each file/folder
      git_fetch = false,   -- fetch from remote, used to display the number of commits ahead/behind, requires git authorization
      show_hidden = false, -- show hidden files/folders
    },
  }
})

-- Keymap
local wk = require("which-key")
wk.add({
  -- Views
  ---- Splits
  { "<leader>sl", "<cmd>vsplit<cr>",                        desc = "Split Vertical" },
  { "<leader>sj", "<cmd>split<cr>",                         desc = "Split Horizontal" },
  ---- Window navigation
  { "<leader>w",  proxy = "<c-w>",                          group = "windows" }, -- proxy to window mappings
  -- FileSystem
  ---- Explorer
  { "<leader>e",  "<cmd>:Neotree focus position=float<cr>", desc = "Open File Explorer",       mode = "n" },
  ---- Navigate files
  { "<leader>ff", "<cmd>Telescope find_files<cr>",          desc = "Find Files",               mode = "n" },
  { "<leader>fg", "<cmd>Telescope live_grep<cr>",           desc = "Grep for files",           mode = "n" },
  { "<leader>b",  "<cmd>:Telescope buffers<cr>",            desc = "Buffers",                  mode = "n" },
  ---- Open Project
  { "<leader>o",  "<cmd>:NeovimProjectDiscover<cr>",        desc = "Open Project",             mode = "n" },
  -- Editor
  ---- Git
  { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>",           desc = "Git reset visual hunk" },
  ---- Tab to indent
  { "<TAB>",      ">>",                                     mode = "n" },
  { "<S-TAB>",    "<<",                                     mode = "n" },
  { "<TAB>",      ">gv",                                    mode = "v" },
  { "<S-TAB>",    "<gv",                                    mode = "v" },
  ---- Remove search on esc
  { "<Esc>",      "<cmd>noh<CR>",                           desc = "general clear highlights", mode = "v" },
})
-- LSP Keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    -- Hover
    vim.keymap.set({ 'n', 'v' }, 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set({ 'n', 'v' }, 'L', vim.diagnostic.open_float, opts)
    -- Code action
    vim.keymap.set({ 'n', 'v' }, '<leader>wc', vim.lsp.buf.code_action, opts)
    -- Rename
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    -- Format document
    vim.keymap.set('n', 'F', vim.lsp.buf.format, opts)
    -- Goto
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>re', vim.lsp.buf.references, opts)
  end
})

-- Copilot
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- Colorscheme
vim.cmd.colorscheme("kanagawa") --  habamax is also nice
