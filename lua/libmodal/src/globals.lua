local VIM_FALSE = 0
local VIM_TRUE  = 1

return {
	--- The default error title for `nvim-libmodal` errors.
	DEFAULT_ERROR_TITLE = 'nvim-libmodal error',

	--- The key-code for the escape character.
	ESC_NR = 27,

	--- The string which is returned by `type(function() end)` (or any function)
	TYPE_FUNC = type(function() end),

	--- The string which is returned by `type(0)` (or any number)
	TYPE_NUM  = type(0),

	--- The string which is returned by `type ''` (or any string)
	TYPE_STR = type '',

	--- The string which is returned by `type {}` (or any table)
	TYPE_TBL = type {},

	--- The value of Vimscript's `v:false`
	VIM_FALSE = VIM_FALSE,

	--- The value of Vimscript's `v:true`
	VIM_TRUE  = VIM_TRUE,

	--- Assert some value is either `false` or `v:false`.
	--- @param val boolean|number
	--- @return boolean
	is_false = function(val)
		return val == false or val == VIM_FALSE
	end,

	--- Assert some value is either `true` or `v:true`.
	--- @param val boolean|number
	--- @return boolean
	is_true = function(val)
		return val == true or val == VIM_TRUE
	end
}
