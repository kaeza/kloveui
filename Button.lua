
---
-- Clickable button.
--
-- **Extends:** `simpleui.Widget`
--
-- **Direct subclasses:**
--
-- * `simpleui.Check`
--
-- @classmod simpleui.Button

local gfx = love.graphics

local Widget = require "simpleui.Widget"

local Button = Widget:extend("simpleui.Button")

---
-- Text label for the button.
--
-- @tfield string text Default is the empty string.
Button.text = ""

---
-- Custom font for the button.
--
-- @tfield love.graphics.Font font Default is nil.
Button.font = nil

---
-- Horizontal alignment for the text.
--
-- @tfield number texthalign Default is 0.5.
-- @see simpleui.Widget:drawtext
Button.texthalign = .5

---
-- Vertical alignment for the text.
--
-- @tfield number textvalign Default is 0.5.
-- @see simpleui.Widget:drawtext
Button.textvalign = .5

---
-- Whether the button is currently pressed.
--
-- @todo This should be private.
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
	local pl, pt, pr, pb = self:paddings()
	local p = self.pressed and 1 or 0
	self:drawtext(not self.enabled, self.text,
			self.texthalign, self.textvalign, self.font,
			pl+p, pt+p, self.w-pl-pr, self.h-pt-pb)
	Widget.paintfg(self)
end

---
-- Called when the button is clicked.
function Button:activate()
end

return Button
