
---
-- @classmod simpleui.Button
-- @see simpleui.Widget

local gfx = love.graphics

local Widget = require "simpleui.Widget"

local Button = Widget:extend("simpleui.Button")

---
-- @tfield string text
Button.text = ""

---
-- @tfield love.graphics.Font font
Button.font = nil

---
-- @tfield number texthalign
Button.texthalign = .5

---
-- @tfield number textvalign
Button.textvalign = .5

---
-- @tfield boolean pressed
Button.pressed = false

Button.padding = 4

function Button:calcminsize()
	local font, text = self.font or gfx.getFont(), self.text
	local tw, th = font:getWidth(text), font:getHeight(text)
	local pl, pt, pr, pb = self:paddings()
	return tw+pl+pr, th+pt+pb
end

function Button:mousepressed(x, y, b)
	if self:inside(x, y) then
		self.pressed = b == self.LMB
	end
end

function Button:mousereleased(x, y, b)
	if self.pressed and b == self.LMB and self:inside(x, y) then
		self:activate()
	end
	self.pressed = false
end

function Button:mousemoved(x, y, dx, dy)
	if not self:inside(x, y) then
		self.pressed = false
	end
end

function Button:paintbg()
	Widget.paintbg(self)
	self:drawbevel(self.pressed)
end

function Button:paintfg()
	local p = self.pressed and 1 or 0
	self:drawtext(not self.enabled, self.text,
			self.texthalign, self.textvalign, self.font,
			p, p, self:size())
	Widget.paintfg(self)
end

---
function Button:activate()
end

return Button
