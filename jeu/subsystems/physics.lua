-- physics subsystem

local physics = {world = nil} -- physics package

-- subsystem initialisation
function physics.init_system()
   love.physics.setMeter(32) -- box2D meter in pixels
   physics.world = love.physics.newWorld(0,0) -- horizontal,vertical gravity
   -- register box2d custom callbacks for sensors
   physics.world:setCallbacks(physics.begin_contact,physics.end_contact)
end

-- subsystem cleanup
function physics.release_system()
end

-- Box2D callbacks
function physics.begin_contact(a,b,coll)
   local user_a = a:getUserData()
   local user_b = b:getUserData()
   if game.is_entity(user_a) then
      user_a:sendMessage("enter_collision",user_b)
   end
   if game.is_entity(user_b) then
      user_b:sendMessage("enter_collision",user_a)
   end
end

function physics.end_contact(a,b,coll)
   local user_a = a:getUserData()
   local user_b = b:getUserData()
   if game.is_entity(user_a) then
      user_a:sendMessage("exit_collision",user_b)
   end
   if game.is_entity(user_b) then
      user_b:sendMessage("exit_collision",user_a)
   end
end

-- entity initialisation
function physics.init_entity(self, cfg)
   self.body = love.physics.newBody(physics.world, self.x,self.y, cfg.body_type or "dynamic")
   self.body:setLinearDamping(30)
   self.body:setFixedRotation(true)
   self.shape = nil
   if cfg.vertices then
      self.shape = love.physics.newChainShape(cfg.vertices,true)
      self.shape.vertices = vertices
   else
      width = cfg.width or 10
      height = cfg.height or 10
      self.shape = love.physics.newRectangleShape(width,height)
      self.shape_width = width
      self.shape_height = height
   end
   self.fixture = love.physics.newFixture(self.body, self.shape)
   self.fixture:setRestitution(0.1)
   self.fixture:setUserData(self)
   self.fixture:getMask( )
   self.fixture:setSensor(cfg.sensor or false)
   self.forceX = 0
   self.forceY = 0
   -- add setForces() method
   self.setForces = function(self,fx,fy)
      self.forceX = fx
      self.forceY = fy
   end
   self.setPosition = function(self,x,y)
      self.body:setPosition(x,y)
   end
end

function physics.update(entities,dt)
   -- box2d update
   physics.world:update(dt)
   -- update all entities, assumes they're all physic entities
   for _,entity in pairs(entities) do
      entity.body:applyForce(entity.forceX,entity.forceY)
      -- print("Entity",entity.name,"position before physics is",entity.x,entity.y)
      entity.x,entity.y = entity.body:getPosition()
      -- print("Entity",entity.name,"position after physics is",entity.x,entity.y)
   end
end

return physics
