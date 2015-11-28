local state = {}
local sti = require("libs/sti")
local translateX = 0
local translateY = 0
local zoom = 1.0
local entity_count = 1

-- FIXME: brutal include modifying global namespace
-- FIXME: make a proper package out of this
require("jeu/player")

-- our global game object, should contain all top level data
-- to prevent global scope garbage
-- FIXME: this should probably go in some other file at some point
game = { map = nil,    -- sti map object
         world = nil,   -- Box2D physics world
         entities = {}, -- all existing game object
}

function game.create_entity(name)
   local entity = {name = name or string.format("entity-%d",entity_count),
                   id = entity_count}
   game.entities[entity_count] = entity
   print("Created entity "..entity.name)
   entity_count = entity_count + 1
   return entity
end

function game.kill_entity(entity)
   game.entities[entity.id] = nil
end

function state.enter()
   -- load our test map and init box2d physics world
   game.map = sti.new("assets/maps/sewers.lua",{"box2d"})
   love.physics.setMeter(32) -- box2D meter in pixels
   game.world = love.physics.newWorld(0,0)
   game.map:box2d_init(game.world)
   -- add a custom sprite layer (see sprite.lua)
   game.map:addCustomLayer("SpriteLayer", #game.map.layers+1)
   local spriteLayer = game.map.layers["SpriteLayer"]

   -- Update callback for Custom Layer
   function spriteLayer:update(dt)
      -- do animation stuff etc here
   end

   -- Draw callback for Custom Layer
   function spriteLayer:draw()
      for _, entity in pairs(game.entities) do
         local sprite = entity
         if sprite.animation then
            sprite.animation:draw(sprite.image,math.floor(sprite.x),
                               math.floor(sprite.y), sprite.angle)
         elseif sprite.image then
            -- draw entity as a static sprite
            love.graphics.draw(sprite.image, math.floor(sprite.x),
                               math.floor(sprite.y), sprite.angle)
         end
      end
   end

   -- create player
   game.player = game.create_entity()
   init_player(game.player)
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
