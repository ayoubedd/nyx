return {
  'tonychg/nvim-k8s-lsp',
  config = function()
    require("nvim-k8s-lsp").setup({
      kubernetes_version = "v1.32.2",
      lsp = {
        clients = {
          -- The names the clients are registered under (vim.lsp.enable).
          yaml = "yamlls",
          helm = "helm_ls",
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
    -- Keep only the per-buffer schema association. Its "deactivate the other
    -- server" step stops the whole client (every buffer, deprecated
    -- vim.lsp.stop_client) and guesses helm from any `templates/` path, so
    -- opening a chart's values.yaml killed helm_ls everywhere. Filetype
    -- detection (config/lsp.lua) already keeps yamlls and helm_ls apart.
    require("nvim-k8s-lsp").deactivate_other_lsp = function() end
  end,
}
