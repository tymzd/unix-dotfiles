-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 0. RUNTIME PATH & PROVIDERS                                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
-- Include ~/.vim in runtimepath for backward compatibility with existing Vim assets
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))
vim.o.packpath = vim.o.runtimepath

-- Disable unused optional language providers to keep :checkhealth clean
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Ensure mg979/vim-visual-multi (multi-cursor plugin) is installed across machines
local vm_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/vim-visual-multi"
if not vim.uv.fs_stat(vm_path) then
  vim.fn.system({
    "git",
    "-c",
    "url.https://github.com/.insteadOf=git@github.com:",
    "clone",
    "--depth=1",
    "https://github.com/mg979/vim-visual-multi.git",
    vm_path,
  })
  vim.cmd("packadd vim-visual-multi | helptags " .. vm_path .. "/doc")
end


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 1. BASICS & INDENTATION                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.splitbelow = true

-- Enable hybrid line numbers (Relative in normal, Absolute in insert)
local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = numbertoggle,
  callback = function()
    if vim.opt.number:get() and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numbertoggle,
  callback = function()
    if vim.opt.number:get() then
      vim.opt.relativenumber = false
    end
  end,
})


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 2. CLIPBOARD & KEYMAPS                                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
-- Use system clipboard by default (uses xsel/xclip on Linux)
vim.opt.clipboard = "unnamedplus"

-- Map Ctrl+c to copy in Visual mode
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, desc = "Copy to system clipboard" })
-- Map Ctrl+x to cut in Visual mode
vim.keymap.set("v", "<C-x>", '"+x', { noremap = true, desc = "Cut to system clipboard" })
-- Map Ctrl+v to paste in Normal/Insert mode
vim.keymap.set("n", "<C-v>", '"+p', { noremap = true, desc = "Paste from system clipboard" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { noremap = true, desc = "Paste from system clipboard" })

-- Quick yank to system clipboard
vim.keymap.set("v", "Y", '"+y', { noremap = true, desc = "Yank to system clipboard" })


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 3. TERMINAL & CURSOR FIXES                                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
-- Reduce delay after pressing ESC without breaking escape sequences
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50

-- Cursor shaping (Block in Normal, Beam in Insert) handled natively via guicursor
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- Restore blinking beam cursor in terminal upon exiting Neovim
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.opt.guicursor = "a:ver25-blinkwait700-blinkoff400-blinkon250"
  end,
})

-- Note: Bracketed paste (<Esc>[200~ ... <Esc>[201~) is handled natively by Neovim,
-- so Vim's XTermPasteBegin() / pastetoggle workaround is intentionally omitted.


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 4. THEMES & VISUALS                                                          ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
vim.opt.termguicolors = true
vim.opt.colorcolumn = "80"

-- Default Colorscheme
vim.cmd.colorscheme("synthwave84")
-- vim.cmd.colorscheme("onedark")

-- Enable transparency (preserves foreground colors)
local transparent_groups = {
  "Normal",
  "NonText",
  "NormalNC",
  "SignColumn",
  "EndOfBuffer",
}
for _, group in ipairs(transparent_groups) do
  vim.cmd(string.format("highlight %s guibg=NONE ctermbg=NONE", group))
end


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 5. MACHINE LOCAL OVERRIDES                                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
-- Load local config for machine-specific themes or settings
local local_vimrc = vim.fn.expand("~/.vimrc.local")
if vim.fn.filereadable(local_vimrc) == 1 then
  vim.cmd.source(local_vimrc)
end

local local_lua = vim.fn.expand("~/.config/nvim/local.lua")
if vim.fn.filereadable(local_lua) == 1 then
  dofile(local_lua)
end
