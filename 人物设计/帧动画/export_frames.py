"""Extract transparent keyframes and APNG previews from the character sheets."""
import json
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parent
JOBS = {
    "idle": ("01_墨痕", 8, [133] * 8, True),
    "run": ("01_墨痕", 8, [67] * 8, True),
    "brake": ("01_墨痕", 4, [67] * 4, False),
    "jump": ("01_墨痕", 8, [65, 45, 55, 70, 70, 55, 45, 80], False),
    "dash_ground_fluid": ("01_墨痕", 8, [67, 50, 33, 17, 50, 33, 50, 83], False),
    "slash_combo": ("01_墨痕", 8, [67, 83, 117, 84, 183, 117, 100, 150], False),
    "pogo_rift": ("01_墨痕", 8, [33, 100, 67, 50, 50, 67, 50, 80], False),
    "fold_slingshot": ("01_墨痕", 6, [67, 83, 90, 50, 67, 83], False),
    "parry_ripout": ("01_墨痕", 8, [33, 67, 260, 117, 50, 70, 60, 80], False),
    "boss_finisher": ("01_墨痕", 8, [65, 70, 50, 50, 50, 50, 320, 90], False),
    "jailer": ("02_盲眼巡卒", 6, [240, 120, 640, 120, 180, 240], False),
    "warden": ("03_镇峰狱尉", 6, [240, 600, 400, 260, 280, 260], False),
    "momei": ("04_墨梅", 6, [240, 220, 170, 240, 180, 420], False),
    "laborer": ("05_巡水工偶", 6, [240, 430, 170, 160, 150, 240], False),
    "magistrate": ("06_伏波画督", 6, [240, 400, 240, 160, 260, 280], False),
    "mozhu": ("07_墨竹", 6, [240, 460, 170, 240, 230, 400], False),
    "shade": ("08_守碑阴傀", 6, [240, 180, 700, 150, 230, 360], False),
    "inquisitor": ("09_司弦刑官", 6, [240, 500, 100, 230, 260, 300], False),
    "mogu": ("10_墨骨", 6, [240, 500, 150, 280, 230, 420], False),
    "deacon": ("11_去色司祝", 6, [240, 150, 560, 170, 230, 300], False),
    "praetor": ("12_平规衡司", 6, [240, 260, 220, 220, 260, 300], False),
    "gukuangmo": ("13_顾狂墨", 6, [260, 200, 220, 200, 260, 420], False),
}


def alpha_key(rgb):
    """Key near-neutral gray while protecting ink and bright white paper."""
    values = rgb.astype(np.float32)
    luminance = values.mean(axis=2)
    chroma = np.ptp(values, axis=2)
    border = np.concatenate((luminance[:, :6].ravel(), luminance[:, -6:].ravel()))
    background = float(np.median(border))
    difference = np.maximum(abs(luminance - background), chroma * 1.25)
    alpha = np.clip((difference - 12) / 23, 0, 1)
    alpha[(chroma < 13) & (luminance >= background - 14)
          & (luminance <= background + 13)] = 0
    alpha[luminance > background + 18] = 1
    return np.round(alpha * 255).astype(np.uint8), background


def divisions(projection, count):
    """Find nearby empty gutters around the requested regular grid."""
    size = len(projection)
    bounds = [0]
    for index in range(1, count):
        expected = index * size / count
        radius = max(8, int(size / count * 0.18))
        options = np.arange(max(bounds[-1] + 10, int(expected) - radius),
                            min(size, int(expected) + radius + 1))
        cost = projection[options] + 0.06 * abs(options - expected)
        bounds.append(int(options[np.argmin(cost)]))
    return bounds + [size]


def extract(source, count):
    rgb = np.asarray(Image.open(source).convert("RGB"))
    alpha, background = alpha_key(rgb)
    solid = alpha > 100
    height, width = solid.shape
    bounds_y = divisions(solid.sum(axis=1), 2)
    result, warnings = [], []
    if background < 195 or background > 237:
        warnings.append(f"source background measured {background:.0f}")
    for top, bottom in zip(bounds_y, bounds_y[1:]):
        columns = divisions(solid[top:bottom].sum(axis=0), count // 2)
        for left, right in zip(columns, columns[1:]):
            mask = alpha[top:bottom, left:right]
            pixels = np.dstack((rgb[top:bottom, left:right], mask))
            frame = Image.fromarray(pixels)
            box = frame.getbbox()
            if box is None or (mask > 100).mean() < 0.01:
                raise ValueError(f"frame {len(result) + 1} is empty")
            if box[0] < 3 or box[2] > frame.width - 3 or box[1] < 3 or box[3] > frame.height - 3:
                warnings.append(f"frame {len(result) + 1}: artwork touches cell edge")
            result.append((frame, box))
    return result, warnings


def playback(frames, durations, loops, path):
    previews = []
    dash_travel = [0, 4, 34, 83, 147, 187, 204, 207]
    for index, frame in enumerate(frames):
        if path.parent.name == "dash_ground_fluid":
            # Preview world travel separately from the in-place source sprites.
            sprite = frame.copy()
            sprite.thumbnail((350, 300), Image.Resampling.LANCZOS)
            matte = Image.new("RGBA", (580, 305), "#e0e0e0")
            matte.alpha_composite(sprite, (10 + dash_travel[index], 300 - sprite.height))
            previews.append(matte.convert("RGB"))
            continue
        matte = Image.new("RGBA", frame.size, "#e0e0e0")
        matte.alpha_composite(frame)
        matte.thumbnail((500, 430), Image.Resampling.LANCZOS)
        previews.append(matte.convert("RGB"))
    times = durations.copy()
    if not loops:
        times[0] += 250
        times[-1] += 650
    previews[0].save(path, save_all=True, append_images=previews[1:],
                     duration=times, loop=0, disposal=0)
    # Also supply a GIF for viewers that display only the first frame of APNG.
    previews[0].save(path.with_suffix(".gif"), save_all=True,
                     append_images=previews[1:], duration=times, loop=0, disposal=2)


def main():
    assets = {}
    report = {"missing": [], "failed": {}, "clips": []}
    for name, (character, count, durations, loops) in JOBS.items():
        source = ROOT / "source" / f"{name}.png"
        if not source.is_file():
            report["missing"].append(name)
            continue
        try:
            frames, warnings = extract(source, count)
        except (OSError, ValueError) as error:
            report["failed"][name] = str(error)
            continue
        assets.setdefault(character, []).append((name, frames, warnings, durations, loops))

    for character, clips in assets.items():
        # Keep a common canvas and pixel scale across all clips for a character.
        width = max(frame.width for _, frames, *_ in clips for frame, _ in frames) + 24
        height = max(frame.height for _, frames, *_ in clips for frame, _ in frames) + 24
        for name, entries, warnings, durations, loops in clips:
            path = ROOT / character / name
            path.mkdir(parents=True, exist_ok=True)
            frames = []
            for index, (sprite, box) in enumerate(entries):
                frame = Image.new("RGBA", (width, height))
                x = (width - sprite.width) // 2
                # Airborne sequences retain the drawn vertical offsets.
                y = height - sprite.height - 12
                if name in {"idle", "dash_ground_fluid"}:
                    y = height - box[3] - 12
                frame.alpha_composite(sprite, (x, y))
                frame.save(path / f"{index + 1:02}.png")
                frames.append(frame)
            playback(frames, durations, loops, path / "preview.png")
            clip = {
                "character": character, "clip": name, "frames": len(frames),
                "canvas_px": [width, height], "pivot_px": [width // 2, height - 12],
                "duration_ms": durations, "loop": loops, "warnings": warnings,
            }
            (path / "clip.json").write_text(json.dumps(clip, ensure_ascii=False, indent=2), encoding="utf-8")
            report["clips"].append(clip)

    (ROOT / "manifest.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Exported {len(report['clips'])} clips / {len(assets)} characters")
    print("Missing:", ", ".join(report["missing"]))
    print("Failed:", report["failed"])


if __name__ == "__main__":
    main()
