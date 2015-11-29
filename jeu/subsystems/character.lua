-- character subsystem

local character = {}

function character.init_entity(self)
   self.move_x = 0
   self.move_y = 0
end

function character.move_left(self)
   self.move_x = -4000
end

function character.move_right(self)
   self.move_x = 4000
end

function character.move_up(self)
   self.move_y = -4000
end

function character.move_down(self)
   self.move_y = 4000
end

function character.update(entities)
   for _,entity in pairs(entities) do
      entity:setForces(entity.move_x,entity.move_y)
      -- FIXME: ugly hack to handle key release
      entity.move_x,entity.move_y = 0,0
   end
end

return character
