" Obsidian のプロパティ (YAML フロントマター) 挿入用
" nvim 側は LuaSnip (~/.config/nvim/luasnippets/markdown.lua) を使用

" ----- <Leader>fm : フロントマター一式をファイル先頭に挿入 -----
function! s:InsertFrontmatter() abort
  let l:today = strftime('%Y-%m-%d')
  let l:lines = [
        \ '---',
        \ 'title: ' . expand('%:t:r'),
        \ 'aliases: []',
        \ 'tags: [note]',
        \ 'created: ' . l:today,
        \ 'updated: ' . l:today,
        \ 'status: draft',
        \ '---',
        \ '',
        \ ]
  call append(0, l:lines)
  call cursor(2, 1)
  normal! $
endfunction

nnoremap <buffer><silent> <Leader>fm :call <SID>InsertFrontmatter()<CR>

" ----- <Leader>fu : updated を現在日時に更新 -----
function! s:TouchUpdated() abort
  let l:save = winsaveview()
  keeppatterns silent! 1,10s/^updated:.*$/\='updated: ' . strftime('%Y-%m-%d %H:%M')/e
  call winrestview(l:save)
endfunction

nnoremap <buffer><silent> <Leader>fu :call <SID>TouchUpdated()<CR>

" ----- 挿入モードの略語 (打って <Space> か <CR> で展開) -----
" 略語は「すべて単語文字」である必要があるため p (property) を接頭辞にする
inoreabbrev <buffer> ptags     tags: [note]
inoreabbrev <buffer> palias    aliases: []
inoreabbrev <buffer> pcss      cssclasses: []
inoreabbrev <buffer> pstatus   status: draft
inoreabbrev <buffer> ppub      publish: false
inoreabbrev <buffer> psource   source: https://
inoreabbrev <buffer> pcreated  <C-r>='created: ' . strftime('%Y-%m-%d')<CR>
inoreabbrev <buffer> pupdated  <C-r>='updated: ' . strftime('%Y-%m-%d %H:%M')<CR>
inoreabbrev <buffer> pdate     <C-r>=strftime('%Y-%m-%d')<CR>
inoreabbrev <buffer> ptime     <C-r>=strftime('%Y-%m-%d %H:%M')<CR>
inoreabbrev <buffer> pcb       - [ ]
