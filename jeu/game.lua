local state = {}
local sti = require("libs/sti")
local translateX = 0
local translateY = 0
local zoom = 1.0
local entity_count = 1

-- subsystems
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
local game = { map = nil,     -- sti map object
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
   entity.addSystem = function(self,sys_name)
      print("Adding system "..sys_name.." to entity "..self._id)
      local sys = systems[sys_name]
      if sys.init_entity then
         sys.init_entity(self)
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
         self:addSystem(sys_name_list[i])
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


-- in-game state callbacks

function state.enter(map_name,player,opponents)
   -- default debug values
   map_name = map_name or "assets/maps/sewers.lua"
   player = player or {name = "Jean-Jacques",
                       role = "hunter"}
   opponents = {
      {name = nil,
       role = "ghost"},
      {name = nil,
       role = "hunter"},
      {name = nil,
       role = "hunter"},
   }
   -- init subsystems
   for _,sys in pairs(systems) do
      if sys.init_system then sys.init_system() end
   end
   -- load our test map and link it to our physical world²
   game.map = sti.new(map_name,{"box2d"})
   game.map:box2d_init(systems.physics.world)

   -- create player controlled entity
   game.player = game.create_entity(player.name)
   game.player:addSystems({"gfx","physics","input_controller","character"})
   game.player:addSystem(player.role)
   -- -- create opponents entities
   -- for name,data in pairs(opponents) do
   --    entity = game.create_entity(name)
   --    entity:addSystems({"gfx","physics"})
   --    if data.controller == "ai" then
   --       entity:addSystem("ai_controller")
   --    else
   --       entity:addSystem("network_controller")
   --    end
   --    entity:addSystem(data.role)
   -- end
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
