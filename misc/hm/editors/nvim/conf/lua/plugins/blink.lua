return {
  'saghen/blink.cmp',
  lazy = false, -- lazy loading handled internally
  -- optional: provides snippets for the snippet source
	dependencies = {
    { 'saghen/blink.compat', version = '*', opts = { impersonate_nvim_cmp = true } },
    "mikavilpas/blink-ripgrep.nvim",
    "rafamadriz/friendly-snippets"
  },
  -- use a release tag to download pre-built binaries
  version = 'v0.*',
  -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- see the "default configuration" section below for full documentation on how to define
    -- your own keymap.
    keymap = { preset = 'default' },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- will be removed in a future release
      use_nvim_cmp_as_default = false,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },


    -- snippets = {
    --   expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
    --   active = function(filter)
    --     if filter and filter.direction then
    --       return require('luasnip').jumpable(filter.direction)
    --     end
    --     return require('luasnip').in_snippet()
    --   end,
    --   jump = function(direction) require('luasnip').jump(direction) end,
    -- },

    -- default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, via `opts_extend`
    sources = {
      default = { 'lsp', 'path',  'buffer' },
      -- completion = {
      --   enabled_providers = { 'lsp', 'ripgrep', 'luasnip', 'path', 'snippets', 'buffer' },
      -- },
      providers = {
        -- ripgrep = {
        --   module = "blink-ripgrep",
        --   name = "Ripgrep",
        --   -- the options below are optional, some default values are shown
        --   ---@module "blink-ripgrep"
        --   ---@type blink-ripgrep.Options
        --   opts = {
        --     -- For many options, see `rg --help` for an exact description of
        --     -- the values that ripgrep expects.
        --
        --     -- the minimum length of the current word to start searching
        --     -- (if the word is shorter than this, the search will not start)
        --     prefix_min_len = 3,
        --
        --     -- The number of lines to show around each match in the preview window
        --     context_size = 5,
        --
        --     -- The maximum file size that ripgrep should include in its search.
        --     -- Useful when your project contains large files that might cause
        --     -- performance issues.
        --     -- Examples: "1024" (bytes by default), "200K", "1M", "1G"
        --     max_filesize = "1M",
        --   },
        -- },
        -- luasnip = {
        --   name = 'luasnip',
        --   module = 'blink.compat.source',
        --
        --   score_offset = -3,
        --
        --   opts = {
        --     use_show_condition = false,
        --     show_autosnippets = true,
        --   },
        -- },
      },
    },

    -- experimental auto-brackets support
    completion = { accept = { auto_brackets = { enabled = false } } },

    -- experimental signature help support
    signature = { enabled = true }
  },
  -- allows extending the enabled_providers array elsewhere in your config
  -- without having to redefine it
  opts_extend = { "sources.completion.enabled_providers" }
}
