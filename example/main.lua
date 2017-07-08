
-- Example use of SimpleUI.

local gfx = love.graphics

local sui = require "simpleui"

-- Let's override `print` to print source location.
local lprint = print
function print(...)
	local info = debug.getinfo(2)
	local loc = info.short_src..":"..(info.currentline or 0)
	local n, t = select("#", ...), { ... }
	for i = 1, n do
		t[i] = tostring(t[i])
	end
	lprint(loc..": "..table.concat(t, " "))
end

-- Example of custom widget classes.

local Example = sui.Widget:extend("Example")

local function drawrect(label, cr, cg, cb, x, y, w, h)
	gfx.setColor(cr, cg, cb, 128)
	gfx.rectangle("fill", x, y, w, h)
	gfx.setColor(cr, cg, cb)
	gfx.rectangle("line", x, y, w, h)
	gfx.print(label, x+2, y+2)
end

-- We draw our widget "background" here.
function Example:paintbg()
	-- As a test, let's draw our layout parameters.

	local ml, mt, mr, mb = self:margins()
	local pl, pt, pr, pb = self:paddings()
	local w, h = self:size()

	-- Margin in red.
	-- Note that we are technically drawing outside the bounds
	-- of our widget. SimpleUI does not clip any graphics calls,
	-- but we should always respect the layout parameters.
	drawrect("Margin", 255, 128, 128, -ml, -mt, w+ml+mr, h+mt+mb)

	-- Padding in blue.
	-- We are "inside" the widget here. You will notice mouse
	-- events (see below) work inside the "padding", but not in
	-- the area marked as "margin".
	-- Note that what "padding" means varies from widget to widget.
	-- For example, buttons add borders around the text, but the
	-- "button" part is still widget-sized.
	drawrect("Padding", 128, 128, 255, 0, 0, w, h)

	-- Content in green.
	drawrect("Content", 128, 255, 128, pl, pt, w-pl-pr, h-pt-pb)
end

-- We draw our widget "foreground" here.
function Example:paintfg()
	-- We should ALWAYS set colors explicitly. SimpleUI does not
	-- save or restore any state besides the transformation matrix.
	gfx.setColor(255, 255, 255)
	self:drawtext(not self.enabled, self.text, .5, .5)
	if self._mousex then
		if self:inside(self._mousex, self._mousey) then
			gfx.setColor(255, 255, 0)
		else
			gfx.setColor(255, 0, 0)
		end
		gfx.circle("fill", self._mousex, self._mousey, 9)
	end
end

-- We should define this method if we want to add it to a
-- container and we don't explicitly set `minw` and `minh`.
function Example:calcminsize()
	return 320, 240
end

-- We can handle mouse events.
function Example:mousepressed(x, y, b)
	-- Note: Since LÖVE developers tend to change constants
	-- between releases, the `simpleui.Widget` class exports
	-- some constants with the correct value for the currently
	-- running version.
	if b == self.LMB then -- Left Mouse Button
		self._mousex, self._mousey = x, y
	end
end

function Example:mousemoved(x, y)
	if self._mousex then
		self._mousex, self._mousey = x, y
	end
end

function Example:mousereleased()
	self._mousex, self._mousey = nil, nil
end

-- Our "root" widget.
-- You will notice the GUI description is like a nice tree structure.
local root; root = sui.Box {
	id = "root",
	mode = "v",
	sui.Box {
		mode = "h",
		sui.Button {
			text = "Disabled",
			enabled = false,
		},
		sui.Button {
			text = "Hello, world!",
		},
		sui.Button {
			text = "Click me to add more buttons!",
			activate = function()
				root:addchild(sui.Button {
					expand=true,
					text="Click me to remove me!",
					activate = function(_self)
						root:removechild(_self)
					end,
				})
			end,
		},
		sui.Button {
			text = "Re-layout",
			activate = function()
				root:layout()
			end,
		},
	},
	sui.Box {
		mode = "h",
		spacing = 8,
		padding = 8,
		sui.Label { text="Example of an horizontal box." },
		sui.Button { text="Yes" },
		sui.Button { text="No" },
	},
	sui.Box {
		mode = "h",
		spacing = 8,
		padding = 8,
		-- If we want to right-align items, we can add a dummy
		-- expandable widget to the start.
		sui.Widget { expand=true, __debug=true },
		sui.Label { text="Example of an horizontal box." },
		sui.Button { text="Yes" },
		sui.Button { text="No" },
	},
	sui.Box {
		mode = "h",
		-- Let's test our example.
		Example {
			expand = true,
			margin = 20,
			-- We can also specify borders separately.
			padding = {
				l = 10,  -- Left
				t = 20,  -- Top
				r = 30,  -- Right
				-- We don't specify bottom, so it defaults to 0.
			},
			text = "Custom widget",
			-- We can add children to our widget, but we must
			-- explicitly set their positions and dimensions,
			-- unless we override `simpleui.Widget:layout`.
			sui.Button {
				x = 40,
				y = 60,
				w = 80,
				h = 24,
				text = "child",
			},
		},
		-- You can also override some methods in-place.
		sui.Widget {
			expand = true,

			-- Let's specify minimum size directly.
			minw = 40,
			minh = 40,

			-- Setting `__debug` to true causes the `paintfg` implementation
			-- in `simpleui.Widget` to paint some debugging information.
			__debug = true,

			-- Though it is not recommended, you can edit some "internal"
			-- fields too. In this case, this is the class name.
			__name = "A widget",

			-- Private fields should begin with a single `_` to avoid clashes.
			_c = 0,

			update = function(_self, dtime)
				_self._c = _self._c+dtime
			end,

			paintfg = function(_self)
				_self:drawtext(not _self.enabled,
						("%.2f"):format(_self._c), .5, .5)
				-- It's important to call the method on the base class to
				-- make `__debug` work.
				sui.Widget.paintfg(_self)
			end,
		},
	},
}

-- Run our UI. This modifies the global `love` event callbacks, sets
-- the specified widget as the root, and returns. The LÖVE event loop
-- then takes care of the rest.
sui.run(root)

-- If you need to modify event handlers, remember to do it *after*
-- calling `simpleui.run`, and to call back into the old function
-- if you don't handle the event yourself.
local oldkeypressed = love.keypressed or function() end
function love.keypressed(k)
	if k == "escape" then
		love.event.quit()
		return
	end
	-- Alternatively, `return sui.keypressed(k)`.
	return oldkeypressed(k)
end
