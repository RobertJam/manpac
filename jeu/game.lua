local state = {}
local game_world = require("jeu/world")

-- subsystems
-- Add your system name here (filename in jeu/subsystems/ without extension)
local system_names = {"physics",
                      "gfx",
                      "character",
                      "input_controller",
                      "ai_controller",
                      "ghost",
                      "hunter",
                      "network",
                      "spawn","exit",}
systems = {} -- loaded systems references

for i=1,#system_names do
   local sys_name = system_names[i]
   local pkg_name = "jeu/subsystems/"..sys_name
   package.loaded[pkg_name] = nil
   local sys = require(pkg_name)
   systems[sys_name] = sys
   sys._entities = {}
   sys.getEntities = function()
      local res = {}
      for k,_ in pairs(sys._entities) do
         table.insert(res,k)
      end
      return res
   end
end

-- game state data
game = { world = nil,     -- our game world (map/environment)
         player = nil,    -- player controlled entity
         entities = {},   -- all existing game object
         entity_count = 1,-- entity counter to generate unique ids
}

-- FIXME: move entity system to its own file
-- FIXME: this filter_entities thing is not efficient at all
-- FIXME: but we need some profiling to be sure of hat
function game.create_entity(name)
   local entity = {
      -- internal management
      _id = game.entity_count,
      _systems = {},
      -- commonly used data
      name = name or string.format("entity-%d",game.entity_count),
      x = 0, y = 0 -- world position of the entity
   }
   entity.addSystem = function(self,sys_name,cfg)
      print("Adding system "..sys_name.." to entity "..self._id)
      cfg = cfg or {}
      print(cfg)
      local sys = systems[sys_name]
      if not sys then
         print("Non existing system "..sys_name)
      end
      if sys.init_entity then
         sys.init_entity(self,cfg)
      end
      self._systems[sys_name] = true
      sys._entities[self] =true
   end
   entity.removeSystem = function(self,sys_name)
      if self._systems[sys_name] == true then
         local sys = systems[sys_name]
         if sys.release_entity then
            sys.release_entity(self)
         end
         self._systems[sys_name] = nil
         sys._entities[self] = nil
      end
   end
   entity.hasSystem = function(self,sys_name)
      return self._systems[sys_name]
   end
   -- entity.hasSystems = function(self,sys_name_list)
   --    for i=1,#sys_name_list do
   --       if not self:hasSystem(sys_name_list[i]) then return false end
   --    end
   --    return true
   -- end
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
   game.entities[game.entity_count] = entity
   print("Created entity "..entity._id)
   game.entity_count = game.entity_count + 1
   return entity
end

function game.kill_entity(entity)
   game.entities[entity._id] = nil
end

-- function game.filter_entities(filter)
--    local filter_func
--    if type(filter) == "table" then
--       filter_func = function(ent)
--          return ent:hasSystems(filter)
--       end
--    elseif type(filter) == "function" then
--       filter_func = filter
--    else
--       print("Invalid entity filter",filter)
--       return {}
--    end
--    local match_list = {}
--    for _,entity in pairs(game.entities) do
--       if filter_func(entity) then
--          table.insert(match_list,entity)
--       end
--    end
--    return match_list
-- end

-- in-game state callbacks

function state.enter(map_name,player,opponents)
   -- default debug values
   map_name = map_name or "assets/maps/sewers.lua"
   player = player or {name = "player",
                       role = "hunter"}
   opponents = opponents or {
      {name = nil,
       controller = "ai",
       ai = {behavior = "stupid"},
       role = "ghost"},
      {name = "stupid_bot",
       ai = {behavior = "stupid"},
       controller = "ai",
       role = "ghost"},
      {name = "stalker_bot",
       ai = {behavior = "stalker"},
       controller = "ai",
       role = "ghost"},
   }
   -- init subsystems
   for _,sys in pairs(systems) do
      if sys.init_system then sys.init_system() end
   end
   -- initialize game world
   game.world = game_world.create(map_name)
   -- create player controlled entity
   local player_spawn = systems.spawn.random(player.role)
   game.player = game.create_entity(player.name)
   game.player:addSystems({{"gfx",{image = "assets/sprites/player.tga"}},
         {"physics",{width = 27,height = 32}},
         "input_controller","character"})
   game.player:addSystem(player.role)
   -- FIXME: need two components ?
   game.player.network_id = player.network_id
   -- game.player:addSystem("network",player)
   player_spawn:placeEntity(game.player)
   -- create opponents entities
   for i,data in ipairs(opponents) do
      entity = game.create_entity(data.name)
      entity:addSystems({{"gfx",{image = "assets/sprites/crabe.png",
                                 scale = 0.1}},
            {"physics",{width = 27,height = 32}}})
      if data.controller == "ai" then
         entity:addSystem("ai_controller",data.ai)
      else
         entity:addSystem("network",data.network)
      end
      entity:addSystem(data.role)
      local entitySpawn = nil
      entitySpawn = systems.spawn.random(data.role)
      entitySpawn:placeEntity(entity)
   end
   systems.network.StartGame()
end

function state.update(dt)
   -- map test keys
   local scrollX,scrollY = 0,0
   if love.keyboard.isDown("d") then scrollX = -10 end
   if love.keyboard.isDown("q") then scrollX = 10 end
   if love.keyboard.isDown("s") then scrollY = -10 end
   if love.keyboard.isDown("z") then scrollY = 10 end
   if scrollX ~= 0 or scrollY ~= 0 then
      game.world:scroll(scrollX,scrollY)
   else
      game.world:setCenter(game.player.x,game.player.y)
   end
   -- update physics
   systems.physics.update(systems.physics:getEntities(),dt)
   -- update character controllers
   systems.ai_controller.update(systems.ai_controller:getEntities(),dt)
   systems.input_controller.update(systems.input_controller:getEntities())
   systems.character.update(systems.character:getEntities())
   -- send locally controlled entities state to server
   -- FIXME: if block for quickstart to work
   if game.player.network_id then
      systems.network.send_state(systems.input_controller:getEntities())
      systems.network.send_state(systems.ai_controller:getEntities())
   end
end

function state.draw()
   -- setup camera position
   love.graphics.push()
   love.graphics.translate(game.world.posX,game.world.posY)
   -- draw world
   game.world:draw()
   -- draw our graphic objects
   systems.gfx.draw(systems.gfx:getEntities())
   -- draw our physical entities
   for _,entity in pairs(systems.physics:getEntities()) do
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
   end
   -- reset tranformation stack
   love.graphics.pop()
end

function state.leave()
   -- exit subsystems
   for _,sys in pairs(systems) do
      if sys.exit_system then sys.exit_system() end
   end
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
