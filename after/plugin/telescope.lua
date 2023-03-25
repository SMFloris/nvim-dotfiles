
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fp', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("Search > ") 
});
end)
vim.keymap.set('n', '<leader>ff', function()
	local path = vim.loop.cwd() .. "/.git"
	local ok, err = vim.loop.fs_stat(path)
	if not ok then
		builtin.find_files({})
	else
		builtin.git_files({})
	end
end)
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>dd', builtin.diagnostics, {})
