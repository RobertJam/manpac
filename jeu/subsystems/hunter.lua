local utils = require("jeu/utils")
local hunter = {}

hunter.keymap = {move_left = "left",
                 move_right = "right",
                 move_up = "up",
                 move_down = "down",
                 shoot = "c",
                 destroy_barrier = "v"}
hunter.can_shoot = false
hunter.destroy_speed = 0.5
hunter.ghost_detect_dist = 350

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

function hunter.init_entity(self,cfg)
   self.destroy_barrier = hunter.destroy_barrier
   self.destroy_speed = cfg.destroy_speed or hunter.destroy_speed
   if cfg.move_force then
      self.setMoveForce(cfg.move_force)
   end
   if self == game.player then
      self.player_update = hunter.player_update
      self.max_sound_dist = cfg.ghost_detect_dist or 250
      self.play_audio = false
   end
   self.shoot_dist = cfg.shoot_dist or 100
   self.shoot_angle = cfg.shoot_angle or math.pi/4.0
   self.shoot = function(self)
      if not hunter.can_shoot then return end
      local ghost_list = systems.ghost:getEntities()
      for i=1,#ghost_list do
         local dist = utils.dist(self,ghost_list[i])
         if (dist < self.shoot_dist) then
            local angle = utils.angle(self.direction,
                                      utils.dir(ghost_list[i],self))
            if (math.abs(angle) <= self.shoot_angle) then
               systems.network.sendData({action = "kill_ghost",
                                         ghost_id = ghost_list[i].network_id})
               game.kill_entity(ghost_list[i])
            end
         end
      end
   end
end

function hunter.destroy_barrier(self)
   local barrier_position = utils.barrier_position(self)
   local bar = systems.barrier.find(barrier_position.x,barrier_position.y)
   if bar then
      if bar:destroy(game.dt*self.destroy_speed) then
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
