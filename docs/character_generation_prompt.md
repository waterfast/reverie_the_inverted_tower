# 猫雷动作图生成记录

工具：内置 imagegen，透明背景。
参考：assets/references/nyaru_setting1.jpg。
初始提示要求 16x16，但输出细节较多，实际导入采用 24x24。
生成原图未重绘；导入时进行尺寸和调色板转换。

## 完整提示词

Use case: stylized-concept. Asset type: production pixel-art sprite sheet for a PICO-8 side-view platform game.
The attached image is ONLY a character identity and outfit reference, not an edit target. Create a new wholesome chibi sprite sheet of VTuber Nekora Nyaru / 猫雷: aqua turquoise twin braided hair, tiny dark purple demon horns and maid headband, purple hair bows, navy-and-white modest maid bodice, turquoise skirt with white apron, small orange bow, dark boots, tiny bat wing silhouette. Fully clothed, simplified compact game character. No reference callouts or underwear diagrams.
CRITICAL: exact 4 columns by 4 rows, sixteen separate frames, equally sized square cells, each cell representing a TRUE 16x16 logical pixel sprite magnified with nearest-neighbor integer pixel blocks. Entire sheet has a 64x64 LOGICAL pixel grid. Every logical pixel should be one solid flat square. Use no details smaller than the 16x16 logical pixels per cell. This is tiny in-game art, not high resolution pixel-style illustration. Character 12 to 14 logical pixels tall, maximum 14 wide, with consistent baseline at local pixel y=14 and central body pivot x=8, transparent padding at least 1 logical pixel around every frame. All sprites face right in a slightly three-quarter side view with same costume and consistent scale. No lines between cells, no grid, no labels, no text, no shadows, no background, no extra sprites. Transparent background.
Palette strictly limited to these PICO-8 colors: #1d2b53 #7e2553 #008751 #ab5236 #5f574f #c2c3c7 #fff1e8 #ff004d #ffa300 #ffec27 #00e436 #29adff #83769c #ff77a8 #ffccaa. Approximate turquoise hair using #29adff with #00e436 selectively; purple accessories use #83769c and #7e2553, dark outlines #1d2b53. NO BLACK (#000000) on the character because black is reserved for transparency in game.
Frame sequence row-major, LEFT to RIGHT:
Row1: idle relaxed, idle slight breathing, run contact right foot forward, run down pose.
Row2: run passing pose, run opposite contact left foot forward, jump launch tucked legs, jump ascent hair trailing.
Row3: falling legs extended, falling alternate hair lift, gravity flip magic pose arms raised small lightning flecks, gravity flip magic second pose. Keep these upright; game will vertically mirror them.
Row4: electric spell attack anticipation, electric spell release right hand forward tiny yellow sparks inside the cell, hurt recoil pose, hurt second recovery pose.
Make all sixteen poses actual useful game animation frames, sharp, clean and readable at 16x16 pixels.
