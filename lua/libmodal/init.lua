-- TODO: this is the only `require` left which is done automatically by `libmodal`. There is probably a way to remove it.
local Layer = require 'libmodal/src/Layer'

return
{
	Layer = Layer,
	layer =
	{
		--- Enter a new layer.
		--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
		--- @param exit_char nil|string a character which can be used to exit the layer from normal mode.
		--- @return function|nil exit a function to exit the layer, or `nil` if `exit_char` is passed
		enter = function(keymap, exit_char)
			local layer = Layer.new(keymap)
			layer:enter()

			if exit_char then
				layer:map('n', exit_char, function() layer:exit() end, {})
			else
				return function() layer:exit() end
			end
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
