--- @class libmodal.collections.Stack
local Stack = require('libmodal/src/utils/classes').new()

--- @return unknown top the foremost value of the stack
function Stack:peek()
	return self[#self]
end

--- Remove the foremost value from the stack and return it.
--- @return unknown top the foremost value of the stack
function Stack:pop()
	return table.remove(self)
end

--- Push some `value` on to the stack.
--- @param value unknown the value to push onto the stack.
function Stack:push(value)
	-- Push to the stack
	self[#self + 1] = value
end

return
{
	new = function()
		return setmetatable({}, Stack)
	end,
}
