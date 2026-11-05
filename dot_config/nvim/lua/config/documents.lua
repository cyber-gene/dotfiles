-- Use built-in folding without requiring an additional parser or plugin.
-- Register after the standard ftplugins so their defaults do not override ours.
vim.cmd("filetype plugin indent on")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DocumentFolding", { clear = true }),
  pattern = { "json", "jsonc", "yaml", "yaml.*" },
  callback = function(event)
    local is_yaml = vim.bo[event.buf].filetype:match("^yaml") ~= nil
    vim.opt_local.foldmethod = is_yaml and "indent" or "syntax"
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldenable = true
    vim.opt_local.foldcolumn = "1"
    -- Include YAML comments in indentation-based folds.
    vim.opt_local.foldignore = ""
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2

    local undo = "setlocal foldmethod< foldlevel< foldenable< foldcolumn< foldignore< expandtab< shiftwidth< softtabstop<"
    vim.b[event.buf].undo_ftplugin = (vim.b[event.buf].undo_ftplugin or "") .. " | " .. undo
  end,
})
