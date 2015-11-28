local state = {}
local sti = require("libs/sti")
local translateX = 0
local translateY = 0
local zoom = 1.0

-- our global game object, should contain all top level data
-- to prevent global scope garbage
-- FIXME: this should probably go in some other file at some point
game = { map = nil,   -- sti map object
         world = nil -- Box2D physics world
}

local function create_player()
   local player = {
         image = love.graphics.newImage("assets/sprites/player.tga"),
         x = 64,
         y = 64,
         r = 0,
   }
   player.body = love.physics.newBody(game.world, player.x/2,
                                           player.y/2, "dynamic")
   player.body:setLinearDamping(10)
   player.body:setFixedRotation(true)

   player.shape   = love.physics.newRectangleShape(27, 32)
   player.fixture = love.physics.newFixture(player.body, player.shape)

   return player
end

function state.enter()
   -- load our test map and init box2d physics world
   game.map = sti.new("assets/maps/sewers.lua",{"box2d"})
   game.world = love.physics.newWorld(0,0)
   game.map:box2d_init(game.world)
   -- add a custom sprite layer
   game.map:addCustomLayer("Sprite Layer", 3)
   local spriteLayer = game.map.layers["Sprite Layer"]
   game.player = create_player()
   spriteLayer.sprites = {
      player = game.player
   }

   -- Update callback for Custom Layer
   function spriteLayer:update(dt)
      -- do animation stuff etc here
   end

   -- Draw callback for Custom Layer
   function spriteLayer:draw()
      for _, sprite in pairs(self.sprites) do
         local x = math.floor(sprite.x)
         local y = math.floor(sprite.y)
         local r = sprite.r
         love.graphics.draw(sprite.image, x, y, r)
      end
   end
end

function state.update(dt)
   -- update physics world
   game.world:update(dt)
   -- map test keys
   if love.keyboard.isDown("d") then translateX = translateX - 10 end
   if love.keyboard.isDown("q") then translateX = translateX + 10 end
   if love.keyboard.isDown("s") then translateY = translateY - 10 end
   if love.keyboard.isDown("z") then translateY = translateY + 10 end
   if love.keyboard.isDown("a") then zoom = zoom + 0.1 end
   if love.keyboard.isDown("e") then zoom = zoom - 0.1 end
   -- player test keys
   local x, y = 0, 0
   if love.keyboard.isDown("up") then y = y - 4000 end
   if love.keyboard.isDown("down") then y = y + 4000 end
   if love.keyboard.isDown("left") then x = x - 4000 end
   if love.keyboard.isDown("right") then x = x + 4000 end
   -- update player physics
   local player = game.player
   player.body:applyForce(x,y)
   player.x,player.y = player.body:getWorldCenter()
   game.map:update(dt)
end

function state.draw()
   local windowWidth  = love.graphics.getWidth()
   local windowHeight = love.graphics.getHeight()
   love.graphics.push()
   love.graphics.translate(translateX,translateY)
   game.map:setDrawRange(-translateX, -translateY, windowWidth, windowHeight)

   -- Draw the map and all objects within
   game.map:draw(zoom,zoom)

   -- Draw Collision Map (useful for debugging)
   love.graphics.setColor(255, 0, 0, 255)
   game.map:box2d_draw()
   -- draw our player collision shape (custom layer so SIT doesn't handle it)
   love.graphics.setColor(255, 0, 0, 255)
   love.graphics.polygon("line", game.player.body:getWorldPoints(game.player.shape:getPoints()))

   love.graphics.pop()

   -- Reset color
   love.graphics.setColor(255, 255, 255, 255)
end

function state.mousepressed(x, y, button)
end

function state.mousereleased(x, y, button)
end

function state.keypressed(key, isrepeat)
end

function state.keyreleased(key)
end

function state.textinput(text)
end

return state
