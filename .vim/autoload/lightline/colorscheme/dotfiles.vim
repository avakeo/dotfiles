" lightline カラースキーム: dotfiles
" gui カラーは NONE、cterm カラーのみ使用
" Normal=青(74), Insert/Replace=赤(203), Visual=オレンジ(173)

let s:p = {'normal': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'inactive': {}, 'tabline': {}}

let s:p.normal.left   = [['NONE', 'NONE', 234, 74,  'bold'], ['NONE', 'NONE', 188, 236]]
let s:p.normal.middle = [['NONE', 'NONE', 188, 234]]
let s:p.normal.right  = [['NONE', 'NONE', 234, 74],  ['NONE', 'NONE', 188, 236]]

let s:p.insert.left   = [['NONE', 'NONE', 234, 203, 'bold'], ['NONE', 'NONE', 188, 236]]
let s:p.insert.middle = [['NONE', 'NONE', 188, 234]]
let s:p.insert.right  = [['NONE', 'NONE', 234, 203], ['NONE', 'NONE', 188, 236]]

let s:p.replace.left   = [['NONE', 'NONE', 234, 203, 'bold'], ['NONE', 'NONE', 188, 236]]
let s:p.replace.middle = [['NONE', 'NONE', 188, 234]]
let s:p.replace.right  = [['NONE', 'NONE', 234, 203], ['NONE', 'NONE', 188, 236]]

let s:p.visual.left   = [['NONE', 'NONE', 234, 173, 'bold'], ['NONE', 'NONE', 188, 236]]
let s:p.visual.middle = [['NONE', 'NONE', 188, 234]]
let s:p.visual.right  = [['NONE', 'NONE', 234, 173], ['NONE', 'NONE', 188, 236]]

let s:p.inactive.left   = [['NONE', 'NONE', 102, 236], ['NONE', 'NONE', 102, 236]]
let s:p.inactive.middle = [['NONE', 'NONE', 102, 234]]
let s:p.inactive.right  = [['NONE', 'NONE', 102, 236], ['NONE', 'NONE', 102, 236]]

let s:p.tabline.left   = [['NONE', 'NONE', 188, 236]]
let s:p.tabline.tabsel = [['NONE', 'NONE', 234, 74]]
let s:p.tabline.middle = [['NONE', 'NONE', 188, 234]]
let s:p.tabline.right  = [['NONE', 'NONE', 188, 236]]

let g:lightline#colorscheme#dotfiles#palette = lightline#colorscheme#flatten(s:p)
