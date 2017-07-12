
---
-- Widget to select from a range of values.
--
-- **Extends:** `simpleui.Widget`
--
-- @classmod simpleui.Slider

local gfx = love.graphics
local min, max, floor = math.min, math.max, math.floor

local Widget = require "simpleui.Widget"

local Slider = Widget:extend("Slider")

---
-- Current value for the slider.
--
-- Lies in the range 0-1 (inclusive).
--
-- @tfield number value Default is 0.
Slider.value = 0

---
-- Value increment.
--
-- If a number, the value snaps to the nearest multiple of that value;
-- if nil, the value resolution depends on the widget's size.
--
-- @tfield nil|number increment Default is nil.
Slider.increment = nil

---
-- Color for the light parts of the handle.
--
-- @tfield simpleui.Color handlelightcolor Default is (255, 255, 255).
Slider.handlelightcolor = ({ 255, 255, 255 })

---
-- Color for the dark parts of the handle.
--
-- @tfield simpleui.Color handledarkcolor Default is (255, 255, 255).
Slider.handledarkcolor = ({ 0, 0, 0 })

---
-- Set the slider's value.
--
-- This method calls `valuechanged` if the value is different.
--
-- @tparam number v New value. Clamped to the range 0-1.
-- @tparam ?boolean force Set new value even if unchanged. Default is false.
-- @treturn number Old value.
function Slider:setvalue(v, force)
	local old = self.value
	v = max(0, min(1, v))
	if force or v ~= self.value then
		self.value = v
		self:valuechanged()
	end
	return old
end

---
-- Called to paint the handle.
--
-- The handle is part of the "foreground".
--
-- @tparam number x X position of the center of the handle.
-- @see simpleui.Widget:paintfg
function Slider:painthandle(x)
	local size = self.h/6
	gfx.setColor(self.handlelightcolor)
	gfx.polygon("fill", x, size, x-size, 0, x+size, 0)
	gfx.setColor(self.handledarkcolor)
	gfx.polygon("line", x, size, x-size, 0, x+size, 0)
	gfx.setColor(self.handlelightcolor)
	gfx.polygon("fill", x, size*5, x-size, size*6, x+size, size*6)
	gfx.setColor(self.handledarkcolor)
	gfx.polygon("line", x, size*5, x-size, size*6, x+size, size*6)
	gfx.setColor(self.handlelightcolor)
	gfx.line(x, size, x, size*2)
	gfx.line(x, size*3, x, size*4)
	gfx.setColor(self.handledarkcolor)
	gfx.line(x, size*2, x, size*3)
	gfx.line(x, size*4, x, size*5)
end

---
-- Called to paint the bar.
--
-- The bar is part of the "background".
--
-- @tparam number x X position of the center of the handle.
-- @see simpleui.Widget:paintbg
function Slider:paintbar()
	gfx.setColor(self.bgcolor)
	gfx.rectangle("fill", 0, 0, self.w, self.h)
end

---
-- Called when the value of the bar changes.
--
-- @see value
function Slider:valuechanged()
end

function Slider:calcminsize()
	return 128, 16
end

function Slider:mousepressed(x, _, b)
	if b == self.LMB then
		self._pressed = true
		self:mousemoved(x)
	end
end

function Slider:mousereleased(_, _, b)
	if b == self.LMB then
		self._pressed = nil
	end
end

function Slider:mousemoved(x)
	if self._pressed then
		local v = x/self.w
		if self.increment then
			v = floor(v/self.increment+.5)*self.increment
		end
		self:setvalue(v)
	end
end

function Slider:wheelmoved(_, y)
	local v = self.value + (self.increment or .1)*(-y)
	self:setvalue(v)
end

function Slider:paintfg()
	self:painthandle(self.w*self.value)
	Widget.paintfg(self)
end

function Slider:paintbg()
	Widget.paintbg(self)
	self:paintbar()
	gfx.setColor(self.bordercolor)
	gfx.rectangle("line", 0, 0, self.w, self.h)
end

return Slider
