-- python-like modulo operator on strings
getmetatable("").__mod = function(s, a)
	if not a then
		return s
	elseif type(a) == "table" then
		return s:format(unpack(a))
	else
		return s:format(a)
	end
end


-- short string lambda
function lambda(s)
	return loadstring("return function(X,Y,Z)return " .. s .. " end")()
end


-- we need some nice oo
Object = {}
setmetatable(Object, { __call = function(self, ...)
	local o = self.init and {} or ... or {}
	setmetatable(o, self)
	self.__index = self
	self.__call = getmetatable(self).__call
	if self.init then self.init(o, ...) end
	return o
end })


-- test
if test then
	Vec2d = Object { x = 4, y = 0 }

	function Vec2d:__tostring()
		return "Vec2d{x = %g, y = %g}" % { self.x, self.y }
	end

	Vec3d = Vec2d { z = 0 }
	function Vec3d:__tostring()
		return "Vec3d{x = %g, y = %g, z = %g}" % { self.x, self.y, self.z }
	end

	a = Vec2d()
	b = Vec3d()

	print(a)
	print(b)

	-- test with init

	Box = Object()

	function Box:init(text)
		self.text = text
	end

	function Box:put()
		print(self.text)
	end


	ChildBox = Box()

	function ChildBox:super_put()
		print(("#"):rep(#self.text + 4))
		print("# %s #" % self.text)
		print(("#"):rep(#self.text + 4))
	end

	w = Box("hallo")
	w:put()

	c = ChildBox("hi there")
	c:put()
	c:super_print()

end

