-- test game state

local state = {}
local sti = require("libs/sti")

function state.enter()
   -- Grab window size
   windowWidth  = love.graphics.getWidth()
   windowHeight = love.graphics.getHeight()

   -- Set world meter size (in pixels)
   -- love.physics.setMeter(32)

   -- Load a map exported to Lua from Tiled
   map = sti.new("assets/sewers.lua", {})

   -- Prepare physics world with horizontal and vertical gravity
   -- world = love.physics.newWorld(0, 0)

   -- Prepare collision objects
   -- map:box2d_init(world)

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
   map:update(dt)
end

function state.draw()
      -- Translation would normally be based on a player's x/y
      local translateX = 0
      local translateY = 0

      -- Draw Range culls unnecessary tiles
      map:setDrawRange(-translateX, -translateY, windowWidth, windowHeight)

      -- Draw the map and all objects within
      map:draw()

      -- Draw Collision Map (useful for debugging)
      love.graphics.setColor(255, 0, 0, 255)
      -- map:box2d_draw()

      -- Reset color
      love.graphics.setColor(255, 255, 255, 255)
end

return state
