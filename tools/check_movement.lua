-- 普通 Lua 检查真实卡带地图与房间逻辑。用法：lua tools/check_movement.lua src
abs=math.abs; min=math.min; max=math.max; flr=math.floor; ceil=math.ceil
sgn=function(x) return x<0 and -1 or 1 end
mid=function(a,b,c) return max(min(a,c),min(max(a,c),b)) end
all=function(t) local i=0; return function() i=i+1; return t[i] end end
local held,pressed={},{}
btn=function(n) return held[n] or false end
btnp=function(n) return pressed[n] or false end
local noop=function() end
cls=noop; line=noop; circ=noop; circfill=noop; rect=noop; rectfill=noop
ovalfill=noop; sspr=noop; memcpy=noop; poke=noop
sin=math.sin; cos=math.cos; sub=string.sub; tonum=tonumber
band=function(a,b) return a & b end
deli=table.remove
del=function(t,v) for i,item in ipairs(t) do if item==v then table.remove(t,i) return end end end
sget=function() return 0 end
pset=noop; spr=noop; clip=noop; camera=noop; map=noop; pal=noop; menuitem=noop
local log=print; print=noop
local root=arg[1] or 'src'
local file=assert(io.open(root..'/../reverie_the_inverted_tower.p8','rb'))
local text=file:read('*a'):gsub('\r','')..'\n__end__\n'; file:close()
local raw=assert(text:match('__map__\n(.-)\n__'))
local flag_text=assert(text:match('__gff__\n(.-)\n__')):gsub('%s','')
local cells={}; local row=0
for line in raw:gmatch('[^\n]+') do
 cells[row]={}
 for column=0,127 do cells[row][column]=tonumber(line:sub(column*2+1,column*2+2),16) or 0 end
 row=row+1
end
mget=function(x,y) return cells[y] and cells[y][x] or 0 end
fget=function(id,flag)
 local flags=tonumber(flag_text:sub(id*2+1,id*2+2),16) or 0
 return math.floor(flags/2^flag)%2==1
end
add=table.insert
for _,name in ipairs({'config','rooms','room','view','player_animation','player','interactions','combat','enemies','drawing','dialogue_data','dialogue','flip_effect','decorations','main'}) do
 dofile(root..'/'..name..'.lua')
end
local function step(n) for _=1,n do _update60(); pressed={} end end
local function check(condition,message) assert(condition,message) end
_init()
check(not game.inverted and player.gravity==1 and player.x==24 and player.y==230 and player.grounded,"default normal entrance")
start_config.intro=true
-- 对话冻结移动、攻击、敌人、伤害；第一次按键补全，下一次翻页。
_init()
local x,y,hp=player.x,player.y,game.hp
held[1]=true; step(20)
check(player.x==x and player.y==y and game.hp==hp,'dialogue pauses simulation')
pressed[5]=true; step(1)
check(dialogue.revealed==dialogue_count(dialogue.pages[1]),'reveal page')
pressed[4]=true; step(1)
check(dialogue.page==2,'next page')
held={}; dialogue=nil; step(15)
check(player.grounded and player.y==230,'initial floor spawn')
-- 逐格对比有效地图（包括门洞、补充平台），而不是只比卡带存储。
for id,definition in ipairs(rooms) do
 room_enter(id,'west')
 game.inverted=false
 local tiles={}
 for ty=0,definition.rows-1 do
  for tx=0,definition.columns-1 do tiles[ty*definition.columns+tx]=room_tile(tx,ty) end
 end
 game.inverted=true
 for ty=0,definition.rows-1 do
  for tx=0,definition.columns-1 do
   check(room_tile(tx,ty)==tiles[ty*definition.columns+tx],'same geometry '..id)
  end
 end
 check(definition.normal==definition.reverse,'shared room data')
 for entry in pairs(definition.normal.entries) do
  room_enter(id,entry)
  check(not room_blocked(player.x,player.y,player.w,player.h),'safe entry '..id..entry)
  check(player.gravity==-1,'gravity retained across rooms')
 end
end
check(#rooms[2].normal.converters==0 and #rooms[3].normal.converters==0,'optional converters')
-- 过场中点仅切重力，保留角色和敌人的实际对象、坐标与生命。
start_config.intro=false; _init(); room_enter(1,'converter'); game.transition=0
local actor=player; local guard=enemies[1]
x,y=player.x,player.y; game.hp=3
check(room_interact(),'activate converter')
step(flip_config.midpoint-1)
check(not game.inverted and player==actor and player.x==x and player.y==y,'freeze before midpoint')
step(1)
check(game.inverted and player.gravity==-1 and game.hp==3,'midpoint gravity switch')
check(player.x==x and player.y<y and player.grounded and enemies[1]==guard,'instant ceiling and no enemy respawn')
step(flip_config.frames-flip_config.midpoint); check(not flip_effect,'transition completes')
step(100); check(player.grounded and player.y<y,'lands on ceiling')
local ceiling_y=player.y
pressed[4]=true; step(1)
check(player.vy>0 and player.y>ceiling_y,'ceiling jump points down')
game.transition=0; check(room_interact(),'converter usable in reverse')
step(flip_config.frames); check(not game.inverted and player.gravity==1,'return gravity')
-- 自动通道在两个重力状态均用原门洞，按方向通行且不会反弹。
for _,inverted in ipairs({false,true}) do
 game.inverted=inverted
 for id,definition in ipairs(rooms) do
  room_enter(id,'west')
  for _,door in ipairs(definition.normal.doors) do
   room_enter(id,'west'); game.transition=0; game.death_timer=0; player.invincible=1000
   player.x=door.direction>0 and door.x-player.w+1 or door.x+door.w-1
   player.y=door.y+door.h-player.h; player.vx=door.direction
   check(not room_blocked(player.x,player.y,player.w,player.h),'clear portal')
   check(room_check_portals() and room.id==door.target and game.entry==door.entry,'portal destination')
   held={}; step(20); check(room.id==door.target,'no bounce')
  end
 end
end
-- 一次电击只伤害一次；击败状态在反重力和重进房间后共用。
_init(); room_enter(2,'west'); game.transition=0
local enemy=enemies[1]
player.x=enemy.x-20; player.y=enemy.y+enemy.h-player.h; player.facing=1
pressed[5]=true; step(10); check(enemy.hp==1,'one hit per swing')
step(15); pressed[5]=true; step(10); check(enemy.hp==0,'second swing defeats')
game.inverted=true; room_enter(2,'west'); check(#enemies==2,'defeat shared across gravity')
-- 法师和弓手攻击差异、子弹撞墙消失。
local archer=enemies[1]; local mage=enemies[2]
check(archer.kind=='ranged' and mage.kind=='mage','three enemy kinds')
player.y=mage.y-20; enemy_shoot(archer); enemy_shoot(mage)
check(projectiles[1].vy==0 and projectiles[2].vy<0,'arrow versus aimed spell')
projectiles[1].x=-8; projectiles[2].x=-8; projectiles_update()
-- 普通 Lua 的 all 模拟迭代器删除后会跳项，因此再更新一次。
projectiles_update(); check(#projectiles==0,'wall removes projectiles')
_init(); dialogue=nil; player_take_damage(1,-1)
check(game.hp==4 and not player_take_damage(1,1),'damage invulnerability')
step(60); check(player_take_damage(4,1),'lethal damage'); step(45)
check(game.hp==5 and player.invincible>0,'respawn protection')
_draw()
log('PASS: identical map cells, gravity/ceiling jump, reversible gravity transition, dialogue pause/pages, optional converters, portals, shared defeat, enemy shots, damage/respawn')

-- 默认开场回到正常地面入口，立即可控制。
start_config.entry="west"; start_config.inverted=false; start_config.intro=false
_init()
check(player.gravity==1 and player.grounded and player.x==24 and player.y==230,'normal entrance start')
held[1]=true; step(10); held={}
check(player.x>24 and player.y==230,'normal walking immediately')
-- 无装置也仅切上下重力，直接到上方支撑面；方向键不能选侧墙。
game.inverted=false; room_enter(3,'west'); game.transition=0
local old_y=player.y
check(#room.state.converters==0 and room_interact(),'ability without converter')
step(flip_config.midpoint)
check(player.gravity==-1 and player.y<old_y and player.grounded,'instant ceiling placement')
check(not room_blocked(player.x,player.y,player.w,player.h),'ceiling placement clear')
step(flip_config.frames-flip_config.midpoint)
_init(); game.inverted=true; room_enter(1,"west"); game.transition=0; player.x=8; player.y=100
held[0]=true; check(room_interact(),'flip while holding left'); held={}
step(flip_config.midpoint)
check(player.gravity==1 and player.x==8 and player.w==8 and player.h==18,'no side wall mode')
check(player.grounded and not room_blocked(player.x,player.y,player.w,player.h),'instant floor placement')
step(flip_config.frames-flip_config.midpoint); game.transition=0
check(room_interact(),'return to ceiling'); step(flip_config.frames)
check(player.gravity==-1 and player.grounded and player.y==8,'return to top support')
log('PASS: instant ceiling/floor placement, unchanged horizontal control, no wall adhesion')
