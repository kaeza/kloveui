
---
-- @module simpleui

local M = { }

local name = ...

for _, m in ipairs({
	"Widget",
	"Label",
	"Button",
	"Box",
}) do
	M[m] = require(name.."."..m)
end

local rootwidget
local mousewidget, mousewidgetx, mousewidgety

function M.draw()
	rootwidget:draw()
end

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

function M.mousepressed(x, y, b)
	local wid, rx, ry = getmouse(x, y)
	if wid then
		mousewidget, mousewidgetx, mousewidgety = wid, wid:abspos()
		wid:mousepressed(rx, ry, b)
	end
end

function M.mousereleased(x, y, b)
	local wid, rx, ry = getmouse(x, y)
	if wid then
		wid:mousereleased(rx, ry, b)
		mousewidget, mousewidgetx, mousewidgety = nil, nil, nil
	end
end

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

function M.resize(w, h)
	rootwidget:size(w, h)
end

function M.run(root)
	rootwidget = root
	love.draw = M.draw
	love.update = M.update
	love.mousepressed = M.mousepressed
	love.mousereleased = M.mousereleased
	love.mousemoved = M.mousemoved
	love.resize = M.resize
	local ww, wh = love.window.getMode()
	love.resize(ww, wh)
end

return M
