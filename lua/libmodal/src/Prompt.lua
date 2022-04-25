local globals = require 'libmodal/src/globals'
local utils   = require 'libmodal/src/utils'

--- @class libmodal.Prompt
--- @field private completions table<string>|nil
--- @field private exit libmodal.utils.Vars
--- @field private help libmodal.utils.Help|nil
--- @field private indicator libmodal.utils.Indicator
--- @field private input libmodal.utils.Vars
--- @field private instruction function|table<string, function|string>
--- @field private name string
--- @field private supress_exit boolean
local Prompt = utils.classes.new()

local HELP = 'help'
local REPLACEMENTS =
{
	'(', ')', '[', ']', '{', '}',
	'=', '+', '<', '>', '^',
	',', '/', ':', '?', '@', '!', '$', '*', '.', '%', '&', '\\',
}

for i, replacement in ipairs(REPLACEMENTS) do
	REPLACEMENTS[i], _ = vim.pesc(replacement)
end

--- Execute the instruction specified by the `user_input`.
--- @param user_input string
function Prompt:execute_instruction(user_input)
	if type(self.instruction) == globals.TYPE_TBL then -- The self.instruction is a command table.
		if self.instruction[user_input] then -- There is a defined command for the input.
			local to_execute = self.instruction[user_input]
			if type(to_execute) == globals.TYPE_FUNC then
				to_execute()
			else
				vim.api.nvim_command(to_execute)
			end
		elseif user_input == HELP then -- The user did not define a 'help' command, so use the default.
			self.help:show()
		else -- show an error.
			utils.api.nvim_show_err(globals.DEFAULT_ERROR_TITLE, 'Unknown command')
		end
	elseif type(self.instruction) == globals.TYPE_STR then -- The self.instruction is a function.
		vim.fn[self.instruction]()
	else -- attempt to call the self.instruction.
		self.instruction()
	end
end

--- Get more input from the user.
--- @return boolean more_input
function Prompt:get_user_input()
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if self.supress_exit and globals.is_true(self.exit:get()) then
		return false
	end

	-- clear previous `echo`s.
	utils.api.nvim_redraw()

	-- determine what to do with the input
	local function user_input_callback(user_input)
		if user_input and string.len(user_input) > 0 then -- The user actually entered something.
			self.input:set(user_input)
			self:execute_instruction(user_input)
		else -- indicate we want to leave the prompt
			return false
		end

		return true
	end

	-- echo the highlighting
	vim.api.nvim_command('echohl ' .. self.indicator.hl)

	-- set the user input variable
	if self.completions then
		vim.api.nvim_command('echo "' .. self.indicator.str .. '"')
		return vim.ui.select(self.completions, {}, user_input_callback)
	else
		return vim.ui.input({prompt = self.indicator.str}, user_input_callback)
	end
end

--- Enter the prompt.
function Prompt:enter()
	-- enter the mode using a loop.
	local continue_mode = true
	while continue_mode do
		local no_errors, prompt_result = pcall(self.get_user_input, self)

		-- if there were errors.
		if not no_errors then
			utils.show_error(prompt_result)
			continue_mode = false
		else
			continue_mode = prompt_result
		end
	end
end

return
{
	--- Enter a prompt.
	--- @param name string the name of the prompt
	--- @param instruction function|table<string, function|string> what to do with user input
	--- @param user_completions table<string>|nil a list of possible inputs, provided by the user
	--- @param supress_exit boolean|nil whether to stop the `<Esc>` key from quitting the mode
	--- @return libmodal.Prompt
	new = function(name, instruction, user_completions, supress_exit)
		name = vim.trim(name)

		local self = setmetatable(
			{
				exit         = utils.Vars.new('exit', name),
				indicator    = utils.Indicator.prompt(name),
				input        = utils.Vars.new('input', name),
				instruction = instruction,
				name        = name
			},
			Prompt
		)

		self.supress_exit = supress_exit or false

		-- get the completion list.
		if type(instruction) == globals.TYPE_TBL then -- unload the keys of the mode command table.
			-- Create one if the user specified a command table.
			local completions   = {}
			local contained_help = false

			for command, _ in pairs(instruction) do
				completions[#completions + 1] = command
				if command == HELP then
					contained_help = true
				end
			end

			if not contained_help then -- assign it.
				completions[#completions + 1] = HELP
				self.help = utils.Help.new(instruction, 'COMMAND')
			end

			self.completions = completions
		elseif user_completions then
			-- Use the table that the user gave.
			self.completions = user_completions
		end

		return self
	end
}
