
---
-- Textual label.
--
-- **Extends:** `simpleui.Widget`
--
-- @classmod simpleui.Label

local gfx = love.graphics

local Widget = require "simpleui.Widget"

local Label = Widget:extend("simpleui.Label")

---
-- Text for the label.
--
-- Must be UTF-8 encoded.
--
-- @tfield string text Default is the empty string.
Label.text = ""

---
-- Custom font for this label.
--
-- @tfield love.graphics.Font font Default is nil.
Label.font = nil

---
-- Horizontal alignment for the text.
--
-- @tfield number texthalign Default is 0.
-- @see simpleui.Widget:drawtext
Label.texthalign = 0

---
-- Vertical alignment for the text.
--
-- @tfield number textvalign Default is 0.5.
-- @see simpleui.Widget:drawtext
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
