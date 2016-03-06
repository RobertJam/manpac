local utils = require("jeu/utils")
local hunter = {}

hunter.keymap = {move_left = "left",
                 move_right = "right",
                 move_up = "up",
                 move_down = "down",
                 destroy_barrier = "v"}

hunter.destroy_speed = 0.5

function hunter.player_update(self, ghosts)
   local dist = self.max_sound_dist
   for i,ghost in ipairs(ghosts) do
      local ghost_dist = utils.dist(self, ghost)
      if ghost_dist < dist then dist = ghost_dist end
   end
   
   if dist < self.max_sound_dist then
      -- print("Distance[" .. tostring(i) .. "] : " .. tostring(dist))
      if not self.play_audio then
         audio.LoopMusic(audio.sounds.fantome_approche, 1 - dist / 350)
         self.play_audio = true
      else
         audio.sounds.fantome_approche:setVolume(1 - dist / 350)
      end
   else
      if self.play_audio then
         love.audio.stop(audio.sounds.fantome_approche)
         self.play_audio = false
      end
   end
end

function hunter.enter_collision(self,other)
   if reseau.host then
      if game.is_entity(other) and other:hasSystem("exit") then
         game.hunter_exit(true)
      end
   end
end

function hunter.exit_collision(self,other)
   if reseau.host then
      if game.is_entity(other) and other:hasSystem("exit") then
         game.hunter_exit(false)
      end
   end
end

function hunter.init_entity(self)
   self.destroy_barrier = hunter.destroy_barrier
   if self == game.player then
      self.player_update = hunter.player_update
      self.max_sound_dist = 250
      self.play_audio = false
   end

   self:addSystems({{"gfx",{image = "assets/sprites/player.tga"}},
         {"physics",{width = 27,height = 32}},
         "character"})
end

function hunter.destroy_barrier(self)
   local barrier_position = utils.barrier_position(self)
   local bar = systems.barrier.find(barrier_position.x,barrier_position.y)
   if bar then
      if bar:destroy(game.dt*hunter.destroy_speed) then
         systems.network.sendData({action = "destroy_barrier",
                                   x = bar.x,
                                   y = bar.y})
      else
         print("Hunter destroying barrier:")
         print(bar.build_state)
         systems.network.sendData({action = "build_barrier",
                                   state = bar.build_state,
                                   x = bar.x,
                                   y = bar.y})
      end
   end
end

function hunter.init_system()
end

return hunter
