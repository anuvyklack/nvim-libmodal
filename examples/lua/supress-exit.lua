local libmodal = require('libmodal')

local function fooMode()
	local userInput = string.char(vim.g.fooModeInput)

	if userInput == '' then
		print('You cant leave using <Esc>.')
	elseif userInput == 'q' then
		vim.g.fooModeExit = true
	end
end

vim.g.fooModeExit = false
libmodal.mode.enter('FOO', fooMode, true)
