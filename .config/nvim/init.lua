-- Install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })
  vim.cmd([[packadd packer.nvim]])
end


require('packer').startup(function(use)
  -- Package manager
  use('wbthomason/packer.nvim')

  use({ -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  })

  use({ -- Autocompletion
    'hrsh7th/nvim-cmp',
    requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  })

  use({ -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update({ with_sync = true }))
    end,
  })

  use({ -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  })

  -- Git related plugins
  use('tpope/vim-fugitive')
  use('tpope/vim-rhubarb')
  use('lewis6991/gitsigns.nvim')

  use 'ellisonleao/gruvbox.nvim'
  use('folke/tokyonight.nvim')
  use('nvim-lualine/lualine.nvim')           -- Fancier statusline
  use('lukas-reineke/indent-blankline.nvim') -- Add indentation guides even on blank lines
  use('numToStr/Comment.nvim')               -- "gc" to comment visual regions/lines
  use('tpope/vim-sleuth')                    -- Detect tabstop and shiftwidth automatically

  -- Fuzzy Finder (files, lsp, etc)
  use({
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    requires = { 'nvim-lua/plenary.nvim' },
  })

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use({
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    cond = vim.fn.executable('make') == 1,
  })

  -- DAP
  -- use('puremourning/vimspector')
  -- use('mfussenegger/nvim-dap')
  -- use('leoluz/nvim-dap-go')


  -- AutoPairs
  use({
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({})
    end,
  })


  use('mfussenegger/nvim-lint')


  -- Packer
  -- use({
  --   "jackMort/ChatGPT.nvim",
  --     config = function()
  --       require("chatgpt").setup({
  --         -- optional configuration
  --       })
  --     end,
  --     requires = {
  --       "MunifTanjim/nui.nvim",
  --       "nvim-lua/plenary.nvim",
  --       "nvim-telescope/telescope.nvim"
  --     }
  -- })

  -- tmux
  use({
    "aserowy/tmux.nvim",
    config = function() return require("tmux").setup() end
  })

  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" }
    }
  }

  -- use { "github/copilot.vim" }
  -- use {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require('copilot').setup({
  --       panel = {
  --         enabled = true,
  --         auto_refresh = false,
  --         keymap = {
  --           jump_prev = "[[",
  --           jump_next = "]]",
  --           accept = "<CR>",
  --           refresh = "gr",
  --           open = "<M-CR>"
  --         },
  --         layout = {
  --           position = "bottom", -- | top | left | right
  --           ratio = 0.4
  --         },
  --       },
  --       suggestion = {
  --         enabled = true,
  --         auto_trigger = true,
  --         debounce = 75,
  --         keymap = {
  --           accept = "<C-l>",
  --           accept_word = false,
  --           accept_line = false,
  --           next = "<M-]>",
  --           prev = "<M-[>",
  --           dismiss = "<C-]>",
  --         },
  --       },
  --       filetypes = {
  --         yaml = false,
  --         markdown = false,
  --         help = false,
  --         gitcommit = false,
  --         gitrebase = false,
  --         hgcommit = false,
  --         svn = false,
  --         cvs = false,
  --         ["."] = false,
  --       },
  --       copilot_node_command = 'node', -- Node.js version must be > 16.x
  --       server_opts_overrides = {},
  --     })
  --   end,
  -- }


  -- install without yarn or npm
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })

  use({ 'fatih/vim-go' })
  -- use({
  --   "xiyaowong/nvim-transparent"
  -- })

  -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print('==================================')
  print('    Plugins are being installed')
  print('    Wait until Packer completes,')
  print('       then restart nvim')
  print('==================================')
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand('$MYVIMRC'),
})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set colorscheme
-- vim.o.background = "light" -- --[[ o ]]r "light" for light mode
-- vim.cmd([[colorscheme tokyonight-storm]])
vim.cmd([[colorscheme gruvbox]])

-- require("transparent").setup({
--   enable = true, -- boolean: enable transparent
--   extra_groups = { -- table/string: additional groups that should be cleared
--     -- In particular, when you set it to 'all', that means all available groups
--
--     -- example of akinsho/nvim-bufferline.lua
--     "BufferLineTabClose",
--     "BufferlineBufferSelected",
--     "BufferLineFill",
--     "BufferLineBackground",
--     "BufferLineSeparator",
--     "BufferLineIndicatorSelected",
--   },
--   exclude = {}, -- table: groups you don't want to clear
--   ignore_linked_group = true, -- boolean: don't clear a group that links to another group
-- })

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
vim.opt.nu = true
vim.wo.number = true
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.opt.relativenumber = true
vim.opt.errorbells = false
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append('@-@')
vim.opt.colorcolumn = '80'
vim.opt.background = 'dark'
vim.opt.cmdheight = 1
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup({
  options = { icons_enabled = false, theme = 'tokyonight', component_separators = '|', section_separators = '',
  },
})

require('Comment').setup()


require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup({
  defaults = {
    -- mappings = {
    --   i = {
    --     ['<C-u>'] = false,
    --     ['<C-d>'] = false,
    --   },
    -- },
  },
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown({
      winblend = 10,
      previewer = false,
    })
  )
end, { desc = '[/] Fuzzily search in current buffer]' })
vim.keymap.set('n', '<leader>?', function()
  require('telescope.builtin').keymaps(
    require('telescope.themes').get_dropdown({
      winblend = 10,
      previewer = false,
    })
  )
end, { desc = '[?] keymaps?' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup({
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'c',
    'cpp',
    'vim',
    'go',
    'python',
    'rust',
    'toml',
    'typescript',
    'javascript',
    'html',
    'css',
    'json',
    'http',
  },
  autotag = { enable = true },
  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>dof', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>dsl', vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>Ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>Wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>Wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>Wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  rust_analyzer = {},
  jedi_language_server = {},
  gopls = {},
  tsserver = {},
}

-- Setup neovim lua configuration
require('neodev').setup()
--
-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
  function(server_name)
    require('lspconfig')[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    })
  end,
})

-- Turn on lsp status information
require('fidget').setup()


-- nvim-cmp setup
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

local map = vim.api.nvim_set_keymap

-- Better scrolling
map('n', '<C-d>', "<C-d>zz", { noremap = true, silent = false })
map('n', '<C-u>', "<C-u>zz", { noremap = true, silent = false })

-- Better copy and paste
-- Yank to system clipboard using xclip in normal mode
-- map('n', '<leader>y', 'yy:"_p<CR>:echo system("xclip -in -selection clipboard", @")<CR>',
--   { noremap = true, silent = true })
-- -- Yank to system clipboard using xclip in visual mode
-- map('v', '<leader>y', 'y:echo system("xclip -in -selection clipboard", @0)<CR>', { noremap = true, silent = true })

-- Mac Copy and Paste
vim.api.nvim_set_keymap('n', '<leader>y', 'yy:<C-U>lua vim.fn.system("pbcopy", vim.fn.getreg("0"))<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>y', 'y:<C-U>lua vim.fn.system("pbcopy", vim.fn.getreg("0"))<CR>', { noremap = true, silent = true })



-- Smart way to move between windows
map('n', '<C-h>', '<C-W>h', { noremap = true, silent = false })
map('n', '<C-j>', '<C-W>j', { noremap = true, silent = false })
map('n', '<C-k>', '<C-W>k', { noremap = true, silent = false })
map('n', '<C-l>', '<C-W>l', { noremap = true, silent = false })

map('n', '<leader>h', '<C-W>h', { noremap = true, silent = false })
map('n', '<leader>j', '<C-W>j', { noremap = true, silent = false })
map('n', '<leader>k', '<C-W>k', { noremap = true, silent = false })
map('n', '<leader>l', '<C-W>l', { noremap = true, silent = false })

-- Resizing
map('n', '<A-l>', ':vertical resize +20<CR>', { noremap = true, silent = true })
map('n', '<A-h>', ':vertical resize -20<CR>', { noremap = true, silent = true })
map('n', '<A-k>', ':resize +20<CR>', { noremap = true, silent = true })
map('n', '<A-j>', ':resize -20<CR>', { noremap = true, silent = true })

-- Netrw
map('n', '<leader>e', ':Explore<CR>', { noremap = true, silent = false })

-- Neovim Buffers
map('n', '<leader>bd', ':bd<CR>', { noremap = true, silent = false })
map('n', '<leader>bw', ':bw<CR>', { noremap = true, silent = false })

-- Fast Save
map('n', '<leader>w', ':w<CR>', { noremap = true, silent = false })

map('n', '<leader>f', ':Format<CR>', { noremap = true, silent = false })



-- Tabs
-- Go to tab by number
map('n', '<leader>1', '1gt', { noremap = true, silent = false })
map('n', '<leader>2', '2gt', { noremap = true, silent = false })
map('n', '<leader>3', '3gt', { noremap = true, silent = false })
map('n', '<leader>4', '4gt', { noremap = true, silent = false })
map('n', '<leader>5', '5gt', { noremap = true, silent = false })
map('n', '<leader>6', '6gt', { noremap = true, silent = false })
map('n', '<leader>7', '7gt', { noremap = true, silent = false })
map('n', '<leader>8', '8gt', { noremap = true, silent = false })
map('n', '<leader>9', '9gt', { noremap = true, silent = false })
map('n', '<leader>0', ':tablast<CR>', { noremap = true, silent = false })

map('n', '<leader>tn', ':$tabnew<CR>', { noremap = true, silent = false })
map('n', '<leader>tt', ':$tab split<CR>', { noremap = true, silent = false })
map('n', '<leader>tc', ':tabclose<CR>', { noremap = true, silent = false })
map('n', '<leader>to', ':tabonly<CR>', { noremap = true, silent = false })

-- Debugging
-- For C/C++/Rust use CodeLLDB
vim.cmd([[
let g:vimspector_sidebar_width = 85
let g:vimspector_bottombar_height = 15
let g:vimspector_terminal_maxwidth = 70
]])
map('n', ',d', ':call vimspector#Launch()<cr>', { noremap = true, silent = false })
map('n', ',n', ':call vimspector#StepOver()<cr>',{ noremap = true, silent = false })
map('n', ',o', ':call vimspector#StepOut()<cr>',{ noremap = true, silent = false })
map('n', ',i', ':call vimspector#StepInto()<cr>',{ noremap = true, silent = false })
map('n', ',b', ':call vimspector#ToggleBreakpoint()<cr>',{ noremap = true, silent = false })
map('n', ',w', ':call vimspector#AddWatch()<cr>',{ noremap = true, silent = false })
map('n', ',e', ':call vimspector#Evaluate()<cr>',{ noremap = true, silent = false })
map('n', ',x', ':call vimspector#Stop()<cr>',{ noremap = true, silent = false })
map('n', ',R', ':call vimspector#Reset()<cr>', { noremap = true, silent = false })
map('n', ',r', ':call vimspector#Restart()<cr>',{ noremap = true, silent = false })
map('n', ',c', ':call vimspector#ClearBreakpoints()<cr>',{ noremap = true, silent = false })

-- Refactoring
-- Remaps for the refactoring operations currently offered by the plugin
vim.api.nvim_set_keymap("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>rf",
  [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
  { noremap = true, silent = true, expr = false })
-- Extract block doesn't need visual mode
vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]],
  { noremap = true, silent = true, expr = false })
vim.api.nvim_set_keymap("n", "<leader>rB", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
  { noremap = true, silent = true, expr = false })
-- Inline variable can also pick up the identifier currently under the cursor without visual mode
vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
  { noremap = true, silent = true, expr = false })

-- Markdown
map('n', '<leader>mp', ':MarkdownPreview<cr>', { noremap = true, silent = false })
map('n', '<leader>ms', ':MarkdownPreviewStop<cr>', { noremap = true, silent = false })
map('n', '<leader>mt', ':MarkdownPreviewToggle<cr>', { noremap = true, silent = false })

-- Pandocs
map('n', '<leader>b', ':w <bar> silent !pandoc % -o %:r.pdf > /dev/null<CR>', { noremap = true, silent = true })
map('n', '<leader>z', ':silent !zathura %:r.pdf &<CR>', { noremap = true, silent = true })



--

-- AutoPairs
local status, autopairs = pcall(require, 'nvim-autopairs')
if not status then
  return
end

autopairs.setup({
  disable_filetype = { 'TelescopePrompt', 'vim' },
})


-- fugitive remaps
map('n', '<leader>G', ':G<CR>', { noremap = true, silent = false })
map('n', '<leader>ga', ':Git add %:p<CR><CR>', { noremap = true, silent = false })
map('n', '<leader>gd', ':Gdiff<CR>', { noremap = true, silent = false })
map('n', '<leader>gl', ':Git log<CR>', { noremap = true, silent = false })
map('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = false })
map('n', '<leader>gC', ':Git commit -v<CR>', { noremap = true, silent = false })
map('n', '<leader>gS', ':Git status<CR>', { noremap = true, silent = false })
map('n', '<leader>gD', ':Gvdiffsplit<CR>', { noremap = true, silent = false })
map('n', '<leader>gp', ':Git push<CR>', { noremap = true, silent = false })
map('n', '<leader>gP', ':Git pull<CR>', { noremap = true, silent = false })

-- Workspace remaps
map('n', '<leader>Wc', ':pwd<CR>', { desc = '[W]orkspace [C]urrent', noremap = true, silent = false })
map('n', '<leader>Wd', ':cd %:p:h<CR>:pwd<CR>', { desc = '[W]orkspace [D]irectory', noremap = true, silent = false })
map('n', '<leader>Wh', ':cd <CR>:pwd<CR>', { noremap = true, silent = false })



-- ChatGPT
-- map('n', '<leader>ai', ':ChatGPT<CR>', { noremap = true, silent = false })

-- Install linters for these languages.
-- ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'toml',
--     'typescript', 'html', 'css', 'json', 'help' },
-- Linters
require('lint').linters_by_ft = {
  -- markdown = { 'vale' },
  typescript = { 'eslint_d' },
}
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function()
    require('lint').try_lint()
  end,
})

-- Formatters


-- To Do
--------
-- Test runner https://github.com/vim-test/vim-test -> https://github.com/tpope/vim-dispatch
-- Formatters
