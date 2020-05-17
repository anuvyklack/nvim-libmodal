local libmodal = require('libmodal')
local fooModeRecurse = 1

function fooMode()

	local userInput = string.char(vim.g[
		'foo' .. tostring(fooModeRecurse) .. 'ModeInput'
	])

	if userInput == 'z' then
		fooModeRecurse = fooModeRecurse + 1
		enter()
		fooModeRecurse = fooModeRecurse - 1
	end
end

function enter()
	libmodal.mode.enter('FOO' .. fooModeRecurse, fooMode)
end

enter()
