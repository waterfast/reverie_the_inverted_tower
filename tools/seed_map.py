"""一次性建立地图编辑器可修改的测试房间；不在游戏启动时执行。

已有地图时拒绝重建，避免覆盖手绘关卡。后续请直接使用 PICO-8 地图编辑器。
"""

from pathlib import Path
import re
from PIL import Image
from import_character import PALETTE

ROOT = Path(__file__).resolve().parents[1]
CART = ROOT / "reverie_the_inverted_tower.p8"
text = CART.read_text(encoding="utf-8")
if "__map__" in text:
    raise SystemExit("Existing map found; edit it in PICO-8 instead of reseeding.")


def replace_section(name, data):
    global text
    pattern = rf"(?ms)^__{name}__\n.*?(?=^__[a-z]+__\s*$|\Z)"
    replacement = f"__{name}__\n{data}\n"
    if re.search(pattern, text):
        text = re.sub(pattern, lambda _: replacement, text)
    else:
        text += replacement


match = re.search(r"(?ms)^__gfx__\n(.*?)(?=^__[a-z]+__\s*$|\Z)", text)
rows = [list(line) for line in match.group(1).splitlines() if line.strip()]
while len(rows) < 128:
    rows.append(list("0" * 128))


def tile(sprite, pattern):
    assert len(pattern) == 8 and all(len(line) == 8 for line in pattern)
    left, top = (sprite % 16) * 8, (sprite // 16) * 8
    for y, line in enumerate(pattern):
        rows[top + y][left:left + 8] = list(line)


# 右侧空白列专门放 8x8 地图素材，不占用角色图集。
tile(14, ["66666666", "15515551", "15515551", "15515551",
          "10010001", "15555155", "15555155", "11111111"])
tile(15, ["99999999", "65565556", "15515551", "15515551",
          "10010001", "15555155", "65565556", "99999999"])
tile(30, ["11111111", "01111011", "01111011", "01111011",
          "00000000", "11011110", "11011110", "11011110"])
tile(31, ["11155111", "11500511", "15012051", "15012051",
          "15555551", "15012051", "15012051", "15555551"])
tile(46, ["11155111", "11105111", "11105111", "11155111",
          "11155111", "11150111", "11150111", "11155111"])
tile(47, ["11555511", "15666651", "56676665", "56676665",
          "56677765", "56666665", "15666651", "11555511"])
replace_section("gfx", "\n".join("".join(row) for row in rows))

flags = [0] * 256
flag_match = re.search(r"(?ms)^__gff__\n(.*?)(?=^__[a-z]+__\s*$|\Z)", text)
if flag_match:
    raw = "".join(flag_match.group(1).split())
    for i in range(min(256, len(raw) // 2)):
        flags[i] = int(raw[i * 2:i * 2 + 2], 16)
flags[14] |= 1
flags[15] |= 1
for sprite in (30, 31, 46, 47):
    flags[sprite] &= ~1
replace_section("gff", "\n".join(
    "".join(f"{flag:02x}" for flag in flags[start:start + 128])
    for start in (0, 128)
))

grid = [[0] * 128 for _ in range(32)]
for y in range(32):
    for x in range(64):
        grid[y][x] = 14 if x in (0, 63) or y in (0, 31) else 30

# 装饰只是地图中的普通格子，未设置实体 flag。
for x in (8, 24, 40, 56):
    for y in (7, 19):
        for dy in range(3):
            for dx in range(2):
                grid[y + dy][x + dx] = 31
for x, stop in ((18, 22), (30, 18), (42, 14), (56, 10)):
    for y in range(1, stop):
        grid[y][x] = 46
for x, y in ((5, 12), (21, 12), (37, 8), (53, 4)):
    grid[y][x] = 47

# 平台逐级上升；底层仍保留贯通通道，能直接测试横向滚动。
for left, right, y in ((2, 10, 26), (14, 22, 22), (26, 34, 18),
                       (38, 46, 14), (50, 61, 10)):
    for x in range(left, right + 1):
        grid[y][x] = 15
replace_section("map", "\n".join("".join(f"{cell:02x}" for cell in row) for row in grid))
CART.write_text(text, encoding="utf-8")

# 同步完整精灵表，避免后续导入旧 PNG 时擦掉新砖块。
sheet = Image.new("RGB", (128, 128))
for y, row in enumerate(rows):
    for x, color in enumerate(row):
        sheet.putpixel((x, y), PALETTE[int(color, 16)])
sheet.save(ROOT / "assets/sprites/nyaru_pico8_sheet.png")
print("Created editable 64x32 map, solid tile flags and six map sprites.")
