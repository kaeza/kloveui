
---
-- Option or "radio" button.
--
-- Radio buttons are like check buttons, but only one in a group may be
-- selected at any one time. They are grouped first by parent, and sub-grouped
-- by their `group` value. When one is "checked", all others with the same
-- parent *and* group are unchecked. Groups are checked for equality using the
-- `rawequal` function.
--
-- **Extends:** `kloveui.Check`
--
-- @classmod kloveui.Option

local graphics = love.graphics

local Check = require "kloveui.Check"

local Option = Check:extend("kloveui.Option")

---
-- Group of this option.
--
-- @tfield any group Default is the empty string.
Option.group = ""

function Option:paintcheck(value, x, y, size)
	size = size/2
	x, y = x+size, y+size
	graphics.circle("line", x, y, size)
	if value then
		graphics.circle("fill", x, y, size-3)
	end
end

function Option:activated()
	local p = self.weakrefs.parent
	for wid in p:children() do
		if rawequal(wid.group, self.group) then
			wid.value = false
		end
	end
	self.value = true
end

return Option
