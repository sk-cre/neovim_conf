vim.cmd.packadd "packer.nvim"

-- Automatically install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system({"git","clone","--depth","1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

require("packer").startup(function(use)
	use({ "wbthomason/packer.nvim" })
    use({ 'neoclide/coc.nvim', {branch = 'release'}})
    use({ 'honza/vim-snippets' })
	use({ "rust-lang/rust.vim" })
    use({ "sainnhe/gruvbox-material" })
	use({ "MunifTanjim/prettier.nvim" })
	use({ "nvim-telescope/telescope.nvim" })

    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
	use({ "nvim-telescope/telescope-file-browser.nvim" })
	use({ "windwp/nvim-ts-autotag" })

end)
