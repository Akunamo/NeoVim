local dap = require('dap')
local dapui = require("dapui")
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end
dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = vim.fn.stdpath("data") .. '/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
}

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = true,
        setupCommands = {
            {
                text = '-enable-pretty-printing',
                description = 'Enable pretty printing',
                ignoreFailures = false
            }
        },
    },
}

-- Alias for C and Rust
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

require("dap-vscode-js").setup({
    debugger_path =
        vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter",

    adapters = {
        "pwa-node",
    },
})

dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",

    executable = {
        command = "node",

        args = {
            vim.fn.stdpath("data")
            .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",

            "${port}",
        },
    },
}

-- Node.js configurations
dap.configurations.javascript = {
    -- Launch a Node.js script
    {
        name = "Launch Node App",
        type = "pwa-node",
        request = "launch",
        program = "${file}", -- Debug current file
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
    },
    -- Launch with custom entry point
    {
        name = "Launch Node App (Custom Entry)",
        type = "pwa-node",
        request = "launch",
        program = function()
            return vim.fn.input('Path to entry file: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
    },
    -- Attach to already running Node process
    {
        name = "Attach to Node Process",
        type = "pwa-node",
        request = "attach",
        processId = require("dap.utils").pick_process, -- Pick from running processes
        cwd = "${workspaceFolder}",
        sourceMaps = true,
    },
    -- Attach to Node process via port
    {
        name = "Attach to Node Port",
        type = "pwa-node",
        request = "attach",
        port = function()
            -- Default Node.js debug port is 9229
            return tonumber(vim.fn.input('Port: ', '9229'))
        end,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
    },
    {
        name = "Launch via NPM",
        type = "pwa-node",
        request = "launch",
        runtimeExecutable = "npm",
        runtimeArgs = { "run", "dev:backend" }, -- or "start"
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        sourceMaps = true,
    },
}

-- Alias for TypeScript (uses same configs)
dap.configurations.typescript = dap.configurations.javascript
