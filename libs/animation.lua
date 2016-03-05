local anim8 = require 'anim8'

function love.load()
  fantome_IA = love.graphics.newImage('../assets/sprites/fantome_IA.png')

                         -- frame, image,    offsets, border
  local grid = anim8.newGrid(52,52, 11628,57,   0,0,     0)

  -- walk
  walk_down = 
  {
                     -- type    -- frames                   --default delay
    anim8.newAnimation(grid('18-34',10), 0.2),
  }
  walk_left = 
  {
    anim8.newAnimation(grid('52-68',10), 0.2),
  }
  walk_right = 
  {
    anim8.newAnimation(grid('86-102',10), 0.2),
  }
  walk_up = 
  {
    anim8.newAnimation(grid('120-136',10), 0.2),
  }
  -- iddle
  iddle_down = 
  {
    anim8.newAnimation(grid('1-17',10), 0.2),
  }
  iddle_left = 
  {
    anim8.newAnimation(grid('35-51',10), 0.2),
  }
  iddle_right = 
  {
    anim8.newAnimation(grid('86-102',10), 0.2),
  }
  iddle_up = 
  {
    anim8.newAnimation(grid('103-119',10), 0.2),
  } 
  -- gausse
  gausse_down = 
  {
    anim8.newAnimation(grid('137-153',10), 0.2),
  }
  gausse_left = 
  {
    anim8.newAnimation(grid('154-170',10), 0.2),
  }
  gausse_right = 
  {
    anim8.newAnimation(grid('171-187',10), 0.2),
  }
  gausse_up = 
  {
    anim8.newAnimation(grid('188-204',10), 0.2),
  } 	
	
  
end