local circles = require('circles')

circles.setup({ icons = { empty = '', filled = '', lsp_prefix = '' }, lsp = true })

require('nvim-tree').setup({
  renderer = {
    icons = {
      glyphs = circles.get_nvimtree_glyphs(),
    },
  },
})
