local anim8 = require 'anim8'

function love.load()
  fantome_IA = love.graphics.newImage('../assets/sprites/fantome_IA.png')

                         -- frame, image,    offsets, border
  local walk = anim8.newGrid(52,52, 11628,57,   0,0,     1)

  walk_down = {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(walk('18-34',2), 0.2),
  }
  walk_left = {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(walk('52-68',2), 0.2),
  }
  walk_right = {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(walk('86-102',2), 0.2),
  }
  walk_up = {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(walk('120-136',2), 0.2),
  }
  	
	
	
  
end