
---
-- @classmod simpleui.Option
-- @see simpleui.Check

local gfx = love.graphics

local Check = require "simpleui.Check"

local Option = Check:extend("simpleui.Option")

---
-- @tparam any group
Option.group = ""

function Option:paintcheck(value, x, y, size)
	size = size/2
	x, y = x+size, y+size
	gfx.circle("line", x, y, size)
	if value then
		gfx.circle("fill", x, y, size-3)
	end
end

function Option:activate()
	local p = self.__refs.parent
	for _, wid in p:children() do
		if wid.group == self.group then
			wid.value = false
		end
	end
	self.value = true
end

return Option
