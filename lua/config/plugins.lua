return {
    -- Core plugin manager & icons
    { "folke/lazy.nvim" },
    { "nvim-tree/nvim-web-devicons" },

    -- Colorscheme (high priority ensures it loads before UI plugins)
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("config.catppuccin")
        end,
    },

    -- Statusline and tabline (loads right after startup finishes)
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("config.lualine")
        end,
    },

    -- File explorer sidebar
    {
        "nvim-tree/nvim-tree.lua",
        event = "VeryLazy",
        config = function()
            require("config.tree")
        end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("config.telescope")
        end,
    },

    -- Quick file bookmarking
    {
        "ThePrimeagen/harpoon",
        event = "VeryLazy",
        config = function()
            require("config.harpoon")
        end,
    },

    -- Visual undo tree (loads only when you press <leader>u)
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
        },
    },

    -- Git tools (Fugitive and LazyGit load on demand; Gitsigns loads when opening a file)
    {
        "tpope/vim-fugitive",
        cmd = "Git",
        keys = {
            { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("config.gitsigns")
        end,
    },
    {
        "kdheepak/lazygit.nvim",
        cmd = "LazyGit",
    },

    -- Seamless split navigation between Neovim and Tmux
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp",
            "TmuxNavigateRight", "TmuxNavigatePrevious", "TmuxNavigatorProcessList",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },

    -- Editing helpers (auto-closing pairs, auto-save, formatting, HTML expansion)
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    {
        "okuuva/auto-save.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("config.auto_save")
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("config.conform")
        end,
    },
    { "mattn/emmet-vim" },

    -- Syntax parsing & textobjects (main branch requires lazy = false)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        },
        config = function()
            require("config.treesitter")
        end,
    },

    -- Language servers & Mason installer (loads when opening or creating a file)
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            -- Needed here so LSP servers receive completion capabilities on attach
            { "hrsh7th/cmp-nvim-lsp" },
        },
        config = function()
            require("config.lsp")
        end,
    },

    -- Standalone Java language server launcher (triggered by ftplugin/java.lua)
    { "mfussenegger/nvim-jdtls" },

    -- Autocomplete menu & snippets (loads the moment you enter Insert mode)
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-nvim-lua" },
            { "saadparwaiz1/cmp_luasnip" },
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        },
        config = function()
            require("config.cmp")
        end,
    },

    -- Debugger (loads only when you press <leader>dt or <leader>dc)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "mxsdev/nvim-dap-vscode-js",
            "williamboman/mason.nvim",
        },
        keys = {
            { "<leader>dt", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
        },
        config = function()
            require("config.dap")
        end,
    },

    -- CMake support (loads only for C/C++/CMake files when CMakeLists.txt exists)
    {
        "Civitasv/cmake-tools.nvim",
        ft = { "cpp", "c", "cmake" },
        cond = function()
            return vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 1
        end,
        config = function()
            require("config.cmaketools")
        end,
    },

    -- Rendered markdown preview (loads only on .md files)
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = "markdown",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
        opts = {},
    },
}
