require "helper"
require "font"

function love.keypressed(key)
	if key == "escape" then
		love.event.push("q")
	elseif key == "f" then
		love.graphics.toggleFullscreen()
	end
end

function love.quit()
	if player.shield == 0 then
		print("BOOM!!! You're dead!")	
	end
	if #fiends == 0 then
		player.score = player.score + 1000
		print("You killed them all!!!")
	end
	print("Score: %d" % player.score)
end


Trash = Object()
function Trash:init(f)
	self.age = 255
	self.x = f.x
	self.y = f.y
	self.color = f.color
	self.w = 20
	self.h = 20

	local r = math.random() * 2 * math.pi
	local d = math.random() * 3
	self.dx = math.cos(r) * d
	self.dy = math.sin(r) * d
end
function Trash:update()
	self.x = self.x + self.dx
	self.y = self.y + self.dy
	self.age = self.age - 10
	return self.age < 0
end
function Trash:draw()
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.age)
	draw(self)
end

Fiend = Object()
function Fiend:init(x, y, t)
	self.x = x
	self.y = y
	self.w = 36
	self.h = 36
	self.age = 0
	self.max_age = math.random(100, 3000)
	self.speed = 1

	if t == "strong" then
		self.shield = 3
		self.points = 500
		self.color = { 255, 0, 200 }
	else
		self.shield = 1
		self.points = 100
		self.color = { 50, 50, 200 }
	end

end
function Fiend:update()
	self.age = self.age + self.speed
	self.x = self.x + math.cos(self.age * 0.01)
	if self.age > self.max_age then
		self.y = self.y + 1
		self.speed = 3
	end

	if math.abs(self.x) > 450 or math.abs(self.y) > 350 then
		return true
	end

	for i, l in ipairs(laser) do
		if collision(self, l) then
			table.remove(laser, i)
			self.shield = self.shield - 1
			if self.shield == 0 then
				player.score = player.score + self.points
				explosion(self)
				return true
			end
		end
	end

	if player.alive then
		if collision(self, player) then
			player.shield = 0
			player:die()
		end
		if math.random(6000) == 1 then
			self:shoot()
		end
	end
end
function Fiend:shoot()
	table.insert(bullets, Bullet(self))
end
function Fiend:draw()
	love.graphics.setColor(unpack(self.color))
	draw(self)
end


Bullet = Object()
function Bullet:init(f)
	self.x = f.x
	self.y = f.y
	self.w = 15
	self.h = 15

	local dx = player.x - f.x
	local dy = player.y - f.y
	local l = math.sqrt(dx * dx + dy * dy)
	self.dx = dx / l * 4
	self.dy = dy / l * 4

end
function Bullet:update()
	self.x = self.x + self.dx
	self.y = self.y + self.dy
	if math.abs(self.x) > 450 or math.abs(self.y) > 350 then
		return true
	end

	if player.alive and collision(self, player) then
		player.shield = player.shield - 1
		if player.shield == 0 then
			player:die()
		end
		return true
	end

end
function Bullet:draw()
	love.graphics.setColor(0, 255, 0)
	love.graphics.circle("fill", self.x, self.y, 8, 6)
end


Laser = Object()
function Laser:init(x, y)
	self.x = x
	self.y = y
	self.w = 10
	self.h = 20
end
function Laser:update()
	self.y = self.y - 10
	if self.y < -300 then
		return true
	end
end
function Laser:draw()
	love.graphics.setColor(220, 255, 0)
	draw(self)
end


function collision(a, b)
	return math.abs(a.x - b.x) < (a.w + b.w) / 2 and math.abs(a.y - b.y) < (a.h + b.h) / 2
end

function draw(a)
	love.graphics.rectangle("fill", a.x - a.w / 2, a.y - a.h / 2, a.w, a.h)
end


function explosion(a)
	for i = 1, 20 do
		table.insert(particles, Trash(a))
	end
end


-- the player

player = {}
player.shield = 3
player.score = 0
player.x = 0
player.y = 200
player.w = 40
player.h = 40
player.color = { 220, 220, 220 }
player.alive = true
player.exit_delay = 60

function player:update()

	if not self.alive or #fiends == 0 then
		self.exit_delay = self.exit_delay - 1
		if self.exit_delay == 0 then
			love.event.push("q")
		end
	end

	if not self.alive then
		return
	end

	local bool = { [true] = 1, [false] = 0 }
	local dx = bool[love.keyboard.isDown("right")] - bool[love.keyboard.isDown("left")]
	local dy = bool[love.keyboard.isDown("down")] - bool[love.keyboard.isDown("up")]
	player.x = player.x + dx * 2
	player.y = player.y + dy * 2
	if player.x < -380 then player.x = -380 end
	if player.x > 380 then player.x = 380 end
	if player.y < -280 then player.y = -280 end
	if player.y > 280 then player.y = 280 end

	if love.keyboard.isDown("x") and shoot == 0 then
		shoot = laser_delay
		table.insert(laser, Laser(player.x, player.y - 10))
	elseif shoot > 0 then
		shoot = shoot - 1
	end
end
function player:draw()
	if self.alive then
		love.graphics.setColor(unpack(self.color))
		draw(self)
	end
end
function player:die()
	self.alive = false
	explosion(self)
end


function love.load()
	love.mouse.setVisible(false)
	font.init()

	laser = {}
	laser_delay = 40
	shoot = 0

	fiends = {}
	for i = -240, 240, 60 do
		table.insert(fiends, Fiend(i, -200, "strong"))
	end
	for i = -240, 240, 60 do
		table.insert(fiends, Fiend(i, -140))
	end
	for i = -240, 240, 60 do
		table.insert(fiends, Fiend(i, -80))
	end
	for i = -180, 180, 60 do
		table.insert(fiends, Fiend(i, -20))
	end

	bullets = {}
	particles = {}

end


function love.update(dt)
--	love.timer.sleep((1 - dt) * 1000 / 60) -- doesn't work \:

	player:update()
	
	if player.alive and #fiends > 0 and math.random(50) == 1 then
		fiends[math.random(#fiends)]:shoot()
	end

	function filter_update(a)
		local i = 1
		while a[i] do
			if a[i]:update() then
				table.remove(a, i)
			else
				i = i + 1
			end
		end
	end

	filter_update(bullets)
	filter_update(laser)
	filter_update(fiends)
	filter_update(particles)

end


function love.draw()
	love.graphics.translate(400, 300)

	for _, l in ipairs(laser) do l:draw() end
	for _, b in ipairs(bullets) do b:draw() end
	for _, f in ipairs(fiends) do f:draw() end
	for _, p in ipairs(particles) do p:draw() end

	player:draw()

	love.graphics.setColor(255, 255, 255, 150)
	font.print("Score: %4d" % player.score, -390, -290)
	for i = 1, player.shield do
		love.graphics.rectangle("fill", -390 + (i - 1) * 22, 270, 20, 20)
	end
end


