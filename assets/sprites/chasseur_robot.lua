local anim8 = require("libs/anim8")
local anim_grid = anim8.newGrid(57,57,1024,1024,0,0,0)
return {
   image = "assets/sprites/chasseur_robot.png",
   frame_width = 57,
   frame_height = 57,
   anim_list = {
      --walk
      walk_down = anim8.newAnimation(anim_grid('1-5',2), 0.1),
      walk_left = anim8.newAnimation(anim_grid('1-5',6), 0.1),
      walk_right = anim8.newAnimation(anim_grid('1-5',8), 0.1),
      walk_up = anim8.newAnimation(anim_grid('1-5',4), 0.1),
      --idle
      idle_down = anim8.newAnimation(anim_grid('1-3',1), 0.1),
      idle_left = anim8.newAnimation(anim_grid('1-3',5), 0.1),
      idle_right = anim8.newAnimation(anim_grid('1-3',7), 0.1),
      idle_up = anim8.newAnimation(anim_grid('1-3',3), 0.1),
      --gausse
      gausse_down = anim8.newAnimation(anim_grid('1-9',9), 0.1),
      gausse_left = anim8.newAnimation(anim_grid('1-9',11), 0.1),
      gausse_right = anim8.newAnimation(anim_grid('1-9',12), 0.1),
      gausse_up = anim8.newAnimation(anim_grid('1-9',10), 0.1),
	  --end
      win = anim8.newAnimation(anim_grid('1-9',13), 0.1),
      loose = anim8.newAnimation(anim_grid('1-5',14), 0.1),      
   }
}
