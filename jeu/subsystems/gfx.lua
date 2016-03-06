-- graphic subsystem
local anim8 = require("libs/anim8")
local gfx = {}

function gfx.init_entity(self,cfg)
   -- requires (x;y) coordinates from base entity
   self.angle = 0
   self.color = cfg.color or {1.0,1.0,1.0,1.0}
   self.scale = cfg.scale or 1.0
   self.animation = nil
   self.anim_list = {}
   if cfg.animation then
      self.image = love.graphics.newImage(cfg.animation)
      self.animation = nil
      local anim_grid = anim8.newGrid(57,57,13680,57,0,0,0)
      self.anim_list = {
         --walk
         walk_down = anim8.newAnimation(anim_grid('18-34',1), 1.0,'loop'),
         walk_left = anim8.newAnimation(anim_grid('52-68',1), 1.0,'loop'),
         walk_right = anim8.newAnimation(anim_grid('86-102',1),1.0,'loop'),
         walk_up = anim8.newAnimation(anim_grid('120-136',1), 1.0,'loop'),
         --idle
         idle_down = anim8.newAnimation(anim_grid('1-17',1), 1.0,'loop'),
         idle_left = anim8.newAnimation(anim_grid('35-51',1), 1.0,'loop'),
         idle_right = anim8.newAnimation(anim_grid('86-102',1), 1.0,'loop'),
         idle_up = anim8.newAnimation(anim_grid('103-119',1), 1.0,'loop'),
         --gausse
         gausse_down = anim8.newAnimation(anim_grid('137-153',1), 1.0,'loop'),
         gausse_left = anim8.newAnimation(anim_grid('154-170',1), 1.0,'loop'),
         gausse_right = anim8.newAnimation(anim_grid('171-187',1),1.0,'loop'),
         gausse_up = anim8.newAnimation(anim_grid('188-204',1), 1.0,'loop'),
      }
      self.offsetX= cfg.offsetX or 57/2
      self.offsetY = cfg.offsetY or 57/2
   else
      self.image = love.graphics.newImage(cfg.image or "assets/sprites/player.tga")
      self.offsetX= cfg.offsetX or self.image:getWidth()/2
      self.offsetY = cfg.offsetY or self.image:getHeight()/2
   end
   self.setImage = function(self,filename)
      self.image = love.graphics.newImage(filename)
   end
   self.gfxGetCenter = function(self)
      return self.x+self.image:getWidth()/2,self.y+self.image:getHeight()/2
   end
   self.setColor = function(self,color)
      self.color = color
   end
   self.setAnimation = function(self,anim_name)
      self.animation = self.anim_list[anim_name]
   end
   self:setAnimation("idle_down")
end

function gfx.init_system()
end

function gfx.draw(entities)
   for _, entity in pairs(entities) do
      love.graphics.setColor(entity.color[1]*255,
                             entity.color[2]*255,
                             entity.color[3]*255,
                             entity.color[4]*255)
      -- draw entity as an animated sprite
      if entity.animation then
         entity.animation:draw(entity.image,math.floor(entity.x),
                               math.floor(entity.y), entity.angle,
                               entity.scale,entity.scale,
                               entity.offsetX,entity.offsetY)
      elseif entity.image then
         -- draw entity as a static entity
         love.graphics.draw(entity.image, math.floor(entity.x),
                            math.floor(entity.y), entity.angle,
                            entity.scale, entity.scale,
                            entity.offsetX,entity.offsetY)
      end
   end
end

function gfx.update(entities,dt)
   for _, entity in pairs(entities) do
      if entity.animation then
         entity.animation:update(dt)
      end
   end
end

return gfx
