local lib = require("nvim-tree.lib")

local circles = require('circles')

circles.setup({ icons = { empty = '', filled = '', lsp_prefix = '' }, lsp = true })

local function open_last_file()
  local oldfiles = vim.v.oldfiles

  for _, filepath in pairs(oldfiles) do
    if vim.startswith(filepath, vim.fn.getcwd()) then
      vim.cmd.edit(filepath)
      break
    end
  end
end

local function open_nvim_tree(data)


  -- buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1
  
  if directory then
    -- create a new, empty buffer
    vim.cmd.enew()

    -- wipe the directory buffer
    vim.cmd.bw(data.buf)
    vim.cmd.cd(data.file)
    vim.defer_fn(open_last_file, 20)
  else
    -- buffer is a real file on the disk
    local real_file = vim.fn.filereadable(data.file) == 1

    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    if not real_file and no_name then  
      return
    end
  end


  -- open the tree, find the file but don't focus it
  require("nvim-tree.api").tree.toggle({focus = false})
end


local git_add = function()
  local node = lib.get_node_at_cursor()
  local gs = node.git_status.file
  
  print("GS IS: ", gs, " FOR ",node.absolute_path)

  -- If the file is untracked, unstaged or partially staged, we stage it
  if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
    vim.cmd("silent !git add " .. node.absolute_path)

  -- If the file is staged, we unstage
  elseif gs == "M " or gs == "A " then
    vim.cmd("silent !git restore --staged " .. node.absolute_path)
  end

  lib.refresh_tree()
end

local merge = function(first_table, second_table)
  for k,v in pairs(second_table) do first_table[k] = v end
  return first_table
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
vim.api.nvim_create_autocmd({ "QuitPre"  }, {
    callback = function() vim.cmd("NvimTreeClose") end,
})
vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeToggle<cr>",
  {silent = true, noremap = true}
)
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFocus<cr>",
  {silent = true, noremap = true}
)
vim.keymap.set("n", "<leader>fe", "<cmd>NvimTreeFindFile<bar>NvimTreeFocus<cr>",
  {silent = true, noremap = true}
)

require("nvim-tree").setup({
  view = {
    mappings = {
      list = {
        { key = "ga", action = "git_add", action_cb = git_add },
      }
    },
  },
  renderer = {
    highlight_git = true,
    icons = {
      git_placement = "after",
      glyphs = merge(circles.get_nvimtree_glyphs(), {
            git = {
              unstaged = "",
              staged = "",
              unmerged = "",
              renamed = "",
              untracked = "*",
              deleted = "",
              ignored = "",
            },
      })
    },
  },
  git = {
    show_on_dirs = true,
    show_on_open_dirs = false
  }
})
