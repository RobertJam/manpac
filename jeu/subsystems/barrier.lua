local barrier = {}

function barrier.init_entity(self,cfg)
   self.owner = cfg.owner -- who created this
   self.build_state = 0.0 -- percentage built
   self.build = barrier.build
   self.destroy = barrier.destroy
end

function barrier.release_entity(self)
   self.owner.nbarriers = self.owner.nbarriers + 1
end

function barrier.init_system()
end

function barrier.create(owner,x,y)
   local self = game.create_entity()
   self:addSystem("gfx",{image = "assets/sprites/barriere.png"})
   self:addSystem("physics",{width = 64,height=64,body_type="static"})
   self:addSystem("barrier",{owner = owner})
   self:setPosition(x,y)
   self:setColor({1.0,1.0,1.0,0.0})
   return self
end

function barrier.build(self,amount)
   self.build_state = self.build_state + amount
   -- TODO: update current animation state based on build
   -- TODO: state
   self:setColor({1.0,1.0,1.0,self.build_state})
   if self.build_state >= 1.0 then
      self.build_state = 1.0
      love.audio.play(audio.sounds.fantom_construit_barriere)
      return true
   end
   return false
end

function barrier.destroy(self,amount)
   self.build_state = self.build_state - amount
   -- TODO: update current animation state based on build
   -- TODO: state
   self:setColor({1.0,1.0,1.0,self.build_state})
   if self.build_state <= 0.0 then
      game.kill_entity(self)
      love.audio.play(audio.sounds.fantome_recupere_barriere)
      return true
   end
   return false
end

return barrier
