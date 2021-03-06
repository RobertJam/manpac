-- character subsystem

local character = {}

function character.init_entity(self,cfg)
   self.move_force = cfg.move_force or 10000
   self.move_x = 0
   self.move_y = 0
   self.direction = {x = 1, y = 0}
   self.move_left = function(self)
      self.move_x = -self.move_force
      self.direction = {x = -1, y = 0}
      self:setAnimation("walk_left")
   end
   self.move_right = function(self)
      self.move_x = self.move_force
      self.direction = {x = 1, y = 0}
      self:setAnimation("walk_right")
   end
   self.move_up = function(self)
      self.move_y = -self.move_force
      self.direction = {x = 0, y = 1}
      self:setAnimation("walk_up")
   end
   self.move_down = function(self)
      self.move_y = self.move_force
      self.direction = {x = 0, y = -1}
      self:setAnimation("walk_down")
   end
   self.isMoving = function(self)
      return (self.move_x ~= 0 or self.move_y ~= 0)
   end
   self.setDirection = function(self,direction,moving)
      self.direction = direction
      if self.direction.x == 1 and self.direction.y == 0 then
         if moving then
            self:setAnimation("walk_right")
         else
            self:setAnimation("idle_right")
         end
      elseif self.direction.x == -1 and self.direction.y == 0 then
         if moving then
            self:setAnimation("walk_left")
         else
            self:setAnimation("idle_left")
         end
      elseif self.direction.y == -1 and self.direction.x == 0 then
         if moving then
            self:setAnimation("walk_down")
         else
            self:setAnimation("idle_down")
         end
      elseif self.direction.y == 1 and self.direction.x == 0 then
         if moving then
            self:setAnimation("walk_up")
         else
            self:setAnimation("idle_up")
         end
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
