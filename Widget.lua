
---
-- @classmod simpleui.Widget

local gfx = love.graphics

local min, max, floor = math.min, math.max, math.floor

local klass = require "klass"

local Widget = klass:extend("simpleui.Widget")

---
-- @tfield any id
Widget.id = nil

---
-- @tfield number x
Widget.x = 0

---
-- @tfield number y
Widget.y = 0

---
-- @tfield number w
Widget.w = 1

---
-- @tfield number h
Widget.h = 1

---
-- @tfield ?number minw
Widget.minw = nil

---
-- @tfield ?number minh
Widget.minh = nil

---
-- @tfield ?number maxw
Widget.maxw = nil

---
-- @tfield ?number maxh
Widget.maxh = nil

---
-- @tfield boolean enabled
Widget.enabled = true

---
-- @tfield table fgcolor
Widget.fgcolor = ({ 240, 240, 240 })

---
-- @tfield table fgcolordisabled
Widget.fgcolordisabled = ({ 192, 192, 192 })

---
-- @tfield table bgcolor
Widget.bgcolor = ({ 64, 64, 64 })

---
-- @tfield table bgcolorraised
Widget.bgcolorraised = ({ 128, 128, 128 })

---
-- @tfield table bgcolorsunken
Widget.bgcolorsunken = ({ 32, 32, 32 })

---
-- @tfield table bordercolor
Widget.bordercolor = ({ 0, 0, 0 })

---
-- @tfield boolean expand
Widget.expand = false

---
-- @tfield table|number margin
Widget.margin = 0

---
-- @tfield table|number padding
Widget.padding = 0

---
-- @tfield boolean canfocus
Widget.canfocus = false

---
-- @tfield boolean focused
Widget.focused = false

---
-- @tfield table __refs
Widget.__refs = nil

---
-- @tfield boolean __debug
Widget.__debug = nil

---
-- @tfield any LMB
Widget.LMB = 1

---
-- @tfield any RMB
Widget.RMB = 2

---
-- @tfield any MMB
Widget.MMB = 3

---
-- @tfield string SPACE
Widget.SPACE = "space"

---
-- @tparam table params
function Widget:init(params)
	self.__refs = setmetatable({ }, { __mode="kv" })
	for _, v in ipairs(params) do
		v.__refs.parent = self
	end
	for k, v in pairs(params) do
		self[k] = v
	end
	self:layout()
end

local function repr(x)
	return type(x) == "string" and ("%q"):format(x) or tostring(x)
end

---
-- @treturn string
function Widget:__tostring()
	return ("<%s: x=%s, y=%s, w=%s, h=%s%s>"):format(self.__name,
			self.x, self.y, self.w, self.h,
			self.id==nil and "" or ", id="..repr(self.id))
end

---
-- @tparam simpleui.Widget child
-- @tparam ?number pos
function Widget:addchild(child, pos)
	child.__refs.parent = self
	table.insert(self, pos or #self+1, child)
	self:layout()
end

---
-- @tparam simpleui.Widget|number child
-- @treturn simpleui.Widget|nil
function Widget:removechild(child)
	if type(child) == "number" then
		local r = table.remove(self, child)
		self:layout()
		return r
	else
		for i, c in ipairs(self) do
			if rawequal(c, child) then
				local r = table.remove(self, i)
				self:layout()
				return r
			end
		end
	end
end

---
function Widget:layout()
end

---
-- @tparam any id
-- @treturn simpleui.Widget|nil
-- @see simpleui.lookup
function Widget:lookup(id)
	for _, child in self:children() do
		local found = child:lookup(id)
		if found then
			return found
		end
	end
	if id == self.id then
		return self
	end
end

---
-- @treturn function iter
-- @treturn table self
-- @treturn nil
function Widget:children()
	return ipairs(self)
end

---
-- @tparam number x
-- @tparam number y
-- @treturn Widget|nil widget
-- @treturn number rx
-- @treturn number ry
function Widget:hittest(x, y)
	if not self.enabled then return nil end
	x, y = x-self.x, y-self.y
	for _, child in self:children() do
		local found, rx, ry = child:hittest(x, y)
		if found then
			return found, rx, ry
		end
	end
	if self:inside(x, y) then
		return self, x, y
	end
	return nil
end

---
-- @tparam number x
-- @tparam number y
-- @treturn boolean
function Widget:inside(x, y)
	return x>=0 and y>=0 and x<self.w and y<self.h
end

---
-- @treturn number x
-- @treturn number y
function Widget:abspos()
	local x, y = 0, 0
	local w = self
	while w do
		x, y = x+w.x, y+w.y
		w = w.__refs.parent
	end
	return x, y
end

---
-- @treturn number w
-- @treturn number h
function Widget:minsize()
	local w, h = self.minw, self.minh
	if not (w and h) then
		local mw, mh = self:calcminsize()
		w, h = w or mw, h or mh
	end
	return w, h
end

---
-- @treturn number w
-- @treturn number h
function Widget:calcminsize()
	return 1, 1
end

---
-- @treturn number w
-- @treturn number h
function Widget:maxsize()
	local w, h = self.maxw, self.maxh
	if not (w and h) then
		local mw, mh = self:calcmaxsize()
		w, h = w or mw, h or mh
	end
	return w, h
end

---
-- @treturn number w
-- @treturn number h
function Widget:calcmaxsize()
	return math.huge, math.huge
end

---
-- @treturn left
-- @treturn top
-- @treturn right
-- @treturn bottom
function Widget:margins()
	local t = self.margin
	if type(t) == "number" then
		return t, t, t, t
	else
		return t.l or 0, t.t or 0, t.r or 0, t.b or 0
	end
end

---
-- @treturn left
-- @treturn top
-- @treturn right
-- @treturn bottom
function Widget:paddings()
	local t = self.padding
	if type(t) == "number" then
		return t, t, t, t
	else
		return t.l or 0, t.t or 0, t.r or 0, t.b or 0
	end
end

---
-- @tparam ?number x
-- @tparam ?number y
-- @treturn number x
-- @treturn number y
function Widget:pos(x, y)
	local mod
	if x ~= nil then mod, self.x = true, x end
	if y ~= nil then mod, self.y = true, y end
	if mod then
		self:layout()
	end
	return self.x, self.y
end

---
-- @tparam ?number w
-- @tparam ?number h
-- @treturn number w
-- @treturn number h
function Widget:size(w, h)
	local mod
	local minw, minh = self:minsize()
	local maxw, maxh = self:maxsize()
	if w ~= nil then
		mod, self.w = true, max(minw, min(maxw, w))
	end
	if h ~= nil then
		mod, self.h = true, max(minh, min(maxh, h))
	end
	if mod then
		self:layout()
	end
	return self.w, self.h
end

---
-- @tparam ?number x
-- @tparam ?number y
-- @tparam ?number w
-- @tparam ?number h
-- @treturn number x
-- @treturn number y
-- @treturn number w
-- @treturn number h
function Widget:rect(x, y, w, h)
	local mod
	if x ~= nil then mod, self.x = true, x end
	if y ~= nil then mod, self.y = true, y end
	local minw, minh = self:minsize()
	local maxw, maxh = self:maxsize()
	if w ~= nil then
		mod, self.w = true, max(minw, min(maxw, w))
	end
	if h ~= nil then
		mod, self.h = true, max(minh, min(maxh, h))
	end
	if mod then
		self:layout()
	end
	return self.x, self.y, self.w, self.h
end

---
function Widget:draw()
	gfx.push()
	gfx.translate(self.x, self.y)
	self:paintbg()
	for _, child in self:children() do
		child:draw()
	end
	self:paintfg()
	gfx.pop()
end

---
function Widget:paintfg()
	if self.__debug then
		gfx.setColor(255, 255, 0, 192)
		gfx.rectangle("line", 0, 0, self:size())
		gfx.print(tostring(self))
	end
end

---
function Widget:paintbg()
end

---
-- @tparam boolean sunken
-- @tparam ?number x
-- @tparam ?number y
-- @tparam ?number w
-- @tparam ?number h
function Widget:drawbevel(sunken, x, y, w, h)
	x, y, w, h = x or 0, y or 0, w or self.w, h or self.h
	gfx.setColor(sunken and self.bgcolorsunken or self.bgcolorraised)
	gfx.rectangle("fill", x, y, w, h)
	gfx.setColor(self.bordercolor)
	gfx.rectangle("line", x, y, w, h)
end

---
-- @tparam boolean disabled
-- @tparam string text
-- @tparam number halign
-- @tparam number valign
-- @tparam ?love.graphics.Font font
-- @tparam ?number x
-- @tparam ?number y
-- @tparam ?number w
-- @tparam ?number h
function Widget:drawtext(disabled, text, halign, valign, font, x, y, w, h)
	x, y, w, h = x or 0, y or 0, w or self.w, h or self.h
	gfx.setColor(disabled and self.fgcolordisabled or self.fgcolor)
	local oldfont = gfx.getFont()
	font = font or oldfont
	local tw, th = font:getWidth(text), font:getHeight(text)
	gfx.setFont(font)
	gfx.print(text, floor(x+((w-tw)*halign)), floor(y+((h-th)*valign)))
	gfx.setFont(oldfont)
end

---
-- @tparam number dtime
function Widget:update(dtime)
	for _, child in self:children() do
		child:update(dtime)
	end
end

---
function Widget:setfocus()
	return require("simpleui").setfocus(self)
end

---
function Widget:focusgot()
end

---
function Widget:focuslost()
end

---
-- @tparam number x
-- @tparam number y
-- @tparam number b
-- @tparam boolean istouch
function Widget:mousepressed(x, y, b, istouch)
end

---
-- @tparam number x
-- @tparam number y
-- @tparam number b
-- @tparam boolean istouch
function Widget:mousereleased(x, y, b, istouch)
end

---
-- @tparam number x
-- @tparam number y
function Widget:mousemoved(x, y)
end

---
function Widget:mouseenter()
end

---
function Widget:mouseleave()
end

---
-- @tparam number dx
-- @tparam number dy
function Widget:wheelmoved(dx, dy)
end

---
-- @tparam love.keyboard.KeyConstant key
-- @tparam boolean isrep
function Widget:keypressed(key, isrep)
end

---
-- @tparam love.keyboard.KeyConstant key
function Widget:keyreleased(key)
end

---
-- @tparam string text
function Widget:textinput(text)
end

return Widget
