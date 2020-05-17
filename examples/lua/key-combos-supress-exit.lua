local libmodal = require('libmodal')
local fooModeCombos = {
	[''] = 'echom "You cant exit using escape."',
	['q'] = 'let g:fooModeExit = 1'
}

vim.g.fooModeExit = 0
libmodal.mode.enter('FOO', fooModeCombos, true)
