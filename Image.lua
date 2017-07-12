
---
-- Simple image widget.
--
-- The image is scaled to the widget size without any corrections.
--
-- If the widget has an image, its minimum size is that of the image,
-- otherwise it is the default minimum size for widgets. You can always
-- override it in the instance.
--
-- **Extends:** `simpleui.Widget`
--
-- @classmod simpleui.Image
-- @see simpleui.Widget:calcminsize

local gfx = love.graphics

local Widget = require "simpleui.Widget"

local Image = Widget:extend("simpleui.Image")

---
-- Image to display.
--
-- @tfield love.graphics.Image image Default is nil.
Image.image = nil

---
-- Tint color for the image.
--
-- @tfield simpleui.Color tintcolor Default is (255, 255, 255).
Image.tintcolor = ({ 255, 255, 255 })

function Image:calcminsize()
	if not self.image then
		return Widget.calcminsize(self)
	end
	return self.image:getDimensions()
end

function Image:paintbg()
	local image = self.image
	if not image then return end
	local w, h = image:getDimensions()
	gfx.push()
	gfx.scale(self.w/w, self.h/h)
	gfx.setColor(self.tintcolor)
	gfx.draw(image)
	gfx.pop()
end

return Image
