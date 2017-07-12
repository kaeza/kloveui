
---
-- @classmod simpleui.Box
-- @see simpleui.Widget

local max = math.max

local Widget = require "simpleui.Widget"

local Box = Widget:extend("simpleui.Box")

---
-- @tfield string mode `"h"` or `"v"`. Default is `"h"`.
Box.mode = "h"

---
-- @tfield number spacing
Box.spacing = 0

function Box:layout()
	local v = self.mode == "v"
	local xstep, ystep = v and 0 or 1, v and 1 or 0
	local pl, pt, pr, pb = self:paddings()
	local rest = ((v and self.h-pt-pb or self.w-pl-pr)
			- ((#self-1)*self.spacing))
	local nexp = 0
	for child in self:children() do
		local ml, mt, mr, mb = child:margins()
		if child.expand then
			nexp = nexp + 1
		else
			rest = rest - (v and child.h+mt+mb or child.w+ml+mr)
		end
	end
	local x, y, expsize = pl, pt, rest/nexp
	for child in self:children() do
		local minw, minh = child:minsize()
		local ml, mt, mr, mb = child:margins()
		local w, h, _
		if v then
			w, h = self.w-pl-pr, (child.expand and expsize or minh)
		else
			w, h = (child.expand and expsize or minw), self.h-pt-pb
		end
		_, _, w, h = child:rect(x+ml, y+mt, w-ml-mr, h-mt-mb)
		x, y = x+(w+ml+mr+self.spacing)*xstep, y+(h+mt+mb+self.spacing)*ystep
	end
end

function Box:calcminsize()
	local v = self.mode == "v"
	local w, h = 0, 0
	for child in self:children() do
		local cw, ch = child:minsize()
		local ml, mt, mr, mb = child:margins()
		w = (v and max(w, cw) or w+cw)+ml+mr
		h = (v and h+ch or max(h, ch))+mt+mb
	end
	local sp = max(0, (#self-1)*self.spacing)
	local pl, pt, pr, pb = self:paddings()
	local ph, pv = pl+pr, pt+pb
	return (v and w or w+sp)+ph, (v and h+sp or h)+pv
end

return Box
