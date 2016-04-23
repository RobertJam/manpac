local anim8 = require("libs/anim8")
local anim_grid = anim8.newGrid(57,57,1024,1024,0,0,0)
return {
   image = "assets/sprites/fantome_IA.png",
   frame_width = 57,
   frame_height = 57,
   anim_list = {
      --walk
      walk_down = anim8.newAnimation(anim_grid('1-17',2), 0.1),
      walk_left = anim8.newAnimation(anim_grid('1-17',4), 0.1),
      walk_right = anim8.newAnimation(anim_grid('1-17',6), 0.1),
      walk_up = anim8.newAnimation(anim_grid('1-17',8), 0.1),
      --idle
      idle_down = anim8.newAnimation(anim_grid('1-17',1), 0.1),
      idle_left = anim8.newAnimation(anim_grid('1-17',3), 0.1),
      idle_right = anim8.newAnimation(anim_grid('1-17',5), 0.1),
      idle_up = anim8.newAnimation(anim_grid('1-17',7), 0.1),
      --gausse
      gausse_down = anim8.newAnimation(anim_grid('1-17',9), 0.1),
      gausse_left = anim8.newAnimation(anim_grid('1-17',10), 0.1),
      gausse_right = anim8.newAnimation(anim_grid('1-17',11), 0.1),
      gausse_up = anim8.newAnimation(anim_grid('1-17',12), 0.1),
	  --end
      die = anim8.newAnimation(anim_grid('1-17',13), 0.1),
      win = anim8.newAnimation(anim_grid('1-17',14), 0.1),
      loose = anim8.newAnimation(anim_grid('1-17',15), 0.1),      
   }
}
