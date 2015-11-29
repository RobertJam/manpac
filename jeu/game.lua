local state = {}
local sti = require("libs/sti")
local translateX = 0
local translateY = 0
local zoom = 1.0
local entity_count = 1

-- subsystems
-- Add your system name here (filename in jeu/subsystems/ without extension)
local system_names = {"physics",
                      "gfx",
                      "character",
                      "input_controller",
                      "network_controller",
                      "ai_controller",
                      "ghost",
                      "hunter"}
systems = {} -- loaded systems references

for i=1,#system_names do
   local sys_name = system_names[i]
   local pkg_name = "jeu/subsystems/"..sys_name
   package.loaded[pkg_name] = nil
   systems[sys_name] = require(pkg_name)
end

-- game state data
game = { map = nil,     -- sti map object
         player = nil,  -- player controlled entity
         entities = {}, -- all existing game object
}

-- FIXME: move entity system to its own file
function game.create_entity(name)
   local entity = {
      -- internal management
      _id = entity_count,
      _systems = {},
      -- commonly used data
      name = name or string.format("entity-%d",entity_count),
      x = 0, y = 0
   }
   entity.addSystem = function(self,sys_name,cfg)
      print("Adding system "..sys_name.." to entity "..self._id)
      cfg = cfg or {}
      print(cfg)
      local sys = systems[sys_name]
      if sys.init_entity then
         sys.init_entity(self,cfg)
      end
      self._systems[sys_name] = true
   end
   entity.removeSystem = function(self,sys_name)
      if self._systems[sys_name] == true then
         local sys = systems[sys_name]
         if sys.release_entity then
            sys.release_entity(self)
         end
         self._systems[sys_name] = nil
      end
   end
   entity.hasSystem = function(self,sys_name)
      return self._systems[sys_name]
   end
   entity.addSystems = function(self,sys_name_list)
      for i=1,#sys_name_list do
         local sys_desc = sys_name_list[i]
         local sys_name = nil
         local sys_cfg = nil
         if type(sys_desc) == "table" then
            sys_name = sys_desc[1]
            sys_cfg = sys_desc[2]
         else
            sys_name = sys_desc
            sys_cfg = {}
         end
         self:addSystem(sys_name,sys_cfg)
      end
   end
   game.entities[entity_count] = entity
   print("Created entity "..entity._id)
   entity_count = entity_count + 1
   return entity
end

function game.kill_entity(entity)
   game.entities[entity._id] = nil
end

function game.filter_entities(sys_name_list)
   local match_list = {}
   for _,entity in pairs(game.entities) do
      local isMatch = true
      for i=1,#sys_name_list do
         if not entity:hasSystem(sys_name_list[i]) then
            isMatch = false
            break
         end
      end
      if isMatch then table.insert(match_list,entity) end
   end
   return match_list
end

function game.find_spawn(team_name)
   local teamSpawns = {}
   for i=1,#game.spawns do
      if game.spawns[i].team == team_name then
         table.insert(teamSpawns,game.spawns[i])
      end
   end
   return teamSpawns[math.random(1,#teamSpawns)]
end

-- in-game state callbacks

function state.enter(map_name,player,opponents)
   -- default debug values
   map_name = map_name or "assets/maps/sewers.lua"
   player = player or {name = "player",
                       role = "hunter"}
   opponents = {
      {name = nil,
       controller = "network",
       role = "ghost"},
      {name = "stupid_bot",
       controller = "ai",
       role = "hunter"},
      {name = "stalker_bot",
       controller = "ai",
       role = "hunter"},
   }
   -- init subsystems
   for _,sys in pairs(systems) do
      if sys.init_system then sys.init_system() end
   end
   -- load our test map and link it to our physical world²
   game.map = sti.new(map_name,{"box2d"})
   game.map:box2d_init(systems.physics.world)
   -- find special areas in the map
   game.exits = {}
   local exitLayer = game.map.layers["sorties"]
   -- exitLayer.visible = false
   -- exitLayer.properties.sensor = true
   for i=1,#exitLayer.objects do
      local mapExit = exitLayer.objects[i]
      local exit = game.create_entity()
      table.insert(game.exits,exit)
   end
   game.spawns = {}
   local spawnLayer = game.map.layers["spawns"]
   -- spawnLayer.visible = false
   -- spawnLayer.collidable = true
   for i=1,#spawnLayer.objects do
      local mapSpawn = spawnLayer.objects[i]
      -- mapSpawn.properties.sensor = true
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
      table.insert(game.spawns,spawn)
   end

   -- create player controlled entity
   local playerSpawn = game.spawns[math.random(1,#game.spawns)]
   local playerTeam = playerSpawn.team
   local opponentTeam = nil
   if playerTeam == "team1" then
      opponentTeam = "team2"
   else
      opponentTeam = "team1"
   end
   game.player = game.create_entity(player.name)
   game.player:addSystems({{"gfx",{image = "assets/sprites/player.tga"}},
                           "physics","input_controller","character"})
   game.player:addSystem(player.role)
   playerSpawn:placeEntity(game.player)
   -- create opponents entities
   for name,data in pairs(opponents) do
      entity = game.create_entity(name)
      entity:addSystems({{"gfx",{image = "assets/sprites/crabe.png",
                                 scale = 0.1}},
            "physics"})
      if data.controller == "ai" then
         entity:addSystem("ai_controller")
      else
         entity:addSystem("network_controller")
      end
      entity:addSystem(data.role)
      local entitySpawn = nil
      if data.role == player.role then -- same team as player
         entitySpawn = game.find_spawn(playerTeam)
      else
         entitySpawn = game.find_spawn(opponentTeam)
      end
      entitySpawn:placeEntity(entity)
   end
   -- create bot
   bot = game.create_entity()
   bot:addSystems({"gfx","physics",
                   {"ai_controller",{behavior = "stupid"}}})
   -- create stalker bot
   bot = game.create_entity()
   bot:addSystems({"gfx","physics",
                   {"ai_controller",{behavior = "stalker",
                                     target = game.player}}})
   bot.target = game.player
end

function state.update(dt)
   -- map test keys
   if love.keyboard.isDown("d") then translateX = translateX - 10 end
   if love.keyboard.isDown("q") then translateX = translateX + 10 end
   if love.keyboard.isDown("s") then translateY = translateY - 10 end
   if love.keyboard.isDown("z") then translateY = translateY + 10 end
   if love.keyboard.isDown("a") then zoom = zoom + 0.1 end
   if love.keyboard.isDown("e") then zoom = zoom - 0.1 end
   -- update physics
   systems.physics.update(game.filter_entities({"physics"}),dt)
   -- update character controllers
   systems.ai_controller.update(game.filter_entities({"ai_controller"}),dt)
   systems.input_controller.update(game.filter_entities({"input_controller"}))
   systems.network_controller.update(game.filter_entities({"network_controller"}))
   systems.character.update(game.filter_entities({"character"}))
end

function state.draw()
   local windowWidth  = love.graphics.getWidth()
   local windowHeight = love.graphics.getHeight()
   love.graphics.push()
   love.graphics.translate(translateX,translateY)
   game.map:setDrawRange(-translateX, -translateY, windowWidth, windowHeight)

   -- Draw the map and all objects within
   game.map:draw(zoom,zoom)
   -- draw our graphic objects
   systems.gfx.draw(game.filter_entities({"gfx"}))
   -- Draw Collision Map (useful for debugging)
   love.graphics.setColor(255, 0, 0, 255)
   game.map:box2d_draw()
   -- draw our physical entities
   for _,entity in pairs(game.filter_entities({"physics"})) do
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
   end

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
