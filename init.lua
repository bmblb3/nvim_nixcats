local wk = require("which-key")
local map = function(mode, lhs, rhs, opts)
  local defaults = { silent = true, noremap = true }
  if opts then defaults = vim.tbl_extend("force", defaults, opts) end
  vim.keymap.set(mode, lhs, rhs, defaults)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.foldcolumn = "1"
vim.opt.fillchars = { foldopen = "", foldclose = "", diff = "╱" }
vim.opt.hlsearch = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4
vim.opt.mouse = "a"
vim.opt.cpoptions:append("I")
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.autowriteall = true
vim.opt.shiftround = true
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.completeopt = "menu,menuone,preview,noselect"
vim.opt.cursorline = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.showmode = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.wrap = false
vim.g.netrw_liststyle = 3
vim.g.netrw_silent = 1
vim.g.netrw_banner = 0
vim.opt.shortmess:append({ a = true, I = true, c = true })
vim.opt.jumpoptions = "view"
vim.opt.laststatus = 3
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function() vim.opt.formatoptions:remove({ "c", "r", "o" }) end,
})

vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
map("n", "n", "nzzzv", { desc = "Next Search Result" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result" })

map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "v", "x" }, "p", '"_dP', { desc = "Keep unammed register when overwriting in visual mode" })

wk.add({ "<leader>d", group = "LSP [d]iagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [d]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic message" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open [f]loating diagnostic message" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics [q]uickfix list" })

vim.cmd.colorscheme("unokai")

require("lualine").setup({})

wk.add({ "<leader>g", group = "[g]it stuff" })
map("n", "<leader>gl", function()
  vim.cmd("silent !zellij run --in-place --close-on-exit -- lazygit")
  vim.cmd("redraw!")
end, { noremap = true, silent = true, desc = "Open lazygit in a zellij floating window" })
require("gitsigns").setup()

local persistence = require("persistence")
persistence.setup({})
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      persistence.load()
      vim.cmd("bufdo doautocmd BufRead")
    end
  end,
})
wk.add({ "<leader>i", group = "Sess[i]on" })
map("n", "<leader>i.", function() persistence.load() end, { desc = "load current [.]" })
map("n", "<leader>ic", function() persistence.select() end, { desc = "[c]hoose" })

local snacks = require("snacks")
snacks.setup({
  scratch = { enabled = true },
  picker = { enabled = true },
})

wk.add({ "<leader>k", group = "S[k]ratch" })
local function get_scratch_config(ft, fallback_name)
  fallback_name = fallback_name or "Scratch"
  local handle = io.popen("readlink -f $(git rev-parse --show-toplevel) 2>/dev/null")
  local git_repo = handle and handle:read("*a"):gsub("\n", "") or nil
  if handle then handle:close() end
  return {
    name = git_repo or fallback_name,
    ft = ft,
    filekey = {
      cwd = not git_repo,
      branch = false,
      count = false,
    },
  }
end
map(
  "n",
  "<leader>k.",
  function() snacks.scratch.open(get_scratch_config("markdown")) end,
  { desc = "[.]current project" }
)
map(
  "n",
  "<leader>kl",
  function() snacks.scratch.open(get_scratch_config("lua", "cmds")) end,
  { desc = "[l]ua commands" }
)
map("n", "<leader>kf", function() snacks.scratch.open(get_scratch_config()) end, { desc = "[f]iletype-specific" })
map("n", "<leader>kc", function() snacks.scratch.select() end, { desc = "[c]hoose" })

require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = false,
      node_decremental = "<bs>",
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})
vim.lsp.enable("basedpyright")
vim.lsp.enable("bashls")
vim.lsp.enable("docker_language_server")
vim.lsp.enable("jinja_lsp")
vim.lsp.enable("lua_ls")
vim.lsp.enable("nil_ls")
vim.lsp.enable("postgres_lsp")
vim.lsp.enable("ruff")
vim.lsp.enable("superhtml")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("ts_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("rust_analyzer")
require("copilot").setup({ panel = { enabled = false }, suggestions = { enabled = false } })
require("CopilotChat").setup({})

require("conform").setup({
  default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    css = { "prettierd" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    html = { "prettierd", "djlint" },
    yaml = { "prettierd" },
    sh = { "shellharden", "shfmt", "shellcheck" },
    java = { "google-java-format" },
    nix = { "nixfmt" },
    typst = { "typstyle" },
    rust = { "rustfmt" },
  },
  formatters = {
    stylua = {
      prepend_args = {
        "--indent-type",
        "Spaces",
        "--indent-width",
        2,
        "--column-width",
        120,
        "--collapse-simple-statement",
        "Always",
      },
    },
  },
  format_on_save = function(bufnr)
    local long_fmt_filetypes = { "html" }
    if vim.tbl_contains(long_fmt_filetypes, vim.bo[bufnr].filetype) then
      return { timeout_ms = 5000, lsp_format = "fallback" }
    end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
})
map("", "<leader>f", function() require("conform").format({ async = true, lsp_fallback = true }) end)

local blink = require("blink.cmp")
blink.setup({
  cmdline = { enabled = false },
  sources = { default = { "lsp", "buffer", "snippets", "path", "copilot", "ripgrep" } },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
  },
})
blink.add_source_provider("copilot", {
  name = "copilot",
  module = "blink-copilot",
  score_offset = 0,
  async = true,
})
blink.add_source_provider("ripgrep", {
  name = "ripgrep",
  module = "blink-ripgrep",
  score_offset = -3,
  async = true,
})

require("flash").setup({ modes = { search = { enabled = true } } })
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Fla[s]h" })
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash tree[S]itter" })
map({ "o" }, "r", function() require("flash").remote() end, { desc = "flash [r]emote" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Flash treesitter [R]emote" })
map({ "s" }, "<C-s>", function() require("flash").toggle() end, { desc = "Toggle Fla[^s]h Search" })

require("hardtime").setup()

map({ "n" }, "<M-k>", function() require("dial.map").manipulate("increment", "normal") end, { desc = "Dial increment" })
map({ "n" }, "<M-j>", function() require("dial.map").manipulate("decrement", "normal") end, { desc = "Dial decrement" })
map({ "v" }, "<M-k>", function() require("dial.map").manipulate("increment", "visual") end, { desc = "Dial increment" })
map({ "v" }, "<M-j>", function() require("dial.map").manipulate("decrement", "visual") end, { desc = "Dial decrement" })
