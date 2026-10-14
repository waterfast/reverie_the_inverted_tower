-- 一个房间只有一套几何、出入口与物件；世界状态只决定重力。
-- 坐标都是房间内的像素。门贴左右边界，entry 是目标房间的安全落点。
rooms={
 {map_x=0,map_y=0,columns=64,rows=32,
  normal={name="clock tower",color=1},
  reverse={name="fallen tower",color=2}},
 {map_x=64,map_y=0,columns=32,rows=16,
  normal={name="moon passage",color=1},
  reverse={name="eclipse passage",color=2}},
 {map_x=96,map_y=0,columns=32,rows=16,
  normal={name="sealed archive",color=1},
  reverse={name="forgotten archive",color=2}},
 {map_x=64,map_y=16,columns=32,rows=16,
  normal={name="silent bell",color=1},
  reverse={name="awakened bell",color=2}}
}

-- 编辑 normal 即编辑实体房间，reverse 是兼容旧工具的同一表引用。
function rooms_configure()
 for id=1,#rooms do
  local definition=rooms[id]
  local width=definition.columns*8
  local floor=definition.rows*8-8
  local state=definition.normal
  -- 逆世界共用房间对象，地形、门、摆件、敌人都不另造一份。
  definition.reverse=state
  state.entries={west={x=24,y=floor-18},east={x=width-40,y=floor-18},
   converter={x=116,y=floor-18}}
  state.doors={}
  if id>1 then
   add(state.doors,{x=0,y=floor-24,w=8,h=24,direction=-1,
    target=id-1,entry="east"})
  end
  if id<#rooms then
   add(state.doors,{x=width-8,y=floor-24,w=8,h=24,direction=1,
    target=id+1,entry="west"})
  end
  state.converters={}
  if id==1 or id==4 then
   add(state.converters,{x=112,y=8,w=24,h=floor-8})
  end
  state.talks={{x=64,y=floor-24,w=12,h=24,story=id==1 and "notice" or "rumor"}}
  state.lamps={{x=40,y=floor-24},{x=width-64,y=8}}

  -- 敌人只有一份击败记录，反重力不会复活；生命跨房间保留。
  local enemy_x=184
  if id==1 then enemy_x=192 end
  state.enemies={{id="guard",x=enemy_x,y=floor-12,hp=2,speed=0.45,
   color=8,damage=1,kind="melee"},
   {id="archer",x=width-48,y=floor-12,hp=2,speed=0.3,color=9,damage=1,kind="ranged"},
   {id="mage",x=width/2+24,y=floor-12,hp=2,speed=0.2,color=13,damage=1,kind="mage"}}
  state.platforms={}
  state.clear_areas={}
  -- 每条横向连接都成对配置：右出口对应目标左入口，反向同理。
  -- 高处捷径：回廊右上 <-> 钟室左上，不再把两间房的右门互相连接。
  if id==1 then
   state.entries.top={x=56,y=22}
   state.entries.ceiling={x=56,y=8}
   state.platforms={{x=16,y=40,w=72}}
  elseif id==2 then
   state.clear_areas={{x=80,y=24,w=176,h=80}}
   state.entries.high_east={x=216,y=54}
   add(state.doors,{x=248,y=48,w=8,h=24,direction=1,
    target=4,entry="high_west"})
   state.platforms={
    {x=80,y=104,w=24}, {x=112,y=88,w=24},
    {x=152,y=72,w=24}, {x=192,y=72,w=64}
   }
  elseif id==4 then
   -- 左上入口有接地平台；清空区域避开 x=0 的边墙，只由门洞打开墙。
   state.clear_areas={{x=8,y=24,w=168,h=80}}
   state.entries.high_west={x=24,y=54}
   add(state.doors,{x=0,y=48,w=8,h=24,direction=-1,
    target=2,entry="high_east"})
   state.platforms={
    {x=0,y=72,w=64}, {x=80,y=72,w=24},
    {x=112,y=88,w=24}, {x=144,y=104,w=24}
   }
  end
 end
end

