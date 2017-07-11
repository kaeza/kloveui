
---
-- @module simpleui

local M = { }

local name = ...

for _, m in ipairs({
	"Widget",
	"Label",
	"Image",
	"Button",
	"Check",
	"Box",
	"Entry",
}) do
	M[m] = require(name.."."..m)
end

local rootwidget
local mousewidget, mousewidgetx, mousewidgety
local focuswidget

---
-- @tparam simpleui.Widget wid
-- @treturn simpleui.Widget|nil oldfocus
function M.setfocus(wid)
	local old = focuswidget
	if old then
		old.focused = false
		old:focuslost()
	end
	focuswidget = wid
	if wid then
		wid.focused = true
		wid:focusgot()
	end
	return old
end

---
-- @treturn simpleui.Widget|nil focus
function M.getfocus(wid)
	local old = focuswidget
	focuswidget = wid
	return old
end

---
function M.draw()
	rootwidget:draw()
end

---
-- @tparam number dtime
function M.update(dtime)
	rootwidget:update(dtime)
end

local function getmouse(x, y)
	local wid, rx, ry
	if mousewidget then
		wid, rx, ry = mousewidget, x-mousewidgetx, y-mousewidgety
	else
		wid, rx, ry = rootwidget:hittest(x, y)
	end
	return wid, rx, ry
end

---
-- @tparam number x
-- @tparam number y
-- @tparam number b
-- @tparam boolean istouch
function M.mousepressed(x, y, b, istouch)
	local wid, rx, ry = getmouse(x, y)
	if wid then
		if wid.canfocus then
			M.setfocus(wid)
		end
		mousewidget, mousewidgetx, mousewidgety = wid, wid:abspos()
		wid:mousepressed(rx, ry, b, istouch)
	end
end

---
-- @tparam number x
-- @tparam number y
-- @tparam number b
-- @tparam boolean istouch
function M.mousereleased(x, y, b, istouch)
	local wid, rx, ry = getmouse(x, y)
	if wid then
		wid:mousereleased(rx, ry, b, istouch)
		mousewidget, mousewidgetx, mousewidgety = nil, nil, nil
	end
end

---
-- @tparam number w
-- @tparam number h
function M.mousemoved(x, y, dx, dy)
	if mousewidget then
		mousewidget:mousemoved(x-mousewidgetx, y-mousewidgety, dx, dy)
	else
		local wid, rx, ry = getmouse(x, y)
		if wid then
			wid:mousemoved(rx, ry, dx, dy)
		end
	end
end

---
-- @tparam number dx
-- @tparam number dy
function M.wheelmoved(dx, dy)
	if mousewidget then
		mousewidget:wheelmoved(dx, dy)
	else
		local wid = getmouse(love.mouse.getPosition())
		if wid then
			wid:wheelmoved(dx, dy)
		end
	end
end

---
-- @tparam number w
-- @tparam number h
function M.resize(w, h)
	rootwidget:size(w, h)
end

---
-- @tparam love.keyboard.KeyConstant key
-- @tparam boolean isrep
function M.keypressed(key, isrep)
	if focuswidget then
		focuswidget:keypressed(key, isrep)
	end
end

---
-- @tparam love.keyboard.KeyConstant key
function M.keyreleased(key)
	if focuswidget then
		focuswidget:keyreleased(key)
	end
end

---
-- @tparam string text
function M.textinput(text)
	if focuswidget then
		focuswidget:textinput(text)
	end
end

---
-- @tparam simpleui.Widget root
function M.run(root)
	rootwidget = root
	mousewidget = nil
	focuswidget = nil
	love.draw = M.draw
	love.update = M.update
	love.mousepressed = M.mousepressed
	love.mousereleased = M.mousereleased
	love.mousemoved = M.mousemoved
	love.wheelmoved = M.wheelmoved
	love.keypressed = M.keypressed
	love.keyreleased = M.keyreleased
	love.textinput = M.textinput
	love.resize = M.resize
	local ww, wh = love.window.getMode()
	love.keyboard.setKeyRepeat(true)
	love.resize(ww, wh)
end

return M
