
---
-- @classmod simpleui.Label
-- @see simpleui.Widget

local gfx = love.graphics

local Widget = require "simpleui.Widget"

local Label = Widget:extend("simpleui.Label")

---
-- @tfield string text
Label.text = ""

---
-- @tfield love.graphics.Font font
Label.font = nil

---
-- @tfield number texthalign
Label.texthalign = 0

---
-- @tfield number textvalign
Label.textvalign = .5

function Label:calcminsize()
	local font, text = self.font or gfx.getFont(), self.text
	local tw, th = font:getWidth(text), font:getHeight(text)
	local pl, pt, pr, pb = self:paddings()
	return tw+pl+pr, th+pt+pb
end

function Label:paintfg()
	self:drawtext(not self.enabled, self.text,
			self.texthalign, self.textvalign, self.font,
			0, 0, self:size())
	Widget.paintfg(self)
end

return Label
