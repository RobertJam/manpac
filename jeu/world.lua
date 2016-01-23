local sti = require("libs/sti")
local world = {}

function world.draw(self)
   local windowWidth  = love.graphics.getWidth()
   local windowHeight = love.graphics.getHeight()
   self.map:setDrawRange(-self.posX, -self.posY, windowWidth, windowHeight)
   self.map:draw(1.0,1.0)
   love.graphics.setColor(255, 0, 0, 255)
   self.map:box2d_draw()
   love.graphics.setColor(255, 255, 255, 255)
end

function world.scroll(self,dx,dy)
   self.posX = self.posX + dx
   self.posY = self.posY + dy
end

function world.setCenter(self,x,y)
   local windowWidth  = love.graphics.getWidth()
   local windowHeight = love.graphics.getHeight()
   self.posX = -x+windowWidth/2
   self.posY = -y+windowHeight/2
end

function world.create(map_name)
   local world = {map = nil,
                  -- camera position
                  posX = 0,posY = 0,
                  -- methods
                  draw = world.draw,
                  scroll = world.scroll,
                  setCenter = world.setCenter,
                  randomSpawn = world.randomSpawn}
   -- load our test map and link it to our physical world²
   world.map = sti.new(map_name,{"box2d"})
   world.map:box2d_init(systems.physics.world)
   return world
end

local function _make_exit(x,y,width,height)
   local exit = game.create_entity()
   exit:addSystem("gfx",{image = "assets/maps/sortie.png",
                         offsetX = 0,
                         offsetY = 0})
   exit:addSystem("physics",{width = width,
                             height = height})
   exit:addSystem("exit",{x = x,
                          y = y})
   return exit
end

function world.create_exits()
   -- find special areas in the map
   local exitLayer = world.map.layers["sorties"]
   exitLayer.visible = false
   local mapExit = exitLayer.objects[math.random(1,#exitLayer.objects)]
   _make_exit(mapExit.x,mapExit.y,mapExit.width,mapExit.height)
end

function world.clone_exit(ex)
   _make_exit(ex.x,ex.y,ex.shape.width,ex.shape.height)
end

function world.create_spawns()
   local registerSpawns = function(layer_name,team_name)
      local spawnLayer = world.map.layers[layer_name]
      spawnLayer.visible = false
      for i=1,#spawnLayer.objects do
         local mapSpawn = spawnLayer.objects[i]
         local spawn = game.create_entity()
         spawn:addSystem("spawn",{x = mapSpawn.x,
                                  y = mapSpawn.y,
                                  team = team_name})
      end
   end
   registerSpawns("spawns_hunter","hunter")
   registerSpawns("spawns_ghost","ghost")
end

function world.place_entities(player,opponents)
   local player_spawn = systems.spawn.random(player.role)
   player_spawn:placeEntity(game.player)
   for i=1,#opponents do
      local ent = opponents[i]
      local role = "hunter"
      if ent:hasSystem("ghost") then
         role = "ghost"
      end
      local entity_spawn = systems.spawn.random(role)
      entity_spawn:placeEntity(ent)
   end
end

return world
