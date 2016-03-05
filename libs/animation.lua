local anim8 = require 'anim8'
local fantome

function love.load()
  fantome_IA = love.graphics.newImage('../assets/sprites/fantome_IA.png')

                         -- frame, image,    offsets, border
  local grid = anim8.newGrid(52,52, 11628,57,   0,0,     0)

  fantome = {
	fantome_IA = fantome_IA,
	x = 0,
	y = 0,
	speed = 10,
	animation = {
		--walk
		walk_down = anim8.newAnimation('loop', grid('18-34',10), 1.0),
		walk_left = anim8.newAnimation('loop', grid('52-68',10), 1.0),
		walk_right = anim8.newAnimation('loop', grid('86-102',10), 1.0),
		walk_up = anim8.newAnimation('loop', grid('120-136',10), 1.0),
		--iddle
		iddle_down = anim8.newAnimation('loop', grid('1-17',10), 1.0),
		iddle_left = anim8.newAnimation('loop', grid('35-51',10), 1.0),
		iddle_right = anim8.newAnimation('loop', grid('86-102',10), 1.0),
		iddle_up = anim8.newAnimation('loop', grid('103-119',10), 1.0),
		--gausse
		gausse_down = anim8.newAnimation('loop', grid('137-153',10), 1.0),
		gausse_left = anim8.newAnimation('loop', grid('154-170',10), 1.0),
		gausse_right = anim8.newAnimation('loop', grid('171-187',10), 1.0),
		gausse_up = anim8.newAnimation('loop', grid('188-204',10), 1.0),
	}
  } 	
	
end

function love.update(dt)

end

function love.draw()

end

function love.keypressed(key)

end