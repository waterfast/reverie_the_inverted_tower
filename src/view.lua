-- 镜头只决定看哪里，不改变角色和地图的世界坐标。
-- 顶部 16 像素留给界面，因此实际游戏视口高 112 像素。
function view_init()
 view={x=0,y=0}
 view_update()
end

function view_update()
 local center_x=player.x+player.w/2
 local center_y=player.y+player.h/2
 -- 到房间边缘时镜头停止，避免露出地图外的空白。
 view.x=flr(mid(0,center_x-view_config.width/2,
  max(0,room.width-view_config.width)))
 view.y=flr(mid(0,center_y-view_config.height/2,
  max(0,room.height-view_config.height)))
end

function view_begin()
 -- camera 会从所有绘图坐标减去偏移；减掉界面高度把画面下移。
 camera(view.x,view.y-view_config.hud_height)
 clip(0,view_config.hud_height,view_config.width,view_config.height)
end

function view_end()
 -- 界面和动作预览使用屏幕坐标，不能继承世界镜头和裁剪区域。
 clip()
 camera()
end
