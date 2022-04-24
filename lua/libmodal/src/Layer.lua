--- The error that occurs when unkeymap a keymap that doesn't exist
local ERR_NO_MAP = 'E5555: API call: E31: No such keymap'

--- Remove and return the right-hand side of a `keymap`.
--- @param keymap table the keymap to unpack
--- @return string lhs, table options
local function unpack_keymap_lhs(keymap)
	local lhs = keymap.lhs
	keymap.lhs = nil

	return lhs, keymap
end

--- Remove and return the right-hand side of a `keymap`.
--- @param keymap table the keymap to unpack
--- @return function|string rhs, table options
local function unpack_keymap_rhs(keymap)
	local rhs = keymap.rhs
	keymap.rhs = nil

	return rhs, keymap
end

--- @class libmodal.Layer
--- @field private existing_keymap table the keymaps to restore when exiting the mode; generated automatically
--- @field private layer_keymap table the keymaps to apply when entering the mode; provided by user
local Layer = require('libmodal/src/utils/classes').new()

--- Apply the `Layer`'s keymaps buffer.
function Layer:enter()
	if self.existing_keymap then
		error('This layer has already been entered. `:exit()` before entering again.')
	end

	-- add local aliases.
	self.existing_keymap = {}

	--[[ iterate over the new keymaps to both:
	     1. Populate a list of keymaps which will be overwritten to `existing_keymap`
		 2. Apply the layer's keymappings. ]]
	for mode, new_keymaps in pairs(self.layer_keymap) do
		-- if `mode` key has not yet been made for `existingKeymap`.
		if not self.existing_keymap[mode] then
			self.existing_keymap[mode] = {}
		end

		-- store the previously mapped keys
		for _, existing_keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
			-- if the new keymaps would overwrite this one
			if new_keymaps[existing_keymap.lhs] then
				-- remove values so that it is in line with `nvim_set_keymap`.
				local lhs, keymap = unpack_keymap_lhs(existing_keymap)
				self.existing_keymap[mode][lhs] = keymap
			end
		end

		-- add the new keymaps
		for lhs, new_keymap in pairs(new_keymaps) do
			local rhs, options = unpack_keymap_rhs(new_keymap)
			vim.keymap.set(mode, lhs, rhs, options)
		end
	end
end

--- Add a keymap to the mode.
--- @param mode string the mode that this keymap for.
--- @param lhs string the left hand side of the keymap.
--- @param rhs function|string the right hand side of the keymap.
--- @param options table options for the keymap.
--- @see `vim.keymap.set`
function Layer:map(mode, lhs, rhs, options)
	if not self.existing_keymap then
		error("Don't call this function before activating the layer; just add to the keymap passed to `Layer.new` instead.")
	end

	if not self.existing_keymap[mode][lhs] then -- the keymap's state has not been saved.
		for _, existing_keymap in ipairs(vim.api.nvim_get_keymap(mode)) do -- check if it has a keymap
			if existing_keymap.lhs == lhs then -- add it to the undo list
				existing_keymap.lhs = nil
				self.existing_keymap[mode][lhs] = existing_keymap
				break
			end
		end
	end

	-- map the `lhs` to `rhs` in `mode` with `options` for the current buffer.
	vim.keymap.set(mode, lhs, rhs, options)

	-- add the new keymap to the keymap
	options.rhs = rhs
	self.layer_keymap[mode][lhs] = options
end

--- Restore one keymapping to its original state.
--- @param mode string the mode of the keymap.
--- @param lhs string the keys which invoke the keymap.
--- @see `vim.api.nvim_del_keymap`
function Layer:unmap(mode, lhs)
	if not self.existing_keymap then
		error("Don't call this function before activating the layer; just remove from the keymap passed to `Layer.new` instead.")
	end

	if self.existing_keymap[mode][lhs] then -- there is an older keymap to go back to.
		-- undo the keymap
		local rhs, options = unpack_keymap_rhs(self.existing_keymap[mode][lhs])
		vim.keymap.set(mode, lhs, rhs, options)
	else
		-- just delete the keymap.
		local noErrors, err = pcall(vim.api.nvim_del_keymap, mode, lhs)

		if not noErrors and err ~= ERR_NO_MAP then
			print(err)
		end
	end

	-- remove this keymap from the list of ones to restore
	self.existing_keymap[mode][lhs] = nil
end

--- Exit the layer, restoring all previous keymaps.
function Layer:exit()
	if not self.existing_keymap then
		error('This layer has not been entered yet.')
	end

	for mode, keymaps in pairs(self.layer_keymap) do
		for lhs, _ in pairs(keymaps) do
			self:unmap(mode, lhs)
		end
	end
	self.existing_keymap = nil
end

return
{
	--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
	--- @return table layer
	new = function(keymap)
		return setmetatable({layer_keymap = keymap}, Layer)
	end
}
