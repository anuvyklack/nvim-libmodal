return
{
	layer =
	{
		--- Enter a new layer.
		--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
		--- @return function exit a function to exit the layer
		enter = function(keymap)
			local layer = require('libmodal/src/Layer').new(keymap)
			layer:enter()
			return function() layer:exit() end
		end
	},

	mode =
	{
		--- Enter a mode.
		--- @param name string the name of the mode.
		--- @param instruction function|string|table a Lua function, keymap dictionary, Vimscript command.
		enter = function(name, instruction, supress_exit)
			require('libmodal/src/Mode').new(name, instruction, supress_exit):enter()
		end
	},

	prompt =
	{
		--- Enter a prompt.
		--- @param name string the name of the prompt
		--- @param instruction function|table<string, function|string> what to do with user input
		--- @param user_completions table<string>|nil a list of possible inputs, provided by the user
		--- @param supress_exit boolean|nil whether to stop the `<Esc>` key from quitting the mode
		enter = function(name, instruction, user_completions, supress_exit)
			require('libmodal/src/Prompt').new(name, instruction, user_completions, supress_exit):enter()
		end
	}
}
