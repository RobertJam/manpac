-- character subsystem

local character = {}

function character.init_entity(self)
   self.move_x = 0
   self.move_y = 0
   self.direction = {x = 1, y = 0}
   self.move_left = function(self)
      self.move_x = -4000
      self.direction = {x = -1, y = 0}
   end
   self.move_right = function(self)
      self.move_x = 4000
      self.direction = {x = 1, y = 0}
   end
   self.move_up = function(self)
      self.move_y = -4000
      self.direction = {x = 0, y = -1}
   end
   self.move_down = function(self)
      self.move_y = 4000
      self.direction = {x = 0, y = 1}
   end
end

function character.update(entities)
   for _,entity in pairs(entities) do
      entity:setForces(entity.move_x,entity.move_y)
      -- FIXME: ugly hack to handle key release
      entity.move_x,entity.move_y = 0,0
   end
end

return character
