-- Imports
local libmodal = require('libmodal')

-- Recurse counter.
local foo_mode_recurse = 0
-- Register 'z' as the map for recursing further (by calling the FooMode function again).
local foo_mode_keymaps  =
{
	z = 'lua FooMode()'
}

-- define the FooMode() function which is called whenever the user presses 'z'
function FooMode()
	foo_mode_recurse = foo_mode_recurse + 1
	libmodal.mode.enter('FOO' .. foo_mode_recurse, foo_mode_keymaps)
	foo_mode_recurse = foo_mode_recurse - 1
end

-- Define the character 'f' as the function we defined— but directly through lua, instead of vimL.
foo_mode_keymaps['f'] = FooMode

-- Call FooMode() initially to begin the demo.
FooMode()
