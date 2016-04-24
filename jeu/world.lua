local sti = require("libs/sti")
local world = {}

function world.draw(self)
   local windowWidth  = love.graphics.getWidth()
   local windowHeight = love.graphics.getHeight()
   self.map:setDrawRange(-self.posX, -self.posY, windowWidth, windowHeight)
   self.map:draw(1.0,1.0)
   -- love.graphics.setColor(255, 0, 0, 255)
   -- self.map:box2d_draw()
   -- love.graphics.setColor(255, 255, 255, 255)
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
                  -- max timer for map
                  game_time = 60,
                  -- methods
                  draw = world.draw,
                  scroll = world.scroll,
                  setCenter = world.setCenter,
                  randomSpawn = world.randomSpawn,
                  createExits = world.createExits,
                  createSpawns = world.createSpawns,
                  placeEntities = world.placeEntities,
                  cloneExit = world.cloneExit}
   -- load our test map and link it to our physical world²
   world.map = sti.new(map_name,{"box2d"})
   world.map:box2d_init(systems.physics.world)
   world.game_time = world.map.properties["game_time"] or 60
   world.map.layers["spawns_hunter"].visible = false
   world.map.layers["spawns_ghost"].visible = false
   return world
end

local function _make_exit(x,y,width,height)
   local exit = game.create_entity()
   exit:addSystem("exit",{x = x,
                          y = y})
   exit:addSystem("gfx",{image = "assets/maps/sortie.png",
                         offsetX = width/2,
                         offsetY = height/2})
   exit:addSystem("physics",{width = width,
                             height = height,
                             sensor = true})
   return exit
end

function world.createExits(self)
   -- find special areas in the map
   local exitLayer = self.map.layers["sorties"]
   exitLayer.visible = false
   local mapExit = exitLayer.objects[math.random(1,#exitLayer.objects)]
   _make_exit(mapExit.x+mapExit.width/2,mapExit.y+mapExit.height/2,
              mapExit.width,mapExit.height)
end

function world.cloneExit(self,ex)
   _make_exit(ex.x,ex.y,ex.width,ex.height)
end

function world.createSpawns(self)
   local registerSpawns = function(layer_name,team_name)
      local spawnLayer = self.map.layers[layer_name]
      for i=1,#spawnLayer.objects do
         local mapSpawn = spawnLayer.objects[i]
         local spawn = game.create_entity()
         spawn:addSystem("spawn",{x = mapSpawn.x+mapSpawn.width/2.0,
                                  y = mapSpawn.y+mapSpawn.height/2.0,
                                  team = team_name})
      end
   end
   registerSpawns("spawns_hunter","hunter")
   registerSpawns("spawns_ghost","ghost")
end

function world.placeEntities(self,entities)
   for i=1,#entities do
      local ent = entities[i]
      local role = "hunter"
      if ent:hasSystem("ghost") then role = "ghost" end
      local entity_spawn = systems.spawn.random(role)
      entity_spawn:placeEntity(ent)
   end
end

return world
