local globals = require 'libmodal/src/globals'

--- @class libmodal.utils.Help
local Help = require('libmodal/src/utils/classes').new()

--- Align `tbl` according to the `longest_key_len`.
--- @param tbl table what to align.
--- @param longest_key_len number how long the longest key is.
--- @return table aligned
local function align_columns(tbl, longest_key_len)
	local to_print = {}
	for key, value in pairs(tbl) do
		to_print[#to_print + 1] = key
		local len = string.len(key)
		local byte = string.byte(key)
		-- account for ASCII chars that take up more space.
		if byte <= 32 or byte == 127 then
			len = len + 1
		end

		for _ = len, longest_key_len do
			to_print[#to_print + 1] = ' '
		end

		to_print[#to_print + 1] = ' │ ' .. (type(value) == globals.TYPE_STR and value or vim.inspect(value)) .. '\n'
	end
	return to_print
end

--- Show the contents of this `Help`.
function Help:show()
	for _, help_text in ipairs(self) do
		print(help_text)
	end
	vim.fn.getchar()
end

--[[/* CLASS `Help` */]]

return
{
	--- Create a default help table with `commands_or_maps` and vim expressions.
	--- @param commands_or_maps table<string, function|string> commands or mappings to vim expressions.
	--- @param title string
	--- @return libmodal.utils.Help
	new = function(commands_or_maps, title)
		-- find the longest key in the table, or at least the length of the title
		local longest_key_maps = string.len(title)
		for key, _ in pairs(commands_or_maps) do
			local key_len = string.len(key)
			if key_len > longest_key_maps then
				longest_key_maps = key_len
			end
		end

		-- define the separator for the help table.
		local help_separator = {}
		for i = 1, string.len(title) do
			help_separator[i] = '-'
		end
		help_separator = table.concat(help_separator)

		-- Create a new `Help`.
		return setmetatable(
			{
				[1] = ' ',
				[2] = table.concat(align_columns({[title] = 'VIM EXPRESSION'}, longest_key_maps)),
				[3] = table.concat(align_columns({[help_separator] = '--------------'}, longest_key_maps)),
				[4] = table.concat(align_columns(commands_or_maps, longest_key_maps)),
			},
			Help
		)
	end
}
