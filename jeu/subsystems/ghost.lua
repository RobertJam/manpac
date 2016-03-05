local utils = require("jeu/utils")
local ghost = {}

ghost.keymap = {move_left = "left",
                 move_right = "right",
                 move_up = "up",
                 move_down = "down",
                 build_barrier = "c",
                 destroy_barrier = "v"}

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
      local build_finish = self.building:build(0.01)
      systems.network.sendData({action = "build_barrier", state = self.building.build_state, x = self.building.x, y = self.building.y})
      if build_finish then self.building = nil end
   else
      -- create a new one
      if self.nbarriers == 0 then return end

      local barrier_position = {x = math.floor((self.x + self.direction.x * (self.shape_width / 2)) / 64) * 64 + self.direction.x * 64 + 32,
                                y = math.floor((self.y + self.direction.y * (self.shape_height / 2)) / 64) * 64 + self.direction.y * 64 + 32}
      local bar = systems.barrier.find(barrier_position.x , barrier_position.y)
      if bar then return end
      self.nbarriers = self.nbarriers - 1
      self.building = systems.barrier.create(self, barrier_position.x ,barrier_position.y)
      systems.network.sendData({action = "create_barrier", x = self.building.x, y = self.building.y})
   end
end

local function _find_closest_barrier(self)
   -- FIXME: consider character direction instead of just the distance
   -- FIXME: consider a maximum distance
   local barrier_list = systems.barrier:getEntities()
   local min_dist = 100
   local selected = nil
   for i=1,#barrier_list do
      local dist = utils.dist(self,barrier_list[i])
      if dist < min_dist then
         min_dist = dist
         selected = barrier_list[i]
      end
   end
   return selected
end

function ghost.destroy_barrier(self)
   self.building = _find_closest_barrier(self)
   if self.building then
      if self.building:destroy(0.1) then
         systems.network.sendData({action = "destroy_barrier", x = self.building.x, y = self.building.y})
         self.building = nil
      else
         systems.network.sendData({action = "build_barrier", state = self.building.build_state, x = self.building.x, y = self.building.y})
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
