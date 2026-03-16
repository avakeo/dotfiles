" lightline カラースキーム: dotfiles
" Normal=青, Insert/Replace=赤, Visual=オレンジ (nvim lualine と統一)
" 形式: [guifg, guibg, ctermfg, ctermbg, attr]

let s:p = {'normal': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'inactive': {}, 'tabline': {}}

" Normal: 青
let s:p.normal.left   = [['#1e1e1e', '#569cd6', 234, 74, 'bold'], ['#d4d4d4', '#2d2d2d', 188, 236]]
let s:p.normal.middle = [['#d4d4d4', '#1e1e1e', 188, 234]]
let s:p.normal.right  = [['#1e1e1e', '#569cd6', 234, 74], ['#d4d4d4', '#2d2d2d', 188, 236]]

" Insert: 赤
let s:p.insert.left   = [['#1e1e1e', '#f44747', 234, 203, 'bold'], ['#d4d4d4', '#2d2d2d', 188, 236]]
let s:p.insert.middle = [['#d4d4d4', '#1e1e1e', 188, 234]]
let s:p.insert.right  = [['#1e1e1e', '#f44747', 234, 203], ['#d4d4d4', '#2d2d2d', 188, 236]]

" Replace: 赤
let s:p.replace.left   = [['#1e1e1e', '#f44747', 234, 203, 'bold'], ['#d4d4d4', '#2d2d2d', 188, 236]]
let s:p.replace.middle = [['#d4d4d4', '#1e1e1e', 188, 234]]
let s:p.replace.right  = [['#1e1e1e', '#f44747', 234, 203], ['#d4d4d4', '#2d2d2d', 188, 236]]

" Visual: オレンジ
let s:p.visual.left   = [['#1e1e1e', '#ce9178', 234, 173, 'bold'], ['#d4d4d4', '#2d2d2d', 188, 236]]
let s:p.visual.middle = [['#d4d4d4', '#1e1e1e', 188, 234]]
let s:p.visual.right  = [['#1e1e1e', '#ce9178', 234, 173], ['#d4d4d4', '#2d2d2d', 188, 236]]

" Inactive
let s:p.inactive.left   = [['#888888', '#2d2d2d', 102, 236], ['#888888', '#2d2d2d', 102, 236]]
let s:p.inactive.middle = [['#888888', '#1e1e1e', 102, 234]]
let s:p.inactive.right  = [['#888888', '#2d2d2d', 102, 236], ['#888888', '#2d2d2d', 102, 236]]

" Tabline
let s:p.tabline.left   = [['#d4d4d4', '#2d2d2d', 188, 236]]
let s:p.tabline.tabsel = [['#1e1e1e', '#569cd6', 234, 74]]
let s:p.tabline.middle = [['#d4d4d4', '#1e1e1e', 188, 234]]
let s:p.tabline.right  = [['#d4d4d4', '#2d2d2d', 188, 236]]

let g:lightline#colorscheme#dotfiles#palette = lightline#colorscheme#flatten(s:p)
