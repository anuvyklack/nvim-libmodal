-- TODO: remove the __index here after a period of time to let people remove `libmodal.Layer` from their configurations
return setmetatable(
	{
		layer =
		{
			--- Enter a new layer.
			--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
			--- @param exit_char nil|string a character which can be used to exit the layer from normal mode.
			--- @return function|nil exit a function to exit the layer, or `nil` if `exit_char` is passed
			enter = function(keymap, exit_char)
				local layer = require('libmodal/src/Layer').new(keymap)
				layer:enter()

				if exit_char then
					layer:map('n', exit_char, function() layer:exit() end, {})
				else
					return function() layer:exit() end
				end
			end,

			--- Create a new layer.
			--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
			--- @return libmodal.Layer
			new = function(keymap)
				return require('libmodal/src/Layer').new(keymap)
			end,
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
			enter = function(name, instruction, user_completions)
				require('libmodal/src/Prompt').new(name, instruction, user_completions):enter()
			end
		}
	},
	{
		__index = function(tbl, key)
			if key ~= 'Layer' then
				return rawget(tbl, key)
			else
				require('libmodal/src/utils/api').nvim_show_err(
					require('libmodal/src/globals').DEFAULT_ERROR_TITLE,
					'`libmodal.Layer` is deprecated in favor of `libmodal.layer`. It will work FOR NOW, but uncapitalize that `L` please :)'
				)
				return require 'libmodal/src/Layer'
			end
		end,
	}
)
