# 《留白》(Ink & Void) 序章动作帧动画资源包（Unity）

> 依据 `act_prompt.md` 生成序章四类角色的全部动作帧动画，帧率为文件的 **2 倍（60 → 120 FPS）**。
> 内容按角色分组，可直接导入 Unity 2D 项目使用。

## 一、内容概览

| 角色 | 画布尺寸 | 3D 包络 | 锚点(脚底) | 动画数 |
| :--- | :--- | :--- | :--- | ---: |
| 主角【墨痕】 | 512×320 px | 5.12m×3.20m | (256,320) | 15 |
| 序章杂兵【盲眼巡卒】 | 320×320 px | 3.20m×3.20m | (160,320) | 3 |
| 序章精英【镇峰狱尉】 | 448×384 px | 4.48m×3.84m | (224,384) | 3 |
| 序章Boss【先锋镇将·墨梅】 | 512×448 px | 5.12m×4.48m | (256,448) | 5 |

## 二、目录结构

```
InkWash_Unity动画资源包/
├── Assets/InkWash_Animations/            ← 复制整个文件夹到你的项目 Assets/ 下
│   ├── manifest.json                     ← 动画清单（供编辑器脚本与文档使用）
│   ├── MoHen/                            ← 主角墨痕
│   │   ├── Sprites/<动画>/<动画>_NNN.png   ← 逐帧 PNG（.png.meta 已配好 Sprite 导入）
│   │   └── Clips/<动画>.anim             ← AnimationClip（120 FPS，sprite 换帧）
│   ├── BlindPatrol/  PeakWarden/  MoMei/ ← 其余角色，结构同上
│   └── Editor/InkWashAnimationSetup.cs   ← 一键重建工具（可选）
├── Preview/
│   ├── index.html                        ← 浏览器预览页（120 FPS 播放）
│   ├── gifs/<角色>/<动画>.gif            ← GIF 预览
│   └── sheets/<角色>/<动画>_sheet.png     ← 序列帧大图
├── 帧率与时长对照表.md
└── README.md
```

## 三、导入 Unity 的方法

1. 打开你的 Unity 2D 项目（Unity 2021.3 及以上）。
2. 把 `Assets/InkWash_Animations` 整个文件夹复制进项目的 `Assets/` 目录。
3. 回到 Unity，等待导入完成。所有 PNG 已配置为 **Sprite（Single 模式、脚底 Bottom 锚点、PixelsPerUnit=100）**，
   `.anim` 已配置为 120 FPS 的 sprite 换帧剪辑。
4. （可选）点击菜单 **Tools → InkWash → Rebuild Animation Assets**，脚本会按 manifest 自动重建全部
   AnimationClip 并为每个角色生成 `AnimatorController`（默认状态 = Idle）。这一步可兜底解决不同 Unity
   版本对手写 `.anim` 的导入差异。

### 使用方式（二选一）

- **Animator 方式**：给角色物体挂 `Animator`，指定对应 `AnimatorController`，在代码里 `animator.Play("Run")`。
- **剪辑直用**：把 `Clips/xxx.anim` 直接拖到 `Animator` 窗口或 `Animation` 组件上播放。

## 四、帧率说明（重要）

- 原文件基准 **60 FPS**，本次按要求输出 **120 FPS（2 倍）**。
- 每个原帧插入 1 个中间帧，**帧数翻倍、总时长不变**，剪辑 `sampleRate = 120`。
- 若你实际需要的是“播放速度翻倍”（每帧时长减半），在 Unity 中把 Animator 的 `Speed` 设为 2 即可，无需重新生成。

## 五、关于画面（占位帧说明）

- 本包中的帧图是**程序化生成的水墨风格占位帧**（骨架人偶 + 毛笔笔画 + 战斗特效），用于：
  - 动作节奏 / 帧率 / 时序的正确呈现；
  - 作为美术成品的 **pose 参考与切帧占位**，保证程序逻辑可先行接入。
- 每帧严格满足：中性浅灰底 `#E0E0E0`、脚底贴底边（Bottom-Center 零净空）、无投影、无悬浮血梅。
- 正式美术可直接用 `act_prompt.md` 第三、四部分的 **AI 生图 Prompt** 逐帧生成，然后**同名替换**
  `Sprites/<动画>/` 下的 PNG 即可，动画剪辑无需改动（帧数、尺寸、锚点、时长均已对齐）。

## 六、动画清单

| 角色 | 动画（120 FPS） |
| :--- | :--- |
| 主角【墨痕】 | Idle / Run / Turn / Jump / Dash / RiftGrind / Slash1 / Slash2 / Slash3 / Pogo / Fold / Slingshot / Parry / Finisher / BossFinisher |
| 盲眼巡卒 | Idle / Patrol / Chase |
| 镇峰狱尉 | Idle / Move / Combat |
| 墨梅 | Idle / Glide / Rush / Kneel / Combat |

## 七、工程对齐基准

- Godot 原案 `Sprite3D pixel_size=0.01`，本包用 `PixelsPerUnit=100` 等价映射：`512px = 5.12m`。
- 脚底锚点 `spritePivot = (0.5, 0)`，与文档 `Bottom-Center` 一致。
- 主相机 2.5D 微俯视（Pitch −15°、FOV 36°），帧图已按 15° 俯视角绘制。
