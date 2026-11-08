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
-- Space as the leader key (matches VSCodeVim). Must be set before any
-- <leader> mappings, since they capture the leader at definition time.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
    if vim.opt.number:get() and vim.api.nvim_get_mode().mode ~= "i"
        and vim.bo.buftype ~= "terminal" then
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

-- <leader>a: multi-cursor on every match of the word under cursor / selection
-- (vim-visual-multi; mirrors VSCodeVim's <leader>a). Then c to change all.
vim.keymap.set("n", "<leader>a", "<Plug>(VM-Select-All)", { desc = "Select all matches" })
vim.keymap.set("x", "<leader>a", "<Plug>(VM-Visual-All)", { desc = "Select all matches" })

-- <leader>e: open the built-in netrw file explorer
vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "File explorer" })


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
-- ║ 4. INTEGRATED TERMINAL                                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
-- Double-Esc leaves terminal mode (a single Esc still reaches the shell)
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Ctrl+h/j/k/l moves between windows, even from inside a terminal
for _, key in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("t", "<C-" .. key .. ">", [[<C-\><C-n><C-w>]] .. key,
    { desc = "Move to window " .. key })
end

-- Terminal buffers: no line numbers, start in insert mode
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("terminal_setup", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- <leader>t (Space then t) opens a 15-line terminal at the bottom
vim.keymap.set("n", "<leader>t", function()
  vim.cmd("botright 15split | terminal")
end, { desc = "Open bottom terminal" })


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║ 5. THEMES & VISUALS                                                          ║
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
-- ║ 6. MACHINE LOCAL OVERRIDES                                                   ║
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
