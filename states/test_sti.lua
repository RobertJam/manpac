-- test game state

local state = {}
local sti = require("libs/sti")
local translateX = 0
local translateY = 0
local zoom = 1.0

function state.enter()
   -- Grab window size
   windowWidth  = love.graphics.getWidth()
   windowHeight = love.graphics.getHeight()

   -- Set world meter size (in pixels)
   love.physics.setMeter(32)

   -- Load a map exported to Lua from Tiled
   map = sti.new("assets/sewers.lua", {"box2d"})

   -- Prepare physics world with horizontal and vertical gravity
   world = love.physics.newWorld(0, 0)

   -- Prepare collision objects
   map:box2d_init(world)

   -- Create a Custom Layer
   -- map:addCustomLayer("Sprite Layer", 3)

   -- -- Add data to Custom Layer
   -- local spriteLayer = map.layers["Sprite Layer"]
   -- spriteLayer.sprites = {
   --    player = {
   --       image = love.graphics.newImage("assets/sprites/player.png"),
   --       x = 64,
   --       y = 64,
   --       r = 0,
   --    }
   -- }

   -- -- Update callback for Custom Layer
   -- function spriteLayer:update(dt)
   --    for _, sprite in pairs(self.sprites) do
   --       sprite.r = sprite.r + math.rad(90 * dt)
   --    end
   -- end

   -- -- Draw callback for Custom Layer
   -- function spriteLayer:draw()
   --    for _, sprite in pairs(self.sprites) do
   --       local x = math.floor(sprite.x)
   --       local y = math.floor(sprite.y)
   --       local r = sprite.r
   --       love.graphics.draw(sprite.image, x, y, r)
   --    end
   -- end
end

function state.leave()
end

function state.update(dt)
   if love.keyboard.isDown("d") then translateX = translateX - 10 end
   if love.keyboard.isDown("q") then translateX = translateX + 10 end
   if love.keyboard.isDown("s") then translateY = translateY - 10 end
   if love.keyboard.isDown("z") then translateY = translateY + 10 end
   if love.keyboard.isDown("a") then zoom = zoom + 0.1 end
   if love.keyboard.isDown("e") then zoom = zoom - 0.1 end
   map:update(dt)
end

function state.draw()
   love.graphics.push()
   love.graphics.translate(translateX,translateY)
   map:setDrawRange(-translateX, -translateY, windowWidth, windowHeight)

      -- Draw the map and all objects within
      map:draw(zoom,zoom)

      -- Draw Collision Map (useful for debugging)
      love.graphics.setColor(255, 0, 0, 255)
      map:box2d_draw()

      love.graphics.pop()

      -- Reset color
      love.graphics.setColor(255, 255, 255, 255)
end

return state
