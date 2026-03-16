" lightline カラースキーム: dotfiles
" Normal=青, Insert/Replace=赤, Visual=オレンジ (nvim lualine と統一)
" 各色は [guiHex, ctermNum] のペア形式

let s:fg_dark  = ['#1e1e1e', 234]
let s:fg_light = ['#d4d4d4', 188]
let s:bg_dark  = ['#1e1e1e', 234]
let s:bg_mid   = ['#2d2d2d', 236]
let s:blue     = ['#569cd6', 74]
let s:red      = ['#f44747', 203]
let s:orange   = ['#ce9178', 173]
let s:gray     = ['#888888', 102]
let s:green    = ['#98c379', 114]

let s:p = {'normal': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'command': {}, 'inactive': {}, 'tabline': {}}

let s:p.normal.left   = [ [s:fg_dark, s:blue, 'bold'], [s:fg_light, s:bg_mid] ]
let s:p.normal.middle = [ [s:fg_light, s:bg_dark] ]
let s:p.normal.right  = [ [s:fg_dark, s:blue], [s:fg_light, s:bg_mid] ]

let s:p.insert.left   = [ [s:fg_dark, s:red, 'bold'], [s:fg_light, s:bg_mid] ]
let s:p.insert.middle = [ [s:fg_light, s:bg_dark] ]
let s:p.insert.right  = [ [s:fg_dark, s:red], [s:fg_light, s:bg_mid] ]

let s:p.replace.left   = [ [s:fg_dark, s:red, 'bold'], [s:fg_light, s:bg_mid] ]
let s:p.replace.middle = [ [s:fg_light, s:bg_dark] ]
let s:p.replace.right  = [ [s:fg_dark, s:red], [s:fg_light, s:bg_mid] ]

let s:p.visual.left   = [ [s:fg_dark, s:orange, 'bold'], [s:fg_light, s:bg_mid] ]
let s:p.visual.middle = [ [s:fg_light, s:bg_dark] ]
let s:p.visual.right  = [ [s:fg_dark, s:orange], [s:fg_light, s:bg_mid] ]

let s:p.command.left   = [ [s:fg_dark, s:green, 'bold'], [s:fg_light, s:bg_mid] ]
let s:p.command.middle = [ [s:fg_light, s:bg_dark] ]
let s:p.command.right  = [ [s:fg_dark, s:green], [s:fg_light, s:bg_mid] ]

let s:p.inactive.left   = [ [s:gray, s:bg_mid], [s:gray, s:bg_mid] ]
let s:p.inactive.middle = [ [s:gray, s:bg_dark] ]
let s:p.inactive.right  = [ [s:gray, s:bg_mid], [s:gray, s:bg_mid] ]

let s:p.tabline.left   = [ [s:fg_light, s:bg_mid] ]
let s:p.tabline.tabsel = [ [s:fg_dark,  s:blue] ]
let s:p.tabline.middle = [ [s:fg_light, s:bg_dark] ]
let s:p.tabline.right  = [ [s:fg_light, s:bg_mid] ]

let g:lightline#colorscheme#dotfiles#palette = lightline#colorscheme#flatten(s:p)
