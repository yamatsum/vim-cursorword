" =============================================================================
" Filename: autoload/cursorword.vim
" Author: itchyny
" License: MIT License
" Last Change: 2017/09/29 20:00:00.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! cursorword#highlight() abort
  if !get(g:, 'cursorword_highlight', 1) | return | endif
  highlight CursorWord term=underline cterm=underline gui=underline
endfunction

let s:alphabets = '^[\x00-\x7f\xb5\xc0-\xd6\xd8-\xf6\xf8-\u01bf\u01c4-\u02af\u0370-\u0373\u0376\u0377\u0386-\u0481\u048a-\u052f]\+$'

function! cursorword#matchadd(...) abort
  let enable = get(b:, 'cursorword', get(g:, 'cursorword', 1)) && !has('vim_starting')
  if !enable && !get(w:, 'cursorword_match') | return | endif
  let i = (a:0 ? a:1 : mode() ==# 'i' || mode() ==# 'R') && col('.') > 1
  let line = getline('.')
  let word = matchstr(line[:(col('.')-i-1)], '\k*$') . matchstr(line[(col('.')-i-1):], '^\k*')[1:]
  if get(w:, 'cursorword_state', []) ==# [ word, enable ] | return | endif
  let w:cursorword_state = [ word, enable ]
  silent! call matchdelete(w:cursorword_id)
  let w:cursorword_match = 0
  if !enable || word ==# '' || len(word) !=# strchars(word) && word !~# s:alphabets || len(word) > 1000 | return | endif
  let pattern = '\<' . escape(word, '~"\.^$[]*') . '\>'
  let w:cursorword_id = matchadd('CursorWord', pattern, -1)
  let w:cursorword_match = 1
endfunction

if !has('vim_starting')
  call cursorword#highlight()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
