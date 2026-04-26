return {
  "marellab/nog.nvim",
  name = "nog",
  dev = vim.fn.isdirectory(vim.fn.expand("~/workspace/plugins/nog.nvim")) == 1,
  dir = vim.fn.isdirectory(vim.fn.expand("~/workspace/plugins/nog.nvim")) == 1
    and "~/workspace/plugins/nog.nvim"
    or nil,
  config = function()
    require("nog").setup()
  end,
  keys = {
    { "<leader>nr", "<cmd>Lazy reload nog<cr>", desc = "Reload Nog plugin for testing" },
    { "<leader>ng", function() require("nog").toggle() end, desc = "Open Nog Window" },
  }
}
