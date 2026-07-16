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
opt.laststatus = 0
opt.showmode = false
opt.ruler = false

local function clean_wrapped_prose()
  local mode = vim.fn.mode()
  local mark_a = mode:match("[vV\22]") and vim.fn.line("v") or vim.fn.line("'<")
  local mark_b = mode:match("[vV\22]") and vim.fn.line(".") or vim.fn.line("'>")
  local first = math.min(mark_a, mark_b) - 1
  local last = math.max(mark_a, mark_b)
  local lines = vim.api.nvim_buf_get_lines(0, first, last, false)
  local cleaned = {}

  for _, line in ipairs(lines) do
    line = line:gsub("^%s+", "")
    local previous = cleaned[#cleaned]
    local starts_structure = line:match("^[-*+] ")
      or line:match("^%d+[.)] ")
      or line:match("^#+ ")
      or line:match("^> ")
      or line:match("^```")

    if line == "" or not previous or previous == "" or starts_structure then
      table.insert(cleaned, line)
    else
      local separator = previous:match("[/._=-]$") and "" or " "
      cleaned[#cleaned] = previous .. separator .. line
    end
  end

  vim.api.nvim_buf_set_lines(0, first, last, false, cleaned)
end

vim.keymap.set("x", "<leader>cl", clean_wrapped_prose, {
  desc = "Clean terminal-wrapped prose",
})

local function insert_response_after(last)
  vim.api.nvim_buf_set_lines(0, last, last, false, { "> " })
  vim.api.nvim_win_set_cursor(0, { last + 1, 1 })
  vim.schedule(function()
    vim.cmd("startinsert!")
  end)
end

local function compose_response()
  local anchor = vim.fn.line("v")
  local cursor = vim.fn.line(".")

  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  insert_response_after(math.max(anchor, cursor))
end

vim.keymap.set("x", "<leader>cr", compose_response, {
  desc = "Compose response below line/selection",
})

vim.keymap.set("n", "<leader>cr", function()
  insert_response_after(vim.fn.line("."))
end, {
  desc = "Compose response below line/selection",
})

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
          { "<leader>c", group = "text actions", mode = { "n", "x" } },
          { "<leader>f", group = "find/search" },
          { "<leader>g", group = "git" },
          { "<leader>h", group = "harpoon" },
          { "<leader>m", group = "markdown" },
          { "<leader>p", group = "plugins" },
          { "<leader>q", group = "macros/registers" },
          { "<leader>u", group = "ui" },
        },
      },
      keys = {
        { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer local keymaps" },
        { "<leader>pl", "<cmd>Lazy<cr>", desc = "Plugin manager" },
        { "<leader>qm", "<cmd>help recording<cr>", desc = "Macro recording help" },
        { "<leader>qr", "<cmd>registers<cr>", desc = "Show registers" },
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
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("tokyonight").setup({
          style = "moon",
          transparent = false,
          dim_inactive = true,
        })
        vim.o.background = "dark"
        vim.cmd.colorscheme("tokyonight-moon")
      end,
    },
    {
      "sphamba/smear-cursor.nvim",
      event = "VeryLazy",
      opts = {},
      keys = {
        { "<leader>uc", "<cmd>SmearCursorToggle<cr>", desc = "Toggle cursor animation" },
      },
    },
    {
      "m4xshen/hardtime.nvim",
      lazy = false,
      dependencies = { "MunifTanjim/nui.nvim" },
      opts = {
        restriction_mode = "hint",
        disable_mouse = false,
      },
      keys = {
        { "<leader>uh", "<cmd>Hardtime toggle<cr>", desc = "Toggle motion coaching" },
        { "<leader>ur", "<cmd>Hardtime report<cr>", desc = "Motion coaching report" },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(buffer)
          local gitsigns = require("gitsigns")
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
          end

          map("]h", function() gitsigns.nav_hunk("next") end, "Next Git hunk")
          map("[h", function() gitsigns.nav_hunk("prev") end, "Previous Git hunk")
          map("<leader>gp", gitsigns.preview_hunk, "Preview Git hunk")
          map("<leader>gs", gitsigns.stage_hunk, "Stage Git hunk")
          map("<leader>gu", gitsigns.undo_stage_hunk, "Undo staged Git hunk")
          map("<leader>gb", function() gitsigns.blame_line({ full = true }) end, "Blame Git line")
        end,
      },
    },
    {
      "OXY2DEV/markview.nvim",
      lazy = false,
      opts = {
        markdown = {
          headings = {
            heading_1 = { sign = "", icon = "◆  " },
            heading_2 = { sign = "", icon = "◇  " },
            heading_3 = { icon = "▪  " },
            heading_4 = { icon = "▫  " },
            heading_5 = { icon = "•  " },
            heading_6 = { icon = "·  " },
            setext_1 = { sign = "", icon = "◆  " },
            setext_2 = { sign = "", icon = "◇  " },
          },
        },
      },
      keys = {
        { "<leader>mp", "<cmd>Markview toggle<cr>", desc = "Markdown preview toggle" },
        { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Markdown split preview" },
      },
    },
  }, {
    checker = { enabled = false },
    change_detection = { notify = false },
  })
end
