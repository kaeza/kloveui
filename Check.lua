
---
-- @classmod simpleui.Check
-- @see simpleui.Button

local gfx = love.graphics

local Widget = require "simpleui.Widget"
local Button = require "simpleui.Button"

local Check = Button:extend("simpleui.Check")

---
-- @tfield boolean value
Check.value = false

function Check:calcminsize()
	local font, text = self.font or gfx.getFont(), self.text
	local tw, th = font:getWidth(text), font:getHeight(text)
	local pl, pt, pr, pb = self:paddings()
	return th+2+tw+pl+pr, th+pt+pb
end

---
-- @tparam boolean value
-- @tparam number x
-- @tparam number y
-- @tparam number w
-- @tparam number h
function Check:paintcheck(value, x, y, size)
	gfx.rectangle("line", x, y, size, size)
	if value then
		gfx.rectangle("fill", x+3, y+3, size-6, size-6)
	end
end

function Check:paintbg()
	Widget.paintbg(self)
end

function Check:paintfg()
	local font, text = self.font or gfx.getFont(), self.text
	local pl, pt, pr, pb = self:paddings()
	local th = font:getHeight(text)
	local p = self.pressed and 1 or 0
	self:drawtext(not self.enabled, self.text,
			self.texthalign, self.textvalign, self.font,
			p+pl+th+2, p+pt, self.w-pl-pr-th+2, self.h-pt-pb)
	self:paintcheck(self.value, pl, pt, th, th)
	Widget.paintfg(self)
end

function Check:activate()
	self.value = not self.value
end

return Check
