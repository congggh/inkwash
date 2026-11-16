"""Build 60 Hz sprite previews and transparent sequences from approved key poses."""
import importlib.util
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(os.environ["TEMP"]) / "inkvoid-motion-deps"))
import cv2
import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parent
OLD = ROOT.parent / "帧动画"
spec = importlib.util.spec_from_file_location("legacy_extract", OLD / "export_frames.py")
legacy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(legacy)
SIZE = (512, 320)
W, H = SIZE
GRID_X, GRID_Y = np.meshgrid(np.arange(W, dtype=np.float32), np.arange(H, dtype=np.float32))

# Cut at ink transformations and between mechanically unrelated poses.
BEAT_CUTS = {
    "pogo_rift": {2, 4, 5},
    "fold_slingshot": {2},
    "parry_ripout": {1, 2, 3},
    "boss_finisher": {1, 3},
    "momei": {2, 4},
    "warden": {3, 4},
    "laborer": {4},
    "magistrate": {4},
    "mozhu": {2, 4},
    "shade": {4},
    "inquisitor": {4},
    "mogu": {2, 4},
    "deacon": {4},
    "praetor": {4},
    "gukuangmo": {1, 4},
}
HERO_VISUAL_FRAMES = {"jump": 13, "slash_combo": 54, "boss_finisher": 16}
GROUNDED = {
    "idle": set(range(8)),
    "run": {0, 1, 2, 4, 5, 6},
    "jump": {0, 1, 6, 7},
    "brake": {0, 1, 2, 3},
    "dash": set(range(6)),
}


def sample_timing(name, ms, count, loop):
    """Sample pose intervals at 60 Hz. Keep real design ms in metadata."""
    if name == "dash":
        return [round(i * 10 / (count - 1)) for i in range(count)], 11
    if name == "slash_combo":
        return [0, 5, 12, 16, 22, 32, 40, 53], 54
    total = sum(ms)
    length = HERO_VISUAL_FRAMES.get(name, round(total * 0.06))
    times = np.cumsum([0] + ms[:-1]) / total
    available = length if loop else length - 1
    ticks = [round(float(t) * available) for t in times]
    for i in range(1, count):
        ticks[i] = max(ticks[i - 1] + 1, min(ticks[i], available - (count - 1 - i)))
    if not loop and name in HERO_VISUAL_FRAMES:
        ticks[-1] = length - 1
    return ticks, length


def foot_x(sprite, rect):
    """Estimate the front planted shoe from the lowest opaque silhouette band."""
    a = np.asarray(sprite.getchannel("A"))
    y0 = max(0, rect[3] - 7)
    _, xs = np.where(a[y0:rect[3]] > 145)
    if not len(xs):
        return sprite.width / 2
    front = xs[xs >= int(np.quantile(xs, 0.7))]
    return float(np.median(front))


def register(name, entries, scale):
    canvases = []
    ground = GROUNDED.get(name, set())
    for i, (sprite, box) in enumerate(entries):
        cropped = sprite.crop(box)
        w, h = (round(cropped.width * scale), round(cropped.height * scale))
        cropped = cropped.resize((w, h), Image.Resampling.LANCZOS)
        anchor = foot_x(sprite, box) if name == "dash" else sprite.width / 2
        if name in GROUNDED:
            bottom_gap = 0 if i in ground else min(25, max(6, sprite.height - box[3] - 18))
        else:
            bottom_gap = min(34, max(0, sprite.height - box[3] - 10))
        x = max(0, min(W - w, round(W / 2 + (box[0] - anchor) * scale)))
        y = max(0, H - h - bottom_gap)
        canvas = Image.new("RGBA", SIZE)
        canvas.alpha_composite(cropped, (x, y))
        canvases.append(np.asarray(canvas).copy())
    return canvases


def premultiplied(frame):
    val = frame.astype(np.float32) / 255
    val[..., :3] *= val[..., 3:4]
    return val


class MotionPair:
    def __init__(self, start, end):
        self.a, self.b = premultiplied(start), premultiplied(end)
        a = self.luminance(self.a)
        b = self.luminance(self.b)
        flow = cv2.DISOpticalFlow_create(cv2.DISOPTICAL_FLOW_PRESET_MEDIUM)
        self.ab = flow.calc(a, b, None)
        self.ba = flow.calc(b, a, None)
        self.overlap = self.flow_overlap()

    @staticmethod
    def luminance(image):
        matte = image[..., :3] + (1 - image[..., 3:4]) * 0.77
        return cv2.cvtColor(np.uint8(matte * 255), cv2.COLOR_RGB2GRAY)

    @staticmethod
    def warp(image, flow, t):
        return cv2.remap(image, GRID_X - t * flow[..., 0],
                         GRID_Y - t * flow[..., 1], cv2.INTER_LINEAR,
                         borderMode=cv2.BORDER_CONSTANT)

    def flow_overlap(self):
        left = self.warp(self.a[..., 3], self.ab, 0.5) > 0.35
        right = self.warp(self.b[..., 3], self.ba, 0.5) > 0.35
        return np.count_nonzero(left & right) / max(1, np.count_nonzero(left | right))

    def tween(self, t):
        left = self.warp(self.a, self.ab, t)
        right = self.warp(self.b, self.ba, 1 - t)
        mixed = (1 - t) * left + t * right
        # At an occlusion, use the nearer drawing instead of double silhouettes.
        # Use a higher threshold for wholly uncovered pixels than painted edges.
        overlap = (left[..., 3] > 0.18) & (right[..., 3] > 0.18)
        chosen = left if t < 0.5 else right
        mixed[~overlap] = chosen[~overlap]
        mixed[..., :3] /= np.maximum(0.002, mixed[..., 3:4])
        return np.uint8(np.clip(mixed * 255 + 0.5, 0, 255))


def animate(keys, ticks, total, loop, cuts):
    result = []
    held = []
    for index, key in enumerate(keys):
        start = ticks[index]
        if index + 1 == len(keys):
            stop = total
            target = keys[0] if loop else key
        else:
            stop = ticks[index + 1]
            target = keys[index + 1]

        pair = None
        if stop - start >= 2 and target is not key and index not in cuts:
            candidate = MotionPair(key, target)
            if candidate.overlap >= 0.48:
                pair = candidate
            else:
                held.append(index + 1)
        result.append(key)
        for local in range(1, stop - start):
            t = local / (stop - start)
            result.append(pair.tween(t) if pair else key)
    return result, held


def soft_background(frame):
    art = Image.fromarray(frame)
    stage = Image.new("RGBA", SIZE, "#dedbd5")
    stage.alpha_composite(art)
    return stage.convert("RGB")


def write_clip(dest, frames, loop, name):
    dest.mkdir(parents=True, exist_ok=True)
    previews = []
    last = len(frames) - 1
    for i, frame in enumerate(frames):
        Image.fromarray(frame).save(dest / f"{i:03d}.png", compress_level=3)
        if name == "dash":
            stage = Image.new("RGBA", (896, H), "#dedbd5")
            stage.alpha_composite(Image.fromarray(frame), (min(360, round(i * 100 / 3)), 0))
            previews.append(stage.convert("RGB"))
        else:
            previews.append(soft_background(frame))
    times = [round((i + 1) * 1000 / 60) - round(i * 1000 / 60) for i in range(len(frames))]
    if not loop:
        times[0] += 340
        times[last] += 520
    previews[0].save(dest / "预览.webp", save_all=True, append_images=previews[1:],
                     duration=times, loop=0, quality=90, method=3)
    if name == "dash":
        slow = [33] * len(previews)
        slow[0] += 340
        slow[-1] += 520
        previews[0].save(dest / "慢放.webp", save_all=True, append_images=previews[1:],
                         duration=slow, loop=0, quality=92, method=3)


def main():
    jobs = {}
    for name, (character, count, ms, loop) in legacy.JOBS.items():
        if name == "dash_ground_fluid":
            name, count, ms = "dash", 6, [30] * 6
        new = ROOT / "关键帧" / (name + ".png")
        previous = OLD / "source" / (name + ".png")
        if name == "dash":
            previous = OLD / "source" / "dash_ground_fluid.png"
        source = new if new.is_file() else previous
        if name == "dash" and source == previous:
            count = 8
            GROUNDED["dash"] = set(range(count))
        entries, warnings = legacy.extract(source, count)
        if len(ms) != count:
            ms = [180 // count] * count
        jobs[name] = (character, count, entries, ms, loop, warnings, source)

    hero_max = max(box[3] - box[1] for character, _, entries, *_ in jobs.values()
                   if character == "01_墨痕" for _, box in entries)
    hero_scale = min(0.94, 308 / hero_max)
    report_path = ROOT / "manifest.json"
    selected = set(sys.argv[1:])
    if selected - jobs.keys():
        raise ValueError(f"Unknown clips: {selected - jobs.keys()}")
    existing = json.loads(report_path.read_text(encoding="utf-8")) if selected and report_path.exists() else []
    report = [clip for clip in existing if clip["clip"] not in selected]
    for name, (character, count, entries, ms, loop, warnings, source) in jobs.items():
        if selected and name not in selected:
            continue
        max_w = max(box[2] - box[0] for _, box in entries)
        max_h = max(box[3] - box[1] for _, box in entries)
        scale = min(496 / max_w, 308 / max_h, hero_scale if character == "01_墨痕" else 1)
        keys = register(name, entries, scale)
        ticks, length = sample_timing(name, ms, count, loop)
        frames, held = animate(keys, ticks, length, loop, BEAT_CUTS.get(name, set()))
        if name in {"idle", "dash"}:
            # A filter can soften the last visible row at a stationary contact.
            # Preserve the registered bottom pixel without adding root travel.
            for frame in frames:
                opaque_rows = np.flatnonzero(np.any(frame[..., 3] > 90, axis=1))
                if len(opaque_rows):
                    offset = H - 1 - opaque_rows[-1]
                    if offset:
                        frame[offset:] = frame[:-offset].copy()
                        frame[:offset] = 0
        dest = ROOT / character / name
        write_clip(dest, frames, loop, name)
        clip = {
            "clip": name, "character": character, "fps": 60,
            "canvas_px": [W, H], "pivot_px": [256, 320],
            "loop": loop, "key_pose_frames_zero_based": ticks, "frames": len(frames),
            "source": source.name, "redrawn_key_poses": source.parent == ROOT / "关键帧",
            "readability_cuts_after_key_one_based": sorted(BEAT_CUTS.get(name, set())),
            "low_overlap_holds_after_key_one_based": held, "source_warnings": warnings,
        }
        if name == "dash":
            clip["gameplay"] = {"duration_ms": 180, "distance_m": 3.6, "speed_m_s": 20,
                                "root_y_delta_m": 0, "invulnerability_ms": 140}
        if name == "slash_combo":
            clip["stage_frame_counts"] = [16, 16, 22]
        (dest / "clip.json").write_text(json.dumps(clip, ensure_ascii=False, indent=2), encoding="utf-8")
        report.append(clip)
        print(name, len(frames), "frames, motion holds", held, flush=True)
    report.sort(key=lambda clip: (clip["character"], clip["clip"]))
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
