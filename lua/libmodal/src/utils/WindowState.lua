--[[
	/*
	 * IMPORTS
	 */
--]]

local api = require('libmodal/src/utils/api')

--[[
	/*
	 * MODULE
	 */
--]]

local WindowState = {['TYPE'] = 'libmodal-window-state'}

local height = 'winheight'
local width = 'winwidth'

--[[
	/*
	 * META `WindowState`
	 */
--]]

local _metaWindowState = require('libmodal/src/classes').new(WindowState.TYPE)

-----------------------------------
--[[ SUMMARY
	* Restore the state of `self`.
]]
-----------------------------------
function _metaWindowState:restore()
	vim.o[height] = self.height
	vim.o[width]  = self.width
	api.nvim_redraw()
end

--[[
	/*
	 * CLASS `WindowState`
	 */
--]]

--------------------------
--[[ SUMMARY:
	* Create a table representing the size of the current window.
]]
--[[ RETURNS:
	* The new `WindowState`.
]]
--------------------------
function WindowState.new()
	return setmetatable(
		{
			['height'] = vim.o[height],
			['width']  = vim.o[width],
		},
		_metaWindowState
	)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return WindowState
