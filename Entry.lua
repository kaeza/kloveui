
---
-- Editable text input widget.
--
-- In addition to handling text input, the widget has some basic editing
-- key bindings (some may not be available on all platforms):
--
-- * Left and right cursor keys move the insertion point one character to the
--   left and right, respectively.
-- * The Home and End keys move the insertion point to the beginning and end
--   of the text, respectively.
-- * Backspace and Delete remove the character directly to the left or right
--   of the insertion point, respectively.
-- * Enter or Return commits the text (calls the `commit` method).
--
-- **Extends:** `simpleui.Widget`
--
-- @classmod simpleui.Entry

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
-- Text of this entry box.
--
-- @tfield string text Default is the empty string.
Entry.text = ""

---
-- Custom font for this entry box.
--
-- @tfield love.graphics.Font font Default is nil.
Entry.font = nil

---
-- Index of insertion caret.
--
-- It refers to the space between characters, where 0 is just before the first
-- character, 1 is between the first and second characters, and so on.
--
-- Note that "characters" refers to groups of bytes representing characters in
-- the UTF-8 encoding. This is not the same unit Lua uses.
--
-- @tfield number index Default is 0.
Entry.index = 0

Entry.padding = 4

---
-- Convert from a pixel offset to an index.
--
-- @tparam number x Pixel offset from the left border of the widget.
-- @treturn number Index of the character at that position.
-- @see index
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
-- Convert from an index to a pixel offset.
--
-- @tparam number index Index of the character.
-- @treturn number Pixel offset from the left border of the widget.
-- @see index
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

---
-- Called when the Enter key is pressed.
function Entry:commit()
end

return Entry
