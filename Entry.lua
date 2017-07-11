
---
-- @classmod simpleui.Entry
-- @see simpleui.Widget

local gfx = love.graphics

local Widget = require "simpleui.Widget"

local Entry = Widget:extend("simpleui.Entry")

Entry.canfocus = true

local utf8 = require "utf8"
local ustroffset = utf8.offset
local ustrlen = utf8.len

local function ustrsub(str, i, j)
	if j<i or i>ustrlen(str) then return "" end
	i = ustroffset(str, i)
	j = ustroffset(str, j)
	return str:sub(i, j-1)
end

---
-- @tfield string text
Entry.text = ""

---
-- @tfield love.graphics.Font font
Entry.font = nil

---
-- @tfield number index
Entry.index = 0

Entry.padding = 4

---
-- @tparam number x
-- @treturn number index
function Entry:postoindex(x)
	local pl = self:paddings()
	local text = self.text
	local len = ustrlen(text)
	x = x-pl
	if x<0 then
		return 0
	elseif x>=self.w then
		return len
	end
	local font = self.font or gfx.getFont()
	for i = 1, len do
		local pfx = ustrsub(text, 1, i)
		local w = font:getWidth(pfx)
		if x<w then
			return i
		end
	end
	return len+1
end

---
-- @tparam number index
-- @treturn number x
function Entry:indextopos(index)
	local pl = self:paddings()
	local font = self.font or gfx.getFont()
	return font:getWidth(ustrsub(self.text, 1, index))+pl
end

function Entry:calcminsize()
	local font, text = self.font or gfx.getFont(), self.text
	local tw, th = font:getWidth(text), font:getHeight(text)
	local pl, pt, pr, pb = self:paddings()
	return tw+pl+pr, th+pt+pb
end

function Entry:mousepressed(x, y, b)
	if not self:inside(x, y) then return end
	self._pressed = b == self.LMB
	return self:mousemoved(x, y, 0, 0)
end

function Entry:mousereleased(x, y, b)
	if self._pressed and b == self.LMB then
		self._pressed = false
	end
end

function Entry:mousemoved(x, y, dx, dy)
	if self._pressed then
		x = self:postoindex(x)
		self.index = x
	end
end

function Entry:keypressed(key)
	if key == "backspace" then
		if self.index < 1 then return end
		self.text = (ustrsub(self.text, 1, self.index-1)
				..ustrsub(self.text, self.index, ustrlen(self.text)+1))
		self.index = self.index - 1
	elseif key == "delete" then
		if self.index > ustrlen(self.text) then return end
		self.text = (ustrsub(self.text, 1, self.index)
				..ustrsub(self.text, self.index+1, ustrlen(self.text)+1))
	elseif key == "home" then
		self.index = 0
	elseif key == "end" then
		self.index = ustrlen(self.text)+1
	elseif key == "left" then
		if self.index <= 0 then return end
		self.index = self.index - 1
	elseif key == "right" then
		if self.index > ustrlen(self.text) then return end
		self.index = self.index + 1
	end
end

function Entry:textinput(text)
	local len = ustrlen(text)
	self.text = (ustrsub(self.text, 1, self.index)..text
			..ustrsub(self.text, self.index, ustrlen(self.text)+1))
	self.index = self.index + len
end

function Entry:paintbg()
	Widget.paintbg(self)
	self:drawbevel(true)
end

function Entry:paintfg()
	local pl, pt, pr, pb = self:paddings()
	local w, h = self:size()
	self:drawtext(not self.enabled, self.text,
			0, 0, self.font,
			pl, pt, w-pl-pr, h-pt-pb)
	local th = (self.font or gfx.getFont()):getHeight("Ay")
	local x = self:indextopos(self.index)
	gfx.line(x, pt-2, x, th+2)
	Widget.paintfg(self)
end

return Entry
