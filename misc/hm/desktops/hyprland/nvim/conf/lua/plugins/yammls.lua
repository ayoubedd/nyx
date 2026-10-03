return {
  'tonychg/nvim-k8s-lsp',
  config = function()
    require("nvim-k8s-lsp").setup({
      kubernetes_version = "v1.32.2",
      lsp = {
        clients = {
          yaml = "yaml",
          helm = "helm",
        },
      },
      schema_stores = {
        kubernetes = {
          repo = "yannh/kubernetes-json-schema",
          branch = "master",
        },
        kubernetes_crds = {
          repo = "datreeio/CRDs-catalog",
          branch = "main",
        },
      },
      integrations = {
        lualine = false,
      },
      ignore_groups = {
        "kind.x-k8s.io",
        "kustomize.config.k8s.io",
        "viaduct.ai",
      },
    })
  end,
}
