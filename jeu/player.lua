
function init_player(self)
   --graphics
   self.image = love.graphics.newImage("assets/sprites/player.tga")
   self.x = 64
   self.y = 64
   self.angle = 0
   self.animation = nil
   -- physics
   self.body = nil
   self.shape = nil
   self.fixture = nil
   self.body = love.physics.newBody(game.world, self.x/2,self.y/2, "dynamic")
   self.body:setLinearDamping(10)
   self.body:setFixedRotation(true)
   self.shape = love.physics.newRectangleShape(27, 32)
   self.fixture = love.physics.newFixture(self.body, self.shape)
   -- gameplay
   self.role = nil
   -- init data
   return self
end
