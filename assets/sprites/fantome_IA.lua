local anim8 = require("libs/anim8")
local anim_grid = anim8.newGrid(57,57,13680,57,0,0,0)
return {
   image = "assets/sprites/fantome_IA.png",
   frame_width = 57,
   frame_height = 57,
   anim_list = {
      --walk
      walk_down = anim8.newAnimation(anim_grid('18-34',1), 0.1),
      walk_left = anim8.newAnimation(anim_grid('52-68',1), 0.1),
      walk_right = anim8.newAnimation(anim_grid('86-102',1), 0.1),
      walk_up = anim8.newAnimation(anim_grid('120-136',1), 0.1),
      --idle
      idle_down = anim8.newAnimation(anim_grid('1-17',1), 0.1),
      idle_left = anim8.newAnimation(anim_grid('35-51',1), 0.1),
      idle_right = anim8.newAnimation(anim_grid('86-102',1), 0.1),
      idle_up = anim8.newAnimation(anim_grid('103-119',1), 0.1),
      --gausse
      gausse_down = anim8.newAnimation(anim_grid('137-153',1), 0.1),
      gausse_left = anim8.newAnimation(anim_grid('154-170',1), 0.1),
      gausse_right = anim8.newAnimation(anim_grid('171-187',1), 0.1),
      gausse_up = anim8.newAnimation(anim_grid('188-204',1), 0.1),
   }
}
