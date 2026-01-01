-- if true then return {} end
return {
  -- Télécharge les thèmes
  { "ellisonleao/gruvbox.nvim" },

  -- Active Gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox"
    },
  }
}
