local state = {}
local game_world = require("jeu/world")
local utils = require("jeu/utils")

-- subsystems
-- Add your system name here (filename in jeu/subsystems/ without extension)
local system_names = {"physics",
                      "gfx",
                      "character",
                      "input_controller",
                      "ai_controller",
                      "network",
                      "ghost","hunter",
                      "spawn","exit",
                      "barrier"}
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
game = { dt = 0.1,        -- last time step
         timer = 0,       -- current game timer
         max_time = 60,   -- on game duratoin (XXX:should depend on the map ?)
         world = nil,     -- our game world (map/environment)
         player = nil,    -- player controlled entity
         opponents = {},  -- non player entities (opponents is a BAD name)
         entities = {},   -- all existing game object
         entity_count = 1,-- entity counter to generate unique ids
}

-- FIXME: move entity system to its own file
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
      -- print("Adding system "..sys_name.." to entity "..self._id)
      cfg = cfg or {}
      -- print(cfg)
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
   entity.sendMessage = function(self,msg,...)
      for sys_name,_ in pairs(self._systems) do
         local sys = systems[sys_name]
         if type(sys[msg]) == 'function' then
            sys[msg](self,...)
         end
      end
   end
   game.entities[game.entity_count] = entity
   -- print("Created entity "..entity._id)
   game.entity_count = game.entity_count + 1
   return entity
end

function game.is_entity(obj)
   if obj['_id'] then return true else return nil end
end

function game.kill_entity(entity)
   local sys_list = {}
   for sys_name,_ in pairs(entity._systems) do
      table.insert(sys_list,sys_name)
   end
   for i=1,#sys_list do
      entity:removeSystem(sys_list[i])
   end
   game.entities[entity._id] = nil
end

function game.hunter_exit(value)
   if value == true then
      game.nhunter_exit = game.nhunter_exit + 1
   else
      game.nhunter_exit = game.nhunter_exit - 1
   end
end

function game.create_prefab(prefab)
   local ent = game.create_entity(prefab.name)
end

function game.create_entities(player,opponents,host_cfg)
   local gameplay_cfg = (host_cfg and host_cfg.gameplay) or {ghost = {},hunter={},game ={}}
   local create_entity = {}
   create_entity.hunter =  function(name,cfg)
      print("Creating hunter")
      utils.tprint(cfg)
      local ent = game.create_entity(name)
      ent:addSystems({
            {"hunter",{destroy_speed = cfg.destroy_speed,
                       shoot_dist = cfg.shoot_dist,
                       shoot_angle = cfg.shoot_angle,
                       ghost_detect_dist = cfg.ghost_detect_dist}},
            {"gfx",{animation = "assets/sprites/chasseur_robot.lua"}},
            {"physics",{width = 35,height = 50}},
            {"character",{move_force = cfg.move_force}}}
      )
      return ent
   end
   create_entity.ghost = function(name,cfg)
      print("Creating ghost")
      utils.tprint(cfg)
      local ent = game.create_entity(name)
      ent:addSystems({
            {"ghost", {max_barriers = cfg.max_barriers,
                        build_speed = cfg.build_speed,
                        destroy_speed = cfg.destroy_speed,
                        shared_barriers = cfg.shared_barriers
            }},
            {"gfx",{animation = "assets/sprites/fantome_IA.lua"}},
            {"physics",{width = 35,height = 50}},
            {"character",{move_force = cfg.move_force}}}
      )
      return ent
   end
   -- create player controlled entity
   game.player = create_entity[player.role](player.name,
                                            gameplay_cfg[player.role])
   if player.role == "hunter" then game.nhunter = game.nhunter + 1 end
   -- FIXME: allow to specify keymap
   game.player:addSystem("input_controller", systems[player.role])
   -- FIXME: we need to make it a proper network entity
   game.player.network_id = player.network_id
   -- create opponents entities
   for i,data in ipairs(opponents) do
      entity = create_entity[data.role](data.name,gameplay_cfg[data.role])
      if data.controller == "ai" then
         entity:addSystem("ai_controller",data.ai)
      else
         entity:addSystem("network",data.network)
      end
      if data.role == "hunter" then game.nhunter = game.nhunter + 1 end
      if player.role == "hunter" and data.role == "ghost" then
         entity:setColor({1.0,1.0,1.0,0.0})
      end
      table.insert(game.opponents,entity)
   end
end

-- in-game state callbacks

function state.enter(map_name,player,opponents,host_cfg)
   -- default debug values
   map_name = map_name or "assets/maps/sewers.lua"
   player = player or {name = "player",
                       role = "ghost"}
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
   local gameplay_cfg = require("game_cfg")   -- init subsystems
   -- init subsystems
   for _,sys in pairs(systems) do
      if sys.init_system then sys.init_system() end
   end
   -- initialize game world
   game.world = game_world.create(map_name)
   game.nhunter = 0
   game.nhunter_exit = 0
   game.timer = 0
   if gameplay_cfg.ghost.shared_barriers then
      systems.ghost.nbarriers = gameplay_cfg.ghost.max_barriers
   end
   game.timeout = gameplay_cfg.game.timeout or game.world.game_time
   game.create_entities(player,opponents,{gameplay = gameplay_cfg})
   if game.player.network_id then
      if reseau.host then
         -- generate spawns and exit
         -- place entities at spawn points
         -- launch clients
         game.world:createExits()
         game.world:createSpawns()
         game.world:placeEntities({game.player})
         game.world:placeEntities(game.opponents)
         systems.network.StartGame(gameplay_cfg)
      else
         -- configure spawns and exits from host_cfg
         for i=1,#host_cfg.exits do
            local exit = host_cfg.exits[i]
            game.world:cloneExit(exit)
         end
         -- place entities from server config
         local net_entities = host_cfg.entities
         for i=1,#net_entities do
            local net_ent = net_entities[i]
            local ent = systems.network.find_entity(net_ent.network_id)
            -- FIXME this need to change if player is a normal network entity
            if net_ent.network_id == game.player.network_id then
               game.player:setPosition(net_ent.x,net_ent.y)
            else
               ent:setPosition(net_ent.x,net_ent.y)
            end
         end
      end
   else
      -- quick start mode, create spawn and exits locally
      -- and place everybody
      game.world:createExits()
      game.world:createSpawns()
      game.world:placeEntities({game.player})
      game.world:placeEntities(game.opponents)
   end
end

function state.update(dt)
   game.dt = dt
   game.timer = game.timer + dt
   if reseau.host then
      if game.nhunter_exit == game.nhunter then
         print("Hunter victory !!!")
         systems.network.sendData({action = "game_over",
                                   win_team = "hunter"})
         gs.switch("jeu/game_over", (game.player:hasSystem("hunter")))
      end
      if game.timer >= game.timeout then
         print("Ghost victory !!!")
         systems.network.sendData({action = "game_over",
                                   win_team = "ghost"})
         gs.switch("jeu/game_over", (game.player:hasSystem("ghost")))
      end
   end
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
   -- update gfx
   systems.gfx.update(systems.gfx:getEntities(),dt)
   -- update physics
   systems.physics.update(systems.physics:getEntities(),dt)
   -- update character controllers
   systems.ai_controller.update(systems.ai_controller:getEntities(),dt)
   systems.input_controller.update(systems.input_controller:getEntities())
   systems.character.update(systems.character:getEntities())
   if game.player.player_update then
      game.player:player_update(systems.ghost:getEntities())
   end
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
   -- for _,entity in pairs(systems.physics:getEntities()) do
   --    love.graphics.setColor(255, 0, 0, 255)
   --    love.graphics.polygon("line", entity.body:getWorldPoints(entity.shape:getPoints()))
   -- end
   -- reset tranformation stack
   love.graphics.pop()
   -- in-game GUI
   love.graphics.print(string.format("Remaining time: %.2f",
                                     game.timeout-game.timer),
                       10,10)
   if game.player:hasSystem("ghost") then
   love.graphics.print(string.format("Remaining barriers: %d",
                                     game.player:nBarriers()),
                       10,20)
    -- Draw polygon to show barriers number
   gui_x = 300
   gui_y = 10
   for i=1, game.player:nBarriers(), 1 do
      x = gui_x + (i * 60)
      y = gui_y
      love.graphics.polygon('fill',
                            x, y,
                            x + 50, y,
                            x + 40, y + 20,
                            x - 10, y + 20
      )
   end
   end
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
