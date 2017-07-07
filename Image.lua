
---
-- @classmod simpleui.Image
-- @see simpleui.Widget

local gfx = love.graphics

local min, max = math.min, math.max

local Widget = require "simpleui.Widget"

local Image = Widget:extend("simpleui.Image")

---
-- @tfield love.graphics.Image image
Image.image = nil

---
-- @tfield table tintcolor
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
