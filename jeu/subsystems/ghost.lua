local utils = require("jeu/utils")
local ghost = {}

ghost.keymap = {move_left = "left",
                 move_right = "right",
                 move_up = "up",
                 move_down = "down",
                 build_barrier = "c",
                 destroy_barrier = "v"}

ghost.build_speed = 0.8
ghost.destroy_speed = 0.8
ghost.nbarriers = nil

function ghost.init_entity(self,cfg)
   game.nghost = game.nghost + 1
   self.nbarriers = cfg.max_barriers or 3
   self.build_speed = cfg.build_speed or ghost.build_speed
   self.destroy_speed = cfg.destroy_speed or ghost.destroy_speed
   self.build_barrier = ghost.build_barrier
   self.destroy_barrier = ghost.destroy_barrier
   self.building = nil
   self.removeBarrier = function(self)
      if ghost.nbarriers then
         ghost.nbarriers = ghost.nbarriers - 1
      else
         self.nbarriers = self.nbarriers - 1
      end
   end
   self.addBarrier = function(self)
      if ghost.nbarriers then
         ghost.nbarriers = ghost.nbarriers + 1
      else
         self.nbarriers = self.nbarriers + 1
      end
   end
   self.hasBarriers = function(self)
      if ghost.nbarriers then
         return ghost.nbarriers ~= 0
      else
         return self.nbarriers ~= 0
      end
   end
   self.nBarriers = function(self)
      return ghost.nbarriers or self.nbarriers
   end
end

function ghost.release_entity(self)
   game.nghost = game.nghost - 1
end

function ghost.init_system()
end


function ghost.build_barrier(self)
   local barrier_position = utils.barrier_position(self)
   local bar = systems.barrier.find(barrier_position.x,barrier_position.y)
   -- building something, just update it with some build amount
   if bar ~= nil then
      local build_finish = bar:build(game.dt*ghost.build_speed)
      systems.network.sendData({action = "build_barrier",
                                state = bar.build_state,
                                x = bar.x, y = bar.y})
   else
      -- create a new one
      if not self:hasBarriers() then return end

      local barrier_position = utils.barrier_position(self)
      local bar = systems.barrier.find(barrier_position.x , barrier_position.y)
      if bar then return end
      self:removeBarrier()
      bar = systems.barrier.create(self, barrier_position.x ,
                                   barrier_position.y)
      systems.network.sendData({action = "create_barrier",
                                x = bar.x,
                                y = bar.y})
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


return ghost
