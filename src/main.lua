-- game 保存跨房间进度；进入房间重建角色物理与敌人，不重置生命和进度。
function _init()
 player=nil
 game={inverted=start_config.inverted,visited={normal={},reverse={}},
  defeated={normal={},reverse={}},transition=0,entry="west",
  hp=combat_config.max_hp,death_timer=0}
 rooms_configure()
 dialogue=nil
 flip_effect=nil
 game.tick=0
 show_gallery=false
 room_enter(start_config.room,start_config.entry)
 if start_config.intro then dialogue_start("intro") end
 menuitem(1,"sprite gallery",function() show_gallery=not show_gallery end)
 menuitem(2,"restart room",player_respawn)
end

function _update60()
 if show_gallery then
  if btnp(controls.jump) or btnp(controls.attack) then show_gallery=false end
  return
 end
 game.tick=game.tick+1
 if dialogue then dialogue_update() return end
 if flip_effect then flip_update() return end
 if game.transition>0 then game.transition=game.transition-1 end
 if game.death_timer>0 then
  game.death_timer=game.death_timer-1
  if game.death_timer==0 then player_respawn() end
  return
 end
 -- 下+Z 是开发用的回入口，回复生命但保留世界和已击败敌人。
 if btn(controls.down) and btnp(controls.jump) then
  player_respawn()
  return
 end
 combat_update_player()
 player_update()
 enemies_update()
 -- 先结算攻击，再判断接触：本帧击败的敌人不再伤害玩家。
 combat_resolve_attack()
 enemies_contact()
 if game.death_timer>0 then return end
 if room_check_portals() then return end
 if btnp(controls.interact) and room_interact() then return end
 view_update()
end

function _draw()
 view_end()
 if show_gallery then character_gallery_draw() return end
 cls(room.state.color)
 view_begin()
 room_draw()
 decorations_draw()
 interactions_draw()
 enemies_draw()
 player_draw()
 combat_draw()
 view_end()
 hud_draw()
 dialogue_draw()
 flip_draw()
end
