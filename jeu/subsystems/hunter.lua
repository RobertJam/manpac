local hunter = {}

hunter.keymap = {move_left = "left",
                 move_right = "right",
                 move_up = "up",
                 move_down = "down",
                 destroy_barrier = "v"}

function hunter.init_entity(self)
   self.destroy_barrier = hunter.destroy_barrier
   
   self:addSystems({{"gfx",{image = "assets/sprites/player.tga"}},
         {"physics",{width = 27,height = 32}},
         "character"})
end

function hunter.destroy_barrier(self)

end

function hunter.init_system()
end

return hunter
