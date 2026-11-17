# -*- coding: utf-8 -*-
"""《留白》(Ink & Void) 序章动作帧 · 水墨人偶渲染核心
程序化水墨风格占位帧：骨架解算 + 毛笔笔画 + 战斗特效。
背景统一 #E0E0E0，角色脚底锁定画布底边（Bottom-Center 零净空）。
"""
import math
import random
from PIL import Image, ImageDraw

BG    = (224, 224, 224)
INK   = (26, 26, 26)
INK2  = (52, 50, 48)
WHITE = (248, 248, 248)
PAPER = (239, 233, 218)
RED   = (195, 39, 43)
GOLD  = (212, 160, 23)
BRONZE= (156, 122, 68)
IRON  = (62, 67, 74)
CHAR  = (32, 30, 29)
CRIM  = (110, 20, 35)
BASALT= (47, 52, 59)
AZUR  = (22, 53, 92)
BLOOD = (122, 31, 31)


def lerp(a, b, t):
    return a + (b - a) * t


def vlerp(a, b, t):
    return (lerp(a[0], b[0], t), lerp(a[1], b[1], t))


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def angle_of(a, b):
    return math.atan2(b[1] - a[1], b[0] - a[0])


def lighten(c, f):
    return tuple(int(v + (255 - v) * f) for v in c)


def darken(c, f):
    return tuple(int(v * (1 - f)) for v in c)


def ik2(p0, p2, l1, l2, bend=1.0):
    d = min(dist(p0, p2), l1 + l2 - 0.5)
    d = max(d, abs(l1 - l2) + 0.5)
    a = math.acos(max(-1.0, min(1.0, (l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d))))
    b = angle_of(p0, p2)
    return (p0[0] + l1 * math.cos(b + bend * a), p0[1] + l1 * math.sin(b + bend * a))


def stroke(d, pts, width, color, outline=None, ow=2.0, feibai=0.0, seed=0):
    pts = [tuple(p) for p in pts]
    if len(pts) < 2:
        return
    if outline:
        d.line(pts, fill=outline, width=int(width + ow * 2), joint='curve')
    d.line(pts, fill=color, width=int(width), joint='curve')
    if feibai > 0:
        rnd = random.Random(seed)
        fc = lighten(color, 0.4)
        for a, b in zip(pts[:-1], pts[1:]):
            ang = angle_of(a, b) + math.pi / 2
            for _ in range(max(2, int(width * feibai))):
                t0, t1 = rnd.random(), rnd.random()
                if t1 < t0:
                    t0, t1 = t1, t0
                off = rnd.uniform(-width * 0.32, width * 0.32)
                p0 = (a[0] + (b[0] - a[0]) * t0 + math.cos(ang) * off,
                      a[1] + (b[1] - a[1]) * t0 + math.sin(ang) * off)
                p1 = (a[0] + (b[0] - a[0]) * t1 + math.cos(ang) * off,
                      a[1] + (b[1] - a[1]) * t1 + math.sin(ang) * off)
                d.line([p0, p1], fill=fc, width=max(1, int(width * 0.18)))


def tapered(d, p0, p1, w0, w1, color, outline=None, ow=2.0):
    ang = angle_of(p0, p1) + math.pi / 2
    c, s = math.cos(ang), math.sin(ang)

    def off(p, w):
        return (p[0] + c * w / 2, p[1] + s * w / 2)

    if outline:
        d.polygon([off(p0, w0 + ow * 2), off(p1, w1 + ow * 2),
                   off(p1, -w1 - ow * 2), off(p0, -w0 - ow * 2)], fill=outline)
    d.polygon([off(p0, w0), off(p1, w1), off(p1, -w1), off(p0, -w0)], fill=color)


# ---------------------------------------------------------------- 特效 ----

def fx_splash(d, x, y, r, n=10, color=INK, seed=0, w=2, flatten=0.55):
    rnd = random.Random(seed)
    for _ in range(n):
        a = rnd.uniform(0, 2 * math.pi)
        rr = rnd.uniform(r * 0.4, r)
        p = (x + math.cos(a) * rr, y + math.sin(a) * rr * flatten)
        q = (p[0] + math.cos(a) * 7, p[1] + math.sin(a) * 7 * flatten)
        d.line([p, q], fill=color, width=w)


def fx_dust(d, x, y, n=8, seed=0, color=(245, 243, 238)):
    rnd = random.Random(seed)
    for _ in range(n):
        dx = rnd.uniform(-12, 12)
        dy = rnd.uniform(4, 18)
        d.line([(x + dx, y), (x + dx * 1.5, y - dy)], fill=color, width=2)


def fx_streak(d, x0, y0, x1, y1, n=4, color=INK, seed=0):
    ang = angle_of((x0, y0), (x1, y1)) + math.pi / 2
    rnd = random.Random(seed)
    for i in range(n):
        off = rnd.uniform(-6, 6)
        p0 = (x0 + math.cos(ang) * off, y0 + math.sin(ang) * off)
        p1 = (x1 + math.cos(ang) * off, y1 + math.sin(ang) * off)
        d.line([p0, p1], fill=color if i % 2 == 0 else lighten(color, 0.45), width=rnd.choice([1, 2]))


def fx_arc(d, cx, cy, r0, r1, a0, a1, color=WHITE, steps=16, seed=0):
    rnd = random.Random(seed)
    outer, inner = [], []
    for i in range(steps + 1):
        a = lerp(a0, a1, i / steps)
        rr = rnd.uniform(r0, r1)
        outer.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
    for i in range(steps, -1, -1):
        a = lerp(a0, a1, i / steps)
        rr = rnd.uniform(r0 * 0.55, r0 * 0.9)
        inner.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
    d.polygon(outer + inner, fill=color)


def fx_droplets(d, pts, color=INK, seed=0):
    rnd = random.Random(seed)
    for p in pts:
        d.ellipse([p[0] - 2, p[1] - 3, p[0] + 2, p[1] + 2], fill=color)
        d.line([p, (p[0] + rnd.uniform(-3, 3), p[1] - 6)], fill=color, width=1)


def fx_butterfly(d, x, y, s=6, seed=0):
    rnd = random.Random(seed)
    c = WHITE
    d.polygon([(x, y), (x - s, y - s * 0.8), (x - s * 0.3, y)], fill=c)
    d.polygon([(x, y), (x + s, y - s * 0.8), (x + s * 0.3, y)], fill=c)
    d.line([(x, y), (x, y + s)], fill=INK, width=1)


def fx_lotus(d, x, y, r=14, color=WHITE):
    for i in range(5):
        a = i * 2 * math.pi / 5
        cx = x + math.cos(a) * r * 0.55
        cy = y + math.sin(a) * r * 0.55
        d.ellipse([cx - r * 0.55, cy - r * 0.38, cx + r * 0.55, cy + r * 0.38],
                  outline=color, width=2)


def fx_ring(d, cx, cy, r, color=WHITE, width=3):
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=color, width=width)


def fx_sparks(d, x, y, n=8, color=GOLD, seed=0):
    rnd = random.Random(seed)
    for _ in range(n):
        a = rnd.uniform(0, 2 * math.pi)
        L = rnd.uniform(6, 16)
        p = (x + math.cos(a) * L, y + math.sin(a) * L * 0.6)
        d.line([(x, y), p], fill=color, width=2)
        d.ellipse([p[0] - 2, p[1] - 2, p[0] + 2, p[1] + 2], fill=color)


def fx_crack(d, x0, x1, y, color=(240, 240, 240), seed=0, amp=3):
    rnd = random.Random(seed)
    n = 8
    pts = []
    for i in range(n + 1):
        t = i / n
        pts.append((lerp(x0, x1, t), y - rnd.uniform(-amp, amp)))
    d.line(pts, fill=color, width=2, joint='curve')


def fx_vortex(d, cx, cy, r, color=INK, turns=2.2, seed=0):
    rnd = random.Random(seed)
    pts = []
    for i in range(40):
        t = i / 39
        a = turns * 2 * math.pi * t
        rr = r * t
        pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr * 0.7))
    d.line(pts, fill=color, width=2, joint='curve')


def fx_sheet(d, x, y, ang, w=40, h=56, color=CHAR, seed=0):
    rnd = random.Random(seed)
    c, s = math.cos(ang), math.sin(ang)
    pts = [(x, y)]
    for i in range(1, 5):
        t = i / 5
        jx = rnd.uniform(-4, 4)
        pts.append((x + s * w * t + jx * c, y + c * w * t - jx * s))
    pts.append((x + s * w + math.cos(ang) * h * 0.4, y + c * w + math.sin(ang) * h * 0.4))
    for i in range(3, -1, -1):
        t = i / 5
        jx = rnd.uniform(-4, 4)
        pts.append((x + s * w * t + math.cos(ang) * h * 0.7 + jx * c,
                    y + c * w * t + math.sin(ang) * h * 0.7 - jx * s))
    d.polygon(pts, fill=color, outline=INK)


def fx_branches(d, x, y, n=8, L=70, color=CHAR, seed=0, spread=1.6):
    rnd = random.Random(seed)
    for i in range(n):
        a = math.pi + rnd.uniform(-spread, spread)
        ln = rnd.uniform(L * 0.5, L)
        tip = (x + math.cos(a) * ln, y + math.sin(a) * ln * 0.7)
        tapered(d, (x, y), tip, 6, 1, color)


def fx_glow_arc(d, cx, cy, r, a0, a1, color=GOLD, width=2):
    pts = []
    for i in range(20):
        a = lerp(a0, a1, i / 19)
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
    d.line(pts, fill=color, width=width, joint='curve')


def fx_glint(d, x0, y0, x1, y1, color=WHITE):
    d.line([(x0, y0), (x1, y1)], fill=color, width=4)
    d.line([(x0, y0), (x1, y1)], fill=RED, width=1)


def fx_thorns(d, x, y, n=5, L=60, color=INK, seed=0):
    rnd = random.Random(seed)
    for i in range(n):
        a = -math.pi / 2 + rnd.uniform(-0.8, 0.8)
        ln = rnd.uniform(L * 0.5, L)
        tip = (x + rnd.uniform(-8, 8) + math.cos(a) * ln, y + math.sin(a) * ln)
        tapered(d, (x + rnd.uniform(-8, 8), y), tip, 7, 1, color)


def fx_vapor(d, x, y, n=3, seed=0):
    rnd = random.Random(seed)
    for _ in range(n):
        rr = rnd.uniform(3, 7)
        d.ellipse([x - rr + rnd.uniform(-8, 8), y - rr * 2,
                   x + rr + rnd.uniform(-8, 8), y + rr * 2], fill=lighten(INK, 0.35))


def fx_char_strokes(d, cx, cy, scale, seed=0, color=INK):
    """巨大狂草题跋字（折/直/藏/休 抽象笔画）。"""
    rnd = random.Random(seed)
    s = scale
    # 横
    tapered(d, (cx - s * 0.7, cy - s * 0.35), (cx + s * 0.7, cy - s * 0.4), s * 0.24, s * 0.1, color)
    # 竖
    tapered(d, (cx, cy - s * 0.7), (cx + s * 0.05, cy + s * 0.6), s * 0.22, s * 0.12, color)
    # 撇
    tapered(d, (cx + s * 0.2, cy - s * 0.5), (cx - s * 0.55, cy + s * 0.5), s * 0.2, s * 0.04, color)
    # 折钩
    tapered(d, (cx - s * 0.5, cy - s * 0.2), (cx - s * 0.05, cy - s * 0.05), s * 0.16, s * 0.12, color)
    d.line([(cx - s * 0.05, cy - s * 0.05), (cx + s * 0.15, cy + s * 0.2)], fill=color, width=int(s * 0.12))
    # 飞白
    fx_streak(d, cx - s * 0.6, cy + s * 0.3, cx + s * 0.6, cy + s * 0.25, n=3, color=lighten(color, 0.4), seed=seed + 1)


def fx_paperfly(d, x, y, n=4, seed=0):
    rnd = random.Random(seed)
    for _ in range(n):
        w = rnd.uniform(4, 9)
        a = rnd.uniform(0, 2 * math.pi)
        d.polygon([(x, y), (x + math.cos(a) * w, y + math.sin(a) * w),
                   (x + math.cos(a + 1.2) * w, y + math.sin(a + 1.2) * w)], fill=WHITE)


# ---------------------------------------------------------------- 骨架 ----

class Rig:
    def __init__(self, st, W, H):
        self.st = st
        self.W = W
        self.H = H
        hf = st['fig_h']
        self.thigh = hf * st.get('thigh_f', 0.29)
        self.shin = hf * st.get('shin_f', 0.29)
        self.upper = hf * st.get('upper_f', 0.24)
        self.fore = hf * st.get('fore_f', 0.24)
        self.pelvis_stand = H - (self.thigh + self.shin)

    # -- 关节解算 ------------------------------------------------------
    def joints(self, pose, fx=1.0):
        st = self.st
        P = pose['pelvis']
        px = P[0]
        m = fx

        def mx(p):
            return (px + (p[0] - px) * m, p[1])

        lean = pose.get('lean', 0.0)
        T = st['torso']
        S = mx((px + math.sin(lean) * T, P[1] - math.cos(lean) * T))
        hw = st['hip_w'] / 2.0
        HL = mx((px - hw, P[1]))
        HR = mx((px + hw, P[1]))
        f0, f1 = mx(pose['feet'][0]), mx(pose['feet'][1])
        h0, h1 = mx(pose['hands'][0]), mx(pose['hands'][1])
        kb = pose.get('knee_bend', 1.0)
        eb = pose.get('elbow_bend', -1.0)
        sm = -1 if m < 0 else 1
        KL = ik2(HL, f0, self.thigh, self.shin, kb * sm)
        KR = ik2(HR, f1, self.thigh, self.shin, kb * sm)
        sw = st['shld_w'] / 2.0
        SL = mx((px - sw, P[1] - T))
        SR = mx((px + sw, P[1] - T))
        EL = ik2(SL, h0, self.upper, self.fore, eb * sm)
        ER = ik2(SR, h1, self.upper, self.fore, eb * sm)
        neck = st['neck']
        ht = pose.get('head_tilt', 0.0)
        Hd = mx((px + math.sin(lean + ht) * (neck + st['head_r'] * 0.6),
                 P[1] - T - neck))
        return dict(P=P, S=S, HL=HL, HR=HR, KL=KL, KR=KR,
                    SL=SL, SR=SR, EL=EL, ER=ER, H=Hd, m=m)

    # -- 单肢体 --------------------------------------------------------
    def limb(self, d, a, k, foot, st, color, w=None, joints=False, seed=0):
        w = w or st['limb_w']
        stroke(d, [a, k, foot], w, color, outline=st['ink'], ow=2.2, feibai=0.3, seed=seed)
        if joints:
            d.ellipse([k[0] - 4, k[1] - 4, k[0] + 4, k[1] + 4], fill=st['ink'])

    # -- 头部 ----------------------------------------------------------
    def head(self, d, j, pose, st, seed):
        Hd = j['H']
        r = st['head_r']
        m = j['m']
        skin = st.get('skin', st['body'])
        d.ellipse([Hd[0] - r, Hd[1] - r, Hd[0] + r, Hd[1] + r], fill=skin, outline=st['ink'], width=3)
        if st.get('blind'):
            d.line([(Hd[0] - r * 0.9, Hd[1] - r * 0.25), (Hd[0] + r * 0.9, Hd[1] - r * 0.25)],
                   fill=BLOOD, width=5)
            d.line([(Hd[0] + r * 0.9, Hd[1] - r * 0.25), (Hd[0] + r * 0.4, Hd[1] + r * 0.5)],
                   fill=BLOOD, width=3)
        elif st.get('helmet'):
            d.ellipse([Hd[0] - r - 4, Hd[1] - r - 6, Hd[0] + r + 4, Hd[1] + r],
                      fill=BRONZE, outline=st['ink'], width=3)
            d.ellipse([Hd[0] - r + 2, Hd[1] - r + 2, Hd[0] + r - 2, Hd[1] + r - 2],
                      fill=darken(BRONZE, 0.3))
            d.line([(Hd[0] + m * (r - 4), Hd[1] - r + 2), (Hd[0] + m * (r + 4), Hd[1] - r + 2)],
                   fill=GOLD, width=3)
        else:
            xa = Hd[0] + m * r * 0.2
            xb = Hd[0] + m * r * 0.7
            d.ellipse([min(xa, xb), Hd[1] - r * 0.3, max(xa, xb), Hd[1] + r * 0.1],
                      fill=st['ink'])
            if st.get('topknot'):
                d.line([(Hd[0] - m * 4, Hd[1] - r), (Hd[0] - m * 8, Hd[1] - r - 14)],
                       fill=st['ink'], width=4)
                d.ellipse([Hd[0] - m * 12, Hd[1] - r - 20, Hd[0] - m * 4, Hd[1] - r - 12],
                          fill=st['ink'])

    def hair(self, d, j, pose, st, vel, seed):
        if not st.get('hair_len'):
            return
        Hd = j['H']
        m = j['m']
        L = st['hair_len']
        vx = vel[0] * 0.5
        tipx = Hd[0] - m * 16 - vx * 1.6
        tipy = Hd[1] + L * 0.4
        pts = [(Hd[0] + m * 8, Hd[1] - 10), (Hd[0] - m * 8, Hd[1] - 6)]
        pts.append((tipx + 6, tipy - 4))
        for k in range(3):
            pts.append((tipx - k * 8, tipy + random.Random(seed + k).uniform(-9, 9)))
        pts.append((Hd[0] + m * 10, Hd[1] + 10))
        pts.append(pts[0])
        d.polygon(pts, fill=st['hair'])

    # -- 大氅 ----------------------------------------------------------
    def cloak(self, d, j, pose, st, vel, seed):
        S = j['S']
        m = j['m']
        L = st.get('cloak_len', 70)
        vx = vel[0] * 0.35
        tipx = S[0] - m * 30 - vx * 2.2
        tipy = S[1] + L - min(0, vx) * 0.2
        rnd = random.Random(seed)
        pts = [(S[0] + m * 6, S[1] - 4)]
        pts.append((S[0] - m * 14, S[1] + L * 0.34))
        pts.append((tipx + 10, tipy - 8))
        for k in range(4):
            pts.append((tipx - k * 9, tipy + rnd.uniform(-11, 11)))
        pts.append((S[0] + m * 4, S[1] + L * 0.3))
        pts.append(pts[0])
        d.polygon(pts, fill=st['cloth'], outline=st['ink'])
        d.line(pts, fill=st['ink'], width=2, joint='curve')
        for k in range(3):
            a = pts[2 + k]
            b = pts[3 + k]
            d.line([a, b], fill=lighten(st['cloth'], 0.35), width=2)

    # -- 长袍下摆 ------------------------------------------------------
    def robe(self, d, j, pose, st, vel, seed):
        P = j['P']
        m = j['m']
        H = self.H
        rnd = random.Random(seed)
        base = P[1] + (H - P[1]) * 0.9
        pts = [(P[0] - m * 10, P[1] - 6), (P[0] + m * 16, P[1] - 2)]
        pts.append((P[0] + m * 34, base + rnd.uniform(-4, 4)))
        pts.append((P[0] + m * 30, H - 2))
        pts.append((P[0] - m * 30, H - 2))
        pts.append((P[0] - m * 34, base + rnd.uniform(-4, 4)))
        pts.append(pts[0])
        d.polygon(pts, fill=st['cloth'], outline=st['ink'])

    # -- 手 ------------------------------------------------------------
    def hands(self, d, j, pose, st):
        for h, name in ((j['EL'], 'L'), (j['ER'], 'R')):
            skin = st.get('skin', st['body'])
            d.ellipse([h[0] - 5, h[1] - 5, h[0] + 5, h[1] + 5], fill=skin, outline=st['ink'], width=2)
            if st.get('mudra') and name == 'L':
                d.line([(h[0], h[1]), (h[0], h[1] - 9)], fill=skin, width=2)
                d.line([(h[0] + 3, h[1]), (h[0] + 3, h[1] - 9)], fill=skin, width=2)

    # -- 兵器 ----------------------------------------------------------
    def prop(self, d, j, pose, st, seed):
        kind = st.get('prop')
        pr = pose.get('prop', {})
        if kind == 'chisel':
            hand = j['ER']
            ang = pr.get('ang', -2.2)
            hlen = st.get('prop_len', 95)
            hw = st.get('prop_w', 10)
            tip = (hand[0] + math.cos(ang) * hlen, hand[1] + math.sin(ang) * hlen)
            tapered(d, hand, tip, hw * 1.15, hw * 0.22, BRONZE, outline=INK, ow=2)
            if pr.get('notch', True):
                nt = vlerp(hand, tip, 0.74)
                d.polygon([(nt[0] - 4, nt[1] - 4), (nt[0] + 2, nt[1] - 3), (nt[0], nt[1] + 4)], fill=BG)
            g = vlerp(hand, tip, 0.09)
            d.line([(g[0] - math.sin(ang) * 8, g[1] + math.cos(ang) * 8),
                    (g[0] + math.sin(ang) * 8, g[1] - math.cos(ang) * 8)], fill=IRON, width=6)
        elif kind == 'ruler':
            hand = j['ER']
            ang = pr.get('ang', 1.4)
            L = st.get('prop_len', 110)
            w = st.get('prop_w', 9)
            tip = (hand[0] + math.cos(ang) * L, hand[1] + math.sin(ang) * L)
            d.line([hand, tip], fill=INK, width=w + 4)
            d.line([hand, tip], fill=IRON, width=w)
            for k in range(1, 7):
                tt = vlerp(hand, tip, k / 7.0)
                d.line([(tt[0] - math.sin(ang) * 4, tt[1] + math.cos(ang) * 4),
                        (tt[0] + math.sin(ang) * 4, tt[1] - math.cos(ang) * 4)], fill=INK, width=2)
        elif kind == 'shield':
            cx, cy = pr.get('pos', j['ER'])
            sh = st.get('shield_h', 210)
            sw = st.get('shield_w', 150)
            d.polygon([(cx - 12, cy - sh / 2), (cx + 12, cy - sh / 2),
                       (cx + 12, cy + sh / 2), (cx - 12, cy + sh / 2)], fill=darken(IRON, 0.25))
            d.polygon([(cx - 12, cy - sh / 2), (cx - 18, cy - sh / 2 - 10),
                       (cx + 18, cy - sh / 2 - 10), (cx + 12, cy - sh / 2)], fill=lighten(IRON, 0.3))
            d.line([(cx - 12, cy - sh * 0.3), (cx + 12, cy - sh * 0.05)], fill=GOLD, width=6)
            d.line([(cx - 12, cy + sh * 0.05), (cx + 12, cy + sh * 0.3)], fill=GOLD, width=6)
            d.rectangle([cx - 12, cy - sh / 2, cx + 12, cy + sh / 2], outline=INK, width=3)
            if pr.get('crackline'):
                d.line([(cx - 12, cy - sh * 0.3), (cx + 8, cy + sh * 0.1)], fill=RED, width=2)
        elif kind == 'rapier':
            hand = j['ER']
            ang = pr.get('ang', -0.2)
            L = st.get('prop_len', 150)
            tip = (hand[0] + math.cos(ang) * L, hand[1] + math.sin(ang) * L)
            mid = vlerp(hand, tip, 0.62)
            mid = (mid[0], mid[1] + pr.get('droop', 6))
            stroke(d, [hand, mid, tip], 3, IRON, outline=INK, ow=1.5)
            d.ellipse([hand[0] - 6, hand[1] - 6, hand[0] + 6, hand[1] + 6],
                      fill=GOLD, outline=INK, width=2)
        elif kind == 'lance':
            hand = j['ER']
            ang = pr.get('ang', -0.4)
            L = st.get('prop_len', 180)
            tip = (hand[0] + math.cos(ang) * L, hand[1] + math.sin(ang) * L)
            tapered(d, hand, tip, 8, 1, darken(IRON, 0.1), outline=INK, ow=2)
            for i in range(3):
                g = vlerp(hand, tip, 0.25 + i * 0.08)
                d.line([(g[0] - math.sin(ang) * 6, g[1] + math.cos(ang) * 6),
                        (g[0] + math.sin(ang) * 6, g[1] - math.cos(ang) * 6)], fill=GOLD, width=2)

    # -- 主绘制 --------------------------------------------------------
    def draw(self, d, pose, fx=1.0, over=None, vel=(0.0, 0.0), seed=0):
        st = dict(self.st)
        st.update(over or {})
        j = self.joints(pose, fx)
        m = j['m']
        back = darken(st['cloth'], 0.16)
        # 后腿 / 后臂
        self.limb(d, j['HR'], j['KR'], pose['feet'][1], st, back, seed=seed + 1)
        self.limb(d, j['HL'], j['KL'], pose['feet'][0], st, back, seed=seed + 2)
        if st.get('cloak'):
            self.cloak(d, j, pose, st, vel, seed + 3)
        # 躯干
        stroke(d, [j['P'], j['S']], st['torso_w'], st['cloth'], outline=st['ink'],
               ow=2.5, feibai=0.4, seed=seed + 4)
        if st.get('merid'):
            for i in range(2):
                off = (i - 0.5) * 7
                stroke(d, [(j['P'][0] + off, j['P'][1] + 8), (j['S'][0] + off, j['S'][1] - 8)],
                       2, st['merid'], seed=seed + 5 + i)
        # 前腿 / 前臂
        armR = st.get('armR', st['cloth'])
        self.limb(d, j['SR'], j['ER'], pose['hands'][1], st, armR, seed=seed + 6)
        self.limb(d, j['SL'], j['EL'], pose['hands'][0], st, st['cloth'], seed=seed + 7)
        if st.get('robe'):
            self.robe(d, j, pose, st, vel, seed + 8)
        self.hair(d, j, pose, st, vel, seed + 9)
        self.head(d, j, pose, st, seed + 10)
        self.hands(d, j, pose, st)
        self.prop(d, j, pose, st, seed + 11)
        return j
