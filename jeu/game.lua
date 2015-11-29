local state = {}
local sti = require("libs/sti")
local translateX = 0
local translateY = 0
local zoom = 1.0
local entity_count = 1

-- subsystems
-- XXX: should not be required elsewhere
-- FIXME: probably store some reference in the game table to prevent this
local physics = require("jeu/subsystems/physics")
local gfx = require("jeu/subsystems/gfx")

-- our global game object, should contain all top level data
-- to prevent global scope garbage
-- FIXME: this should probably go in some other file at some point
game = { map = nil,     -- sti map object
         entities = {}, -- all existing game object
}

-- FIXME: move entity system to its own file
function game.create_entity(name)
   local entity = {name = name or string.format("entity-%d",entity_count),
                   id = entity_count,
                   -- commonly used data
                   x = 0, y = 0}
   game.entities[entity_count] = entity
   print("Created entity "..entity.name)
   entity_count = entity_count + 1
   return entity
end

function game.kill_entity(entity)
   game.entities[entity.id] = nil
end

-- in-game state callbacks

function state.enter()
   -- init subsystems
   gfx.init_system()
   physics.init_system()
   -- load our test map and link it to our physical world
   game.map = sti.new("assets/maps/sewers.lua",{"box2d"})
   game.map:box2d_init(physics.world)
   -- add a custom sprite layer (see sprite.lua)
   game.map:addCustomLayer("SpriteLayer", #game.map.layers+1)
   local spriteLayer = game.map.layers["SpriteLayer"]

   -- Update callback for Custom Layer
   function spriteLayer:update(dt)
      -- do animation stuff etc here
   end

   -- Draw callback for Custom Layer
   function spriteLayer:draw()
      gfx.draw(game.entities)
   end

   -- create player
   game.player = game.create_entity()
   gfx.init_entity(game.player)
   physics.init_entity(game.player)
   
   -- create bot
   game.bot = game.create_entity()
   gfx.init_entity(game.bot)
   physics.init_entity(game.bot)
end

function state.update(dt)
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
   game.player:setForces(x,y)
   
   -- bot
   local x_bot, y_bot = 0, 0
   local deplacement_bot = 1000
   x_bot = love.math.random(-deplacement_bot, deplacement_bot)
   y_bot = love.math.random(-deplacement_bot, deplacement_bot)
   game.bot:setForces(x_bot,y_bot)
   
   -- update physics
   physics.update(game.entities,dt)
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
