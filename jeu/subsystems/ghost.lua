local utils = require("jeu/utils")
local ghost = {}

ghost.keymap = {move_left = "left",
                 move_right = "right",
                 move_up = "up",
                 move_down = "down",
                 build_barrier = "c",
                 destroy_barrier = "v"}

ghost.build_speed = 1.0
ghost.destroy_speed = 1.0

function ghost.init_entity(self,cfg)
   self.nbarriers = cfg.max_barriers or 3
   self.build_barrier = ghost.build_barrier
   self.destroy_barrier = ghost.destroy_barrier
   self.building = nil

   self:addSystems({{"gfx",{image = "assets/sprites/crabe.png", scale = .1}},
         {"physics",{width = 27,height = 32}},
         "character"})
end

function ghost.init_system()
end



function ghost.build_barrier(self)
   -- building something, just update it with some build amount
   if self.building ~= nil then
      local build_finish = self.building:build(game.dt*ghost.build_speed)
      systems.network.sendData({action = "build_barrier",
                                state = self.build_state,
                                x = self.x, y = self.y})
      if build_finish then self.building = nil end
   else
      -- create a new one
      if self.nbarriers == 0 then return end

      local barrier_position = utils.barrier_position(self)
      local bar = systems.barrier.find(barrier_position.x , barrier_position.y)
      if bar then return end
      self.nbarriers = self.nbarriers - 1
      self.building = systems.barrier.create(self, barrier_position.x ,barrier_position.y)
      systems.network.sendData({action = "create_barrier",
                                x = self.building.x,
                                y = self.building.y})
   end
end


function ghost.destroy_barrier(self)
   local barrier_position = utils.barrier_position(self)
   local bar = systems.barrier.find(barrier_position.x,barrier_position.y)
   if bar then
      if bar:destroy(game.dt*ghost.destroy_speed) then
         systems.network.sendData({action = "destroy_barrier",
                                   x = bar.x,
                                   y = bar.y})
      else
         systems.network.sendData({action = "build_barrier",
                                   state = bar.build_state,
                                   x = bar.x,
                                   y = bar.y})
      end
   end
end

function ghost.update(entities)
   -- TODO: cancel building when too far
   -- for _,entity in pairs(entities) do
   --    if entity.building and dist(self,entity.building) > max_build_dist then
   --       entity.building = nil
   --    end
   -- end
end

return ghost
