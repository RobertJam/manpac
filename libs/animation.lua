local anim8 = require 'anim8'

function love.load()
  fantome_IA = love.graphics.newImage('../assets/sprites/fantome_IA.png')

                         -- frame, image,    offsets, border
  local walk = anim8.newGrid(52,52, 11628,57,   3,3,     1)

  walk = {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(walk_left(52,'52-68'), 0.2),
	anim8.newAnimation(walk_right(86,'86-102'), 0.2),
	anim8.newAnimation(walk_up(120,'120-136'), 0.2),
	anim8.newAnimation(walk_down(18,'18-34'), 0.2),
  }
