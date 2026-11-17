# -*- coding: utf-8 -*-
"""生成 Unity 动画资源包：.meta、.anim、Editor 脚本、README、对照表、预览页、zip。"""
import os
import json
import uuid
import zipfile
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PKG = os.path.join(ROOT, 'InkWash_Unity动画资源包')
ASSETS = os.path.join(PKG, 'Assets', 'InkWash_Animations')

CHAR_LABEL = {
    'MoHen': '主角【墨痕】',
    'BlindPatrol': '序章杂兵【盲眼巡卒】',
    'PeakWarden': '序章精英【镇峰狱尉】',
    'MoMei': '序章Boss【先锋镇将·墨梅】',
}

CANVAS = {
    'MoHen': (512, 320),
    'BlindPatrol': (320, 320),
    'PeakWarden': (448, 384),
    'MoMei': (512, 448),
}

PNG_META_TMPL = """fileFormatVersion: 2
guid: {guid}
TextureImporter:
  internalIDToNameTable: []
  externalObjects: {{}}
  serializedVersion: 12
  mipmaps:
    mipMapMode: 0
    enableMipMap: 0
    sRGBTexture: 1
    linearTexture: 0
    fadeOut: 0
    borderMipMap: 0
    mipMapsPreserveCoverage: 0
    alphaTestReferenceValue: 0.5
    mipMapFadeDistanceStart: 1
    mipMapFadeDistanceEnd: 3
  bumpmap:
    convertToNormalMap: 0
    externalNormalMap: 0
    heightScale: 0.25
    normalMapFilter: 0
  isReadable: 0
  streamingMipmaps: 0
  streamingMipmapsPriority: 0
  vTOnly: 0
  ignoreMipmapLimit: 0
  grayScaleToAlpha: 0
  generateCubemap: 6
  cubemapConvolution: 0
  seamlessCubemap: 0
  textureFormat: 1
  maxTextureSize: 2048
  textureSettings:
    serializedVersion: 2
    filterMode: 1
    aniso: 1
    mipBias: 0
    wrapU: 1
    wrapV: 1
    wrapW: 1
  nPOTScale: 0
  lightmap: 0
  compressionQuality: 50
  spriteMode: 1
  spriteExtrude: 1
  spriteMeshType: 1
  alignment: 0
  spritePivot: {{x: 0.5, y: 0}}
  spritePixelsToUnits: 100
  spriteBorder: {{x: 0, y: 0, z: 0, w: 0}}
  spriteGenerateFallbackPhysicsShape: 1
  alphaUsage: 1
  alphaIsTransparency: 1
  spriteTessellationDetail: -1
  textureType: 8
  textureShape: 1
  singleChannelComponent: 0
  flipbookRows: 1
  flipbookColumns: 1
  maxTextureSizeSet: 0
  compressionQualitySet: 0
  textureFormatSet: 0
  ignorePngGamma: 0
  applyGammaDecoding: 0
  cookieLightType: 0
  platformSettings:
  - serializedVersion: 3
    buildTarget: DefaultTexturePlatform
    maxTextureSize: 2048
    resizeAlgorithm: 0
    textureFormat: -1
    textureCompression: 1
    compressionQuality: 50
    crunchedCompression: 0
    allowsAlphaSplitting: 0
    overridden: 0
    androidETC2FallbackOverride: 0
    forceMaximumCompressionQuality_BC6H_BC7: 0
  spriteSheet:
    serializedVersion: 2
    sprites: []
    outline: []
    physicsShape: []
    bones: []
    spriteID: 5e97eb03825dee720800000000000000
    internalID: 0
    vertices: []
    indices: 
    edges: []
    weights: []
    secondaryTextures: []
    nameFileIdTable: {{}}
  spritePackingTag: 
  pSDRemoveMatte: 0
  userData: 
  assetBundleName: 
  assetBundleVariant: 
"""

ANIM_META_TMPL = """fileFormatVersion: 2
guid: {guid}
NativeFormatImporter:
  externalObjects: {{}}
  mainObjectFileID: 7400000
  userData: 
  assetBundleName: 
  assetBundleVariant: 
"""


def build_anim_yaml(name, loop, guids, frame_dur_s):
    curve_lines = []
    mapping_lines = []
    for i, g in enumerate(guids):
        t = i * frame_dur_s
        curve_lines.append('    - time: %.6f\n      value: {fileID: 21300000, guid: %s, type: 3}\n' % (t, g))
        mapping_lines.append('    - {fileID: 21300000, guid: %s, type: 3}\n' % g)
    stop = len(guids) * frame_dur_s
    loop_int = 1 if loop else 0
    tpl = """%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!74 &7400000
AnimationClip:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_Name: @NAME@
  serializedVersion: 7
  m_Legacy: 0
  m_Compressed: 0
  m_UseHighQualityCurve: 1
  m_RotationCurves: []
  m_CompressedRotationCurves: []
  m_EulerCurves: []
  m_PositionCurves: []
  m_ScaleCurves: []
  m_FloatCurves: []
  m_PPtrCurves:
  - serializedVersion: 2
    curve:
@CURVES@    attribute: m_Sprite
    script: {fileID: 0}
    path: 
    classID: 212
  m_SampleRate: 120
  m_WrapMode: 0
  m_Bounds:
    m_Center: {x: 0, y: 0, z: 0}
    m_Extent: {x: 0, y: 0, z: 0}
  m_ClipBindingConstant:
    genericBindings:
    - serializedVersion: 2
      path: 0
      attribute: 0
      script: {fileID: 0}
      typeID: 212
      customType: 0
      isPPtrCurve: 1
      isIntCurve: 0
      isSerializeReferenceCurve: 0
    pptrCurveMapping:
@MAPPING@  m_AnimationClipSettings:
    serializedVersion: 2
    m_AdditiveReferencePoseClip: {fileID: 0}
    m_AdditiveReferencePoseTime: 0
    m_StartTime: 0
    m_StopTime: @STOP@
    m_OrientationOffsetY: 0
    m_Level: 0
    m_CycleOffset: 0
    m_HasAdditiveReferencePose: 0
    m_LoopTime: @LOOP@
    m_LoopBlend: 0
    m_LoopBlendOrientation: 0
    m_LoopBlendPositionY: 0
    m_LoopBlendPositionXZ: 0
    m_KeepOriginalOrientation: 0
    m_KeepOriginalPositionY: 1
    m_KeepOriginalPositionXZ: 0
    m_HeightFromFeet: 0
    m_Mirror: 0
  m_EditorCurves: []
  m_EulerEditorCurves: []
  m_HasGenericRootTransform: 0
  m_HasMotionFloatCurves: 0
  m_Events: []
"""
    return (tpl.replace('@NAME@', name)
               .replace('@CURVES@', ''.join(curve_lines))
               .replace('@MAPPING@', ''.join(mapping_lines))
               .replace('@STOP@', '%.6f' % stop)
               .replace('@LOOP@', str(loop_int)))


def gen_meta_and_anim():
    with open(os.path.join(ASSETS, 'manifest.json'), encoding='utf-8') as fp:
        manifest = json.load(fp)
    # 1) 为所有 PNG 生成 .meta，记录 guid
    sprite_guids = {}  # (char, name, i) -> guid
    for anim in manifest['animations']:
        char, name = anim['character'], anim['name']
        spr_dir = os.path.join(ASSETS, char, 'Sprites', name)
        for i in range(anim['frameCount']):
            png = os.path.join(spr_dir, '%s_%03d.png' % (name, i))
            guid = uuid.uuid4().hex
            sprite_guids[(char, name, i)] = guid
            with open(png + '.meta', 'w', encoding='utf-8') as fp:
                fp.write(PNG_META_TMPL.format(guid=guid))
    # 2) 生成 .anim
    for anim in manifest['animations']:
        char, name = anim['character'], anim['name']
        loop = anim['loop']
        frame_dur = anim['perFrameMs'] / 1000.0
        guids = [sprite_guids[(char, name, i)] for i in range(anim['frameCount'])]
        clip_dir = os.path.join(ASSETS, char, 'Clips')
        os.makedirs(clip_dir, exist_ok=True)
        yaml = build_anim_yaml(name, loop, guids, frame_dur)
        with open(os.path.join(clip_dir, name + '.anim'), 'w', encoding='utf-8') as fp:
            fp.write(yaml)
        cguid = uuid.uuid4().hex
        with open(os.path.join(clip_dir, name + '.anim.meta'), 'w', encoding='utf-8') as fp:
            fp.write(ANIM_META_TMPL.format(guid=cguid))
    return manifest


def write_editor_script():
    d = os.path.join(ASSETS, 'Editor')
    os.makedirs(d, exist_ok=True)
    cs = r"""// 《留白》序章动画资源 · 一键重建工具
// 菜单：Tools > InkWash > Rebuild Animation Assets
// 作用：扫描 Sprites 文件夹，按 manifest.json 生成 120FPS 的 AnimationClip 与 AnimatorController。
// 若手写的 .anim 因 Unity 版本差异导入异常，运行本脚本即可自动重建全部动画资源。
#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

namespace InkWashAnim
{
    [System.Serializable]
    public class AnimDef
    {
        public string character;
        public string name;
        public bool loop;
        public int frameCount;
        public float perFrameMs;
        public float durationMs;
        public int sourceFrames;
    }

    [System.Serializable]
    public class AnimManifest
    {
        public int sampleRate;
        public List<AnimDef> animations;
    }

    public static class InkWashAnimationSetup
    {
        const float SampleRate = 120f;
        const string Root = "Assets/InkWash_Animations";

        [MenuItem("Tools/InkWash/Rebuild Animation Assets")]
        public static void Rebuild()
        {
            string manifestPath = Root + "/manifest.json";
            if (!File.Exists(manifestPath))
            {
                Debug.LogError("[InkWash] manifest.json 未找到：" + manifestPath);
                return;
            }
            var manifest = JsonUtility.FromJson<AnimManifest>(File.ReadAllText(manifestPath));
            int built = 0;
            foreach (var group in manifest.animations.GroupBy(a => a.character))
            {
                BuildController(group.Key, group.ToList(), ref built);
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log("[InkWash] 动画资源重建完成，共 " + built + " 个动画（120 FPS）。");
        }

        static void BuildController(string character, List<AnimDef> defs, ref int built)
        {
            string ctrlPath = Root + "/" + character + "/" + character + ".controller";
            var controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(ctrlPath);
            if (controller == null)
                controller = AnimatorController.CreateAnimatorControllerAtPath(ctrlPath);
            var sm = controller.layers[0].stateMachine;
            foreach (var s in sm.states.ToList())
                sm.RemoveState(s.state);
            foreach (var def in defs)
            {
                var clip = BuildClip(def);
                if (clip == null) continue;
                var state = sm.AddState(def.name);
                state.motion = clip;
                state.writeDefaultValues = false;
                built++;
            }
            if (defs.Count > 0)
                sm.defaultState = sm.states[0].state;
            EditorUtility.SetDirty(controller);
        }

        static AnimationClip BuildClip(AnimDef def)
        {
            string clipPath = Root + "/" + def.character + "/Clips/" + def.name + ".anim";
            var clip = AssetDatabase.LoadAssetAtPath<AnimationClip>(clipPath);
            if (clip == null)
            {
                clip = new AnimationClip();
                AssetDatabase.CreateAsset(clip, clipPath);
            }
            clip.frameRate = SampleRate;
            var sprites = LoadSprites(def);
            if (sprites.Count == 0) return null;
            var binding = EditorCurveBinding.PPtrCurve("", typeof(SpriteRenderer), "m_Sprite");
            float frameDur = 1f / SampleRate;
            var keys = new ObjectReferenceKeyframe[sprites.Count];
            for (int i = 0; i < sprites.Count; i++)
                keys[i] = new ObjectReferenceKeyframe { time = i * frameDur, value = sprites[i] };
            AnimationUtility.SetObjectReferenceCurve(clip, binding, keys);
            var settings = AnimationUtility.GetAnimationClipSettings(clip);
            settings.loopTime = def.loop;
            AnimationUtility.SetAnimationClipSettings(clip, settings);
            EditorUtility.SetDirty(clip);
            return clip;
        }

        static List<Sprite> LoadSprites(AnimDef def)
        {
            var list = new List<Sprite>();
            for (int i = 0; i < def.frameCount; i++)
            {
                string p = string.Format("{0}/{1}/Sprites/{2}/{2}_{3:D3}.png",
                    Root, def.character, def.name, i);
                var s = AssetDatabase.LoadAssetAtPath<Sprite>(p);
                if (s == null) Debug.LogWarning("[InkWash] 缺少精灵：" + p);
                else list.Add(s);
            }
            return list;
        }
    }
}
#endif
"""
    with open(os.path.join(d, 'InkWashAnimationSetup.cs'), 'w', encoding='utf-8') as fp:
        fp.write(cs)


def write_docs(manifest):
    by_char = {}
    for a in manifest['animations']:
        by_char.setdefault(a['character'], []).append(a)

    # 帧率与时长对照表
    lines = ['# 《留白》序章动作帧 · 帧率与时长对照表\n',
             '> 基准：原文件 60 FPS（16.67 ms/帧）→ 输出 **120 FPS（8.33 ms/帧）**，即帧率翻倍。',
             '> 做法：每个原帧插入 1 个中间帧（帧数翻倍），**总时长保持不变**，Unity 剪辑 sampleRate=120。\n',
             '| 角色 | 动画 | 原帧数 | 输出帧数(120FPS) | 每帧(ms) | 总时长(ms) | 循环 |',
             '| :--- | :--- | ---: | ---: | ---: | ---: | :---: |']
    for char in ['MoHen', 'BlindPatrol', 'PeakWarden', 'MoMei']:
        for a in by_char[char]:
            loop = '是' if a['loop'] else '否'
            lines.append('| %s | %s | %d | %d | %.2f | %.2f | %s |'
                         % (CHAR_LABEL[char], a['name'], a['sourceFrames'], a['frameCount'],
                            a['perFrameMs'], a['durationMs'], loop))
    lines.append('')
    with open(os.path.join(PKG, '帧率与时长对照表.md'), 'w', encoding='utf-8') as fp:
        fp.write('\n'.join(lines))

    # README
    readme = """# 《留白》(Ink & Void) 序章动作帧动画资源包（Unity）

> 依据 [act_prompt.md] 生成序章四类角色的全部动作帧动画，帧率为文件的 **2 倍（60 → 120 FPS）**。
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
- 正式美术可直接用 [act_prompt.md] 第三、四部分的 **AI 生图 Prompt** 逐帧生成，然后**同名替换**
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
"""
    readme = readme.replace('[act_prompt.md]', '`act_prompt.md`')
    with open(os.path.join(PKG, 'README.md'), 'w', encoding='utf-8') as fp:
        fp.write(readme)


def write_preview(manifest):
    by_char = {}
    for a in manifest['animations']:
        by_char.setdefault(a['character'], []).append(a)

    sections = []
    for char in ['MoHen', 'BlindPatrol', 'PeakWarden', 'MoMei']:
        W, H = CANVAS[char]
        cards = []
        for a in by_char[char]:
            name = a['name']
            fc = a['frameCount']
            dur = a['durationMs']
            loop = 'true' if a['loop'] else 'false'
            frames_js = ','.join(
                "'../Assets/InkWash_Animations/%s/Sprites/%s/%s_%03d.png'" % (char, name, name, i)
                for i in range(fc))
            cards.append("""
        <div class="card">
          <canvas id="cv_%s_%s" width="%d" height="%d" title="点击播放/暂停"></canvas>
          <div class="meta"><b>%s</b><span>%d 帧 · %.0fms%s</span><span class="fps">120 FPS</span></div>
        </div>""" % (char, name, W, H, name, fc, dur, ' · 循环' if a['loop'] else ''))
            cards.append("""<script>
  makePlayer('cv_%s_%s', [%s], %.2f, %s);
</script>""" % (char, name, frames_js, a['perFrameMs'], loop))
        sections.append("""  <section>
    <h2>%s</h2>
    <p class="sub">%d×%d px · 画布底部中心锚点</p>
    <div class="grid">%s
    </div>
  </section>""" % (CHAR_LABEL[char], W, H, ''.join(cards)))

    html = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>《留白》序章动作帧 · 120FPS 预览</title>
<style>
  :root { --bg:#141414; --card:#1f1f1f; --ink:#e8e2d0; --sub:#9a917c; --fps:#c3272b; }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--ink);
         font-family:"Microsoft YaHei",system-ui,sans-serif; }
  header { padding:28px 24px 8px; border-bottom:1px solid #2a2a2a; }
  header h1 { margin:0; font-size:22px; }
  header p { color:var(--sub); margin:8px 0 0; font-size:13px; }
  .wrap { max-width:1200px; margin:0 auto; padding:8px 20px 60px; }
  section h2 { margin:26px 0 2px; font-size:18px; }
  section .sub { color:var(--sub); margin:0 0 14px; font-size:12px; }
  .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:14px; }
  .card { background:var(--card); border-radius:10px; overflow:hidden;
          border:1px solid #2c2c2c; transition:border .15s; }
  .card:hover { border-color:#5a5a5a; }
  .card canvas { display:block; width:100%; height:auto; background:#e0e0e0; cursor:pointer; }
  .card .meta { padding:8px 10px; display:flex; flex-direction:column; gap:2px; font-size:12px; }
  .card .meta b { font-size:13px; }
  .card .meta span { color:var(--sub); }
  .card .meta .fps { color:var(--fps); font-weight:600; }
  .legend { color:var(--sub); font-size:12px; margin:14px 0 0; }
</style>
</head>
<body>
<header>
  <div class="wrap" style="padding-top:0">
    <h1>《留白》(Ink &amp; Void) · 序章动作帧动画</h1>
    <p>帧率：<b style="color:var(--fps)">120 FPS</b>（原文件 60 FPS 的两倍）· 点击画布播放 / 暂停 ·
       浏览器为 60Hz 显示器时会以 60fps 呈现，Unity 内为真实 120 FPS。</p>
  </div>
</header>
<div class="wrap">
@SECTIONS@
  <p class="legend">说明：帧图为程序化水墨占位帧（用于时序与 pose 参考），正式美术可用 act_prompt.md 内的 AI 生图 Prompt 同名替换。</p>
</div>
<script>
function makePlayer(id, srcs, frameMs, loop) {
  var c = document.getElementById(id);
  var ctx = c.getContext('2d');
  var imgs = srcs.map(function(s){ var im=new Image(); im.src=s; return im; });
  var idx = 0, playing = false, acc = 0, last = 0, ready = 0;
  imgs.forEach(function(im, i){
    im.onload = function(){ ready++; if (i === 0) draw(0); };
  });
  function draw(i){ ctx.clearRect(0,0,c.width,c.height); ctx.drawImage(imgs[i],0,0); }
  function tick(ts){
    if (!playing) return;
    if (!last) last = ts;
    acc += ts - last; last = ts;
    while (acc >= frameMs) {
      acc -= frameMs; idx++;
      if (idx >= imgs.length) { if (loop) idx = 0; else { idx = imgs.length-1; playing=false; break; } }
    }
    draw(idx);
    requestAnimationFrame(tick);
  }
  c.addEventListener('click', function(){
    playing = !playing; last = 0;
    if (playing) requestAnimationFrame(tick);
  });
}
</script>
</body>
</html>
"""
    html = html.replace('@SECTIONS@', ''.join(sections))
    os.makedirs(os.path.join(PKG, 'Preview'), exist_ok=True)
    with open(os.path.join(PKG, 'Preview', 'index.html'), 'w', encoding='utf-8') as fp:
        fp.write(html)


def make_zip():
    zip_path = os.path.join(ROOT, 'InkWash_序章动画资源包_v1.0.zip')
    base = os.path.basename(PKG)
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(PKG):
            for f in files:
                fp = os.path.join(root, f)
                arc = os.path.join(base, os.path.relpath(fp, PKG))
                z.write(fp, arc)
    return zip_path


def main():
    manifest = gen_meta_and_anim()
    write_editor_script()
    write_docs(manifest)
    write_preview(manifest)
    zip_path = make_zip()
    print('built meta/anim/editor/docs/preview')
    print('zip:', zip_path)
    print('size: %.1f MB' % (os.path.getsize(zip_path) / 1048576.0))


if __name__ == '__main__':
    main()
