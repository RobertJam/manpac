local barrier = {}

function barrier.init_entity(self,cfg)
   self.owner = cfg.owner -- who created this
   self.build_state = 0.0 -- percentage built
   self.build = barrier.build
   self.destroy = barrier.destroy
   self.set_state = barrier.set_state
end

function barrier.release_entity(self)
   if self.owner then
      self.owner:addBarrier()
   end
end

function barrier.init_system()
end

function barrier.create(owner,x,y)
   local self = game.create_entity()
   self:addSystem("gfx",{animation = "assets/sprites/barriere.lua"})
   self:addSystem("physics",{width = 64,height=64,body_type="static"})
   self:addSystem("barrier",{owner = owner})
   self:setPosition(x,y)
   return self
end

function barrier.build(self,amount)
   self.build_state = self.build_state + amount
   
   -- Calculate step from 1 to 10
   step = math.ceil(self.build_state * 10)
   self:setAnimation("construct"..step)

   if self.build_state >= 1.0 then
      self.build_state = 1.0
	  self:setAnimation("construct10")
      love.audio.play(audio.sounds.fantom_construit_barriere)
      return true
   else
      return false
   end
end

function barrier.set_state(self, amount)
   self.build_state = amount

   if self.build_state == 1.0 then
      love.audio.play(audio.sounds.fantom_construit_barriere)
   end
end

function barrier.destroy(self,amount)
   self.build_state = self.build_state - amount
   
   -- Calculate step from 1 to 10
   step = math.ceil(self.build_state * 10)
   self:setAnimation("destruct"..step)

   if self.build_state <= 0.0 then
      game.kill_entity(self)
      love.audio.play(audio.sounds.fantome_recupere_barriere)
      return true
   end
   return false
end

function barrier.find(posx, posy)
   local barrier_list = barrier:getEntities()
   for i,bar in ipairs(barrier_list) do
      if bar.x == posx and bar.y == posy then
         return bar
      end
   end
   return nil
end

return barrier
