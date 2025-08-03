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
vim.g.netrw_banner = 0
vim.opt.shortmess:append({ a = true, I = true, c = true })
vim.opt.formatoptions = "jrql"
vim.opt.jumpoptions = "view"
vim.opt.laststatus = 3

vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set(
    { "n", "v", "x" },
    "<leader>Y",
    '"+yy',
    { noremap = true, silent = true, desc = "Yank line to clipboard" }
)
vim.keymap.set({ "n", "v", "x" }, "<C-a>", "gg0vG$", { noremap = true, silent = true, desc = "Select all" })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set(
    "i",
    "<C-p>",
    "<C-r><C-p>+",
    { noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)
vim.keymap.set(
    "x",
    "<leader>P",
    '"_dP',
    { noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)

vim.cmd.colorscheme("unokai")

require("lualine").setup({})
local wk = require("which-key")

wk.add({ "<leader>g", group = "[g]it stuff" })
vim.keymap.set("n", "<leader>gl", function()
    vim.cmd("silent !zellij run --in-place --close-on-exit -- lazygit")
    vim.cmd("redraw!")
end, { noremap = true, silent = true, desc = "Open lazygit in a zellij floating window" })
require("gitsigns").setup()

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

local snacks = require("snacks")

snacks.setup({
    scratch = { enabled = true },
    picker = { enabled = true },
})

-- persistence
local persistence = require("persistence")
persistence.setup({})
wk.add({ "<leader>i", group = "Sess[i]on" })

vim.keymap.set("n", "<leader>i.", function()
    persistence.load()
end, { desc = "load the session for the [.]current dir" })

vim.keymap.set("n", "<leader>ic", function()
    persistence.select()
end, { desc = "[c]hoose a previously saved session" })

-- scratch file
wk.add({ "<leader>k", group = "S[k]ratch" })

local function get_scratch_config(ft)
    local handle = io.popen("basename $(git rev-parse --show-toplevel) 2>/dev/null")
    local git_repo = handle and handle:read("*a"):gsub("\n", "") or nil
    if handle then
        handle:close()
    end

    return {
        name = git_repo or "Scratch",
        ft = ft,
        filekey = {
            cwd = not git_repo,
            branch = false,
            count = false,
        },
    }
end

vim.keymap.set("n", "<leader>k.", function()
    snacks.scratch.open(get_scratch_config("markdown"))
end, { desc = "Toggle markdown scratchfile for the [.]current project" })

vim.keymap.set("n", "<leader>kf", function()
    snacks.scratch.open(get_scratch_config())
end, { desc = "Toggle [f]iletype-specific scratchfile for the current project" })

vim.keymap.set("n", "<leader>kc", function()
    snacks.scratch.select()
end, { desc = "[c]hoose a scratchfile" })

-- LSP and formatters
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
})
vim.lsp.enable("bashls")
vim.lsp.enable("docker_language_server")
vim.lsp.enable("jinja_lsp")
vim.lsp.enable("lua_ls")
vim.lsp.enable("nil_ls")
vim.lsp.enable("ruff")
vim.lsp.enable("superhtml")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("ts_ls")
vim.lsp.enable("yamlls")
require("copilot").setup({ panel = { enabled = false }, suggestions = { enabled = false } })
require("CopilotChat").setup({})

-- Completion
local blink = require("blink.cmp")
blink.setup({
    cmdline = { enabled = false },
    sources = { default = { "lsp", "buffer", "snippets", "path", "copilot", "ripgrep" } },
})
blink.add_source_provider("copilot", {
    name = "copilot",
    module = "blink-copilot",
    score_offset = 100,
    async = true,
})
blink.add_source_provider("ripgrep", {
    name = "ripgrep",
    module = "blink-ripgrep",
    score_offset = 10,
    async = true,
})

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        css = { "prettierd" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        html = { "prettierd", "djlint" },
        yaml = { "prettierd" },
        bash = { "shellharden", "shfmt" },
        java = { "google-java-format" },
        nix = { "nixfmt" },
        typst = { "typstyle" },
    },
    formatters = {
        stylua = { prepend_args = { "--indent-type", "Spaces" } },
        djlint = { timeout_ms = 1000 },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
    },
})

-- flash
require("flash").setup({ modes = { search = { enabled = true } } })
wk.add({
    {
        mode = { "n", "x", "o" },
        {
            "s",
            function()
                require("flash").jump()
            end,
            desc = "Fla[s]h (local)",
        },
        {
            "S",
            function()
                require("flash").tressitter()
            end,
            desc = "Flash tree[S]itter (local)",
        },
    },
    {
        "r",
        mode = "o",
        function()
            require("flash").remote()
        end,
        desc = "Flash ([r]emote)",
    },
    {
        "R",
        mode = { "o", "x" },
        function()
            require("flash").treesitter_search()
        end,
        desc = "Flash treesitter ([R]emote)",
    },
    {
        "<c-s>",
        mode = { "c" },
        function()
            require("flash").toggle()
        end,
        desc = "Toggle Fla[^s]h Search",
    },
})
