-- graphic subsystem

local gfx = {}

function gfx.init_entity(self)
   -- requires (x;y) coordinates from base entity
   self.image = love.graphics.newImage("assets/sprites/player.tga")
   self.angle = 0
   self.animation = nil
end

function gfx.init_system()
end

function gfx.draw(entities)
   for _, entity in pairs(game.entities) do
      -- draw entity as an animated sprite
      if entity.animation then
         entity.animation:draw(entity.image,math.floor(entity.x),
                               math.floor(entity.y), entity.angle)
      elseif entity.image then
         -- draw entity as a static entity
         love.graphics.draw(entity.image, math.floor(entity.x - 10),
                            math.floor(entity.y - 18), entity.angle)
      end
   end
end

return gfx
