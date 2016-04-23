-- global game configuration
return {
   -- ghost entities config
   ghost = {
      -- total number of barrier (per ghost or shared)
      max_barriers = 3,
      -- barrier stock shared between all ghosts ?
      shared_barriers = true,
      -- barrier build speed
      build_speed = 0.8,
      -- barrier destroy speed
      destroy_speed = 0.8,
      -- force to apply when moving
      move_force = 15000
   },
   -- hunter entities config
   hunter = {
      can_shoot = true,
      shoot_dist = 100,
      shoot_angle = 1.0,
      -- barrier destroy speed
      destroy_speed = 0.5,
      -- force to apply when moving
      move_force = 10000,
      -- distance at which hunter starts to detect a ghost
      ghost_detect_dist = 25.0
   },
   -- global game config
   game = {
      -- game duration in seconds (nil uses map value)
      timeout = nil
   }
}
