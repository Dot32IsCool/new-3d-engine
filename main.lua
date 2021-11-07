local cpml = require("vendor.cpml")

local intro = require("intro")
intro:init()

local shader = love.graphics.newShader(love.filesystem.read("vs.glsl"), love.filesystem.read("fs.glsl"))
local vertices = require("vertices")
local format = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexColor", "byte", 4}
}
local mesh = love.graphics.newMesh(format, vertices, "triangles", "static")
mesh:setTexture(love.graphics.newImage("dot.png"))
local canvas = love.graphics.newCanvas()

local view = cpml.mat4.identity()
view = view:translate(view, cpml.vec3.new(0, 0, -10))
view = view:rotate(view, math.rad(26.57), cpml.vec3.new(1,0,0))

local player = {xV=0, zV=0}
player.mat = cpml.mat4.identity()

local somethingElse = cpml.mat4.identity()
somethingElse:translate(somethingElse, cpml.vec3.new(4,0,0))

local elseTable = {}
for i=1, 60 do
	local object = cpml.mat4.identity()
	object:rotate(object, math.rad(math.random()*360), cpml.vec3.new(0,1,0))
	object:translate(object, cpml.vec3.new(math.random()*10-5, 0,math.random()*10-5))
	object:scale(object, cpml.vec3.new(0.5,0.5,0.5))
	table.insert(elseTable, object)
end

local size = 8
local aspect = love.graphics.getWidth() / love.graphics.getHeight()
local projection = cpml.mat4.from_ortho(-size, size, -size/aspect, size/aspect, 0.1, 1000)

function love.update(dt)
	view = view:rotate(view, math.rad(10)*dt, cpml.vec3.new(0,1,0))

	if love.keyboard.isDown("left") then
		player.xV = player.xV - 1*dt
	end
	if love.keyboard.isDown("right") then
		player.xV = player.xV + 1*dt
	end
	if love.keyboard.isDown("up") then
		player.zV = player.zV - 1*dt
	end
	if love.keyboard.isDown("down") then
		player.zV = player.zV + 1*dt
	end

	player.xV = player.xV*(1/(1 + (dt*14)))
	player.zV = player.zV*(1/(1 + (dt*14)))

	player.mat:translate(player.mat, cpml.vec3.new(player.xV, 0, player.zV))

	intro:update()
end

function love.draw()
	love.graphics.setCanvas({canvas, depth=true})
	love.graphics.setShader(shader)
	love.graphics.setDepthMode("less", true)
	love.graphics.clear()	

	shader:send("view", "column", view)
	shader:send("projection", "column", projection)

	shader:send("model", "column", player.mat)
	love.graphics.draw(mesh)

	shader:send("model", "column", somethingElse)
	love.graphics.draw(mesh)

	for i,v in ipairs(elseTable) do
		shader:send("model", "column", v)
		love.graphics.draw(mesh)
	end

	love.graphics.setShader()
	love.graphics.setCanvas()

	love.graphics.draw(canvas)
	intro:draw()
end

function love.resize(w, h)
	aspect = love.graphics.getWidth() / love.graphics.getHeight()
	projection = cpml.mat4.from_ortho(-size, size, -size/aspect, size/aspect, 0.1, 1000)
	canvas = love.graphics.newCanvas()
end

function love.keypressed(k)
	if k == "r" then
		elseTable = {}
		for i=1, 60 do
			local object = cpml.mat4.identity()
			object:translate(object, cpml.vec3.new(math.random()*10-5, 0,math.random()*10-5))
			object:scale(object, cpml.vec3.new(0.5,0.5,0.5))
			object:rotate(object, math.rad(math.random()*90), cpml.vec3.new(0,1,0))
			table.insert(elseTable, object)
		end
	end
end