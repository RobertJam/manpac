local sti = require("libs/sti")
local world = {}

function world.randomSpawn(self,team_name)
   local teamSpawns = {}
   for i=1,#self.spawns do
      if self.spawns[i].team == team_name then
         table.insert(teamSpawns,self.spawns[i])
      end
   end
   return teamSpawns[math.random(1,#teamSpawns)]
end

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
                  spawns = nil,
                  exits = nil,
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
   -- find special areas in the map
   world.exits = {}
   local exitLayer = world.map.layers["sorties"]
   exitLayer.visible = false
   local mapExit = exitLayer.objects[math.random(1,#exitLayer.objects)]
   local exit = game.create_entity()
   exit:addSystem("gfx",{image = "assets/maps/sortie.png",
                         offsetX = 0,
                         offsetY = 0})
   exit:addSystem("physics",{width = exit.width,
                             height = exit.height})
   exit.x,exit.y = mapExit.x,mapExit.y
   table.insert(world.exits,exit)
   world.spawns = {}
   local spawnLayer = world.map.layers["spawns"]
   spawnLayer.visible = false
   for i=1,#spawnLayer.objects do
      local mapSpawn = spawnLayer.objects[i]
      -- mapSpawn.properties.sensor = true
      -- FIXME: create a spawn component maybe ?
      local spawn = game.create_entity()
      spawn.x,spawn.y = mapSpawn.x,mapSpawn.y
      spawn.placeEntity = function (self,entity)
         print("Spawn placing entity at "..self.x..";"..self.y)
         entity:setPosition(self.x,self.y)
      end
      if mapSpawn.properties.spawn_team1 then
         spawn.team = "team1"
      else
         spawn.team = "team2"
      end
      table.insert(world.spawns,spawn)
   end
   return world
end

return world
