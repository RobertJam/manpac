-- graphic subsystem

local gfx = {}

function gfx.init_entity(self,cfg)
   -- requires (x;y) coordinates from base entity
   self.image = love.graphics.newImage(cfg.image or "assets/sprites/player.tga")
   self.angle = 0
   self.scale = cfg.scale or 1.0
   self.offsetX= cfg.offsetX or self.image:getWidth()/2
   self.offsetY = cfg.offsetY or self.image:getHeight()/2
   self.animation = nil
   self.setImage = function(self,filename)
      self.image = love.graphics.newImage(filename)
   end
   self.gfxGetCenter = function(self)
      return self.x+self.image:getWidth()/2,self.y+self.image:getHeight()/2
   end
end

function gfx.init_system()
end

function gfx.draw(entities)
   for _, entity in pairs(entities) do
      -- draw entity as an animated sprite
      if entity.animation then
         entity.animation:draw(entity.image,math.floor(entity.x),
                               math.floor(entity.y), entity.angle, entity.scale,entity.scale,
                               entity.offsetX,entity.offsetY)
      elseif entity.image then
         -- draw entity as a static entity
         love.graphics.draw(entity.image, math.floor(entity.x),
                            math.floor(entity.y), entity.angle, entity.scale, entity.scale,
                               entity.offsetX,entity.offsetY)
      end
   end
end

return gfx
