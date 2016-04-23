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
      move_force = 40000
   },
   -- hunter entities config
   hunter = {
      -- barrier destroy speed
      destroy_speed = 0.5,
      -- force to apply when moving
      move_force = 4000,
      -- distance at which hunter starts to detect a ghost
      ghost_detect_dist = 25.0
   },
   -- global game config
   game = {
      -- game duration in seconds
      timeout = 30
   }
}
