" ~/.vimrc -- plain-Vim port of .config/nvim/init.lua
" Target: Apple /usr/bin/vim 9.0 (-python3 -lua -clientserver). Languages: python, go,
" java, typescript/javascript. See ~/.dotfiles/.config/nvim/init.lua for the nvim config;
" the two are independent and share only ~/.vim/undodir.

" Must come first: with `vim -u <file>` Vim does not imply 'nocompatible', and 'C' in
" cpoptions disables the backslash line continuations used below.
set nocompatible

" Leader must be set before plugins load.
let mapleader = ' '
let maplocalleader = ' '

" [[ Bootstrap vim-plug ]]
let s:plug = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug))
  silent execute '!curl -fLo ' . s:plug . ' --create-dirs'
        \ . ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Colorscheme
Plug 'morhetz/gruvbox'

" LSP. vim-lsp is pure vimscript: Apple's vim has no +python3/+lua, and 9.0.2018 is below
" yegappan/lsp's floor. vim-lsp-settings replaces mason + mason-lspconfig.
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" Autocompletion
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" Fuzzy finder. The brew-installed fzf ships its own vim plugin; pointing Plug at the
" formula dir keeps the binary and the plugin in lockstep instead of cloning a second copy.
Plug '/opt/homebrew/opt/fzf'
Plug 'junegunn/fzf.vim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'

" UI / editing
Plug 'itchyny/lightline.vim'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-highlightedyank'

" tmux integration. Owns <C-hjkl>; the <M-hjkl> resize is hand-rolled below.
Plug 'christoomey/vim-tmux-navigator'

" Go. vim-go starts its own gopls unless told not to, which would race vim-lsp; see the
" g:go_* block below. Kept for :GoBuild/:GoTest/:GoFillStruct and gofmt-on-save.
Plug 'fatih/vim-go', { 'for': 'go' }

" Markdown preview. 'vim-plug' must be in the ft list or the plugin is not on the
" runtimepath when :PlugInstall runs the build step.
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install',
      \ 'for': ['markdown', 'vim-plug'] }

call plug#end()

" [[ Options ]]
" Things nvim defaults on and vim does not.
syntax enable
filetype plugin indent on
set encoding=utf-8
set backspace=indent,eol,start
set hidden
set laststatus=2
set ttimeout
set ttimeoutlen=10
set belloff=all

set background=dark
silent! colorscheme gruvbox

set completeopt=menuone,noselect
set number
set relativenumber
set mouse=a
set breakindent
set noerrorbells
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nowrap
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set nohlsearch
set incsearch
set scrolloff=8
set signcolumn=yes
set isfname+=@-@
set colorcolumn=80
set cmdheight=1
set ignorecase
set smartcase
set updatetime=250

" termguicolors inside tmux needs the RGB escapes declared explicitly, and tmux must
" advertise RGB for screen-256color (see terminal-features in ~/.tmux.conf).
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" [[ Plugin options ]]
let g:lightline = { 'colorscheme': 'powerline' }

let g:gitgutter_sign_added              = '+'
let g:gitgutter_sign_modified           = '~'
let g:gitgutter_sign_removed            = '_'
let g:gitgutter_sign_removed_first_line = "‾"
let g:gitgutter_sign_modified_removed   = '~'

" indentLine drives 'conceallevel', which mangles markdown/json rendering.
let g:indentLine_char = '|'
let g:indentLine_fileTypeExclude = ['markdown', 'json', 'help', 'fzf']

let g:highlightedyank_highlight_duration = 150

" Don't wrap around at the outermost pane -- mirrors the `if -F '#{pane_at_left}'` guards
" on the non-vim branch of ~/.tmux.conf, so edges behave the same whichever side handles
" the key.
let g:tmux_navigator_no_wrap = 1

" auto-pairs off in vimscript (matches nvim-autopairs' disable_filetype).
autocmd FileType vim let b:AutoPairs = {}

" vim-go. g:go_gopls_enabled is the one that does not appear in the nvim config: under
" nvim, tooling came from gopls-via-lspconfig only. Here vim-go would start a second
" gopls of its own.
let g:go_gopls_enabled          = 0
let g:go_def_mapping_enabled    = 0
let g:go_code_completion_enabled = 0
let g:go_doc_keywordprg_enabled = 0

" Syntax highlighting. vim-go ships these but defaults every one of them to 0, which is
" why stock Go looks flat compared to the treesitter setup under nvim. Regex-based, so it
" works with no server attached and covers gomod/templates too. The whitespace-error
" flags stay off (they paint alignment red), as do variable_declarations/assignments --
" semantic tokens below colour variables more accurately.
let g:go_highlight_types               = 1
let g:go_highlight_fields              = 1
let g:go_highlight_functions           = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls      = 1
let g:go_highlight_operators           = 1
let g:go_highlight_extra_types         = 1
let g:go_highlight_build_constraints   = 1
let g:go_highlight_generate_tags       = 1
let g:go_highlight_format_strings      = 1

" [[ LSP ]]
" Semantic tokens: the server tells vim what each identifier actually *is*, which is the
" closest plain-vim gets to treesitter highlighting. Must be enabled at BOTH ends -- gopls
" ships `semanticTokens: false`, and it decides whether to advertise semanticTokensProvider
" during `initialize`, so the flag has to ride in initialization_options; sending it later
" as workspace_config is too late and the server reports no legend at all.
let g:lsp_semantic_enabled = 1

" vim-lsp REPLACES its default client capabilities when a server declares its own
" (autoload/lsp.vim: `if has_key(l:server_info, 'capabilities')`), and vim-lsp-settings'
" gopls entry declares only a documentSymbol stub. That silently drops vim-lsp's
" semanticTokens.tokenTypes list, and gopls derives its legend by intersecting with what
" the client declares -- so it answers with an empty legend and zero tokens. Rebuild the
" full default block and merge gopls' own addition back in.
function! s:gopls_capabilities(...) abort
  let l:caps = lsp#default_get_supported_capabilities({})
  call extend(l:caps['textDocument'],
        \ {'documentSymbol': {'hierarchicalDocumentSymbolSupport': v:true}}, 'force')
  return l:caps
endfunction

" vim-lsp-settings has no merge hook (it replaces the key wholesale), so the rest of this
" dict is its own gopls default copied verbatim -- re-sync with
" ~/.vim/plugged/vim-lsp-settings/settings/gopls.vim if that file changes.
let g:lsp_settings = {
      \ 'gopls': {
      \   'initialization_options': {
      \     'semanticTokens': v:true,
      \     'completeUnimported': v:true,
      \     'matcher': 'fuzzy',
      \     'ui.inlayhint.hints': {
      \       'assignVariableTypes': v:true,
      \       'compositeLiteralFields': v:true,
      \       'compositeLiteralTypes': v:true,
      \       'constantValues': v:true,
      \       'functionTypeParameters': v:true,
      \       'parameterNames': v:true,
      \       'rangeVariableTypes': v:true,
      \     },
      \     'codelenses': { 'generate': v:true, 'test': v:true },
      \   },
      \   'capabilities': function('s:gopls_capabilities'),
      \ },
      \ }

" vim-lsp auto-links most LspSemantic* groups to sensible defaults, but these token types
" -- emitted by gopls/ts_ls/jdt.ls -- have no default and would render as plain Normal.
" Applied now rather than on VimEnter (which fires after -c/-S commands), and re-applied
" whenever the colorscheme changes, since that clears highlight links.
function! s:LspSemanticColors() abort
  highlight default link LspSemanticNamespace        Identifier
  highlight default link LspSemanticMember           Identifier
  highlight default link LspSemanticAnnotationMember Identifier
  highlight default link LspSemanticRecordComponent  Identifier
  highlight default link LspSemanticRecord           Type
  highlight default link LspSemanticLabel            Label
endfunction

call s:LspSemanticColors()
augroup lsp_semantic_colors
  autocmd!
  autocmd ColorScheme * call s:LspSemanticColors()
augroup END

let g:lsp_diagnostics_enabled       = 1
let g:lsp_diagnostics_echo_cursor   = 0
let g:lsp_diagnostics_float_cursor  = 1
let g:lsp_document_highlight_enabled = 0
let g:lsp_fold_enabled              = 0

" Pin one server per language so vim-lsp-settings does not offer the whole catalogue.
let g:lsp_settings_filetype_python     = ['jedi-language-server']
let g:lsp_settings_filetype_go         = ['gopls']
let g:lsp_settings_filetype_java       = ['eclipse-jdt-ls']
let g:lsp_settings_filetype_typescript = ['typescript-language-server']
let g:lsp_settings_filetype_javascript = ['typescript-language-server']

" vim-lsp drops reference results into the quickfix list. Pipe that through fzf so `gr`
" behaves like the telescope picker it replaces (there is no vim-lsp/fzf bridge plugin --
" ojroques/vim-lsp-fuzzy is neovim-only).
function! s:lsp_list_sink(line) abort
  let l:m = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\(\d\+\):')
  if empty(l:m) | return | endif
  execute 'edit ' . fnameescape(l:m[1])
  call cursor(str2nr(l:m[2]), str2nr(l:m[3]))
  normal! zz
endfunction

function! s:lsp_qf_to_fzf(prompt) abort
  let l:list = filter(getqflist(), {_, v -> v.bufnr > 0})
  if empty(l:list)
    echohl WarningMsg | echo 'No results' | echohl None
    return
  endif
  let l:lines = map(copy(l:list), {_, v -> printf('%s:%d:%d: %s',
        \ fnamemodify(bufname(v.bufnr), ':.'), v.lnum, v.col, trim(v.text))})
  cclose
  " fzf#vim#with_preview bolts on fzf.vim's preview.sh, which reads the `file:line` prefix
  " and renders that file centred on the line. The option set mirrors fzf.vim's own :Rg
  " (same delimiter and '+{2}/2' scroll offset) so this picker behaves like the others.
  call fzf#run(fzf#wrap(fzf#vim#with_preview({
        \ 'source': l:lines,
        \ 'sink': function('s:lsp_list_sink'),
        \ 'options': ['--ansi', '--prompt', a:prompt . '> ',
        \             '--delimiter', ':', '--preview-window', '+{2}/2'],
        \ })))
endfunction

" LspReferences is async and vim-lsp emits no completion event, so clear the quickfix
" list, fire the request, and poll for the handler to fill it (50ms x 60 = 3s ceiling).
function! s:lsp_references_poll(timer) abort
  if !empty(getqflist())
    call timer_stop(a:timer)
    call s:lsp_qf_to_fzf('References')
  endif
endfunction

function! s:lsp_references_fzf() abort
  call setqflist([])
  LspReferences
  call timer_start(50, function('s:lsp_references_poll'), {'repeat': 60})
endfunction

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes

  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> <leader>ca <plug>(lsp-code-action-float)

  nmap <buffer> gd <plug>(lsp-definition)
  nnoremap <buffer> <silent> gr :call <SID>lsp_references_fzf()<CR>
  nmap <buffer> gI <plug>(lsp-implementation)
  nmap <buffer> gD <plug>(lsp-declaration)
  nmap <buffer> <leader>D  <plug>(lsp-type-definition)
  nmap <buffer> <leader>ds <plug>(lsp-document-symbol-search)
  nmap <buffer> <leader>Ws <plug>(lsp-workspace-symbol-search)

  nmap <buffer> K     <plug>(lsp-hover)
  " NOTE: this shadows vim-tmux-navigator's pane-up in LSP buffers -- same as the nvim
  " config, where the LspAttach mapping wins over tmux.nvim.
  nmap <buffer> <C-k> <plug>(lsp-signature-help)

  nmap <buffer> [d <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <plug>(lsp-next-diagnostic)

  command! -buffer Format LspDocumentFormat
endfunction

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" [[ Completion ]]
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"
imap <C-Space> <Plug>(asyncomplete_force_refresh)

" [[ Keymaps ]]
nnoremap <Space> <Nop>
vnoremap <Space> <Nop>

" Word-wrap aware j/k
nnoremap <expr> <silent> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> <silent> j v:count == 0 ? 'gj' : 'j'

" fzf (was telescope)
nnoremap <leader><space> :Buffers<CR>
nnoremap <leader>/ :BLines<CR>
nnoremap <leader>? :Maps<CR>
nnoremap <leader>sf :Files<CR>
nnoremap <leader>sh :Helptags<CR>
nnoremap <leader>sw :execute 'Rg ' . expand('<cword>')<CR>
nnoremap <leader>sg :Rg<CR>
nnoremap <leader>sd :LspDocumentDiagnostics<CR>

" Diagnostics. g:lsp_diagnostics_float_cursor above covers what <leader>dof's
" open_float() did; vim-lsp has no separate float command.
nnoremap <leader>dof :LspDocumentDiagnostics<CR>
nnoremap <leader>dsl :LspDocumentDiagnostics<CR>

" Better scrolling
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Mac copy to system clipboard. xnoremap, not vnoremap: nvim's 'v' mode is visual+select,
" and binding select mode here would shadow typing over a selection.
nnoremap <silent> <leader>y yy:<C-u>call system('pbcopy', getreg('0'))<CR>
xnoremap <silent> <leader>y y:<C-u>call system('pbcopy', getreg('0'))<CR>

" Window navigation.
" NOTE: <C-hjkl> is deliberately NOT mapped here. vim-tmux-navigator owns it so that
" hitting an edge window hands control back to tmux for pane switching (see the is_vim
" guard in ~/.tmux.conf). Mapping it here would shadow the plugin and silently break
" cross-pane movement. <M-hjkl> is handled by s:TmuxAwareResize below.
" Terminal vim needs the Alt termcodes spelled out; nvim recognises <M-...> natively.
execute "set <M-h>=\<Esc>h"
execute "set <M-j>=\<Esc>j"
execute "set <M-k>=\<Esc>k"
execute "set <M-l>=\<Esc>l"

" <M-hjkl> resize: adjust the vim split when this buffer is in a split, otherwise hand the
" resize to tmux so the pane grows -- what tmux.nvim did under neovim. Rolled by hand
" because melonmanchan/vim-tmux-resizer only ever resizes vim windows, never calls tmux,
" and emits a literal <CR> into :execute (so it is a no-op at best).
function! s:TmuxAwareResize(dir) abort
  if winnr('$') > 1
    execute {'h': 'vertical resize -1', 'l': 'vertical resize +1',
          \ 'j': 'resize +1', 'k': 'resize -1'}[a:dir]
  elseif !empty($TMUX)
    call system('tmux resize-pane '
          \ . {'h': '-L', 'j': '-D', 'k': '-U', 'l': '-R'}[a:dir] . ' 1')
  endif
endfunction

nnoremap <silent> <M-h> :call <SID>TmuxAwareResize('h')<CR>
nnoremap <silent> <M-j> :call <SID>TmuxAwareResize('j')<CR>
nnoremap <silent> <M-k> :call <SID>TmuxAwareResize('k')<CR>
nnoremap <silent> <M-l> :call <SID>TmuxAwareResize('l')<CR>

nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Netrw
nnoremap <leader>e :Explore<CR>

" Buffers
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bw :bw<CR>

" Fast save / format
nnoremap <leader>w :w<CR>
nnoremap <leader>f :Format<CR>

" Tabs
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>0 :tablast<CR>
nnoremap <leader>tn :$tabnew<CR>
nnoremap <leader>tt :$tab split<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>to :tabonly<CR>

" Markdown
nnoremap <leader>mp :MarkdownPreview<CR>
nnoremap <leader>ms :MarkdownPreviewStop<CR>
nnoremap <leader>mt :MarkdownPreviewToggle<CR>

" Pandoc. NOTE: <leader>b is a prefix of <leader>bd/<leader>bw, so those wait out
" 'timeoutlen'. Carried over from the nvim config as-is.
" nnoremap <silent> <leader>b :w <bar> silent !pandoc % -o %:r.pdf > /dev/null<CR>
" nnoremap <silent> <leader>z :silent !zathura %:r.pdf &<CR>

" Fugitive
nnoremap <leader>G  :G<CR>
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gl :Git log<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gC :Git commit -v<CR>
nnoremap <leader>gS :Git status<CR>
nnoremap <leader>gD :Gvdiffsplit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gP :Git pull<CR>

" Workspace
nnoremap <leader>Wc :pwd<CR>
nnoremap <leader>Wd :cd %:p:h<CR>:pwd<CR>
nnoremap <leader>Wh :cd <CR>:pwd<CR>

" vim: ts=2 sts=2 sw=2 et
