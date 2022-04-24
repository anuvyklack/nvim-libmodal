return
{
	layer =
	{
		enter = function(keymap)
			local layer = require('libmodal/src/Layer').new(keymap)
			layer:enter()
			return function() layer:exit() end
		end
	},

	mode =
	{
		enter = function(name, instruction, ...)
			require('libmodal/src/Mode').new(name, instruction, ...):enter()
		end
	},

	prompt =
	{
		enter = function(name, instruction, ...)
			require('libmodal/src/Prompt').new(name, instruction, ...):enter()
		end
	}
}
