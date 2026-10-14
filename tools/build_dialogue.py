"""从中文剧情生成卡带可用的字模和 ASCII 字符编号，不依赖运行时系统字体。"""
import argparse
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--font', default='C:/Windows/Fonts/simsun.ttc')
    args = parser.parse_args()
    stories = json.loads((ROOT / 'assets/dialogue/stories.json').read_text(encoding='utf-8'))
    characters = sorted({c for pages in stories.values() for page in pages for c in page['text']})
    if len(characters) > 255:
        raise ValueError('当前字库最多 255 个不同汉字；扩容时改为三位编号。')
    ids = {char: index + 1 for index, char in enumerate(characters)}
    font = ImageFont.truetype(args.font, 12)
    output = ['-- 自动生成；请编辑 assets/dialogue/stories.json 后运行 tools/build_dialogue.py。',
              'dialogue_font={']
    for char in characters:
        image = Image.new('1', (12, 12))
        ImageDraw.Draw(image).text((0, -2), char, font=font, fill=1)
        bitmap = ''.join(f'{sum(image.getpixel((x,y)) << (11-x) for x in range(12)):03x}'
                         for y in range(12))
        output.append(f' "{bitmap}",')
    output.extend(['}', 'stories={'])
    for name, pages in stories.items():
        output.append(f' {name}={{')
        for page in pages:
            # 每页三行，每行九字，留出左右边框和翻页提示。
            text = page['text']
            for start in range(0, len(text), 27):
                chunk = text[start:start + 27]
                lines = [chunk[i:i + 9] for i in range(0, len(chunk), 9)]
                encoded = ['"' + ''.join(f'{ids[c]:02x}' for c in line) + '"' for line in lines]
                speaker = json.dumps(page['speaker'], ensure_ascii=True)
                output.append(f'  {{speaker={speaker},lines={{{",".join(encoded)}}}}},')
        output.append(' },')
    output.append('}')
    (ROOT / 'src/dialogue_data.lua').write_text('\n'.join(output) + '\n', encoding='utf-8')
    print(f'已生成 {len(characters)} 字与 {len(stories)} 段对话')


if __name__ == '__main__':
    main()
