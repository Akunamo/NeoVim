local util = require("conform.util")
--@type conform.FileFormatterConfig
return {
    meta = {
        url = "https://clang.llvm.org/docs/ClangFormat.html",
        description = "Tool to format C/C++/... code according to a set of rules and heuristics.",
    },
    command = "clang-format",
    args = function(ctx)
        local base_args = {
            "--assume-filename",
            "$FILENAME",
            "--style",
            "{BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4, BreakBeforeBraces: Allman, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: Never, AllowShortLoopsOnASingleLine: false}" }
        if ctx.range then
            local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
            local length = end_offset - start_offset
            vim.list_extend(base_args, {
                "--offset",
                tostring(start_offset),
                "--length",
                tostring(length),
            })
        end
        return base_args
    end,
    stdin = true,
}
