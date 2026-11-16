# 《留白》（Ink & Void）场景原画与《ICEY》式 2.5D 舞台工程全典

## 【转】第二章：飞白苍凉 · 枯笔断魂（2.5D 舞台重构版）

> **【主美执行总则与《ICEY》式 2.5D 舞台宪章】**：
> “水尽墨枯，笔锋见骨。
> 世人皆以为执笔阁将天下反叛画圣削骨削肉镇压于此，筑成了一座座倒插在狂沙之中的无名黑色荒冢；
> 却不知在被抽干一切水分的古宣底稿深处，每一座倒插的石碑，都是一位抱瑟傲立的上古乐仙；每一根紧绷嗜血的生铁绞索，都是流淌着千古绝响的黄金工尺音律天路！
> 表层是极尽干燥、风化脱水、如铁如炭的**焦墨画冢与嗜血铁瑟戏台**；
> 里层则是万圣先烈未曾屈服的**《天籁遗音·韶乐总谱》万仙抚琴雅集**——空灵、苍茫、至真至纯，通体由 `$0.25\ \text{mm}$` 汉金石单线铁线描勾勒，浮动着千年硬黄古纸的坚韧帘纹。
> 镜头全面升级为《ICEY》（艾希）标志性的**长焦窄视角微俯视 2.5D 舞台透视**（`FOV = 26° ~ 28°`，微俯角 `Pitch = -2.5° ~ -8.5°`）：所有碰撞与踩弦判定严格死锁于 `$Z = 0$` 平面，微俯视角清晰展现龟裂焦土宽度、倒插墓碑顶面厚度与深渊峡谷的纵深落差，在断弦如雷与流沙飞石中演出一场斩断血弦、踏谱化龙的苍凉史诗。”

---

# 第一部分：Godot 4 真 3D 空间 2.5D 舞台与动态渲染规范

```text
├── Layer -2 (Z = +4.5m ~ +7.5m): 极近景黑色剪影遮挡 (倒插断碑棱角/崩断钢弦/飞白枯枝，压四角暗角)
├── Layer -1 (Z = +1.5m ~ +3.0m): 近景动态微粒层 (GPUParticles3D / Sprite3D：焦墨石粉/流沙/断弦火星)
│
├── Layer  0 (Z =  0.0m 绝对锁定): 主战斗与戏台平面 (下 1/3 横剖面 + XZ 平面铺设 3.5m~5.0m 立体碑顶/琴台)
│
├── Layer +1 (Z = -4.0m ~ -9.0m): 次近景舞台布景 (破损汉白玉石匣/断裂生铁排箫/乐仙石雕裙裾)
├── Layer +2 (Z = -22m ~ -45m)  : 中远景长卷主体 (万座倒插黑色无字巨碑 / 里层通天白描韶乐编钟仙楼)
├── Layer +3 (Z = -85m ~ -140m) : 极远景天顶气象 (干裂苍白铅云/天门死霜/万道上古韶乐星轨，叠加逐材质雾)
└── Layer +4 (Z = -180m 巨幅天幕): 底层宣纸胎体天幕 (固定不动的 4K 陈化干裂硬黄古纸帘纹暗斑)
```

## 1.1 《ICEY》式 2.5D 舞台机位四大核心模式（Godot 4 `StageCamera3D`）

全章统一采用 `Projection = Perspective` 透视摄像机配合全局贴图比例 `pixel_size = 0.01`（`$Z = 0$` 交互面与 `$1080\text{p}$` 屏幕像素 `$1:1$` 对齐）：

| 模式类别 | `Cam Z` 纵深 / `FOV` | 高度偏移 `Offset Y` 与微俯角 `Pitch` | 阻尼系数（`$X / Y$`） | 适用场景与戏剧演出表达 |
| :--- | :--- | :--- | :--- | :--- |
| **2.5D 画冢流沙探索** | **`+22.8m ~ +25.2m`** / `FOV = 28°` | `Offset Y = +2.2m`；`Pitch = -6.5°` | `$X = 0.15, Y = 0.25$` | 幕 2-1 至 幕 2-7。微俯角展现龟裂荒原与倒插碑顶厚度，启用落地 `$Y$` 轴锚点吸附与冲刺 `Cam Z` 后退（`$+1.8\ \text{m}$`）。 |
| **拓碑古瑟剧场决斗** | **`+17.0m`** / `FOV = 26°` | `Offset Y = +1.8m`；`Pitch = -5.5°` | `$X = 0.05, Y = 0.08$`（死区归零） | 幕 2-3 司弦刑官战与 幕 2-9 墨骨一阶段。左右拓碑屏风或沥青火柱如大幕锁死舞台，`$6:4$` 非对称构图配合长鞭距离自适应后退。 |
| **断弦飞跃与万仙空战** | **`+23.5m ~ +27.5m`** / `FOV = 28°` | 空战 `Offset Y = +3.6m`；`Pitch = -2.5° ~ -8.5°` | `$X = 0.15 \sim 0.20, Y = 0.10 \sim 0.20$` | 幕 2-4 踏弦峡谷、幕 2-5 `$45^\circ$` 弹射、幕 2-8 崩解绝壁与 幕 2-10 墨骨无地面水袖空战（空战调平俯角释放头顶留白）。 |
| **狂草“藏”字电影处决** | **`+13.0m`** / `FOV = 24°` | 死锁长刀贯碑交接点；`Pitch = -3.0°` | `$X = 0.00, Y = 0.00$`（无插值瞬切） | 幕 2-10 墨骨终极处决。压入 `$2.39:1$` 电影宽银幕黑边，全屏反相为底黑线白的金石拓片负片。 |

## 1.2 第二章 3D 空间长卷无缝循环、渲染排序与防重复机制

* **3D 空间长卷无缝循环（`InfiniteScroll3D`）**：
  * 万座倒插墓碑中远景面片（`Sprite3D`）按世界单位宽度 `$40.96\ \text{m}$`（`$4096\ \text{px}$`）队列循环调度；中景残破生铁编钟与断壁面片按 `$20.48\ \text{m}$`（`$2048\ \text{px}$`）无缝循环拼接，导入启用 `Linear Mipmap` 与 `Clamp` 采样，消除横向横移时的枯笔飞白闪烁与拼接黑线。
* **双 `SubViewport` 与深度缓冲排序**：
  * 表里两套 3D 场景共享同一 `Camera3D` 变换矩阵；硬边缘 `Sprite3D` 启用 `Alpha Cut = Discard` 写入深度缓冲，半透明黑色流沙瀑布与冷灰光束设为 `Blend Mode = Add` 并按 `$Z$` 轴递增设置 `Render Priority`。
* **破除长卷重复感四大工程机制**：
  1. **DECO 非周期贴花**：在倒插石碑与干裂地表投射干燥焦墨龟裂纹、风化石皮剥落与暗红朱砂古篆残印。
  2. **次级独立地标覆盖层**：每隔 `$5.0\ \text{m} \sim 8.0\ \text{m}$`（`$500\ \text{px} \sim 800\ \text{px}$`）穿插不可复用的独立道具（半埋流沙的汉白玉石匣、砸裂排箫、断裂生铁断瑟、乐仙断臂石雕）。
  3. **Verlet 动态垂挂物理**：悬空紧绷的生铁琴弦与崩断钢丝绑定弹簧骨骼，受峡谷风暴驱动产生 `$2.5\ \text{Hz}$` 高频微颤，角色踩踏时触发大幅弯曲回弹。
  4. **跨层流沙瀑布与追光阻断**：在 `$Z = -2.0\ \text{m} \sim +2.0\ \text{m}$` 穿插垂直倾泻的黑色流沙瀑布与斜向光束，隔断循环周期记忆。

## 1.3 第二章三大立体渲染技法与“刮白”逐材质 Shader 动态联动

1. **空气透视与色彩衰减（Atmospheric Perspective）—— 枯笔沙暴双轨瞬切**：
   * **表层常规态**：通过逐材质 `SpatialShader` 根据节点 `$Z$` 轴深度（`$Z = -22\ \text{m} \sim -140\ \text{m}$`），将中远景图层向第二章主色调**干裂焦墨沙灰（`#2B2A27`）**混合 **`$35\% \sim 60\%$`**，使远方上万座倒插墓碑融入苍凉沙尘雾霭，确保 `$Z = 0$` 主角的凌厉刀光与琴弦判定线清晰剥离。
   * **【刮白瞬切联动】**：挥刀“刮白”撕开表层枯墨布景时，Shader 采样屏幕空间撕裂遮罩，撕裂区域内部的空气透视在 **`$0.15\ \text{s}$`** 内瞬切为**温润御用硬黄古宣漫射天光（雾气混合度降至 `$< 5\%$`）**，表层沙灰瘴雾散去，里层清雅的盛唐韶乐仙阁与万仙抚琴图景通透浮现。
2. **动态前景暗影框定（Foreground Framing）—— 断碑钢弦掠过与破幕消融**：
   * **表层常规态**：在 `$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$` 布置纯黑倒插断碑棱角与崩断卷曲的生铁琴弦剪影。角色冲刺或 `$45^\circ$` 超音速弹射时，前景剪影高速掠过屏幕边缘，放大苍凉凌厉的速度感。
   * **【破幕消融联动】**：在“刮白”撕裂窗口内，遮挡视线的断碑与钢弦暗影同步触发 Shader **水墨消融（Alpha Dissolve）**，转化为极淡的游丝白描琴弦或暂时隐去，保障里层工尺音符天路的无遮挡跳跃视野。
3. **跨层体积光（Volumetric Light Shafts）—— 裂缝透光与音律天路指引**：
   * **表层常规态**：在 `$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$` 穿插 `Blend Mode = Add` 的冷灰沙尘丁达尔光束，缝合碑林与深渊图层。
   * **【裂缝追光联动】**：劈开表层拓碑断壁或焦石障壁后，体积光束直接从画布撕裂裂缝迸射，精准打亮里层转化出的安全落脚结构（浮空工尺律吕天阶、白描玉磬石台与万仙水袖飘带）。

## 1.4 2.5D 微俯视透视下的 `$Z = 0$` 机制碰撞中心线校准

针对第二章 `$5.5^\circ \sim 8.5^\circ$` 微俯视角下极细琴弦与破碎石块的判定精度要求，全章交互机关必须严格执行以下 `$Z = 0$` 视觉靶心校准：

* **紧绷猩红生铁琴弦（幕 2-2 / 2-4 / 2-5）**：所有可踩踏或可斩断弹射的琴弦，其物理碰撞线（`CollisionShape3D`）与视觉渲染中心必须**严格居中锁定于 `$Z = 0$` 平面**，弦身叠加高频猩红高光（`#FF3B3F`）与微幅声波震颤粒子，彻底消除微俯视角下细弦的“踩空错觉”。
* **倒插墓碑顶面与崩塌落石（幕 2-2 / 2-8）**：碑顶与下坠焦石在 `XZ` 平面呈现 `$3.5\ \text{m}$` 立体厚度，但**`$Z = 0$` 前沿踩踏锋线必须刻画高对比白描飞白高光边缘**，作为空中下劈（Pogo）与落脚的绝对视觉基准。

---

# 第二部分：第二章全 10 幕与跨章过渡 2.5D 舞台场景工程全典

```text
[幕 2-1: 荒冢入口] ──► [幕 2-2: 倒插墓碑林] ──► [幕 2-3: 拓碑断壁] ──► [幕 2-4: 枯笔风沙峡谷]
 (脱水焦土/万仙琴案)   (紧绷血弦/韶乐总谱)    (司弦刑官/古瑟仙像)   (Z=0红弦靶心/工尺天路)
        │
        ▼
[幕 2-5: 残瑟断头台] ──► [幕 2-6: 万古碑廊] ──► [幕 2-7: 韶乐金钟废墟] ──► [幕 2-8: 崩解绝壁]
 (45°超音速弹射)       (凿烂画圣志/金石刻心)  (音波共鸣/编钟悬楼)      (踩落石/水袖踏云)
        │
        ▼
[幕 2-9: 司碑古坛 (墨骨I)] ──► [幕 2-10: 凌空裂渊 (墨骨II/III)] ──► [幕 T-1/T-2: 狂草化龙破门 (跨章过渡)]
 (拆面断鞭/砸碎地面)            (水袖空战/调平俯角/题跋“藏”)        (千丈墨龙垂直冲霄撞碎铅白天门)
```

---

## 幕 2-1：荒冢入口（断碑迎风）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.8m`，`FOV = 28°`，`Offset Y = +2.2m`，微俯角 `Pitch = -6.5°`，阻尼 `$X = 0.15, Y = 0.25$`。
* **戏剧演戏演出**：主角自瀑布干涸深坑爬出，镜头微俯角展现龟裂焦土向内延伸的荒原纵深与下方地层横剖面；风卷炭灰斜掠镜头，烘托水尽墨枯的死寂苍凉。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝水死域）**：纯度极高的焦墨与骨灰混合脱水硬化地表，布满龟甲状裂缝，`$Z = 0$` 路面边缘保留清晰焦石锋线；入口横立十丈无名残碑，铭文被生铁錾暴力凿烂。
* **里层白描宣纸底稿（Baimiao Draft: 韶乐迎仙门）**：展现唐代御用硬黄陈化古宣（`#F4E8C1`），残碑化为【盛唐太虚韶乐第一仙门】，碑基显露一对席地抚瑟的白描单线汉白玉童子仙雕，地面裂缝化为流淌金石暖芒的《韶乐总谱》工尺字迹。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6.5-degree elevated top-down angle showing visible cracked black earth floor depth and walkway width, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 2-1 Desolate Tombs Entrance.
- THEME: Bleak dried-up wasteland of cracked black charred-ink earth with shattered white marble steles chiseled blank and locked with iron chains.
- FOREGROUND: Defocused fractured stele corners in sharp black silhouette with dry-brush feibai edges framing the screen corners.
- MIDDLE-GROUND (Playable Stage): Desiccated black earth pavement showing clear surface breadth, eroded stone steps, charcoal ash dust drifts.
- BACKGROUND: Monolithic upside-down steles receding into hazy lead-grey dust storm horizon on aged imperial hard-yellow Xuan paper texture (#F4E8C1).
- PALETTE: Charcoal black (#0A0908), dull bone grey, parched yellow Xuan paper (#F4E8C1). Seamless horizontal composition --ar 21:9
```

---

## 幕 2-2：倒插墓碑林（流沙与血弦）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +25.2m`，`FOV = 28°`，微俯角 `Pitch = -6.0°`，广角微俯视同时呈现倒插墓碑顶面平台纵深与横跨舞台的猩红琴弦网格。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝望画冢荒原）**：倒插墓碑四方碑底朝天充当平台（**`$Z = 0$` 前沿刻画白描飞白高光锋线**）；横跨视野的四根猩红生铁古瑟琴弦（`#8C1D20`）居中锁定于 `$Z = 0$` 平面，在暴风中高频震颤。
* **里层白描宣纸底稿（Baimiao Draft: 韶乐万仙雅集）**：**表层每座倒插死碑在里层 `$1:1$` 对应的位置，全是一位位抱瑟而立的白描单线乐仙石雕**；倒插碑底化为雕花汉白玉琴案，嗜血铁弦转化为流淌淡金微光的【浮空工尺律吕天路】。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6-degree elevated angle showing the square tops of inverted black tombstones and chasm depth, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 2-2 Inverted Stele Graveyard.
- THEME: Desolate canyon filled with thousands of inverted black tombstones acting as platforms, spanned by tense vibrating blood-red raw iron zither strings, and black sand cascades.
- FOREGROUND: Sharp jagged edges of inverted steles and vibrating crimson cables framing the screen borders.
- BACKGROUND: Endless forest of upside-down black monoliths piercing a bleak lead-grey dust storm sky.
- PALETTE: Pitch black (#0A0908), parched bone white, dried cinnabar rust red (#8C1D20). Seamless horizontal composition --ar 21:9
```

---

## 幕 2-3：拓碑断壁（精英怪：司弦刑官战）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +17.0m`，`FOV = 26°`，`Offset Y = +1.8m`，微俯角 `Pitch = -5.5°`，阻尼 `$X = 0.05, Y = 0.08$`（死区归零）。
* **戏剧演戏演出**：踏入拓碑石室 `Area3D` 时，左右两侧高达 `$8.0\ \text{m}$` 的生铁拓碑屏风如剧场大幕轰然合拢锁死视野，顶部 `SpotLight3D` 体积追光打亮玄武岩台面；精准弹反司弦刑官断头古瑟触发音爆震屏与 `Cam Z` 瞬推至 `+15.2m` 黑白抽色特写。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 夺命铁瑟）**：泼满高黏度浓黑油墨的玄武岩平台展现湿润反光纵深，刑官挥舞改装断头瑟刃释放割裂地面的猩红音波刃。
* **里层白描宣纸底稿（Baimiao Draft: 司乐考律仙台）**：显现【盛唐大司乐考工仙台】，拓碑石壁化为悬浮的白描编钟、特磬与排箫楼阁，刑官体内提线化作飞天琴弦解脱。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle revealing glossy wet black rubbing-ink basalt floor depth, towering iron stele-rubbing screens framing the far left and right edges like theater curtains, fluttering black-and-white stone rubbings framing the top border, dramatic volumetric stage spotlights, inspired by ICEY and Wu Shan Wu Xing, Stage 2-3 Stele Rubbing Duel.
- THEME: Claustrophobic execution chamber with heavy iron stamping hammers, sonic wave distortion trails, and walls hung with martyrs' epitaph rubbings.
- PALETTE: Jet black ink (#0A0908), weathered limestone grey, crimson wire glow (#8C1D20). --ar 16:9
```

---

## 幕 2-4：枯笔风沙峡谷（踏弦飞跃）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +23.5m`，`FOV = 28°`，微俯角 `Pitch = -8.5°`，加大俯角同时纳入三根悬空琴弦的落脚高度差与深渊底部的黑色尘暴。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 裂风杀戮弦）**：跨度 `$500\ \text{px}$` 的无底风沙深渊，横跨三根不同高低的紧绷生铁琴弦跳板（**严格居中于 `$Z = 0$` 平面并叠加猩红高频高光 `#FF3B3F`**，确保微俯角下精准踏弦）。
* **里层白描宣纸底稿（Baimiao Draft: 天风环佩仙台）**：显现【天风环佩白描律吕天廊】，紧绷铁弦化为黄金工尺古谱构筑的悬空律吕天阶，踩踏奏出宫商角徵羽清澈音律。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with an 8.5-degree elevated top-down angle showing fragile feibai cliff ledge thickness and deep chasm drop, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 2-4 The Feibai Chasm.
- THEME: 500-pixel bottomless wind chasm spanned by three glowing crimson-highlighted steel zither cables acting as tightrope platforms, surrounded by whistling charcoal sandstorms.
- FOREGROUND: Whistling charcoal sandstorm particles and shredded paper fibers framing the screen borders.
- BACKGROUND: Wind-eroded canyon walls textured with violent dry brushstrokes fading into a bottomless black ink abyss.
- PALETTE: Desiccated charcoal black (#0A0908), bleached bone grey, bright crimson wire highlight (#FF3B3F). --ar 16:9
```

---

## 幕 2-5：残瑟断头台（`$45^\circ$` 绝命断弦弹射机制）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +24.5m`，`FOV = 28°`，微俯角 `Pitch = -7.0°`。斩断主弦触发 **`$32.0\ \text{m/s}$`** 超音速弹射瞬间，前瞻视野向右上 `$45^\circ$` 偏置并同步拉远 `Cam Z` 至 `+26.5m`，前景断弦火星高速掠屏制造飞翔张力。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝命断头瑟）**：长达 `$15\ \text{m}$`、呈 `$45^\circ$` 仰角斜插悬崖的巨型生铁古瑟，微俯角展现瑟身宽阔琴面纵深；**`$Z = 0$` 轴线上的血红绞紧主弦泛高频红芒**，斩断后爆发出横贯屏幕的暗红朱砂火星束。
* **里层白描宣纸底稿（Baimiao Draft: 九霄环佩神瑟）**：断头瑟转化为【盛唐太虚九霄环佩古瑟】白描真容，生铁断口还原为神圣单线凤首，反冲动能化为纯白音波莲花法阵托举飞仙跨越 `$800\ \text{px}$` 深渊。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with a 7-degree elevated angle showing the broad cast-iron soundboard depth of a colossal fractured zither inclined at 45 degrees over a bottomless cliff, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 2-5 The Severed Zither Catapult.
- THEME: Over-tightened blood-red steel cord snapping on a 45-degree inclined cast-iron zither with exploding cinnabar sparks, facing a sheer 30-meter black stone wall across an 800-pixel void.
- FOREGROUND: Blurry snapped iron wire coils and exploding cinnabar spark particles framing the edges.
- PALETTE: Raw iron grey, dark asphalt black (#0A0908), blazing cinnabar sparks (#C3272B). --ar 16:9
```

---

## 幕 2-6：万古碑廊（风化石刻与题跋长卷）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +19.5m`，`FOV = 28°`，微俯角 `Pitch = -5.0°`，配合 `$3.5\ \text{m}$` 低矮天花板压低视口，营造活埋历史的地下棺椁般窒息舞台纵深。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 抹杀历史之廊）**：开裂的黑色墓志铭石碑地面展现清晰廊道宽度，天花板倒插生铁凿子滴落黑油，两侧矗立被齐颈斩首的无名画圣石像。
* **里层白描宣纸底稿（Baimiao Draft: 文心万古长明库）**：北宋澄心堂宣牙白色（`#EFE9DA`），被斩首石俑恢复顾恺之、吴道子、张僧繇等宗师完好白描真容，石壁浮现万道白描草书题跋长卷。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, side-view camera with a slight 5-degree elevated angle showing cracked black epitaph stone floor depth, horizontal cutaway corridor in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 2-6 The Hall of Erased Steles.
- THEME: Suffocating low-ceiling corridor lined with decapitated black stone statues of ancient master painters, flat-ground steles sealed with black pitch, and sharp hanging iron chisels overhead.
- FOREGROUND: Out-of-focus hanging iron chisels and dripping dark pitch droplets framing the top border.
- BACKGROUND: Receding identical black monolithic stele walls fading into cold tomb grey mist.
- PALETTE: Charcoal black (#0A0908), cold tomb grey, faded cinnabar seal red (#C3272B). Seamless horizontal composition --ar 21:9
```

---

## 幕 2-7：韶乐金钟废墟（音波共鸣解密）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.8m`，`FOV = 28°`，微俯角 `Pitch = -7.0°`，围绕倾覆的巨型青铜编钟架横梁上下跳跃；挥刀敲响神钟共鸣瞬间，镜头叠加微幅声波震颤并释放全屏涟漪扭曲环。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 哑钟死坑）**：倾倒在焦墨流沙坑中的生铁编钟架横梁（**`$Z = 0$` 踩踏面边缘保留铜绿高光界线**），破钟裂缝释放带击退判定的淡黑色音波圈。
* **里层白描宣纸底稿（Baimiao Draft: 黄钟大吕神殿）**：破裂铁钟还原为纯洁白玉雕琢的单线白描十二律编钟与特磬，敲响“黄钟”正音后声波绽开白描音符天路，流沙平息为白描波纹。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 7-degree elevated angle showing massive overturned bronze Bianzhong bell rack timber beams over black quicksand, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 2-7 The Ruined Bianzhong Chimes.
- THEME: Colossal overturned iron and bronze Bianzhong bell rack collapsing into black quicksand, cracked bells emitting dark sonic shockwave rings.
- FOREGROUND: Distorted circular sonic blast rings and drifting green bronze patina motes framing the borders.
- BACKGROUND: Half-buried titanic bronze bell silhouettes and collapsing temple columns in atmospheric dust fog.
- PALETTE: Heavy oxidized iron, tarnished verdigris green, dry sand black (#0A0908). Seamless horizontal composition --ar 21:9
```

---

## 幕 2-8：崩解绝壁（下劈工尺谱天路）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +26.5m`，`FOV = 28°`，微俯角 `Pitch = -8.5°`，超广角微俯视展现 `$600\ \text{px}$` 完全虚空断崖与持续下坠的崩塌巨石流；连续空中下劈（Pogo）落石借力腾空时，每次命中触发 `$0.05\ \text{s}$` 顿帧与向下微顿回弹。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 崩天裂渊）**：完全虚空断崖，唯有一块块自天顶滚落的崩塌焦石（寿命 `$1.5\ \text{s}$`，**`$Z = 0$` 顶面前沿刻画白描飞白高光锋线**）。
* **里层白描宣纸底稿（Baimiao Draft: 工尺韶乐长卷）**：深渊展开横贯九霄的【太虚白描工尺韶乐总谱长卷】，坠落碎石对应静静悬浮的白描双勾工尺音符平台（上、尺、工、凡、六），踩踏生长出乐谱飞天扶栏。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with an 8.5-degree elevated top-down angle showing tumbling basalt boulder tops and a bottomless 600-pixel chasm depth, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 2-8 The Collapsing Precipice.
- THEME: Catastrophic collapsing cliff with falling jagged charcoal basalt boulders with highlighted top edges over a pitch-black bottomless abyss, tearing ink dust storms.
- FOREGROUND: Falling fractured rock silhouettes and flying cursive scroll pages tumbling down the screen borders.
- BACKGROUND: Colossal cliff faces fracturing into thousands of falling pillars, swirling black vortex below.
- PALETTE: Scorched charcoal black (#0A0908), bone grey, torn paper white. --ar 16:9
```

---

## 幕 2-9：司碑古坛（守关主宰：墨骨一阶段）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +17.0m`，`FOV = 26°`，`Offset Y = +1.8m`，微俯角 `Pitch = -5.5°`，阻尼 `$X = 0.05, Y = 0.08$`（死区归零）。
* **戏剧演戏演出**：四方玄武岩古坛四角生铁火柱轰然燃起黑色沥青冷火，左右柱体如剧场大幕框定擂台；启用 `$6:4$` 非对称权重构图，当墨骨挥舞十丈拓碑黑鞭拉远距离时，触发距离自适应 `Cam Z` 平滑后退。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 墨骨点卯杀坛）**：长达 `$1800\ \text{px}$` 的孤峰四方汉白玉拓碑古坛，微俯角清晰展现台面九宫排水槽中蓄满的浓黑油墨倒影；墨骨胸口嵌三块《永寿诏书》黑色残碑，手持生铁开山錾长鞭。
* **里层白描宣纸底稿（Baimiao Draft: 受禅封圣仙坛）**：死坛转化为【盛唐太虚受禅封圣仙坛】，生漆柱化为白描汉白玉蟠龙柱；弹反擦除罪碑后，显露 `$0.25\ \text{mm}$` 极细单线勾勒的白描枯骨文人真身。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle revealing square basalt altar floor depth and ink-filled drainage channels, massive cast-iron pillars burning with black pitch flames framing the far left and right edges like theater curtains, whirling black ink whip blur lines framing the top corners, dramatic volumetric spotlights, inspired by ICEY and Wu Shan Wu Xing, Stage 2-9 Stele Master Altar.
- THEME: Stark square basalt execution altar suspended over a chasm, facing an armored stone-rubbing executioner boss.
- PALETTE: Basalt black (#0A0908), pitch dark, cold tomb grey, dull bronze. --ar 16:9
```

---

## 幕 2-10：凌空裂渊（守关主宰：墨骨二/三阶段与题跋处决）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：二阶段无地面空战 `Cam Z = +27.5m`（`FOV = 28°`），`Offset Y` 向上抬升至 `+3.6m` 且俯角调平至 **`Pitch = -2.5°`**，释放充足头顶高空弹道视野；三阶段题跋处决瞬间无插值瞬切至 `Cam Z = +13.0m`（`FOV = 24°`）。
* **戏剧演戏演出**：墨骨一錾砸碎古坛进入纯空战，万仙水袖飘带在空中交织成网（**`$Z = 0$` 踩踏中心线泛白描金光**）；触发怀素狂草**“藏”**字处决瞬间，压入 `$2.39:1$` 电影黑边，全屏反相为底黑线白的金石拓片负片。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 石翼狂暴大空战）**：地面完全不复存在，墨骨展开四座三丈长的倒插墓碑黑色石翼掀起焦墨飓风，天穹顶端矗立冰封死锁的【铅白死绝天门】。
* **里层白描宣纸底稿（Baimiao Draft: 万仙水袖与狂草“藏”）**：南唐澄心堂纸底色，乐仙广袖化为【万仙水袖天网】，处决引爆狂草“藏”字，石翼粉碎，墨骨安祥合掌化作甘露消散。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, 2.5D stage perspective, far-back side-view camera with a flattened 2.5-degree angle providing vast vertical headroom in a bottomless abyss, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 2-10 Climax The Shattered Chasm.
- THEME: Aerial boss duel in a bottomless abyss where the stone floor has shattered completely; floating white baimiao silk ribbons with glowing golden centerlines serve as aerial walkways against a winged tombstone boss, with a colossal frozen lead-white celestial gate looming at the distant sky apex.
- FOREGROUND: Sharp stone chips and swirling charcoal dust clouds framing the lens borders.
- PALETTE: Ink black (#0A0908), dry bone white, weathered stone grey, faint mud gold. --ar 16:9
```

---

## 幕 T-1 / T-2：狂草化龙破门卷（跨章无缝过渡幕）

### 1. 2.5D 舞台机位与物理运动学演变
* **幕 T-1（万碑共鸣与化龙冲霄）**：万座倒插墓碑崩解，千圣文心化作千丈【五彩狂草墨龙】。镜头沿 `Path3D` 拉远至 `Cam Z = +34.5m`（`FOV = 28°`），俯角转为微仰视 **`Pitch = +4.0°`**，墨龙驮负主角以峰值 **`$+50.0\ \text{m/s}$`** 超音速垂直仰冲，两侧绝壁如流光倒退。
* **幕 T-2（撞穿天门与神坛滑跪）**：墨龙轰穿万仞铅白死绝天门，炸裂数亿白玉碎块与铅粉暴雪。主角滑跪稳稳落于终章汉白玉神道，`Cam Z` 收回 `+22.0m`（`Pitch = -6.5°`），世界无缝切入第三章 `$95\%$` 大去色铅白极乐神境。

### 2. 生图 Prompt 规约
```text
2D side-scrolling action game transition art, 2.5D theatrical stage perspective, far-back side-view camera with a slight 4-degree upward tilt showing monumental vertical ascent scale, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage T-1 Dragon Ascent.
- THEME: Colossal five-color cursive calligraphy ink dragon carrying a tiny swordsman vertically upward at supersonic speed, shattering a towering sterile lead-white celestial gate at the top of the screen.
- FOREGROUND: Upward vertical speed lines and shattered white marble fragments flying past the lens borders.
- PALETTE: Brilliant cursive black ink (#0A0908), bursting cinnabar red (#C3272B) and azurite blue (#16355C) sparks, blinding lead white (#F8F8F8). --ar 16:9
```