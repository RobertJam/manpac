local anim8 = require("libs/anim8")
local anim_grid = anim8.newGrid(64,64,896,64,0,0,0)
return {
   image = "assets/sprites/animation_barriere_haut.png",
   frame_width = 64,
   frame_height = 64,
   anim_list = {
      -- Construct
      construct1 = anim8.newAnimation(anim_grid('1-5',1), 0.15),
      construct2 = anim8.newAnimation(anim_grid('2-6',1), 0.15),
      construct3 = anim8.newAnimation(anim_grid('3-7',1), 0.15),
      construct4 = anim8.newAnimation(anim_grid('4-8',1), 0.15),
      construct5 = anim8.newAnimation(anim_grid('5-9',1), 0.15),
      construct6 = anim8.newAnimation(anim_grid('6-10',1), 0.15),
      construct7 = anim8.newAnimation(anim_grid('7-11',1), 0.15),
      construct8 = anim8.newAnimation(anim_grid('8-12',1), 0.15),
      construct9 = anim8.newAnimation(anim_grid('9-13',1), 0.15),
      construct10 = anim8.newAnimation(anim_grid('14-14',1), 0.15),
	  
	  -- Destruct
      destruct1 = anim8.newAnimation(anim_grid('5-1',1), 0.15),
      destruct2 = anim8.newAnimation(anim_grid('6-2',1), 0.15),
      destruct3 = anim8.newAnimation(anim_grid('7-3',1), 0.15),
      destruct4 = anim8.newAnimation(anim_grid('8-4',1), 0.15),
      destruct5 = anim8.newAnimation(anim_grid('9-5',1), 0.15),
      destruct6 = anim8.newAnimation(anim_grid('10-6',1), 0.15),
      destruct7 = anim8.newAnimation(anim_grid('11-7',1), 0.15),
      destruct8 = anim8.newAnimation(anim_grid('12-8',1), 0.15),
      destruct9 = anim8.newAnimation(anim_grid('13-9',1), 0.15),
      destruct10 = anim8.newAnimation(anim_grid('14-14',1), 0.15),
   }
}
