vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- WSL2 clipboard bridge. Neovim can auto-detect win32yank, but making the
-- provider explicit keeps copy and paste working consistently inside tmux.
if vim.fn.has("wsl") == 1 and vim.fn.executable("win32yank.exe") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

local opt = vim.opt
local undo_dir = vim.fn.stdpath("data") .. "/undo"

vim.fn.mkdir(undo_dir, "p")

opt.number = true
opt.relativenumber = true
opt.signcolumn = "number"
opt.cursorline = true
opt.cursorlineopt = "number"
opt.undofile = true
opt.undodir = undo_dir
opt.clipboard = "unnamedplus"
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.scrolloff = 4
opt.sidescrolloff = 4
opt.confirm = true
opt.mouse = ""

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Use softer editing defaults for prose",
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Plugin bootstrap kept in this file because the current config is intentionally
-- small. Leader-based mappings avoid common tmux control-key conflicts.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
local lazy_ok = uv.fs_stat(lazypath) ~= nil

if not lazy_ok then
  local lazy_repo = "https://github.com/folke/lazy.nvim.git"
  local clone_output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazy_repo,
    lazypath,
  })
  lazy_ok = vim.v.shell_error == 0
  if not lazy_ok then
    vim.api.nvim_echo({
      { "failed to clone lazy.nvim:\n", "ErrorMsg" },
      { clone_output, "WarningMsg" },
    }, true, {})
  end
end

if lazy_ok then
  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup({
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        preset = "modern",
        icons = { mappings = false },
        spec = {
          { "<leader>f", group = "find/search" },
          { "<leader>h", group = "harpoon" },
        },
      },
      keys = {
        { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer local keymaps" },
      },
    },
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = "Telescope",
      keys = {
        { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
        { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
        { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Telescope buffers" },
        { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Telescope help tags" },
        { "<leader>fk", function() require("telescope.builtin").keymaps() end, desc = "Telescope keymaps" },
        { "<leader>fc", function() require("telescope.builtin").commands() end, desc = "Telescope commands" },
      },
      config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
          defaults = {
            path_display = { "smart" },
            mappings = {
              i = {
                ["<esc>"] = actions.close,
              },
            },
          },
        })
      end,
    },
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      opts = {},
      keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      },
    },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
      keys = {
        { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
        { "<leader>hh", function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end, desc = "Harpoon menu" },
        { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
        { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
        { "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
        { "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
        { "<leader>hp", function() require("harpoon"):list():prev() end, desc = "Harpoon previous" },
        { "<leader>hn", function() require("harpoon"):list():next() end, desc = "Harpoon next" },
      },
      config = function()
        require("harpoon"):setup()
      end,
    },
  }, {
    checker = { enabled = false },
    change_detection = { notify = false },
  })
end
