
-- Example use of KLÖVEUI.

local graphics = love.graphics

local kloveui = require "kloveui"

local Box = require "kloveui.Box"
local Button = require "kloveui.Button"
local Check = require "kloveui.Check"
local Entry = require "kloveui.Entry"
local Label = require "kloveui.Label"
local Option = require "kloveui.Option"
local Slider = require "kloveui.Slider"
local Widget = require "kloveui.Widget"

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
-- See `kloveui.Widget`.

local Example = Widget:extend("Example")

local function drawrect(label, cr, cg, cb, x, y, w, h)
	graphics.setColor(cr, cg, cb, .5)
	graphics.rectangle("fill", x, y, w, h)
	graphics.setColor(cr, cg, cb)
	graphics.rectangle("line", x, y, w, h)
	graphics.print(label, x+2, y+2)
end

-- We draw our widget "background" here.
-- See `kloveui.Widget:paintbg`.
function Example:paintbg()
	-- As a test, let's draw our layout parameters.

	local ml, mt, mr, mb = self:margins()
	local pl, pt, pr, pb = self:paddings()
	local w, h = self:size()

	-- Margin in red.
	-- Note that we are technically drawing outside the bounds
	-- of our widget. KLÖVEUI does not clip any graphics calls,
	-- but we should always respect the layout parameters.
	drawrect("Margin", 1, .5, .5, -ml, -mt, w+ml+mr, h+mt+mb)

	-- Padding in blue.
	-- We are "inside" the widget here. You will notice mouse
	-- events (see below) work inside the "padding", but not in
	-- the area marked as "margin".
	-- Note that what "padding" means varies from widget to widget.
	-- For example, buttons add borders around the text, but the
	-- "button" part is still widget-sized.
	drawrect("Padding", .5, .5, 1, 0, 0, w, h)

	-- Content in green.
	drawrect("Content", .5, 1, .5, pl, pt, w-pl-pr, h-pt-pb)
end

-- We draw our widget "foreground" here.
-- See `kloveui.Widget:paintfg`.
function Example:paintfg()
	-- We should ALWAYS set colors explicitly. KLÖVEUI does not
	-- save or restore any state besides the transformation matrix.
	graphics.setColor(1, 1, 1)
	self:drawtext(not self.enabled, self.text, .5, .5)
	if self._mousex then
		if self:inside(self._mousex, self._mousey) then
			graphics.setColor(1, 1, 0)
		else
			graphics.setColor(1, 0, 0)
		end
		graphics.circle("fill", self._mousex, self._mousey, 9)
	end
end

-- We should define this method if we want to add it to a
-- container and we don't explicitly set `minw` and `minh`.
-- See `kloveui.Widget:calcminsize`.
-- See `kloveui.Widget.minw`.
-- See `kloveui.Widget.minh`.
function Example:calcminsize()
	return 320, 240
end

-- We can handle mouse events.
-- See `kloveui.Widget:mousepressed`.
function Example:mousepressed(x, y, b)
	if b == 1 then -- Left Mouse Button
		self._mousex, self._mousey = x, y
	end
end

-- See `kloveui.Widget:mousemoved`.
function Example:mousemoved(x, y)
	if self._mousex then
		self._mousex, self._mousey = x, y
	end
end

-- See `kloveui.Widget:mousereleased`.
function Example:mousereleased()
	self._mousex, self._mousey = nil, nil
end

-- Our "root" widget.
-- You will notice the GUI description is like a nice tree structure.
-- See `kloveui.Box`.
local root; root = Box {
	id = "root",
	mode = "v",
	Box {
		mode = "h",
		-- See `kloveui.Button`.
		Button {
			text = "Disabled",
			enabled = false,
		},
		Button {
			text = "Hello, world!",
		},
		Button {
			text = "Click me to add more buttons!",
			activated = function()
				root:addchild(Button {
					expand=true,
					text="Click me to remove me!",
					activated = function(_self)
						root:removechild(_self)
						root:layout()
					end,
				})
				-- We must call `layout` after adding/removing children.
				root:layout()
			end,
		},
		Button {
			text = "Re-layout",
			activated = function()
				root:layout()
			end,
		},
	},
	Box {
		mode = "h",
		spacing = 8,
		padding = 8,
		-- See `kloveui.Label`.
		Label { text="Example of an horizontal box." },
		Button { text="Yes" },
		Button { text="No" },
	},
	Box {
		mode = "h",
		spacing = 8,
		padding = 8,
		-- If we want to right-align items, we can add a dummy
		-- expandable widget to the start.
		Widget { expand=true, __debug=true },
		Label { text="Example of an horizontal box." },
		Button { text="Yes" },
		Button { text="No" },
	},
	Box {
		mode = "h",
		spacing = 8,
		padding = 8,
		-- See `kloveui.Check`.
		Check { text="Check 1" },
		Check { text="Check 2", value=true },
		Check { text="Check 3" },
		-- See `kloveui.Option`.
		Option { text="Option 1" },
		Option { text="Option 2", value=true },
		Option { text="Option 3", group="bar" },
		Option { text="Option 4", value=true, group="bar" },
	},
	Box {
		mode = "h",
		spacing = 8,
		padding = 8,
		Label { text="Sliders" },
		Label { text="Free" },
		-- See `kloveui.Slider`.
		Slider {
			expand = true,
			valuechanged = function(_self)
				print(_self.value)
			end,
		},
		Label { text="Snapping" },
		Slider {
			expand = true,
			increment = 0.1,
			valuechanged = function(_self)
				print(_self.value)
			end,
		},
	},
	-- See `kloveui.Entry`.
	Entry {
		text = "An editable text entry. ãéìôüñ",
		committed = function(_self)
			print(_self.text)
		end,
	},
	Box {
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
			-- unless we override `kloveui.Widget:layout`.
			Button {
				x = 40,
				y = 60,
				w = 80,
				h = 24,
				text = "child",
			},
		},
		-- You can also override some methods in-place.
		Widget {
			expand = true,

			-- Let's specify minimum size directly.
			minw = 40,
			minh = 40,

			-- Setting `__debug` to true causes the `paintfg` implementation
			-- in `kloveui.Widget` to paint some debugging information.
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
				Widget.paintfg(_self)
			end,
		},
	},
}

-- If you need to modify event handlers, remember to call back into the old
-- function if you don't handle the event yourself.
-- See `kloveui.keypressed`.
local oldkeypressed = kloveui.keypressed
function kloveui.keypressed(key, scan, isrep)
	if key == "escape" then
		love.event.quit()
		return
	end
	return oldkeypressed(key, scan, isrep)
end

local function main()
	-- We must call `layout` to let boxes and other layout widgets do their
	-- job. We only need to call this for the root; it is expected it will
	-- call `rect` (which calls `layout` after positioning) to position its
	-- children as needed .
	-- See `kloveui.Widget:layout`.
	root:layout()
	-- See `kloveui.Widget:run`.
	return root:run()
end

return main()
