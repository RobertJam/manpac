local anim8 = require 'anim8'
local fantome_player

function love.load()
    fantome = love.graphics.newImage('../assets/sprites/fantome_IA.png')
    local grid = anim8.newGrid(52,52, 11628,57,   0,0,     0)
    fantome_player = {
        fantome = fantome,
        x = 0,
        y = 0,
        speed = 10,
        animations = {
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
    if love.keyboard.isDown("up") and fantome_player.y > 0 then 
        fantome_player.y = fantome_player.y - fantome_player.speed * dt
        fantome_player.animation = fantome_player.animations.up
    elseif love.keyboard.isDown("down") and fantome_player.x < 10000 then 
        fantome_player.y = fantome_player.y + fantome_player.speed * dt
        fantome_player.animation = fantome_player.animations.down
    elseif love.keyboard.isDown("left") and fantome_player.x > 0 then 
        fantome_player.x = fantome_player.x - fantome_player.speed * dt
        fantome_player.animation = fantome_player.animations.left
    elseif love.keyboard.isDown("right") and fantome_player.x < 10000 then
        fantome_player.x = fantome_player.x + fantome_player.speed * dt
        fantome_player.animation = fantome_player.animations.right
    end
    fantome_player.animation:update(dt)
end

function love.draw()
    fantome_player.animation:draw(fantome_player.fantome, fantome_player.x, fantome_player.y)
end

function love.keypressed(key)
    if love.keyboard.isDown("escape") then
        love.event.quit("quit")
    end
end