local anim8 = require("libs/anim8")
local anim_grid = anim8.newGrid(64,64,896,64,0,0,0)
return {
   image = "assets/sprites/animation_barriere_haut.png",
   frame_width = 64,
   frame_height = 64,
   anim_list = {
      -- Steps
      step1 = anim8.newAnimation(anim_grid('1-1',1), 0.15),
      step2 = anim8.newAnimation(anim_grid('2-2',1), 0.15),
      step3 = anim8.newAnimation(anim_grid('3-3',1), 0.15),
      step4 = anim8.newAnimation(anim_grid('4-4',1), 0.15),
      step5 = anim8.newAnimation(anim_grid('5-5',1), 0.15),
      step6 = anim8.newAnimation(anim_grid('6-6',1), 0.15),
      step7 = anim8.newAnimation(anim_grid('7-7',1), 0.15),
      step8 = anim8.newAnimation(anim_grid('8-8',1), 0.15),
      step9 = anim8.newAnimation(anim_grid('9-9',1), 0.15),
      step10 = anim8.newAnimation(anim_grid('10-10',1), 0.15),
      step11 = anim8.newAnimation(anim_grid('11-11',1), 0.15),
      step12 = anim8.newAnimation(anim_grid('12-12',1), 0.15),
      step13 = anim8.newAnimation(anim_grid('13-13',1), 0.15),
      step14 = anim8.newAnimation(anim_grid('14-14',1), 0.15),
   }
}
