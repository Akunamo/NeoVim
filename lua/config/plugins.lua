return {
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "folke/lazy.nvim" },
    { "mfussenegger/nvim-jdtls" },
    { "nvim-tree/nvim-tree.lua" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "ThePrimeagen/harpoon" },
    { "mbbill/undotree" },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("config.treesitter")
        end,
    },

    { "tpope/vim-fugitive" },

    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        },
        config = function()
            require("config.lsp")
        end
    },
 
    { "zbirenbaum/nvterm" },
    { "mattn/emmet-vim" },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 999,
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    { "okuuva/auto-save.nvim" },

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
        end
    },

    {
        "Civitasv/cmake-tools.nvim",
        ft = { "cpp", "c", "cmake" },
        cond = function()
            return vim.fn.filereadable(vim.fn.getcwd() .. "/CMakeLists.txt") == 0
        end,
        config = function()
            require("config.cmaketools")
        end,
    },

    { "stevearc/conform.nvim" },

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

    { "nvim-tree/nvim-web-devicons" },
    { "lewis6991/gitsigns.nvim" },
    { "kdheepak/lazygit.nvim" },

    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("config.lualine")
        end
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = "markdown",
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
        opts = {},
    }
}
