-- 通道自动触发；只有转换器需要按上。换房冷却与方向检查避免来回弹。
function boxes_overlap(a,b)
 return a.x+a.w>b.x and a.x<b.x+b.w
  and a.y+a.h>b.y and a.y<b.y+b.h
end

function interaction_near(object)
 return boxes_overlap(player,{x=object.x-7,y=object.y,w=object.w+14,h=object.h})
end

function room_interaction_target()
 for object in all(room.state.talks) do
  if interaction_near(object) then return object,"talk" end
 end
 for converter in all(room.state.converters) do
  if interaction_near(converter) then return converter,"converter" end
 end
 return nil,nil
end

function room_interact()
 if game.transition>0 or game.death_timer>0 then return false end
 local object,kind=room_interaction_target()
 if kind=="talk" then dialogue_start(object.story) return true end
 -- 地图不变，切换上下重力后直接贴到对应支撑面。
 flip_start()
 return true
end

function room_check_portals()
 if game.transition>0 or game.death_timer>0 then return false end
 for door in all(room.state.doors) do
  if boxes_overlap(player,door) and player.vx*door.direction>0 then
   room_enter(door.target,door.entry)
   return true
  end
 end
 return false
end

function interactions_draw()
 local color=9
 if game.inverted then color=13 end
 for door in all(room.state.doors) do
  -- 开放的拱洞，没有门板；上下边框标示可通行的位置。
  rectfill(door.x,door.y,door.x+door.w-1,door.y+door.h-1,0)
  line(door.x,door.y,door.x+door.w-1,door.y,color)
  line(door.x,door.y+door.h-1,door.x+door.w-1,door.y+door.h-1,color)
  local center=door.x+4
  line(center-door.direction*2,door.y+10,center+door.direction*2,door.y+12,color)
  line(center+door.direction*2,door.y+12,center-door.direction*2,door.y+14,color)
 end
 for converter in all(room.state.converters) do
  -- 一根贯穿上下的装置，两端均能操作；建筑本身不随重力移动。
  for y=converter.y+28,converter.y+converter.h-28,6 do
   pset(converter.x+12,y,color)
  end
  for side=1,2 do
   local y=converter.y+11
   if side==2 then y=converter.y+converter.h-21 end
   circfill(converter.x+12,y,9,0)
   circ(converter.x+12,y,9,color)
   line(converter.x+12,y,converter.x+12,y-7,12)
   line(converter.x+12,y,converter.x+17,y+3,12)
  end
 end
end
