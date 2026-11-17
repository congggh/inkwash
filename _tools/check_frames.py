# -*- coding: utf-8 -*-
"""帧图程序化质检：非背景占比、边界框、脚底贴边、帧间差异。"""
import os, json, glob
from PIL import Image

BG = (224, 224, 224)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, 'InkWash_Unity动画资源包', 'Assets', 'InkWash_Animations')

def analyze(path):
    im = Image.open(path).convert('RGB')
    W, H = im.size
    px = im.load()
    n = 0
    minx, miny, maxx, maxy = W, H, -1, -1
    bottom_hit = False
    for y in range(H):
        for x in range(W):
            r, g, b = px[x, y]
            if abs(r - BG[0]) > 12 or abs(g - BG[1]) > 12 or abs(b - BG[2]) > 12:
                n += 1
                if x < minx: minx = x
                if x > maxx: maxx = x
                if y < miny: miny = y
                if y > maxy: maxy = y
                if y >= H - 2:
                    bottom_hit = True
    return dict(count=n, bbox=(minx, miny, maxx, maxy) if n else None,
                bottom=bottom_hit, W=W, H=H)

def main():
    problems = []
    total = 0
    for anim_dir in sorted(glob.glob(os.path.join(ASSETS, '*', 'Sprites', '*'))):
        name = os.path.relpath(anim_dir, ASSETS)
        files = sorted(glob.glob(os.path.join(anim_dir, '*.png')))
        if not files:
            continue
        counts = []
        prev = None
        for f in files:
            r = analyze(f)
            total += 1
            counts.append(r['count'])
            if r['count'] < 40:
                problems.append('%s: 几乎空白 count=%d' % (os.path.basename(f), r['count']))
            if r['bbox'] and (r['bbox'][0] < 0 or r['bbox'][2] > r['W']):
                problems.append('%s: 越界 %s' % (os.path.basename(f), r['bbox']))
        # 帧间差异
        minc, maxc = min(counts), max(counts)
        if maxc - minc < 20 and len(counts) > 2:
            problems.append('%s: 帧间差异过小 (%d~%d)' % (name, minc, maxc))
        first = analyze(files[0])
        print('%-28s frames=%-3d count[%d..%d] bbox=%s bottom=%s'
              % (name, len(files), minc, maxc, first['bbox'], first['bottom']))
    print('---')
    print('total frames:', total)
    print('problems:', len(problems))
    for p in problems[:40]:
        print('  ', p)

if __name__ == '__main__':
    main()
