"""一次性将三个房间写入地图空白区，保留初始房间和现有图像。

运行前做项目备份。已有房间数据时拒绝覆盖；后续在地图编辑器修改。
"""
import re
from PIL import Image
from import_character import ROOT, CART, PALETTE

text = CART.read_text(encoding="utf-8")


def section(name):
    return re.search(rf"(?ms)^__{name}__\n(.*?)(?=^__[a-z]+__\s*$|\Z)", text)


def write_section(name, data):
    global text
    match = section(name)
    if match:
        text = text[:match.start(1)] + data + "\n" + text[match.end(1):]
    else:
        text += f"__{name}__\n{data}\n"


map_rows = section("map").group(1).splitlines()
grid = [[int(line[x:x + 2], 16) for x in range(0, 256, 2)] for line in map_rows]
assert len(grid) == 32
areas = [(64, 0), (96, 0), (64, 16)]
for left, top in areas:
    if any(grid[y][x] for y in range(top, top + 16) for x in range(left, left + 32)):
        raise SystemExit("Destination contains map data; refusing to overwrite it.")

gfx = [list(line) for line in section("gfx").group(1).splitlines()]


def sprite(number, pattern):
    assert len(pattern) == 8 and all(len(line) == 8 for line in pattern)
    left, top = number % 16 * 8, number // 16 * 8
    for y, line in enumerate(pattern):
        gfx[top + y][left:left + 8] = line


sprite(62, ["55555555", "129a1291", "129a1291", "55555555",
            "1da91da1", "1da91da1", "1da91da1", "55555555"])
sprite(63, ["111a1111", "11171111", "11171111", "11171111",
            "11171111", "11151111", "11555111", "11111111"])
sprite(78, ["111cc111", "11c11c11", "1c1cc1c1", "c1c11c1c",
            "c1c11c1c", "1c1cc1c1", "11c11c11", "111cc111"])
sprite(79, ["11111111", "11177611", "11766111", "17661111",
            "17661111", "11766111", "11177611", "11111111"])

flags_raw = "".join(section("gff").group(1).split())
flags = [int(flags_raw[i:i + 2], 16) for i in range(0, 512, 2)]
for number in (62, 63, 78, 79):
    flags[number] &= ~1

for index, (left, top) in enumerate(areas):
    for y in range(16):
        for x in range(32):
            grid[top + y][left + x] = 14 if x in (0, 31) or y in (0, 15) else 30
    # 低平台可跳上，较高的平台是后续设计的探索区域。
    # 留出水平空隙，让两种世界都能经过低平台后落回地面到达出口。
    for start, y in ((6, 13), (14, 9), (22, 3)):
        for x in range(start, start + 4):
            grid[top + y][left + x] = 15
    if index == 0:
        for x in (4, 12, 20, 28):
            grid[top + 3][left + x] = 79
            grid[top + 8][left + x] = 31
    elif index == 1:
        for x in (4, 12, 20, 28):
            for y in (5, 6, 7, 8):
                if grid[top + y][left + x] == 30:
                    grid[top + y][left + x] = 62
            grid[top + 11][left + x] = 63
    else:
        for x in (4, 12, 20, 28):
            grid[top + 5][left + x] = 78
            grid[top + 9][left + x] = 46

write_section("gfx", "\n".join("".join(row) for row in gfx))
write_section("gff", "\n".join("".join(f"{flag:02x}" for flag in flags[start:start + 128]) for start in (0, 128)))
write_section("map", "\n".join("".join(f"{cell:02x}" for cell in row) for row in grid))
CART.write_text(text, encoding="utf-8")
sheet = Image.new("RGB", (128, 128))
for y, row in enumerate(gfx):
    for x, color in enumerate(row):
        sheet.putpixel((x, y), PALETTE[int(color, 16)])
sheet.save(ROOT / "assets/sprites/nyaru_pico8_sheet.png")
print("Added three editable rooms, bookcases, candles, runes and moons.")
