-- 灯台固定于建筑，焰尖与飘散火星跟随重力，让同一场景显出倒置。
function decorations_draw()
 local gravity=game.inverted and -1 or 1
 for lamp in all(room.state.lamps) do
  spr(224,lamp.x,lamp.y,2,2)
  local x=lamp.x+7
  local y=lamp.y+5
  local flicker=sin(game.tick/18+x)*2
  ovalfill(x-3,y-3,x+3,y+3,9)
  line(x,y,x+flicker,y-gravity*8,10)
  pset(x+flicker,y-gravity*(10+game.tick%12),10)
 end
 for object in all(room.state.talks) do
  spr(226,object.x-2,object.y+8,2,2)
  if interaction_near(object) then print("up",object.x,object.y-7,10) end
 end
end
