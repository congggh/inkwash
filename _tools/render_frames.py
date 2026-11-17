# -*- coding: utf-8 -*-
"""《留白》序章动作帧生成器
角色：主角墨痕 / 杂兵盲眼巡卒 / 精英镇峰狱尉 / Boss 墨梅
帧率：120 FPS（原文件 60 FPS 基准的两倍），每个源帧 + 1 个中间帧，时长不变。
输出：帧 PNG、序列图、GIF、manifest.json
"""
import math
import os
import json
import random
from collections import deque
from PIL import Image, ImageDraw

from ink_rig import (Rig, BG, INK, INK2, WHITE, PAPER, RED, GOLD, BRONZE, IRON,
                     CHAR, CRIM, BASALT, AZUR, BLOOD,
                     lerp, vlerp, lighten, darken, tapered,
                     fx_splash, fx_dust, fx_streak, fx_arc, fx_droplets, fx_butterfly,
                     fx_lotus, fx_ring, fx_sparks, fx_crack, fx_vortex, fx_sheet,
                     fx_branches, fx_glow_arc, fx_glint, fx_thorns, fx_vapor,
                     fx_char_strokes, fx_paperfly)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PKG = os.path.join(ROOT, 'InkWash_Unity动画资源包')
OUT_ASSETS = os.path.join(PKG, 'Assets', 'InkWash_Animations')
OUT_SHEETS = os.path.join(PKG, 'Preview', 'sheets')
OUT_GIFS = os.path.join(PKG, 'Preview', 'gifs')

GRID = 1000.0 / 120.0  # 8.333 ms


def quantize(ms):
    steps = max(1, int(round(ms / GRID)))
    return steps * GRID


# ---------------------------------------------------------------- 角色风格 ----
STYLE = {
    'MoHen': dict(
        fig_h=198, torso=60, neck=9, head_r=17, shld_w=30, hip_w=26, limb_w=13,
        torso_w=30, body=PAPER, ink=INK, cloth=(46, 44, 42), hair=(18, 17, 16),
        skin=PAPER, charred=(32, 30, 29), merid=RED, armR=(32, 30, 29),
        prop='chisel', prop_len=95, prop_w=10, cloak=True, cloak_len=72,
        hair_len=52, mudra=True,
    ),
    'BlindPatrol': dict(
        fig_h=166, torso=52, neck=6, head_r=15, shld_w=24, hip_w=22, limb_w=12,
        torso_w=26, body=(66, 71, 77), ink=INK, cloth=(56, 60, 65), hair=None,
        skin=(66, 71, 77), armR=(56, 60, 65), blind=True, hair_len=0,
        prop='ruler', prop_len=110, prop_w=9, cloak=False,
    ),
    'PeakWarden': dict(
        fig_h=300, torso=105, neck=10, head_r=24, shld_w=36, hip_w=40, limb_w=24,
        torso_w=58, body=BASALT, ink=INK, cloth=BASALT, hair=None,
        skin=BASALT, armR=BASALT, helmet=True, hair_len=0,
        prop='shield', shield_h=210, shield_w=150, cloak=False,
    ),
    'MoMei': dict(
        fig_h=278, torso=62, neck=7, head_r=16, shld_w=26, hip_w=24, limb_w=12,
        torso_w=28, body=CRIM, ink=INK, cloth=CRIM, hair=(16, 16, 16),
        skin=(239, 233, 218), armR=CRIM, topknot=True, hair_len=40,
        prop='rapier', prop_len=150, prop_w=3, cloak=True, cloak_len=80, robe=True,
    ),
}

CANVAS = {
    'MoHen': (512, 320),
    'BlindPatrol': (320, 320),
    'PeakWarden': (448, 384),
    'MoMei': (512, 448),
}

ANCHOR = {
    'MoHen': (256, 320),
    'BlindPatrol': (160, 320),
    'PeakWarden': (224, 384),
    'MoMei': (256, 448),
}


# ---------------------------------------------------------------- pose helper ----
def P(x=240, y=206, lean=0.0, feet=((216, 320), (264, 320)),
      hands=((214, 170), (262, 180)), **kw):
    d = dict(pelvis=(x, y), lean=lean, feet=list(feet), hands=list(hands))
    d.update(kw)
    return d


# ---------------------------------------------------------------- 主角墨痕 ----
def mo_idle():
    ps = []
    for i in range(8):
        b = math.sin(2 * math.pi * i / 8)
        ps.append(P(x=240, y=206 + 2 * b, lean=0.03,
                    feet=((214, 320), (262, 318)),
                    hands=((210, 166 + b), (258, 192)),
                    mudra=True, prop={'ang': -2.5 + b * 0.05}))
    return ps


def mo_run():
    ps = []
    for i in range(8):
        t = 2 * math.pi * i / 8
        stride, lift = 30, 16
        liftR = max(0, math.sin(t)) * lift
        liftL = max(0, -math.sin(t)) * lift
        xR = 240 + stride * math.sin(t) * 0.6
        xL = 240 - stride * math.sin(t) * 0.6
        bob = 206 - 3 * abs(math.sin(t))
        ps.append(P(x=240, y=bob, lean=0.56,
                    feet=((xL, 320 - liftL), (xR, 320 - liftR)),
                    hands=((240 + 22 * math.sin(t + math.pi), 210 - 8 * math.cos(t)),
                           (240 - 24 * math.sin(t), 214 - 8 * math.cos(t + math.pi))),
                    prop={'ang': -2.6},
                    fx_back=[('dust', xL if liftL < 3 else xR, 320)]))
    return ps


def mo_turn():
    return [
        P(x=240, y=210, lean=-0.31, feet=((206, 318), (262, 320)),
          hands=((214, 170), (258, 182)), fx=1.0, prop={'ang': -2.4},
          fx_back=[('dust', 230, 318)]),
        P(x=240, y=208, lean=0.0, feet=((220, 316), (258, 318)),
          hands=((238, 150), (244, 176)), fx=0.45, prop={'ang': -1.0}),
        P(x=240, y=207, lean=0.05, feet=((218, 318), (256, 318)),
          hands=((246, 156), (236, 180)), fx=-0.6, prop={'ang': -0.5}),
        P(x=240, y=206, lean=0.08, feet=((216, 320), (260, 320)),
          hands=((248, 160), (224, 186)), fx=-1.0, prop={'ang': -1.2}),
    ]


def mo_jump():
    return [
        P(x=240, y=222, lean=0.1, feet=((208, 320), (256, 320)),
          hands=((212, 220), (262, 224)), prop={'ang': -2.2}),
        P(x=240, y=196, lean=0.15, feet=((210, 316), (254, 306)),
          hands=((206, 190), (270, 196)), prop={'ang': -2.4},
          fx_back=[('ring', 240, 316, 16)]),
        P(x=240, y=150, lean=0.12, feet=((226, 240), (250, 244)),
          hands=((208, 150), (272, 152)), mudra=True, prop={'ang': -2.5}),
        P(x=240, y=108, lean=0.1, feet=((230, 192), (252, 196)),
          hands=((204, 108), (276, 110)), mudra=True, prop={'ang': -2.5}),
        P(x=240, y=84, lean=0.05, feet=((224, 160), (256, 164)),
          hands=((196, 92), (284, 90)), prop={'ang': -2.5}),
        P(x=240, y=82, lean=0.05, feet=((222, 158), (258, 162)),
          hands=((194, 90), (286, 88)), prop={'ang': -2.5}),
        P(x=240, y=86, lean=0.05, feet=((224, 160), (256, 164)),
          hands=((198, 94), (282, 92)), prop={'ang': -2.5}),
        P(x=240, y=126, lean=0.25, feet=((232, 200), (240, 204)),
          hands=((206, 150), (262, 146)), prop={'ang': -1.9}),
        P(x=240, y=178, lean=0.3, feet=((234, 258), (242, 262)),
          hands=((210, 206), (260, 198)), prop={'ang': -1.7}),
        P(x=240, y=224, lean=0.2, feet=((230, 308), (242, 310)),
          hands=((208, 244), (262, 238)), prop={'ang': -1.5}),
        P(x=240, y=246, lean=0.15, feet=((206, 320), (260, 320)),
          hands=((206, 260), (262, 256)), prop={'ang': -2.0},
          fx_back=[('dust', 224, 318), ('dust', 258, 318)]),
        P(x=240, y=250, lean=0.12, feet=((208, 320), (258, 320)),
          hands=((208, 262), (262, 258)), prop={'ang': -2.1}),
        P(x=240, y=206, lean=0.08, feet=((214, 320), (262, 320)),
          hands=((212, 190), (262, 196)), prop={'ang': -2.3}),
    ]


def mo_dash():
    xs = [210, 228, 246, 264, 282, 300]
    ps = []
    for i in range(6):
        x = xs[i]
        if i == 0:
            ps.append(P(x=x, y=252, lean=0.66, feet=((x - 44, 320), (x - 6, 318)),
                        hands=((x - 66, 238), (x - 56, 246)), prop={'ang': -2.7},
                        fx_back=[('splash', x - 44, 316, 16, INK)]))
        elif i < 5:
            sw = [0, 1, -1, 0][i - 1]
            ps.append(P(x=x, y=246, lean=0.66,
                        feet=((x - 44 + sw * 4, 318), (x - 6 - sw * 4, 320)),
                        hands=((x - 66, 224), (x - 54, 232)), prop={'ang': -2.75},
                        fx_back=[('streak', x - 90, 240, x - 40, 250),
                                 ('crack', x - 70, x - 20, 318)]))
        else:
            ps.append(P(x=x, y=232, lean=0.2, feet=((x - 20, 318), (x + 22, 320)),
                        hands=((x + 24, 180), (x - 8, 220)), mudra=True, prop={'ang': -2.4},
                        fx_back=[('dust', x + 10, 318)]))
    return ps


def mo_rift():
    return [
        P(x=240, y=236, lean=0.7, feet=((204, 318), (252, 318)),
          hands=((268, 252), (262, 266)), prop={'ang': -2.6},
          fx_back=[('crack', 220, 300, 318)]),
        P(x=240, y=252, lean=0.75, feet=((206, 320), (256, 320)),
          hands=((276, 260), (268, 274)), prop={'ang': -2.7},
          over={'cloth': INK, 'body': INK, 'skin': INK, 'armR': INK},
          fx_back=[('vortex', 232, 300, 20)]),
        P(x=240, y=300, lean=0.0, feet=((220, 320), (260, 320)),
          hands=((230, 300), (250, 300)), inkform=True,
          fx_back=[('brushline', 240, 300, 260), ('butterfly', 190, 260), ('butterfly', 300, 270)]),
        P(x=240, y=300, lean=0.0, feet=((220, 320), (260, 320)),
          hands=((230, 300), (250, 300)), inkform=True,
          fx_back=[('brushline', 240, 300, 260), ('butterfly', 170, 250), ('butterfly', 320, 280)]),
        P(x=240, y=250, lean=0.4, feet=((210, 318), (252, 318)),
          hands=((250, 250), (260, 258)), prop={'ang': -2.4},
          over={'skin': lighten(PAPER, 0.3)}, fx_back=[('splash', 240, 300, 18)]),
        P(x=240, y=232, lean=0.1, feet=((214, 320), (258, 318)),
          hands=((230, 180), (250, 190)), prop={'ang': -1.6}, fx=-1.0),
    ]


def _slash_seg(n, sweep_lo, sweep_hi, hit_range):
    """通用横扫：n 帧，刀角 sweep_lo->sweep_hi，hit_range=(起,止) 判定帧区间。"""
    ps = []
    for i in range(n):
        if i < hit_range[0]:
            ang = sweep_lo
        elif i <= hit_range[1]:
            ang = sweep_lo + (i - hit_range[0] + 1) / (hit_range[1] - hit_range[0] + 1) * (sweep_hi - sweep_lo)
        else:
            ang = sweep_hi
        hitting = hit_range[0] <= i <= hit_range[1]
        fx = []
        if hitting:
            fx.append(('arc', 252, 208, 92, 72, sweep_lo, sweep_hi))
        ps.append(P(x=244, y=208, lean=0.2 if hitting else 0.12,
                    feet=((206, 320), (264, 318)) if hitting else ((214, 320), (256, 320)),
                    hands=((206, 172), (256 + math.cos(ang) * 14, 192 + math.sin(ang) * 14)),
                    prop={'ang': ang},
                    fx_front=fx))
    return ps


def mo_slash1():
    return _slash_seg(16, -1.3, 1.9, (4, 8))


def mo_slash2():
    ps = []
    for i in range(16):
        if i < 3:
            ang = 1.9
        elif i <= 7:
            ang = 1.9 - (i - 3 + 1) / 5 * (1.9 + 0.9)
        else:
            ang = -0.9
        hitting = 3 <= i <= 7
        fx = []
        if hitting:
            fx.append(('arc', 248, 204, 80, 62, -0.9, 1.9))
            fx.append(('streak', 180, 200, 250, 180))
        ps.append(P(x=240, y=204, lean=0.18 if hitting else 0.08,
                    feet=((212, 316), (254, 320)) if hitting else ((214, 320), (258, 320)),
                    hands=((206, 168), (256 + math.cos(ang) * 14, 190 + math.sin(ang) * 14)),
                    prop={'ang': ang}, fx_front=fx))
    return ps


def mo_slash3():
    ps = []
    n = 22
    for i in range(n):
        if i < 7:
            # 凌空翻腾蓄力
            t = i / 6
            y = 206 - 120 * math.sin(math.pi * t)
            lean = 0.1 - 1.2 * math.sin(math.pi * t)
            ps.append(P(x=240, y=max(y, 60), lean=lean,
                        feet=((228 - t * 10, 320 - 90 * t), (252 - t * 10, 320 - 90 * t)),
                        hands=((206, max(70, y - 40)), (270, max(70, y - 40))),
                        prop={'ang': -2.8}))
        elif i < 13:
            ang = math.pi / 2
            t = (i - 7) / 5
            y = 120 + 90 * t
            hitting = i >= 11
            fx = []
            if hitting:
                fx.append(('arc', 256, 200, 60, 46, -0.6, math.pi / 2 + 0.6))
                fx.append(('sparks', 252, 316))
                fx.append(('crack', 210, 290, 318))
            ps.append(P(x=240, y=y, lean=0.4, feet=((232, 320), (248, 320)),
                        hands=((230, y - 40), (256, y - 40)), prop={'ang': ang},
                        fx_front=fx))
        else:
            t = (i - 13) / 8
            y = 210 + 30 * t
            ps.append(P(x=240, y=y, lean=0.15,
                        feet=((206, 320), (248, 320)),
                        hands=((212, y - 30), (262, y - 28)), prop={'ang': -0.6}))
    return ps


def mo_pogo():
    ps = []
    n = 12
    for i in range(n):
        if i < 2:
            ps.append(P(x=240, y=100, lean=-1.6, feet=((230, 56), (246, 62)),
                        hands=((238, 90), (252, 150)), prop={'ang': math.pi / 2}))
        elif i < 8:
            t = (i - 2) / 5
            y = 100 + 130 * t
            hitting = i >= 4
            fx = []
            if hitting:
                fx.append(('lotus', 254, y + 46, 12 + 6 * t))
            ps.append(P(x=240, y=y, lean=-1.6 + 0.8 * t, feet=((230, y - 44), (246, y - 38)),
                        hands=((238, y - 10), (252, y + 10)), prop={'ang': math.pi / 2},
                        fx_front=fx))
        else:
            t = (i - 8) / 3
            y = 230 - 110 * t
            ps.append(P(x=240, y=y, lean=0.3, feet=((222, y + 90), (254, y + 96)),
                        hands=((190, y), (292, y - 6)), prop={'ang': -2.0}))
    return ps


def mo_fold():
    ps = []
    n = 14
    for i in range(n):
        if i < 4:
            a = 2 * math.pi * i / 4
            ps.append(P(x=240, y=216, lean=0.02, feet=((180, 320), (276, 320)),
                        hands=((240 + 40 * math.cos(a), 170 + 22 * math.sin(a)),
                               (240 - 40 * math.cos(a), 170 - 22 * math.sin(a))),
                        prop={'ang': -2.3},
                        fx_front=[('glow', 240, 170, 44, 0, 2 * math.pi)]))
        elif i < 9:
            t = (i - 4) / 4
            hx = 240 - 34 * t
            ps.append(P(x=240, y=216, lean=0.02, feet=((190, 320), (270, 320)),
                        hands=((240 - 40 + 6 * t, 170), (240 + 40 - 6 * t, 170)),
                        prop={'ang': -2.3},
                        fx_front=[('vortex', 240, 180, 16 + 14 * t)]))
        else:
            t = (i - 9) / 4
            ps.append(P(x=240, y=214, lean=0.02, feet=((190, 320), (270, 320)),
                        hands=((150 - 10 * t, 190), (312 + 10 * t, 184)),
                        prop={'ang': -2.2},
                        fx_back=[('streak', 150, 230, 90, 240), ('streak', 330, 230, 390, 240)]))
    return ps


def mo_sling():
    ps = []
    n = 12
    for i in range(n):
        if i < 3:
            ps.append(P(x=240, y=140, lean=0.1, feet=((226, 220), (250, 226)),
                        hands=((206, 120), (262, 128)), prop={'ang': -2.4},
                        fx_front=[('glint', 190, 130, 220, 160)]))
        elif i < 7:
            t = (i - 3) / 3
            ps.append(P(x=240, y=150, lean=-0.5 * t, feet=((220, 250), (250, 256)),
                        hands=((150 - 10 * t, 140), (170 - 8 * t, 158)), prop={'ang': -2.3},
                        fx_front=[('arc', 168, 150, 30 + 16 * t, 22 + 12 * t, -2.4, 0.6)]))
        else:
            t = (i - 7) / 4
            ps.append(P(x=240, y=150, lean=0.9 * t, feet=((240, 260), (252, 268)),
                        hands=((292 + 8 * t, 150), (300 + 6 * t, 162)), prop={'ang': -1.0},
                        fx_back=[('streak', 180, 200, 120, 190), ('streak', 190, 220, 130, 210)]))
    return ps


def mo_parry():
    ps = []
    n = 14
    for i in range(n):
        if i < 2:
            ps.append(P(x=240, y=212, lean=0.15, feet=((204, 320), (256, 320)),
                        hands=((258, 180), (262, 176)), prop={'ang': 0.0}))
        elif i < 6:
            ps.append(P(x=240, y=212, lean=0.15, feet=((204, 320), (256, 320)),
                        hands=((258, 180), (262, 176)), prop={'ang': 0.0}, negative=True,
                        fx_front=[('ring', 262, 176, 20), ('sparks', 262, 176)]))
        elif i < 10:
            ang = -0.4 + (i - 6) / 3 * 1.3
            ps.append(P(x=240, y=210, lean=0.3, feet=((206, 320), (262, 318)),
                        hands=((206, 170), (262, 190)), prop={'ang': ang},
                        fx_front=[('arc', 258, 200, 78, 62, -0.3, 1.0), ('sheet', 320, 200, -0.5)]))
        else:
            ps.append(P(x=240, y=208, lean=0.08, feet=((214, 320), (258, 320)),
                        hands=((210, 172), (258, 188)), prop={'ang': -1.2}))
    return ps


def mo_finisher():
    ps = []
    n = 10
    for i in range(n):
        if i < 3:
            x = 300 - i * 40
            ps.append(P(x=x, y=206, lean=0.5, feet=((x - 20, 318), (x + 16, 320)),
                        hands=((x + 20, 170), (x + 12, 184)), prop={'ang': -2.0},
                        over={'cloth': lighten((46, 44, 42), 0.4), 'body': lighten(PAPER, 0.4),
                              'skin': lighten(PAPER, 0.4), 'armR': lighten((32, 30, 29), 0.4)},
                        fx_back=[('victim', 360, 320)]))
        elif i < 7:
            t = (i - 3) / 3
            ps.append(P(x=216, y=212, lean=0.2, feet=((200, 320), (238, 320)),
                        hands=((250 + 10 * t, 190), (256, 200)), prop={'ang': -1.5},
                        fx_front=[('sheet', 300 - 20 * t, 210, 0.2)]))
        else:
            ps.append(P(x=216, y=206, lean=0.05, feet=((204, 320), (236, 320)),
                        hands=((190, 240), (250, 200)), mudra=True, prop={'ang': -1.4},
                        fx_back=[('butterfly', 300, 200), ('butterfly', 320, 240), ('butterfly', 280, 260)]))
    return ps


def mo_boss_finisher():
    ps = []
    # 第 1 段
    ps.append(P(x=250, y=260, lean=0.3, feet=((210, 320), (270, 320)),
                hands=((250, 220), (278, 300)), prop={'ang': math.pi / 2 + 0.2},
                fx_back=[('splash', 280, 318, 14, INK)]))
    ps.append(P(x=250, y=250, lean=0.4, feet=((210, 320), (270, 320)),
                hands=((240, 200), (280, 300)), prop={'ang': math.pi / 2},
                fx_front=[('crack', 260, 360, 320)]))
    # 6 个狂草斩姿
    for i in range(6):
        a = math.pi / 2 + (i - 2.5) * 0.9
        y = 120 + 40 * abs(math.sin(i))
        ps.append(P(x=260, y=y, lean=math.cos(a) * 0.9,
                    feet=((240, y + 120), (280, y + 116)),
                    hands=((250, y - 20), (268 + math.cos(a) * 14, y + math.sin(a) * 14)),
                    prop={'ang': a},
                    fx_back=[('brushline', 260, y + 60, 200), ('butterfly', 200, y + 40)]))
    # 第 2 段
    ps.append(P(x=250, y=200, lean=0.2, feet=((226, 318), (258, 320)),
                hands=((236, 180), (262, 190)), prop={'ang': -1.8}))
    ps.append(P(x=250, y=206, lean=0.06, feet=((220, 320), (256, 320)),
                hands=((238, 176), (264, 186)), prop={'ang': -1.5}))
    ps.append(P(x=250, y=206, lean=0.04, feet=((220, 320), (256, 320)),
                hands=((238, 176), (264, 186)), prop={'ang': -1.5}))
    # 双手贯心（拓片反相）
    for i in range(3):
        ps.append(P(x=250, y=210, lean=0.25, feet=((204, 320), (252, 320)),
                    hands=((252, 178), (268, 178)), prop={'ang': 0.0}, negative=True,
                    fx_front=[('sparks', 274, 178)]))
    # 题跋引爆
    ps.append(P(x=250, y=206, lean=0.08, feet=((214, 320), (254, 320)),
                hands=((238, 176), (258, 190)), prop={'ang': -1.2},
                fx_front=[('char', 320, 200, 90), ('butterfly', 300, 200), ('butterfly', 340, 240),
                          ('paperfly', 320, 260)]))
    ps.append(P(x=250, y=206, lean=0.06, feet=((214, 320), (254, 320)),
                hands=((236, 176), (254, 190)), prop={'ang': -1.4},
                fx_front=[('char', 320, 200, 90), ('butterfly', 280, 180), ('butterfly', 350, 260),
                          ('paperfly', 300, 240)]))
    return ps


# ---------------------------------------------------------------- 盲眼巡卒 ----
def bp_idle():
    ps = []
    for i in range(4):
        tilt = [0, 0.12, 0, -0.12][i]
        bob = [0, 1, 0, 1][i]
        ps.append(P(x=160, y=224 + bob, lean=0.0, feet=((136, 320), (150, 320)),
                    hands=((150, 180), (180, 196)), head_tilt=tilt,
                    prop={'ang': math.pi / 2}))
    return ps


def bp_patrol():
    ps = []
    for i in range(6):
        t = 2 * math.pi * i / 6
        liftR = max(0, math.sin(t)) * 6
        liftL = max(0, -math.sin(t)) * 6
        xR = 160 + 18 * math.sin(t) * 0.5
        xL = 160 - 18 * math.sin(t) * 0.5
        ps.append(P(x=160, y=224, lean=0.1, feet=((xL, 320 - liftL), (xR, 320 - liftR)),
                    hands=((150, 180), (150, 200)), prop={'ang': -0.35},
                    fx_back=[('crack', xL - 20, xL, 319)]))
    return ps


def bp_chase():
    ps = []
    for i in range(6):
        t = 2 * math.pi * i / 6
        liftR = max(0, math.sin(t)) * 10
        liftL = max(0, -math.sin(t)) * 10
        xR = 160 + 14 * math.sin(t)
        xL = 160 - 14 * math.sin(t)
        ps.append(P(x=160, y=222, lean=0.52, feet=((xL, 320 - liftL), (xR, 320 - liftR)),
                    hands=((150, 172), (176, 168)), prop={'ang': 0.0},
                    fx_back=[('streak', 130, 190, 90, 200)]))
    return ps


# ---------------------------------------------------------------- 镇峰狱尉 ----
def pw_idle():
    ps = []
    for i in range(4):
        b = [0, 1, 0, 1][i]
        ps.append(P(x=200, y=212 + b, lean=0.0, feet=((140, 384), (280, 384)),
                    hands=((220, 150), (280, 150)), prop={'pos': (296, 150)},
                    fx_back=[('vapor', 210, 180)] if i % 2 == 0 else []))
    return ps


def pw_move():
    ps = []
    for i in range(6):
        t = 2 * math.pi * i / 6
        bob = 2 * abs(math.sin(t))
        x0 = 200 + 12 * math.sin(t)
        if i % 2 == 0:
            feet = ((170, 384), (250, 384))
        else:
            feet = ((190, 384), (230, 384))
        ps.append(P(x=x0, y=210 + bob, lean=0.0, feet=feet,
                    hands=((220, 150), (280, 150)), prop={'pos': (296, 150)},
                    fx_back=[('dust', 200, 383)]))
    return ps


def pw_combat():
    ps = []
    # F0 守势
    ps.append(P(x=200, y=212, lean=0.0, feet=((140, 384), (280, 384)),
                hands=((220, 150), (280, 150)), prop={'pos': (300, 150)}))
    # F1 蓄力
    ps.append(P(x=200, y=214, lean=-0.15, feet=((140, 384), (280, 384)),
                hands=((220, 150), (280, 150)), prop={'pos': (298, 150)},
                fx_front=[('sparks', 300, 150)]))
    # F2 冲撞（判定）
    ps.append(P(x=220, y=212, lean=0.5, feet=((150, 384), (290, 384)),
                hands=((220, 150), (300, 150)), prop={'pos': (320, 150)},
                fx_front=[('arc', 320, 150, 70, 54, -0.9, 0.9), ('sparks', 320, 150)]))
    # F3 撕甲
    ps.append(P(x=200, y=212, lean=0.1, feet=((140, 384), (280, 384)),
                hands=((220, 150), (280, 150)), prop={'pos': (296, 150), 'crackline': True},
                fx_front=[('sheet', 300, 170, -0.6)]))
    # F4 暴露木偶骨架
    ps.append(P(x=200, y=230, lean=0.15, feet=((160, 384), (250, 384)),
                hands=((210, 200), (260, 200)),
                over={'cloth': lighten(BASALT, 0.5), 'body': lighten(BASALT, 0.5),
                      'skin': lighten(BASALT, 0.5), 'armR': lighten(BASALT, 0.5), 'prop': None},
                fx_front=[('ring', 200, 230, 18, RED)]))
    # F5 崩解
    ps.append(P(x=200, y=230, lean=0.15, feet=((160, 384), (250, 384)),
                hands=((210, 200), (260, 200)),
                over={'cloth': lighten(BASALT, 0.65), 'body': lighten(BASALT, 0.65),
                      'skin': lighten(BASALT, 0.65), 'armR': lighten(BASALT, 0.65), 'prop': None},
                fx_back=[('butterfly', 180, 200), ('butterfly', 240, 180), ('butterfly', 300, 220),
                         ('paperfly', 200, 240)]))
    return ps


# ---------------------------------------------------------------- 墨梅 ----
def mm_idle():
    ps = []
    for i in range(4):
        b = [0, 1, 0, 1][i]
        ps.append(P(x=256, y=288 + b, lean=0.04, feet=((232, 448), (276, 448)),
                    hands=((224, 240), (272, 262)), prop={'ang': 1.5, 'droop': 6}))
    return ps


def mm_glide():
    ps = []
    for i in range(6):
        t = 2 * math.pi * i / 6
        xR = 268 + 20 * math.sin(t) * 0.5
        xL = 248 - 20 * math.sin(t) * 0.5
        ps.append(P(x=256, y=292, lean=0.18, feet=((xL, 446), (xR, 448)),
                    hands=((224, 240), (274, 260)), prop={'ang': 1.35, 'droop': 8}))
    return ps


def mm_rush():
    ps = []
    for i in range(6):
        t = 2 * math.pi * i / 6
        ps.append(P(x=256, y=330, lean=0.6, feet=((220, 446), (280, 448)),
                    hands=((210, 300), (268, 320)), prop={'ang': 1.0, 'droop': 10},
                    over={'cloth': CHAR, 'body': CHAR, 'armR': CHAR, 'skin': CHAR},
                    fx_back=[('branches', 240, 320), ('streak', 160, 320, 120, 330)]))
    return ps


def mm_kneel():
    ps = []
    white = (240, 240, 240)
    for i in range(4):
        b = [0, 1, 0, 1][i]
        ps.append(P(x=256, y=340 + b, lean=0.1, feet=((210, 448), (260, 448)),
                    hands=((224, 320), (270, 340)), prop={'ang': math.pi / 2, 'droop': 2},
                    over={'cloth': white, 'body': white, 'skin': white, 'armR': white,
                          'hair': white, 'ink': (170, 170, 170), 'merid': (170, 170, 170)},
                    ))
    return ps


def mm_combat():
    ps = []
    # F0 剑客起手
    ps.append(P(x=256, y=290, lean=0.05, feet=((232, 448), (276, 448)),
                hands=((224, 240), (274, 260)), prop={'ang': -0.15, 'droop': 4}))
    # F1 突刺（判定）
    ps.append(P(x=270, y=288, lean=0.45, feet=((216, 448), (284, 446)),
                hands=((224, 240), (290, 250)), prop={'ang': -0.1, 'droop': 2},
                fx_front=[('glint', 274, 250, 360, 250)]))
    # F2 空中回旋斩
    ps.append(P(x=256, y=160, lean=0.3, feet=((240, 300), (272, 296)),
                hands=((200, 140), (280, 150)), prop={'ang': 2.6, 'droop': 6},
                fx_front=[('arc', 256, 160, 90, 70, 0, 2 * math.pi)]))
    # F3 二阶段爆枝
    ps.append(P(x=256, y=300, lean=0.2, feet=((230, 448), (276, 448)),
                hands=((224, 260), (276, 280)), prop={'ang': 1.2, 'droop': 8},
                over={'cloth': CHAR, 'body': CHAR, 'armR': CHAR},
                fx_back=[('branches', 240, 300, 10, 110), ('sparks', 256, 300)]))
    # F4 地面荆棘
    ps.append(P(x=256, y=300, lean=0.15, feet=((230, 448), (276, 448)),
                hands=((220, 260), (274, 280)), prop={'ang': 1.3, 'droop': 8},
                over={'cloth': CHAR, 'body': CHAR, 'armR': CHAR},
                fx_back=[('thorns', 200, 448, 5, 70), ('thorns', 300, 448, 5, 70)]))
    # F5 披风剥离
    ps.append(P(x=256, y=296, lean=0.1, feet=((232, 448), (276, 448)),
                hands=((224, 250), (272, 270)), prop={'ang': 1.4, 'droop': 6},
                fx_front=[('sheet', 330, 260, -0.5)]))
    # F6 三阶段白描跪姿
    white = (240, 240, 240)
    ps.append(P(x=256, y=340, lean=0.1, feet=((214, 448), (262, 448)),
                hands=((226, 320), (270, 340)), prop={'ang': math.pi / 2, 'droop': 2},
                over={'cloth': white, 'body': white, 'skin': white, 'armR': white,
                      'hair': white, 'ink': (170, 170, 170)}))
    return ps


# ---------------------------------------------------------------- 动画表 ----
def build_all():
    """返回动画定义列表。frames = 源帧数，dur_ms = 源总时长，loop 布尔。"""
    return [
        dict(char='MoHen', name='Idle', frames=8, dur_ms=1066.7, loop=True, build=mo_idle),
        dict(char='MoHen', name='Run', frames=8, dur_ms=533.3, loop=True, build=mo_run),
        dict(char='MoHen', name='Turn', frames=4, dur_ms=266.7, loop=False, build=mo_turn),
        dict(char='MoHen', name='Jump', frames=13, dur_ms=866.7, loop=False, build=mo_jump),
        dict(char='MoHen', name='Dash', frames=6, dur_ms=180.0, loop=False, build=mo_dash),
        dict(char='MoHen', name='RiftGrind', frames=6, dur_ms=180.0, loop=False, build=mo_rift),
        dict(char='MoHen', name='Slash1', frames=16, dur_ms=266.7, loop=False, build=mo_slash1),
        dict(char='MoHen', name='Slash2', frames=16, dur_ms=266.7, loop=False, build=mo_slash2),
        dict(char='MoHen', name='Slash3', frames=22, dur_ms=366.7, loop=False, build=mo_slash3),
        dict(char='MoHen', name='Pogo', frames=12, dur_ms=200.0, loop=False, build=mo_pogo),
        dict(char='MoHen', name='Fold', frames=14, dur_ms=240.0, loop=False, build=mo_fold),
        dict(char='MoHen', name='Slingshot', frames=12, dur_ms=200.0, loop=False, build=mo_sling),
        dict(char='MoHen', name='Parry', frames=14, dur_ms=554.0, loop=False, build=mo_parry),
        dict(char='MoHen', name='Finisher', frames=10, dur_ms=180.0, loop=False, build=mo_finisher),
        dict(char='MoHen', name='BossFinisher', frames=16, dur_ms=533.3, loop=False, build=mo_boss_finisher),
        dict(char='BlindPatrol', name='Idle', frames=4, dur_ms=800.0, loop=True, build=bp_idle),
        dict(char='BlindPatrol', name='Patrol', frames=6, dur_ms=600.0, loop=True, build=bp_patrol),
        dict(char='BlindPatrol', name='Chase', frames=6, dur_ms=600.0, loop=True, build=bp_chase),
        dict(char='PeakWarden', name='Idle', frames=4, dur_ms=800.0, loop=True, build=pw_idle),
        dict(char='PeakWarden', name='Move', frames=6, dur_ms=800.0, loop=True, build=pw_move),
        dict(char='PeakWarden', name='Combat', frames=6, dur_ms=600.0, loop=False, build=pw_combat),
        dict(char='MoMei', name='Idle', frames=4, dur_ms=800.0, loop=True, build=mm_idle),
        dict(char='MoMei', name='Glide', frames=6, dur_ms=600.0, loop=True, build=mm_glide),
        dict(char='MoMei', name='Rush', frames=6, dur_ms=480.0, loop=True, build=mm_rush),
        dict(char='MoMei', name='Kneel', frames=4, dur_ms=800.0, loop=True, build=mm_kneel),
        dict(char='MoMei', name='Combat', frames=7, dur_ms=840.0, loop=False, build=mm_combat),
    ]


# ---------------------------------------------------------------- 插值 ----
NUM_KEYS = {'lean', 'head_tilt', 'knee_bend', 'elbow_bend', 'fx'}
SNAP_KEYS = {'over', 'negative', 'inkform', 'fx_back', 'fx_front', 'mudra'}


def interp_pose(a, b, t):
    if t <= 0:
        return dict(a)
    if t >= 1:
        return dict(b)
    out = {}
    for k, v in a.items():
        if k in SNAP_KEYS:
            out[k] = v if t < 0.5 else b.get(k, v)
        elif k in NUM_KEYS:
            out[k] = lerp(v, b.get(k, v), t)
        elif k == 'pelvis':
            out[k] = vlerp(v, b.get(k, v), t)
        elif k in ('feet', 'hands'):
            out[k] = [vlerp(x, y, t) for x, y in zip(v, b.get(k, []))]
        elif k == 'prop':
            pa = dict(v)
            pb = b.get(k, v) or {}
            out[k] = {}
            for kk, vv in pa.items():
                if isinstance(vv, (int, float)) and kk in pb and isinstance(pb[kk], (int, float)):
                    out[k][kk] = lerp(vv, pb[kk], t)
                else:
                    out[k][kk] = vv if t < 0.5 else pb.get(kk, vv)
        else:
            out[k] = v if t < 0.5 else b.get(k, v)
    return out


# ---------------------------------------------------------------- 特效 dispatch ----
def apply_fx(d, fxlist, seed):
    if not fxlist:
        return
    for i, fx in enumerate(fxlist):
        kind = fx[0]
        sd = seed + i * 13
        try:
            if kind == 'splash':
                fx_splash(d, fx[1], fx[2], fx[3], color=fx[4] if len(fx) > 4 else INK, seed=sd)
            elif kind == 'dust':
                fx_dust(d, fx[1], fx[2], seed=sd)
            elif kind == 'streak':
                fx_streak(d, fx[1], fx[2], fx[3], fx[4], seed=sd)
            elif kind == 'arc':
                fx_arc(d, fx[1], fx[2], fx[3], fx[4], fx[5], fx[6], seed=sd)
            elif kind == 'droplets':
                fx_droplets(d, fx[1], seed=sd)
            elif kind == 'butterfly':
                fx_butterfly(d, fx[1], fx[2], seed=sd)
            elif kind == 'lotus':
                fx_lotus(d, fx[1], fx[2], fx[3])
            elif kind == 'ring':
                c = fx[4] if len(fx) > 4 else WHITE
                fx_ring(d, fx[1], fx[2], fx[3], color=c)
            elif kind == 'sparks':
                fx_sparks(d, fx[1], fx[2], seed=sd)
            elif kind == 'crack':
                fx_crack(d, fx[1], fx[2], fx[3], seed=sd)
            elif kind == 'vortex':
                fx_vortex(d, fx[1], fx[2], fx[3], seed=sd)
            elif kind == 'sheet':
                fx_sheet(d, fx[1], fx[2], fx[3], seed=sd)
            elif kind == 'branches':
                fx_branches(d, fx[1], fx[2], n=fx[3] if len(fx) > 3 else 8,
                            L=fx[4] if len(fx) > 4 else 70, seed=sd)
            elif kind == 'glow':
                fx_glow_arc(d, fx[1], fx[2], fx[3], fx[4], fx[5])
            elif kind == 'glint':
                fx_glint(d, fx[1], fx[2], fx[3], fx[4])
            elif kind == 'thorns':
                fx_thorns(d, fx[1], fx[2], n=fx[3] if len(fx) > 3 else 5,
                          L=fx[4] if len(fx) > 4 else 60, seed=sd)
            elif kind == 'vapor':
                fx_vapor(d, fx[1], fx[2], seed=sd)
            elif kind == 'char':
                fx_char_strokes(d, fx[1], fx[2], fx[3], seed=sd)
            elif kind == 'paperfly':
                fx_paperfly(d, fx[1], fx[2], seed=sd)
            elif kind == 'victim':
                draw_victim(d, fx[1], fx[2])
            elif kind == 'brushline':
                draw_brushline(d, fx[1], fx[2], fx[3], seed=sd)
        except Exception as e:
            print('  fx warn', kind, e)


def draw_brushline(d, cx, cy, half, seed=0):
    rnd = random.Random(seed)
    tapered(d, (cx - half, cy), (cx + half, cy + 3), 15, 3, INK)
    fx_streak(d, cx - half * 0.8, cy - 10, cx + half * 0.7, cy - 8, n=4, color=INK2, seed=seed)
    fx_streak(d, cx - half * 0.7, cy + 10, cx + half * 0.8, cy + 12, n=3, color=lighten(INK, 0.4), seed=seed + 5)
    for _ in range(3):
        x = cx + rnd.uniform(-half, half)
        d.line([(x, cy + 4), (x + rnd.uniform(-3, 3), cy + 20)], fill=INK, width=2)


def draw_victim(d, cx, cy):
    """处决/终局中的敌方残影（墨色人形）。"""
    d.ellipse([cx - 14, cy - 118, cx + 14, cy - 90], fill=INK)
    d.polygon([(cx - 16, cy - 88), (cx + 16, cy - 88), (cx + 20, cy - 8), (cx - 20, cy - 8)], fill=INK)
    d.line([(cx - 10, cy - 8), (cx - 14, cy)], fill=INK, width=8)
    d.line([(cx + 10, cy - 8), (cx + 14, cy)], fill=INK, width=8)


# ---------------------------------------------------------------- 渲染 ----
WHITE_OVER = {'cloth': WHITE, 'body': WHITE, 'skin': WHITE, 'hair': WHITE,
              'armR': WHITE, 'ink': WHITE, 'prop': None, 'merid': (170, 170, 170)}

LAG = 6


def render_anim(anim, rig, W, H, char, global_idx):
    N = anim['frames']
    loop = anim['loop']
    poses = anim['build']()
    M = 2 * N if loop else 2 * N - 1
    out_dur = quantize(anim['dur_ms'] / M)
    name = anim['name']
    spr_dir = os.path.join(OUT_ASSETS, char, 'Sprites', name)
    os.makedirs(spr_dir, exist_ok=True)
    frames = []
    hist = deque()
    for i in range(M):
        f = i / 2.0
        i0 = int(math.floor(f)) % N
        i1 = (i0 + 1) % N
        t = f - math.floor(f)
        if not loop and i1 < i0:
            pose = dict(poses[i0])
        else:
            pose = interp_pose(poses[i0], poses[i1], t)
        fx = pose.get('fx', 1.0)
        if abs(fx) < 0.98:
            fx = max(min(fx, 1.0), -1.0)
        # velocity 历史
        px = pose['pelvis'][0]
        py = pose['pelvis'][1]
        hist.append((i, px, py))
        if len(hist) > LAG:
            hist.popleft()
        vel = (0.0, 0.0)
        if len(hist) >= 2:
            dt = max(1, hist[-1][0] - hist[0][0]) / 120.0
            vel = ((hist[-1][1] - hist[0][1]) / dt, (hist[-1][2] - hist[0][2]) / dt)
        img = Image.new('RGB', (W, H), BG)
        d = ImageDraw.Draw(img)
        # 后置特效
        apply_fx(d, pose.get('fx_back', []), global_idx * 1000 + i * 50)
        if pose.get('negative'):
            d.rectangle([px - 155, py - 170, px + 155, H], fill=(16, 16, 16), outline=WHITE, width=3)
            rig.draw(d, pose, fx, over=WHITE_OVER, vel=vel, seed=i * 77)
        elif pose.get('inkform'):
            draw_brushline(d, px, H - 20, 260, seed=i * 77)
        else:
            rig.draw(d, pose, fx, over=pose.get('over'), vel=vel, seed=i * 77)
        # 前置特效
        apply_fx(d, pose.get('fx_front', []), global_idx * 1000 + i * 50 + 7)
        path = os.path.join(spr_dir, '%s_%03d.png' % (name, i))
        img.save(path)
        frames.append((path, img))
    # 序列图
    _make_sheet(frames, os.path.join(OUT_SHEETS, char, name + '_sheet.png'))
    _make_gif(frames, os.path.join(OUT_GIFS, char, name + '.gif'), int(round(out_dur)))
    return dict(character=char, name=name, loop=loop, frameCount=M,
                perFrameMs=round(out_dur, 2), durationMs=round(out_dur * M, 2),
                sourceFrames=N)


def _make_sheet(frames, outpath):
    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    w, h = frames[0][1].size
    gap = 3
    sheet = Image.new('RGB', (w * len(frames) + gap * (len(frames) - 1), h), BG)
    x = 0
    for _, img in frames:
        sheet.paste(img, (x, 0))
        x += w + gap
    sheet.save(outpath)


def _make_gif(frames, outpath, dur):
    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    imgs = [im for _, im in frames]
    imgs[0].save(outpath, save_all=True, append_images=imgs[1:],
                 duration=max(10, dur), loop=0, disposal=2)


def main():
    random.seed(42)
    os.makedirs(OUT_ASSETS, exist_ok=True)
    os.makedirs(OUT_SHEETS, exist_ok=True)
    os.makedirs(OUT_GIFS, exist_ok=True)
    anims = build_all()
    rigs = {}
    manifest = []
    gi = 0
    for anim in anims:
        char = anim['char']
        W, H = CANVAS[char]
        if char not in rigs:
            rigs[char] = Rig(STYLE[char], W, H)
        print('[%02d/%02d] %s/%s' % (gi + 1, len(anims), char, anim['name']))
        info = render_anim(anim, rigs[char], W, H, char, gi)
        manifest.append(info)
        gi += 1
    # manifest
    with open(os.path.join(OUT_ASSETS, 'manifest.json'), 'w', encoding='utf-8') as fp:
        json.dump({'sampleRate': 120, 'animations': manifest}, fp, ensure_ascii=False, indent=2)
    print('done:', len(manifest), 'animations, sampleRate=120')


if __name__ == '__main__':
    main()
