local map = function(mode, lhs, rhs, opts)
  local defaults = { silent = true, noremap = true }
  if opts then defaults = vim.tbl_extend("force", defaults, opts) end
  vim.keymap.set(mode, lhs, rhs, defaults)
end

vim.loader.enable()

vim.g.loaded_python3_provider = 0
vim.g.loaded_python_provider = 0
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_silent = 1

vim.opt.autowriteall = true
vim.opt.breakindent = true
vim.opt.completeopt = "menu,menuone,preview,noselect"
vim.opt.cpoptions:append("I")
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = { foldopen = "", foldclose = "", diff = "╱" }
vim.opt.foldcolumn = "1"
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.jumpoptions = "view"
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.shortmess:append({ a = true, I = true, c = true })
vim.opt.showmode = false
vim.opt.sidescrolloff = 4
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.softtabstop = 2
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.splitright = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = true
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function() vim.opt.formatoptions:remove({ "c", "r", "o" }) end,
})

local wk = require("which-key")
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })

map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "v", "x" }, "p", '"_dP', { desc = "Keep unammed register when overwriting in visual mode" })

wk.add({ "<leader>d", group = "LSP [d]iagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [d]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic message" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open [f]loating diagnostic message" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics [q]uickfix list" })

vim.cmd.colorscheme("vim-monokai-tasty")

require("lualine").setup({})

local snacks = require("snacks")

wk.add({ "<leader>g", group = "[g]it stuff" })
require("gitsigns").setup()
local function get_git_repo_name()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  local git_repo = handle and handle:read("*a"):gsub("\n", "") or nil
  if handle then handle:close() end
  return git_repo
end
map("n", "<leader>gl", function() snacks.lazygit.open() end, { noremap = true, silent = true, desc = "Open lazygit" })
map(
  "n",
  "<leader>gw",
  function() snacks.terminal("github_workflow") end,
  { noremap = true, silent = true, desc = "Launch github workflow" }
)
map(
  { "n", "o" },
  "]g",
  function() vim.cmd("Gitsigns next_hunk") end,
  { noremap = true, silent = true, desc = "Next git hunk" }
)
map(
  { "n", "o" },
  "[g",
  function() vim.cmd("Gitsigns prev_hunk") end,
  { noremap = true, silent = true, desc = "Prev git hunk" }
)
map(
  "n",
  "<leader>gk",
  function() vim.cmd("Gitsigns preview_hunk") end,
  { noremap = true, silent = true, desc = "Preview hunk" }
)
map(
  "n",
  "<leader>gs",
  function() vim.cmd("Gitsigns stage_hunk") end,
  { noremap = true, silent = true, desc = "Stage/unstage hunk" }
)
map("n", "<leader>gc", function()
  if vim.bo.filetype ~= "gitcommit" then return end
  local buf = vim.api.nvim_get_current_buf()

  local diff = vim.fn.systemlist("git diff --cached")
  if vim.v.shell_error ~= 0 then return end
  if #diff == 0 then return end

  local prompt_base = [[
Write commit message for the below changes using the conventional-commits convention.
- Keep the title under 50 characters.
- The body is VERY MUCH OPTIONAL, add it ONLY if the commit is complex.
- Don't add body for simple self explanatory commits
- Body if added should be readable bullet points.
- Body if added should explain the 'why' of a commit (if you know why)
- Remember the exclamation mark if ANYTHING in the PUBLIC API changes (when in doubt add it)
- Wrap message at 72 characters.
- Output only the commit message, as raw text.
]]

  local prompt = prompt_base .. "\n" .. table.concat(diff, "\n")

  require("CopilotChat").ask(prompt, {
    callback = function(response)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n"))
      vim.cmd("CopilotChatClose")
    end,
  })
end, { desc = "Generate commit message with Copilot", noremap = true, silent = true })

local persistence = require("persistence")
persistence.setup({})
wk.add({ "<leader>i", group = "Sess[i]on" })
map("n", "<leader>i.", function() persistence.load() end, { desc = "load current [.]" })
map("n", "<leader>ic", function() persistence.select() end, { desc = "[c]hoose" })

snacks.setup({
  scratch = { enabled = true },
  picker = { enabled = true },
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  scroll = { enabled = true },
  indent = { enabled = true },
  words = { enabled = true },
})

wk.add({ "<leader>k", group = "S[k]ratch" })

local function get_scratch_config(opts)
  local default_opts = {
    filekey = {
      cwd = get_git_repo_name() or true,
      branch = false,
      count = false,
    },
  }
  return vim.tbl_deep_extend("force", default_opts, opts)
end

map(
  "n",
  "<leader>km",
  function() snacks.scratch.open(get_scratch_config({ ft = "markdown" })) end,
  { desc = "[m]arkdown (current project)" }
)
map(
  "n",
  "<leader>kk",
  function() snacks.scratch.open(get_scratch_config({ name = "Hacks", ft = "lua", filekey = { cwd = false } })) end,
  { desc = "lua hac[k]s" }
)
map("n", "<leader>kf", function() snacks.scratch.open(get_scratch_config()) end, { desc = "[f]iletype" })
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
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = { enable = false },
      check = { command = "clippy" },
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

wk.add({ "<leader>a", group = "[A]I" })
require("copilot").setup({
  panel = { enabled = false },
  suggestions = { enabled = false },
})
local copilotchat = require("CopilotChat")
copilotchat.setup({})
map({ "n", "v" }, "<leader>ac", function() copilotchat.toggle() end, { desc = "Chat" })
map({ "n", "v" }, "<leader>ap", function() copilotchat.select_prompt() end, { desc = "Pick Prompt" })
map({ "n", "v" }, "<leader>am", function() copilotchat.select_model() end, { desc = "Pick Model" })

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
map(
  "",
  "<leader>f",
  function() require("conform").format({ async = true, lsp_fallback = true }) end,
  { desc = "[f]ormat using conform" }
)

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

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("spider").setup({ skipInsignificantPunctuation = false })
map({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>")
map({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>")
map({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>")

require("yanky").setup()
map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
map("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
map("n", "<c-n>", "<Plug>(YankyNextEntry)")

local picker = snacks.picker
map("n", "<leader>p", function() picker() end, { desc = "list [p]ickers" })
map("n", "<leader><Space>", function() snacks.picker.smart() end, { desc = "find files (smart)" })
map("n", "<leader>,", function() snacks.picker.buffers() end, { desc = "find files (buffers)" })
map("n", "<leader>/", function() snacks.picker.grep() end, { desc = "find by grep" })
map("n", "grd", function() snacks.picker.lsp_definitions() end, { desc = "Goto [d]efinition" })
map("n", "grD", function() snacks.picker.lsp_declarations() end, { desc = "Goto [D]eclaration" })
map("n", "grr", function() snacks.picker.lsp_references() end, { desc = "Goto [r]eferences", nowait = true })
map("n", "gri", function() snacks.picker.lsp_implementations() end, { desc = "Goto [i]mplementation" })
map("n", "grt", function() snacks.picker.lsp_type_definitions() end, { desc = "Goto [t]ype Definition" })
map("n", "grc", function() snacks.picker.diagnostics() end, { desc = "Open LSP daignotsti[c]s" })

if os.getenv("EXTRA_VIMRC") then vim.cmd("source " .. os.getenv("EXTRA_VIMRC")) end

map("n", "<Enter>", function() vim.cmd("update") end, { desc = "Write file" })

-- Disable swap for gitcommit
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function() vim.opt_local.swapfile = false end,
})
