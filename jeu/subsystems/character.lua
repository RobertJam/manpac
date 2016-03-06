-- character subsystem

local character = {}

function character.init_entity(self)
   self.move_x = 0
   self.move_y = 0
   self.direction = {x = 1, y = 0}
   self.move_left = function(self)
      self.move_x = -4000
      self.direction = {x = -1, y = 0}
      self:setAnimation("walk_left")
   end
   self.move_right = function(self)
      self.move_x = 4000
      self.direction = {x = 1, y = 0}
      self:setAnimation("walk_right")
   end
   self.move_up = function(self)
      self.move_y = -4000
      self.direction = {x = 0, y = -1}
      self:setAnimation("walk_up")
   end
   self.move_down = function(self)
      self.move_y = 4000
      self.direction = {x = 0, y = 1}
      self:setAnimation("walk_down")
   end
   self.dont_move = function(self)
      if self.direction.x == 1 and self.direction.y == 0 then
         self:setAnimation("idle_right")
      elseif self.direction.x == -1 and self.direction.y == 0 then
         self:setAnimation("idle_left")
      elseif self.direction.y == 1 and self.direction.x == 0 then
         self:setAnimation("idle_down")
      elseif self.direction.y == -1 and self.direction.x == 0 then
         self:setAnimation("idle_up")
      end
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
