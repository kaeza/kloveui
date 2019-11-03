
---
-- Simple image widget.
--
-- The image is scaled to the widget size without any corrections.
--
-- If the widget has an image, its minimum size is that of the image,
-- otherwise it is the default minimum size for widgets. You can always
-- override it in the instance.
--
-- **Extends:** `kloveui.Widget`
--
-- @classmod kloveui.Image
-- @see kloveui.Widget:calcminsize

local graphics = love.graphics

local Widget = require "kloveui.Widget"

local Image = Widget:extend("kloveui.Image")

---
-- Image to display.
--
-- @tfield love.graphics.Image image Default is nil.
Image.image = nil

---
-- Tint color for the image.
--
-- @tfield kloveui.Color tintcolor Default is (1, 1, 1).
Image.tintcolor = ({ 1, 1, 1 })

function Image:calcminsize()
	if not self.image then
		return Widget.calcminsize(self)
	end
	return self.image:getDimensions()
end

function Image:paintbg()
	local image = self.image
	if not image then
		return
	end
	local w, h = image:getDimensions()
	graphics.push()
	graphics.scale(self.w/w, self.h/h)
	graphics.setColor(self.tintcolor)
	graphics.draw(image)
	graphics.pop()
end

return Image
