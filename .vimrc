" ~/.vimrc -- plain-Vim port of .config/nvim/init.lua
" Target: Apple /usr/bin/vim 9.0 (-python3 -lua -clientserver). Languages: python, go,
" java, typescript/javascript. See ~/.dotfiles/.config/nvim/init.lua for the nvim config;
" the two are fully independent -- separate plugin dirs and separate undo dirs.

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
" NOT shared with neovim. Both write the same "Vim\x9fUnDo\xe5" magic, but vim writes
" undo version 2 and nvim writes version 3, and neither reads the other's -- so a shared
" undodir means E824 on every file the other editor has touched. Worse, the error is
" raised from inside :edit, so it also aborts vim-lsp's jump callbacks mid-flight.
" nvim keeps ~/.vim/undodir (see .config/nvim/init.lua); vim gets its own.
set undodir=~/.vim/undo-vim
set undofile
" vim does not create undodir itself; without this, undofile writes fail silently.
if !isdirectory(expand('~/.vim/undo-vim'))
  call mkdir(expand('~/.vim/undo-vim'), 'p', 0700)
endif
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

" fzf's built-in directory walker only skips .git and node_modules -- it knows nothing
" about .gitignore, so :Files would list vendored and generated trees. ripgrep honours
" .gitignore/.ignore by default, so hand fzf that instead. (:Rg already shells out to rg
" and is gitignore-aware without help.)
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
endif

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

" gopls and jdt.ls happily return references from vendored or generated files that git
" ignores. Ask git about the whole batch in one `check-ignore --stdin` call rather than
" once per path. Exit 0 = some ignored, 1 = none ignored, anything higher (e.g. not a
" repo) means leave the list alone.
let g:lsp_refs_respect_gitignore = 1

function! s:drop_gitignored(items) abort
  if empty(a:items) || !g:lsp_refs_respect_gitignore || !executable('git')
    return a:items
  endif
  let l:Path = {item -> fnamemodify(bufname(item.bufnr), ':p')}
  let l:out = systemlist('git check-ignore --stdin 2>/dev/null',
        \ map(copy(a:items), {_, v -> l:Path(v)}))
  if v:shell_error > 1
    return a:items
  endif
  let l:ignored = {}
  for l:line in l:out
    let l:ignored[l:line] = 1
  endfor
  return filter(copy(a:items), {_, v -> !has_key(l:ignored, l:Path(v))})
endfunction

function! s:lsp_qf_to_fzf(prompt) abort
  let l:raw = filter(getqflist(), {_, v -> v.bufnr > 0})
  let l:list = s:drop_gitignored(l:raw)
  if empty(l:list)
    echohl WarningMsg
    echo empty(l:raw) ? 'No results'
          \ : 'No results (all ' . len(l:raw) . ' are in git-ignored files)'
    echohl None
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

  if &filetype ==# 'java'
    " jdt.ls answers with jdt:// URIs for anything outside your sources (JDK, Spring,
    " any jar). vim-lsp has no handler for that scheme, so plain gd silently fails --
    " see s:JavaDefinition below.
    nnoremap <buffer> <silent> gd :call <SID>JavaDefinition()<CR>
  else
    nmap <buffer> gd <plug>(lsp-definition)
  endif
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

" [[ Java / Maven ]]
" Everything here degrades to a no-op when the server or tool is missing, so the same
" vimrc works on a machine that has none of it installed.

let s:jdtls_dir   = expand('~/.local/share/vim-lsp-settings/servers/eclipse-jdt-ls')
let s:spring_dir  = expand('~/.local/share/vim-lsp-settings/servers/spring-boot-language-server')

" The JVM that RUNS jdt.ls, resolved independently of $PATH. jenv rewrites `java` per
" directory, so in a module pinned to Java 8 the stock launcher would try to start
" jdt.ls (needs 21+) on Java 8 and it would simply never come up. /usr/libexec/java_home
" ignores jenv and reports the newest JDK, which is what we want for the server itself --
" the *project's* JDK is a separate matter, handled by java.configuration.runtimes below.
" $JDTLS_JAVA_HOME overrides everything if you need to pin it.
function! s:JdtlsJavaExe() abort
  if !empty($JDTLS_JAVA_HOME) && executable($JDTLS_JAVA_HOME . '/bin/java')
    return $JDTLS_JAVA_HOME . '/bin/java'
  endif
  if executable('/usr/libexec/java_home')
    let l:home = trim(system('/usr/libexec/java_home 2>/dev/null'))
    if v:shell_error == 0 && executable(l:home . '/bin/java')
      return l:home . '/bin/java'
    endif
  endif
  return 'java'
endfunction

" Every JDK we can find, named the way jdt.ls wants (JavaSE-1.8, JavaSE-17, ...), so a
" monolith targeting 8 and a service targeting 21 both resolve against the right one.
" jenv's own version dir is included because jenv-managed JDKs are often not registered
" with java_home.
function! s:JavaRuntimes() abort
  let l:globs = [
        \ '~/.jenv/versions/*',
        \ '/Library/Java/JavaVirtualMachines/*/Contents/Home',
        \ '~/Library/Java/JavaVirtualMachines/*/Contents/Home',
        \ '/opt/homebrew/opt/openjdk*/libexec/openjdk.jdk/Contents/Home',
        \ '/usr/local/opt/openjdk*/libexec/openjdk.jdk/Contents/Home',
        \ ]
  let l:seen = {}
  let l:out = []
  for l:g in l:globs
    for l:home in glob(expand(l:g), 0, 1)
      let l:home = resolve(l:home)
      if !filereadable(l:home . '/release') || has_key(l:seen, l:home)
        continue
      endif
      let l:ver = matchstr(join(readfile(l:home . '/release'), "\n"),
            \ 'JAVA_VERSION="\zs[0-9._]\+\ze"')
      if empty(l:ver) | continue | endif
      let l:major = l:ver =~# '^1\.' ? '1.' . split(l:ver, '\.')[1]
            \ : matchstr(l:ver, '^\d\+')
      let l:name = 'JavaSE-' . l:major
      if has_key(l:seen, l:name) | continue | endif
      let l:seen[l:home] = 1
      let l:seen[l:name] = 1
      call add(l:out, {'name': l:name, 'path': l:home})
    endfor
  endfor
  return l:out
endfunction

" One workspace per project. The stock launcher hardcodes `-data <install>/data`, shared
" by every Java project on the machine -- that single flag is the usual cause of jdt.ls
" reporting nonsense classpaths or thousands of phantom errors after you switch repos.
function! s:JdtlsDataDir(root) abort
  let l:dir = expand('~/.cache/jdtls/') . substitute(a:root, '[^A-Za-z0-9]', '_', 'g')
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif
  return l:dir
endfunction

" Nearest pom.xml = the module; walking up while the parent still has one = the reactor
" root. Builds and tests run in the module, full installs at the root.
function! s:MvnModuleDir() abort
  let l:pom = findfile('pom.xml', expand('%:p:h') . ';')
  return empty(l:pom) ? getcwd() : fnamemodify(l:pom, ':p:h')
endfunction

function! s:MvnRootDir() abort
  let l:d = s:MvnModuleDir()
  while filereadable(fnamemodify(l:d, ':h') . '/pom.xml')
    let l:d = fnamemodify(l:d, ':h')
  endwhile
  return l:d
endfunction

" vim-lsp-settings' catalog ships root_uri_patterns ['pom.xml','build.gradle'] and
" find_nearest_parent_file_directory returns the NEAREST hit -- in a multi-module build
" that is whichever module you happen to have open, so classes in sibling modules are
" invisible and cross-module gd fails. Anchor on the OUTERMOST pom instead: the reactor
" root in a monolith, the service root in a repo of independent services.
function! s:JdtlsRoot() abort
  return empty(findfile('pom.xml', expand('%:p:h') . ';'))
        \ ? lsp#utils#uri_to_path(lsp_settings#root_uri('eclipse-jdt-ls'))
        \ : s:MvnRootDir()
endfunction

function! s:JdtlsRootUri(...) abort
  return lsp#utils#path_to_uri(s:JdtlsRoot())
endfunction

function! s:JdtlsCmd(...) abort
  let l:launcher = glob(s:jdtls_dir . '/plugins/org.eclipse.equinox.launcher_*.jar')
  " config_mac is the x86 OSGi config; the stock installer picks it even on arm64.
  let l:cfg = s:jdtls_dir . (has('macunix') && system('uname -m') =~# 'arm64'
        \ ? '/config_mac_arm' : '/config_mac')
  if !isdirectory(l:cfg)
    let l:cfg = s:jdtls_dir . '/config_mac'
  endif
  let l:cmd = [s:JdtlsJavaExe(),
        \ '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        \ '-Dosgi.bundles.defaultStartLevel=4',
        \ '-Declipse.product=org.eclipse.jdt.ls.core.product',
        \ '-Dlog.level=ERROR',
        \ '-Dfile.encoding=UTF-8',
        \ '-Xms256m',
        \ '-Xmx' . get(g:, 'jdtls_max_heap', '3G'),
        \ '-XX:+UseG1GC',
        \ '-XX:+UseStringDeduplication',
        \ '--add-modules=ALL-SYSTEM',
        \ '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        \ '--add-opens', 'java.base/java.lang=ALL-UNNAMED']
  if filereadable(s:jdtls_dir . '/lombok.jar')
    call add(l:cmd, '-javaagent:' . s:jdtls_dir . '/lombok.jar')
  endif
  return l:cmd + ['-jar', l:launcher, '-configuration', l:cfg,
        \ '-data', s:JdtlsDataDir(s:JdtlsRoot())]
endfunction

" Spring's jdt.ls bundles. These are the server half of the Spring/jdt.ls bridge; they
" are harmless on their own and cost nothing when the directory is absent, but they only
" pay off once a client services sts/addClasspathListener (see g:enable_spring_lsp below).
function! s:SpringBundles() abort
  return isdirectory(s:spring_dir . '/jars')
        \ ? glob(s:spring_dir . '/jars/*.jar', 0, 1) : []
endfunction

if isdirectory(s:jdtls_dir)
  let g:lsp_settings['eclipse-jdt-ls'] = {
        \ 'cmd': function('s:JdtlsCmd'),
        \ 'root_uri': function('s:JdtlsRootUri'),
        \ 'initialization_options': {
        \   'bundles': s:SpringBundles(),
        \   'extendedClientCapabilities': { 'classFileContentsSupport': v:true },
        \   'settings': { 'java': {
        \     'configuration': {
        \       'runtimes': s:JavaRuntimes(),
        \       'updateBuildConfiguration': 'automatic',
        \     },
        \     'import': { 'maven': { 'enabled': v:true }, 'gradle': { 'enabled': v:false } },
        \     'maven': { 'downloadSources': v:true, 'updateSnapshots': v:false },
        \     'eclipse': { 'downloadSources': v:true },
        \     'references': { 'includeDecompiledSources': v:true },
        \     'contentProvider': { 'preferred': 'fernflower' },
        \     'errors': { 'incompleteClasspath': { 'severity': 'ignore' } },
        \     'compile': { 'nullAnalysis': { 'mode': 'disabled' } },
        \     'completion': { 'maxResults': 50,
        \                     'importOrder': ['java', 'javax', 'jakarta', 'org', 'com'] },
        \     'signatureHelp': { 'enabled': v:true },
        \     'autobuild': { 'enabled': v:true },
        \   } },
        \ },
        \ }
endif

" --- gd into jars -----------------------------------------------------------
" jdt.ls returns `jdt://contents/...` for anything it only has as a class file. Resolve
" it with the java/classFileContents extension request and show the decompiled source in
" a scratch buffer. Plain vim-lsp treats the URI as a filename and does nothing.
function! s:JavaOpenClassFile(uri, line) abort
  call lsp#send_request('eclipse-jdt-ls', {
        \ 'method': 'java/classFileContents',
        \ 'params': { 'uri': a:uri },
        \ 'on_notification': function('s:JavaClassFileContents', [a:uri, a:line]),
        \ })
endfunction

function! s:JavaClassFileContents(uri, line, data) abort
  let l:text = get(get(a:data, 'response', {}), 'result', '')
  if type(l:text) != type('') || empty(l:text)
    echohl WarningMsg | echo 'No decompiled source available' | echohl None
    return
  endif
  let l:name = matchstr(a:uri, '[^/?]\+\ze\%(\.class\)\?\%(?.*\)\?$')
  execute 'noswapfile enew'
  setlocal buftype=nofile bufhidden=hide nobuflisted
  silent put =split(l:text, "\n")
  silent 1delete _
  setlocal filetype=java nomodifiable
  execute 'file' fnameescape('jdt://' . l:name)
  if a:line > 0
    execute 'normal! ' . a:line . 'G'
  endif
  normal! zz
endfunction

function! s:JavaDefinitionHandler(data) abort
  let l:res = get(get(a:data, 'response', {}), 'result', v:null)
  if type(l:res) == type([])
    let l:res = get(l:res, 0, v:null)
  endif
  if type(l:res) != type({}) || !has_key(l:res, 'uri')
    echohl WarningMsg | echo 'No definition found' | echohl None
    return
  endif
  let l:uri = l:res['uri']
  let l:line = get(get(get(l:res, 'range', {}), 'start', {}), 'line', 0) + 1
  let l:char = get(get(get(l:res, 'range', {}), 'start', {}), 'character', 0) + 1
  if l:uri =~# '^jdt://'
    call s:JavaOpenClassFile(l:uri, l:line)
    return
  endif
  execute 'edit' fnameescape(lsp#utils#uri_to_path(l:uri))
  call cursor(l:line, l:char)
  normal! zz
endfunction

function! s:JavaDefinition() abort
  call lsp#send_request('eclipse-jdt-ls', {
        \ 'method': 'textDocument/definition',
        \ 'params': { 'textDocument': lsp#get_text_document_identifier(),
        \             'position': lsp#get_position() },
        \ 'on_notification': function('s:JavaDefinitionHandler'),
        \ })
endfunction

" --- Spring Boot language server -------------------------------------------
" Deliberately NOT allowlisted for `java`. vim-lsp picks a single server per request
" (first one with the capability), so letting both claim java silently shadows jdt.ls --
" hover in particular comes back empty. The Java-side Spring features instead arrive
" through the jdt.ls `bundles` passed above, which is the same split VS Code uses; this
" server then owns application*.yml / *.properties.
" vim-lsp does not declare workspace.executeCommand, and this server dereferences it
" unguarded while building its capabilities -- without it `initialize` dies with an NPE.
" NOTE: this is called to produce a plain dict, not passed as a Funcref. lsp#register_server
" assigns server_info['capabilities'] straight to a lowercase local, so handing it a
" Funcref raises E704 on every buffer open (which also aborts unrelated autocmds).
" The gopls equivalent can stay a Funcref only because lsp_settings#get calls it first.
function! s:SpringCapabilities(...) abort
  let l:caps = lsp#default_get_supported_capabilities({})
  let l:caps['workspace']['executeCommand'] = { 'dynamicRegistration': v:false }
  return l:caps
endfunction

let s:spring_jar = glob(s:spring_dir . '/language-server/spring-boot-language-server-*-exec.jar')

" The User lsp_setup event can fire more than once, and lsp#register_server re-registers
" on each call -- which resets vim-lsp's bookkeeping for an already-running server, so its
" status reads back as 'not running' and nothing is ever dispatched to it. Register once.
" (vim-lsp-settings guards its own server files the same way.)
function! s:RegisterSpringServer() abort
  if get(s:, 'spring_registered', 0)
    return
  endif
  let s:spring_registered = 1
  call lsp#register_server({
        \ 'name': 'spring-boot-language-server',
        \ 'cmd': {server_info -> [s:JdtlsJavaExe(), '-Xmx768m', '-jar', s:spring_jar]},
        \ 'root_uri': {server_info -> s:JdtlsRootUri()},
        \ 'allowlist': ['yaml', 'jproperties'],
        \ 'capabilities': s:SpringCapabilities(),
        \ 'initialization_options': { 'workspaceFolders': v:null },
        \ })
endfunction

" OFF by default, and here is why. The server starts fine and owns application*.yml, but
" it returns ZERO property completions, because it does not read the classpath itself: it
" sends the client a custom `sts/addClasspathListener` request and expects the client to
" register a listener and stream project classpath data back. In VS Code that is serviced
" by the extension talking to jdt.ls (the jdt-ls-extension.jar bundles are the server half
" of that bridge). vim-lsp has no handler for it, so the server never learns the classpath
" and has no property metadata to complete from. Making this work means reimplementing
" that coordination layer, which is a long way from lean.
" Verified against a real spring-boot-starter-web project: initialize OK, status running,
" completion items = 0. Set this to 1 only if you want to experiment.
let g:enable_spring_lsp = get(g:, 'enable_spring_lsp', 0)

if g:enable_spring_lsp && !empty(s:spring_jar) && filereadable(s:spring_jar)
  augroup spring_boot_lsp
    autocmd!
    autocmd User lsp_setup call s:RegisterSpringServer()
  augroup END
endif

" --- Maven, async, into the quickfix list -----------------------------------
" Compile errors and the `at pkg.Cls.m(File.java:42)` frames of a test failure both
" become quickfix entries, so a CLI build is navigable instead of copy-pasted.
let s:mvn_efm = join([
      \ '[ERROR]\ %f:[%l\,%v]\ %m',
      \ '[WARNING]\ %f:[%l\,%v]\ %m',
      \ '[ERROR]\ %f:[%l]\ %m',
      \ '%E%f:%l:\ error:\ %m',
      \ '%W%f:%l:\ warning:\ %m',
      \ '%-G%.%#',
      \ ], ',')

" Surefire failures. The frame worth jumping to is the first one naming a file that
" actually exists in this project -- everything above it is JUnit/reflection internals.
" Maven's own summary line carries the message but not a usable path, so pair the two.
function! s:MvnTestFailures(lines, dir) abort
  let l:items = []
  let l:msg = ''
  let l:want = 0
  for l:line in a:lines
    if l:line =~# '<<< \%(FAILURE\|ERROR\)!'
      let l:want = 1
      let l:msg = ''
      continue
    endif
    if !l:want
      continue
    endif
    if empty(l:msg) && l:line !~# '^\s*at ' && l:line !~# '^\s*$'
      let l:msg = substitute(l:line, '^\s*', '', '')
      continue
    endif
    let l:m = matchlist(l:line,
          \ '^\s*at \([A-Za-z0-9_.$]\+\)\.[A-Za-z0-9_<>$]\+(\([A-Za-z0-9_$]\+\.java\):\(\d\+\))')
    if empty(l:m)
      continue
    endif
    let l:pkg = substitute(matchstr(l:m[1], '^.*\ze\.[^.]\+$'), '\.', '/', 'g')
    for l:src in ['src/test/java/', 'src/main/java/']
      let l:path = a:dir . '/' . l:src . l:pkg . '/' . l:m[2]
      if filereadable(l:path)
        call add(l:items, { 'filename': l:path, 'lnum': str2nr(l:m[3]), 'col': 1,
              \ 'type': 'E', 'text': empty(l:msg) ? 'test failure' : l:msg })
        let l:want = 0
        break
      endif
    endfor
  endfor
  return l:items
endfunction

function! s:MvnOut(ch, msg) abort
  call add(s:mvn_lines, a:msg)
endfunction

function! s:MvnExit(job, status) abort
  call setqflist([], 'r', {'title': s:mvn_title, 'lines': s:mvn_lines, 'efm': s:mvn_efm})
  call setqflist(s:MvnTestFailures(s:mvn_lines, s:mvn_last[1]), 'a')
  " Maven reports each compiler error twice (plugin output, then the summary); collapse.
  let l:seen = {}
  let l:items = []
  for l:e in getqflist()
    let l:key = l:e.bufnr . ':' . l:e.lnum . ':' . l:e.col . ':' . l:e.text
    if !has_key(l:seen, l:key)
      let l:seen[l:key] = 1
      call add(l:items, l:e)
    endif
  endfor
  call setqflist([], 'r', {'title': s:mvn_title, 'items': l:items})
  let l:n = len(getqflist())
  if l:n > 0
    copen
  else
    cclose
  endif
  echohl ModeMsg
  echo printf('%s: exit %d, %d quickfix %s', s:mvn_title, a:status, l:n,
        \ l:n == 1 ? 'entry' : 'entries')
  echohl None
endfunction

function! s:MvnRun(args, dir) abort
  if !executable('mvn')
    echohl WarningMsg | echo 'mvn not found on $PATH' | echohl None
    return
  endif
  if exists('s:mvn_job') && job_status(s:mvn_job) ==# 'run'
    call job_stop(s:mvn_job)
  endif
  let s:mvn_last = [a:args, a:dir]
  let s:mvn_lines = []
  let s:mvn_title = 'mvn ' . a:args
  call setqflist([], 'r', {'title': s:mvn_title . ' (running)', 'items': []})
  echo s:mvn_title . ' in ' . fnamemodify(a:dir, ':~') . ' ...'
  let s:mvn_job = job_start(['/bin/sh', '-c',
        \ 'cd ' . shellescape(a:dir) . ' && mvn -B ' . a:args . ' 2>&1'],
        \ { 'out_cb': function('s:MvnOut'), 'err_cb': function('s:MvnOut'),
        \   'exit_cb': function('s:MvnExit') })
endfunction

function! s:MvnRerun() abort
  if !exists('s:mvn_last')
    echohl WarningMsg | echo 'Nothing to re-run' | echohl None
    return
  endif
  call s:MvnRun(s:mvn_last[0], s:mvn_last[1])
endfunction

" Nearest enclosing method name, for running a single test. Matches the ordinary
" `public void shouldDoThing()` shape; falls back to the whole class if none is found.
function! s:JavaEnclosingMethod() abort
  let l:pat = '^\s*\%(@\w\+\%((.*)\)\?\s*\)*\%(public\|private\|protected\)\?' .
        \ '\s*\%(static\s\+\)\?\%(final\s\+\)\?[A-Za-z_<>,?\[\]. ]\+\s\+\(\w\+\)\s*('
  let l:ln = search(l:pat, 'bcnW')
  return l:ln ? matchlist(getline(l:ln), l:pat)[1] : ''
endfunction

command! -nargs=* Mvn call s:MvnRun(<q-args>, s:MvnModuleDir())
command! -nargs=* MvnRoot call s:MvnRun(<q-args>, s:MvnRootDir())

function! s:JavaMavenMaps() abort
  nnoremap <buffer> <silent> <leader>Jb :call <SID>MvnRun('compile', <SID>MvnModuleDir())<CR>
  nnoremap <buffer> <silent> <leader>Jc :call <SID>MvnRun('clean install -DskipTests', <SID>MvnRootDir())<CR>
  nnoremap <buffer> <silent> <leader>Jt :call <SID>MvnRun('test -Dtest=' . expand('%:t:r'), <SID>MvnModuleDir())<CR>
  nnoremap <buffer> <silent> <leader>JT :call <SID>MvnRun('test -Dtest=' . expand('%:t:r') . '#' . <SID>JavaEnclosingMethod(), <SID>MvnModuleDir())<CR>
  nnoremap <buffer> <silent> <leader>Ja :call <SID>MvnRun('test', <SID>MvnModuleDir())<CR>
  nnoremap <buffer> <silent> <leader>Jr :call <SID>MvnRerun()<CR>
  nnoremap <buffer> <silent> <leader>Jd :call <SID>MvnRun('dependency:tree', <SID>MvnModuleDir())<CR>
endfunction

augroup java_maven
  autocmd!
  autocmd FileType java,xml call s:JavaMavenMaps()
augroup END

" Quickfix navigation (vim-unimpaired style), useful well beyond Java.
nnoremap <silent> ]q :cnext<CR>zz
nnoremap <silent> [q :cprevious<CR>zz
nnoremap <silent> ]Q :clast<CR>zz
nnoremap <silent> [Q :cfirst<CR>zz
nnoremap <silent> <leader>q :copen<CR>

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
