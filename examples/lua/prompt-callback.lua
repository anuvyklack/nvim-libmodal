local libmodal = require('libmodal')
local commandList = {'new', 'close', 'last'}

function FooMode()
	local userInput = vim.g.fooModeInput
	if userInput == 'new' then
		vim.cmd('tabnew')
	elseif userInput == 'close' then
		vim.cmd('tabclose')
	elseif userInput == 'last' then
		vim.cmd('tablast')
	end
end

libmodal.prompt.enter('FOO', FooMode, commandList)
