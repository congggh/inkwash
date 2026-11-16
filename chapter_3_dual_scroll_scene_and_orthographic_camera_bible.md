# 《留白》（Ink & Void）场景原画与《ICEY》式 2.5D 舞台工程全典

## 【合】第三章（终章）：白粉凝霜 · 天地留白（2.5D 舞台重构版）

> **【主美执行总则与《ICEY》式 2.5D 舞台宪章】**：
> “天地非白，乃因众生贪恋红绿万色，方生出万古杀戮与流血。
> 大阁尊顾狂墨以天笔施‘天下大去色’，将人间万象涂作冰冷无尘的铅白死霜，自以为筑成了一座无垢、无争的永恒极乐天宫；
> 却不知在那被铅粉死霜封死的罗纹底纸里，每一道颤抖的改稿，都是他数千个不眠之夜里，为天下苍生流尽的血泪——里面画满了万名被他亲手处决的少年弟子的单线白描速写与泣血忏悔！
> 表层是令人窒息的 `$95\%$` 绝望大去色、神圣千手戒尺法环与**铅白死霜汉白玉神宫戏台**；
> 里层则是撕开神明胸膛后，震撼神魂的《大阁尊万夜泣血自剖草稿》与沉睡的五彩原谱火种。
> 镜头全面升级为《ICEY》（艾希）标志性的**长焦窄视角微俯视 2.5D 舞台透视**（`FOV = 26° ~ 28°`，微俯角 `Pitch = -2.5° ~ -9.0°`）：所有交互判定严格死锁于 `$Z = 0$` 平面，微俯视角清晰展现汉白玉神道上的泥金九宫格地砖纵深与莲花神坛台基厚度，在弑神定格与万里大留白落幕拉远中记录这场剥尽死白、还彩人间的终极涅槃。”

---

# 第一部分：Godot 4 真 3D 空间 2.5D 舞台与动态渲染规范

```text
├── Layer -2 (Z = +4.5m ~ +7.5m): 极近景纯白剪影遮挡 (垂落汉白玉戒尺/铅霜冰棱/死白流苏，压四角暗角)
├── Layer -1 (Z = +1.5m ~ +3.0m): 近景动态微粒层 (GPUParticles3D / Sprite3D：铅白矿粉/霜花纸屑/虚空光斑)
│
├── Layer  0 (Z =  0.0m 绝对锁定): 主战斗与戏台平面 (下 1/3 横剖面 + XZ 平面铺设 3.5m~5.0m 汉白玉神道/草稿纸面)
│
├── Layer +1 (Z = -4.0m ~ -9.0m): 次近景舞台布景 (断裂白玉莲座/去色石经幢/无相跪像/洗笔石案)
├── Layer +2 (Z = -22m ~ -45m)  : 中远景长卷主体 (三百六十柄纯金戒尺法环 / 里层万卷血泪忏悔草图)
├── Layer +3 (Z = -85m ~ -140m) : 极远景天顶气象 (95%去色惨白虚空/静止天轨规矩圆环/太虚五彩星云，叠加逐材质雾)
└── Layer +4 (Z = -180m 巨幅天幕): 底层宣纸胎体天幕 (固定不动的 4K 极品温润澄心堂生宣帘纹暗斑)
```

## 1.1 《ICEY》式 2.5D 舞台机位四大核心模式（Godot 4 `StageCamera3D`）

全章统一采用 `Projection = Perspective` 透视摄像机配合全局贴图比例 `pixel_size = 0.01`（`$Z = 0$` 交互面与 `$1080\text{p}$` 屏幕像素 `$1:1$` 对齐）：

| 模式类别 | `Cam Z` 纵深 / `FOV` | 高度偏移 `Offset Y` 与微俯角 `Pitch` | 阻尼系数（`$X / Y$`） | 适用场景与戏剧演出表达 |
| :--- | :--- | :--- | :--- | :--- |
| **2.5D 铅白神道探索** | **`+22.0m ~ +25.2m`** / `FOV = 28°` | `Offset Y = +2.2m`；`Pitch = -6.5°` | `$X = 0.12, Y = 0.20$` | 幕 3-1 至 幕 3-6。微俯角展现汉白玉地砖与泥金九宫格线的冰冷透视纵深，启用落地 `$Y$` 轴吸附与“破幕刮白”微脉冲。 |
| **神坛弑神剧场决斗** | **`+16.5m ~ +17.0m`** / `FOV = 26°` | `Offset Y = +1.8m`；`Pitch = -5.5°` | `$X = 0.05, Y = 0.05$`（死区归零） | 幕 3-3 平规衡司战与 幕 3-9 顾狂墨一阶段。左右金色华表如大幕锁死舞台，冷白 `SpotLight3D` 打亮中心莲座，`$6:4$` 非对称构图。 |
| **天下大去色与深渊** | **`+27.5m ~ +28.5m`** / `FOV = 28°` | `Offset Y = +3.4m`；`Pitch = -2.5° ~ -8.5°` | `$X = 0.20, Y = 0.20$` | 幕 3-8 泣血深渊与 幕 3-10 二阶段 `$95\%$` 白化狂澜。调平俯角释放高空千手法环弹道留白，在漫天死白中寻找草稿撕裂口。 |
| **处决“休”与万里落幕** | **`+12.2m` $\to$ `+48.0m`** / `FOV = 24°` $\to$ `28°` | 刀尖特写 $\to$ 宇宙长卷俯瞰；`Pitch = -3.0°` $\to$ `-5.0°` | 瞬切 $\to$ `$0.05\ \text{Hz}$` `Path3D` 极缓拉远 | 幕 3-10 三阶段狂草“休”字处决（`$2.39:1$` 黑边负片）至尾声 幕 E-3 全屏 `$80\%$` 太虚大留白朱砂巨印落幕。 |

## 1.2 终章 3D 空间长卷无缝循环、渲染排序与防重复机制

* **3D 空间长卷无缝循环（`InfiniteScroll3D`）**：
  * 汉白玉神宫立柱与悬空神道面片（`Sprite3D`）按世界单位宽度 `$20.48\ \text{m}$`（`$2048\ \text{px}$`）队列循环调度；远景去色虚空与千手戒尺天网面片按 `$40.96\ \text{m}$`（`$4096\ \text{px}$`）无缝循环拼接，导入启用 `Linear Mipmap` 与 `Clamp` 采样，消除横向移动时泥金细线的锯齿闪烁与拼接黑线。
* **双 `SubViewport` 与深度缓冲排序**：
  * 表里两套 3D 场景共享同一 `Camera3D` 变换矩阵；硬边缘 `Sprite3D` 启用 `Alpha Cut = Discard` 写入深度缓冲，半透明寒霜毒雾与冷白圣光束设为 `Blend Mode = Add` 并按 `$Z$` 轴递增设置 `Render Priority`。
* **破除长卷重复感四大工程机制**：
  1. **DECO 非周期贴花**：在汉白玉地表随机投射铅白霜花结晶、泥金九宫规矩细线、暗红自剖血泪手印与残卷贴花。
  2. **次级独立地标覆盖层**：每隔 `$5.0\ \text{m} \sim 8.0\ \text{m}$`（`$500\ \text{px} \sim 800\ \text{px}$`）穿插不可复用的独立道具（断裂白玉莲座、去色石经幢、弟子白描跪像残石）。
  3. **Verlet 动态垂挂物理**：`Layer -2` 极近景倒悬的汉白玉戒尺流苏与半透明白绫绑定弹簧骨骼，随深渊铅粉上升气流与冲刺风压产生微幅起伏。
  4. **跨层寒霜毒雾与追光阻断**：在 `$Z = -2.0\ \text{m} \sim +2.0\ \text{m}$` 穿插 `$95\%$` 大去色铅白死霜雾气面片与局部纯白高光光斑，打破几何周期记忆。

## 1.3 终章三大立体渲染技法与“刮白”逐材质 Shader 动态联动

1. **空气透视与色彩衰减（Atmospheric Perspective）—— 铅白死霜双轨瞬切**：
   * **表层常规态**：通过逐材质 `SpatialShader` 根据节点 `$Z$` 轴深度（`$Z = -22\ \text{m} \sim -130\ \text{m}$`），将中远景图层向终章主色调**极寒铅白死霜雾（`#DCE3E8`）**混合 **`$40\% \sim 60\%$`**，营造无机质“白色暴盲”的窒息神域压迫感，同时反衬 `$Z = 0$` 主角墨衣黑刃的孤独剪影。
   * **【刮白瞬切联动】**：挥刀“刮白”或释放“破宣斩”撕开表层铅霜画布时，Shader 采样屏幕空间撕裂遮罩，撕裂区域内部的空气透视在 **`$0.15\ \text{s}$`** 内瞬切为**温润南唐澄心堂生宣漫射天光（雾气混合度降至 `$< 5\%$`）**，刺眼死白消退，大阁尊颤抖的朱砂血书忏悔与万名弟子白描速写清晰浮现。
2. **动态前景暗影框定（Foreground Framing）—— 寒霜流苏掠过与破幕消融**：
   * **表层常规态**：在 `$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$` 布置半透明铅白戒尺流苏、冰棱与空白挂轴剪影。角色高速冲刺时，前景剪影掠过屏幕边缘，强化神殿的森严窥视感。
   * **【破幕消融联动】**：在“刮白”撕裂窗口内，前景铅白流苏与空白挂轴同步触发 Shader **水墨消融（Alpha Dissolve）**，转化为极淡的游丝白描线条或隐去，确保高空戒尺跳跃与深渊空战视野绝对通透。
3. **跨层体积光（Volumetric Light Shafts）—— 裂缝透光与救赎天路指引**：
   * **表层常规态**：在 `$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$` 穿插 `Blend Mode = Add` 的冷白圣光光束，缝合神殿立柱与千手法环。
   * **【裂缝追光联动】**：劈开表层冰封画壁或铅白结界后，体积光束直接从画布撕裂裂缝迸射，精准打亮里层转化出的安全落脚结构（白描经书散页、洗笔石案与弟子亡魂托举的素宣人梯）。

## 1.4 2.5D 微俯视透视下的 `$Z = 0$` 机制碰撞中心线校准

针对终章 `$5.5^\circ \sim 8.5^\circ$` 微俯视角下纯白地面与金色戒尺容易产生“白色过曝融边”的问题，全章交互机关必须严格执行以下 `$Z = 0$` 视觉靶心校准：

* **下沉黄金戒尺与倾斜天平浮板（幕 3-5 / 3-8）**：戒尺与玉板在 `XZ` 平面呈现 `$3.5\ \text{m}$` 金属/玉石立体厚度，但**严格对应 `$Z = 0$` 碰撞体顶面的前沿刃口，必须刻画锐利冷白/暗金双色高光边界线（`#FFFFFF` / `#8A6508`）**，防止在高调死白背景中丢失落脚边缘。
* **浑天规矩仪青铜交叉梁（幕 3-7）**：转动圆环横梁的 `$Z = 0$` 踩踏轴线附加泥金刻度高光点，确保机械旋转中的跳跃落点清晰可辨。

---

# 第二部分：终章全 10 幕 2.5D 舞台场景工程全典

```text
[幕 3-1: 铅白神道] ──► [幕 3-2: 去色天门] ──► [幕 3-3: 千手戒尺殿] ──► [幕 3-4: 凝霜画壁]
 (死白神阶/九宫纵深)    (金戒尺法环/同心碑)    (平规衡司/大幕追光)    (破幕撕壁/万名弟子录)
        │
        ▼
[幕 3-5: 虚空白塔] ──► [幕 3-6: 抹痕回廊] ──► [幕 3-7: 天道规矩坛] ──► [幕 3-8: 泣血深渊]
 (Z=0刃口金尺攀登)     (白布名画/补遗秘库)    (浑天生铁规矩/童心木模) (破宣撕渊/朱砂血书壁)
        │
        ▼
[幕 3-9: 弑神神坛 (顾狂墨I)] ──► [幕 3-10: 天下大去色 (顾狂墨II/III)] ──► [尾声: 万里乾坤大留白]
 (千手戒尺阵/莲座擂台)            (95%白化/心头锁链/狂草“休”字处决)       (春雨市井/朱砂巨印“留白则生”)
```

---

## 幕 3-1：铅白神道（极乐天阶）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.0m`，`FOV = 28°`，`Offset Y = +2.2m`，微俯角 `Pitch = -6.5°`，阻尼 `$X = 0.12, Y = 0.20$`。
* **戏剧演戏演出**：主角自碎裂天门滑跪起身，镜头微俯角展现汉白玉神道上笔直延伸的泥金九宫格透视网格与下方玉石台基横剖面；画面剥离一切原色，脚步在厚干铅粉上留下孤寂印痕。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝色神域）**：汉白玉石板覆盖碱式碳酸铅粉（`#F8F8F8`）哑光死霜，接缝以泥金（`#D4A017`）勾勒严苛九宫格网；两侧浮立工笔泥金戒尺石桩直插云霄。
* **里层白描宣纸底稿（Baimiao Draft: 问道初卷）**：底板展现五代南唐澄心堂纸温润质地（`#EFE9DA`），显露【大阁尊青年问道草稿长卷】，地面浮现鲜红朱砂批注：“若去尽万色，人间真可安宁否？”，戒尺桩化作摆放宣纸笔洗的书案。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6.5-degree elevated top-down angle showing visible white marble roadway depth and gold mathematical gridlines, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 3-1 The Lead-White Sacred Way.
- THEME: Sterile, majestic floating white marble celestial roadway covered in toxic lead-white frost and golden compass rulers.
- FOREGROUND: Defocused pristine white marble tassels and jagged lead icicles framing the top corners.
- MIDDLE-GROUND (Playable Stage): Pure white jade pathway showing clear surface breadth with mud-gold gridlines and occasional blood-red cinnabar tear stains.
- BACKGROUND: Monumental rotating halos of golden architectural rulers and monolithic four-faced white jade statues fading into 95% desaturated lead-white mist on ancient Chengxingtang raw Xuan paper texture.
- PALETTE: Blinding lead white (#F8F8F8), pale mud gold (#D4A017), sterile stone grey. Seamless horizontal composition --ar 21:9
```

---

## 幕 3-2：去色天门（字字抹杀）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +25.2m`，`FOV = 28°`，微俯角 `Pitch = -5.5°`，拉远构图展现三十米熔铅重门与自转的三百六十柄纯金戒尺法环的巨构压迫感。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝色天关）**：平整汉白玉阶梯展现立体台阶纵深，三十米重门通体浇筑两寸厚熔铅封皮，金尺法环释放水平扫过的去色金光。
* **里层白描宣纸底稿（Baimiao Draft: 开阁同心卷）**：重门转化为【开阁同心纪功碑坊】，门扇内部显现李公麟单线白描百米群像（年轻顾狂墨与欢笑弟子泼墨嬉戏），边缘留有泪水晕开的悔恨手记。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 5.5-degree elevated angle showing white marble ceremonial step depth, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 3-2 The Desaturated Heavenly Gate.
- THEME: 30-meter sterile white marble gate sealed with molten lead, haloed by a spinning ring of 360 golden executioner rulers, faceless deacons sweeping white frost.
- FOREGROUND: Swirling dense white lead-powder clouds framing the bottom border.
- BACKGROUND: Massive white marble archways and blank white reflective tablets fading into cold lead-white mist.
- PALETTE: Sterile lead white (#F8F8F8), gleaming mud gold (#D4A017), cold ash grey. Seamless horizontal composition --ar 21:9
```

---

## 幕 3-3：千手戒尺殿（精英怪：平规衡司）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +17.0m`，`FOV = 26°`，`Offset Y = +1.8m`，微俯角 `Pitch = -5.5°`，阻尼 `$X = 0.05, Y = 0.08$`（死区归零）。
* **戏剧演戏演出**：进入神殿 `Area3D` 瞬间，左右两根刻有绝对刻度的金色汉白玉华表如剧场大幕锁死左右边界，冷白 `SpotLight3D` 顶光打亮神殿中央；精准弹反平规衡司黄金天平触发 `$12$` 帧黑白抽色定格与 `Cam Z` 瞬推至 `+15.2m`。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝对裁决殿）**：长 `$1500\ \text{px}$` 的封闭汉白玉神殿地板展现清晰的地面纵深与泥金网格陷阱，平规衡司双手托持万斤生铁黄金天平。
* **里层白描宣纸底稿（Baimiao Draft: 度量衡正司）**：显现【盛唐营造度量衡正司】，天平被弹反击碎后露出一尊单线白描盲眼大匠木雕，天平转化为白描水利称量装置，两端盛放谷种与清泉。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle revealing immaculate marble courtroom floor depth and glowing mud-gold laser gridlines, towering gold-engraved white jade pillars framing the far left and right edges like theater curtains, raining vertical gold ruler silhouettes framing the top border, dramatic volumetric stage spotlights, inspired by ICEY and Wu Shan Wu Xing, Stage 3-3 Hall of the Thousand-Handed Praetor.
- THEME: Sterile marble courtroom dominated by a four-faced white jade Buddha executioner wielding a colossal golden balance scale.
- PALETTE: Pure white jade (#F8F8F8), brilliant mud gold (#D4A017), deep pitch black, sterile grey. --ar 16:9
```

---

## 幕 3-4：凝霜画壁（冰封群仙）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.8m`，`FOV = 28°`，微俯角 `Pitch = -6.0°`，平稳横移展现两百米冰封通天画壁的宏大长卷纵深；连续出刀撕开冰壳画壁时，裂缝内逐材质 Shader 瞬间切为温润古宣天光，丁达尔光束照亮万名弟子白描遗像。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 永恒封冻画廊）**：光滑汉白玉栈桥展现清晰桥面宽度，千仞玉壁覆三寸厚铅白晶体冰壳，封存变质发黑的历代名画，壁画前矗立被铅浆浇铸冰封的断笔画仙雕像。
* **里层白描宣纸底稿（Baimiao Draft: 泣血弟子录）**：显现大阁尊亲手绘制的【万名被诛弟子白描灵堂】，工楷标注生卒年月与颤抖自责：“我之过也，我之罪也！”，底部印满百米暗红朱砂自剖血手印。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6-degree elevated angle showing frosted white marble bridge floor depth, horizontal cutaway corridor in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 3-4 The Frost-Locked Mural.
- THEME: 200-meter white marble wall encasing ancient vibrant murals inside suffocating lead-white frost, petrified statues of artists holding broken brushes.
- FOREGROUND: Close-up blurry hanging frosted banners and drifting toxic white flakes framing the borders.
- BACKGROUND: Faded ancient mural outlines sealed under translucent white stone sheets with golden imperial seals fading into cold mist.
- PALETTE: Sterile lead white (#F8F8F8), cold ivory, pale mud gold (#D4A017), withered ink black. Seamless horizontal composition --ar 21:9
```

---

## 幕 3-5：虚空白塔（空中造桥与极空升阶）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +23.5m`，`FOV = 28°`，微俯角 `Pitch = -4.5°`，横向阻尼放宽至 `$X = 0.30$` 锁死白塔中轴，纵向阻尼收紧至 `$Y = 0.10$` 敏锐跟随 `$800\ \text{px}$` 高空升阶攀登。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝色通天塔）**：悬空跳板由纯金包边生铁度量戒尺构成（踩踏后 `$1.5\ \text{s}$` 下沉），**每根戒尺在 `$Z = 0$` 碰撞刃口保留锐利冷白与暗金双色高光边界**，防止在自下而上的铅白上升暴风中丢失落脚判断。
* **里层白描宣纸底稿（Baimiao Draft: 登天浮屠仙梯）**：通天死塔转化为【太虚白描登天浮屠宝塔】，下沉戒尺化为舒缓铺展的白描经书散页与祥云经案，毒雾化作漫天飞舞的白描飞天与优昙婆罗花瓣。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, side-view camera with a 4.5-degree elevated angle showing golden-edged execution ruler platform depth inside a monumental vertical white pagoda void, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 3-5 The Hollow White Spire.
- THEME: Vertical climb through a sterile white marble pagoda void, unstable sinking golden compass rulers with crisp highlighted front edges serving as platforms amidst a blinding upward blizzard of lead-white dust.
- FOREGROUND: Blinding vertical streaks of lead-white mineral dust framing the screen borders.
- BACKGROUND: Infinite vertical white marble tower facades with serene faceless Bodhisattva reliefs fading into icy mist.
- PALETTE: Pure alabaster white (#F8F8F8), pale mud gold (#D4A017), icy silver. --ar 16:9
```

---

## 幕 3-6：抹痕回廊（被抹去的名画）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +19.5m`，`FOV = 28°`，微俯角 `Pitch = -5.0°`，配合 `$3.2\ \text{m}$` 矮顶天花板与空白挂轴长阵，制造死寂停尸房般的窒息舞台纵深。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 抹杀之殿）**：纯白汉白玉方砖地面覆有厚干铅粉，回廊悬挂数以千计被强行洗成开裂白布的名画挂轴（《洛神赋图》、《步辇图》等），两侧壁龛陈列削去面容的白玉画师无相跪像。
* **里层白描宣纸底稿（Baimiao Draft: 补遗救赎卷）**：空白挂轴背后，大阁尊用南宋单线铁线描将销毁名画完完整整重摹，边角写满精神分裂的自责手记：“白粉可遮世人之眼，何以遮我心头血？！”

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, side-view camera with a slight 5-degree elevated angle showing seamless white marble pavement depth, horizontal cutaway corridor in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 3-6 The Corridor of Erased Masterpieces.
- THEME: Claustrophobic low-ceiling white marble gallery lined with hundreds of hanging silk scrolls brutally whitewashed into blank cracked white paperboards with mud-gold seals, and faceless kneeling artist statues in alcoves.
- FOREGROUND: Defocused blank white silk scroll banners framing the top border.
- BACKGROUND: Endless receding corridor of hanging white tablets fading into cold sterile mist.
- PALETTE: Whitewashed bone paper, cold marble white (#F8F8F8), antique mud gold (#D4A017), ash grey. Seamless horizontal composition --ar 21:9
```

---

## 幕 3-7：天道规矩坛（机关破坏与天平破灭）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +23.5m`，`FOV = 28°`，微俯角 `Pitch = -7.5°`，围绕三十米纯金浑天规矩仪交叉梁跳跃，抬高头顶留白规避活塞式上下抽动的生铁戒尺绞链。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 铁律天枢）**：青铜浑天仪外环交叉梁构成立体金属平台（**`$Z = 0$` 踩踏轴线附加泥金刻度高光点**），天仪轴心白玉池翻滚高压铅白矿浆并喷洒剧毒死霜蒸汽。
* **里层白描宣纸底稿（Baimiao Draft: 童心浑天仪）**：杀戮机器转化为【盛唐开阁同心浑象仪木模】，齿牙内部刻着弟子稚拙小名“阿牛刻”、“小妹磨”，轴心还原为白描小石童捧水盆。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with a 7.5-degree elevated angle showing interlocking brass armillary ring walkway depth and boiling lead pigment vats, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 3-7 The Altar of Absolute Rules.
- THEME: Terrifying mechanical engine of divine order dominated by a 30-meter-wide rotating golden armillary sphere with guillotine-sharp teeth and vertical piston ruler cables.
- FOREGROUND: Whirring vertical iron chain cables with razor ruler attachments framing the screen borders.
- BACKGROUND: Monolithic golden concentric astrolabe rings rotating endlessly against a cold lead-white void.
- PALETTE: Heavy mud gold (#D4A017), cast bronze, boiling lead white (#F8F8F8). --ar 16:9
```

---

## 幕 3-8：泣血深渊（撕开底稿）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +27.5m`，`FOV = 28°`，微俯角 `Pitch = -8.5°`，超广角微俯视展现 `$600\ \text{px}$` 铅霜暴雪深渊与倾斜浮板；挥刀施展【破宣斩】撕裂惨白假象天幕瞬间，裂缝内逐材质 Shader 空气透视瞬切，丁达尔光束直照朱砂血书岩壁。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 绝色死渊）**：全屏白化率达 `$90\%$` 的铅白死霜暴雪深渊，空中漂浮两面倾斜汉白玉戒尺天平浮板（**`$Z = 0$` 前沿边缘刻画暗金与冷白双色高光锋线**，防止白色暴盲下踩空）。
* **里层白描宣纸底稿（Baimiao Draft: 万夜自剖长廊）**：犬牙交错撕裂的桑皮生宣长纤维，数千丈石壁密布原矿朱砂（`#C3272B`）狂草自罪书：“我非神圣，我乃天下第一罪囚！”，危险落脚点化为万名弟子白描亡魂托举的【素宣人梯天路】。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with an 8.5-degree elevated top-down angle showing tilted white marble balance platform depth over a bottomless 600-pixel abyss, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 3-8 The Chasm of Weeping Drafts.
- THEME: Blinding lead-white blizzard abyss torn open through a jagged paper rift to reveal sheer canyon walls covered in frantic blood-red cinnabar cursive calligraphy confessions and ethereal white baimiao spirits.
- FOREGROUND: Blinding white frost sheets and torn manuscript shreds whipping past the screen edges.
- PALETTE: Blinding blizzard white (#F8F8F8), torn paper ivory (#EFE9DA), frantic cinnabar red (#C3272B), void black. --ar 16:9
```

---

## 幕 3-9：弑神神坛（守关主宰：大阁尊顾狂墨一阶段）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +17.0m`，`FOV = 26°`，`Offset Y = +1.8m`，微俯角 `Pitch = -5.5°`，阻尼 `$X = 0.05, Y = 0.05$`（死区归零）。
* **戏剧演戏演出**：左右纯白神殿立柱如剧场大幕锁死两千像素汉白玉擂台，冷白 `SpotLight3D` 体积追光打亮两丈高铅白莲座；启用 `$6:4$` 非对称构图与距离自适应 `Cam Z` 后退，精准弹反金色主尺触发黑白抽色瞬推特写。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 铅白极乐神尊）**：长达 `$2000\ \text{px}$` 的纯平汉白玉弑神擂台，微俯角展现泥金九宫罗盘地纹纵深与莲座台基厚度；顾狂墨身披铅白神袍，背后悬浮三百六十柄纯金戒尺组成的【千手千眼规矩法环】。
* **里层白描宣纸底稿（Baimiao Draft: 枯骨心锁卷）**：白玉佛身外壳瓦解，里层仅是一位单线白描粗布长衫、瘦骨嶙峋的古稀老翁，胸膛被四根生铁戒尺链条洞穿绞锁，双目流淌焦墨血泪。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle revealing floating white jade arena platform depth, gold compass floor engravings, and lotus throne base thickness, monolithic white temple pillars framing the far left and right edges like theater curtains, translucent white tassels framing the top border, dramatic volumetric stage spotlights, inspired by ICEY and Wu Shan Wu Xing, Stage 3-9 Grand Master Gu Kuangmo Phase 1.
- THEME: Divine duel atop a floating white marble altar haloed by a monumental rotating ring of 360 flying golden executioner rulers against an absolute white void.
- PALETTE: Brilliant lead white (#F8F8F8), shimmering mud gold (#D4A017), deep charcoal black (#0A0908). --ar 16:9
```

---

## 幕 3-10：天下大去色（顾狂墨二/三阶段与终极处决：狂草“休”）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：二阶段（`$95\%$` 天下大去色狂澜）`Cam Z = +28.5m`（`FOV = 28°`），`Offset Y` 抬升至 `+3.4m` 且俯角调平至 `Pitch = -2.5°`；三阶段（真容逼近态）平滑推进至 `Cam Z = +16.5m`（`Pitch = -5.5°`）；终极大题跋处决瞬间无插值瞬切至 **`Cam Z = +12.2m`（`FOV = 24°`）**。
* **戏剧演戏演出**：二阶段顾狂墨挥动五丈焦墨枯笔强行洗白舞台，全屏白化率飙升至 `$95\%$`；三阶段老人单膝跪地露出胸膛五彩火种，主角断铁錾轻触火种瞬间，上下压入 `$2.39:1$` 电影黑边，**全屏反相为底黑线白的金石拓片碑刻负片**，怀素狂草巨字——**“休”**横贯九天引爆，五彩墨浪奔腾席卷万里长卷！

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 大去色终局狂澜）**：神袍碎裂，舞台地平线在二阶段融化为纯白平涂，老人胸膛空洞封锁着天地最初一团五彩矿彩原谱火种（石青、石绿、朱砂、藤黄）。
* **里层白描宣纸底稿（Baimiao Draft: 天地大归真与狂草“休”）**：太虚素宣底色（`#FFFFFF`），处决引爆狂草“休”字后，老人化作素宣光羽与五彩火种融为一体。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, 2.5D stage perspective, side-view camera with a slight 3-degree elevated angle showing fractured white paper stage floor turning into pitch-black stone rubbing negative, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 3-10 The Grand Epigraph Execution "休".
- THEME: Climax epigraph execution where the screen inverts into pitch-black stone rubbing negative with luminous bone-white contours, monumental cursive calligraphy brushstrokes tearing the void as five-colored mineral flames (cinnabar, malachite, azurite, gold) burst from the center.
- FOREGROUND: Flying dry-brush ink motes and glowing white paper butterflies framing the borders.
- PALETTE: Inverted pitch black (#0A0908), bone white (#FFFFFF), radiant five-color mineral pigments (#C3272B, #1F4E3F, #16355C, #D4A017). --ar 16:9
```

---

# 第三部分：尾声【万里乾坤大留白】（2.5D 落幕拉远与大印封卷）

```text
[幕 E-1: 市井春雨 (江南烟火)] ──► [幕 E-2: 千里山河复苏 (五彩长卷)] ──► [幕 E-3: 万里乾坤大留白 (朱砂巨印封卷)]
 (2.5D青石雨巷/顽童泼墨/春茶)      (Path3D慢速垂升/写意青绿江山)         (Cam Z=+48m拉远/80%纯白留白/朱砂巨印)
```

## 幕 E-1：市井春雨（江南烟火还彩）
* **2.5D 舞台机位**：`Cam Z = +22.0m`，`FOV = 28°`，`Offset Y = +2.2m`，微俯角 `Pitch = -6.5°`，平稳温润的探索机位。
* **场景与演出**：戏台规矩彻底瓦解，微俯角清晰映出江南水乡青石板街巷的雨巷水光纵深；酒肆屋檐下垂挂红布幌子与竹帘（`Layer -2` 微风轻摆），街角孩童在废弃生铁戒尺上用朱砂藤黄涂鸦小猫小鸟，人间在五彩与留白间自由呼吸。

## 幕 E-2：千里山河复苏（五彩长卷）
* **2.5D 舞台机位**：`Cam Z` 沿 `Path3D` 平滑后退至 `+34.5m`（`FOV = 28°`），微俯角加深至 `Pitch = -9.0°`，镜头自江南市井向九霄高空缓缓垂直平移攀升。
* **场景与演出**：曾经死寂厚堆的石青石绿矿彩化为水汽蒸腾的写意青绿，沉埋三万沉船的江河百舸争流，严格恪守“计白当黑”之法，浓墨处高山壁立，留白处云海苍茫。

## 幕 E-3：万里乾坤大留白（朱砂巨印终章）
* **2.5D 舞台机位**：全游戏终极落幕拉远——**`Cam Z = +48.0m`（`FOV = 28°`，微俯角 `Pitch = -5.0°`，以 `$0.05\ \text{Hz}$` 极缓速率拉升）**。
* **终局封卷演出**：整座戏台山川逐渐缩小为长卷正中的一段精致画心，整个 `$16:9$` 屏幕的 **`$80\%$`** 空间彻底转化为纯净太虚大留白（Pure White Void）；屏幕右侧虚空之中，一枚方阔半屏的原矿朱砂九叠篆白文巨印伴随洪钟重音轰然盖下：

$$\text{\Huge【画满则滞 · 留白则生】}$$

### 尾声专属生图 Prompt
```text
2D side-scrolling action game epilogue art, 2.5D theatrical stage perspective, ultra-far-back side-view camera with a 5-degree elevated angle showing a serene Song Dynasty riverside town shrunk into a delicate painted centerpiece surrounded by 80% expansive untouched pure white void (negative space), narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Epilogue Grand Void.
- FOREGROUND: Delicate translucent bamboo blinds and weeping willow branches framing the screen edges.
- CENTERPIECE: White-walled riverside residences, wet flagstone alleys, small wooden sampan boats, children splashing cinnabar paint on old iron rulers, and gentle baimiao mountain outlines fading seamlessly into raw Mulberry Xuan paper texture.
- SKY & VOID: Expansive 80% pure untouched white paper void anchored by a square cinnabar-red seal stamp (#C3272B) in the top-right corner.
- PALETTE: Li Gonglin 0.25mm baimiao line-art, pure paper white (#FFFFFF), charcoal black, delicate pastel mineral washes, focal cinnabar red (#C3272B). --ar 16:9
```

---

# 第四部分：终章 2.5D 舞台生成专用通用 Prompt 词库规则

全员在向 AI（Midjourney / Flux / SD）生成终章与尾声概念图时，必须强制在头部与尾部嵌入以下控制字组：

### 1. 强制头部 2.5D 舞台镜头锁（2.5D Stage Camera Header Lock）
```text
2D side-scrolling action game environment concept art, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible floor depth and walkway width, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing --ar 21:9
```
*(注：封闭 BOSS 决斗戏台、垂直白塔与深渊幕次将 `--ar 21:9` 替换为 `--ar 16:9`，并加入 `symmetrical theatrical stage composition, pillars framing the far left and right edges like theater curtains`。)*

### 2. 终章铅白神圣死霜材质锁（Lead-White Divine Frost Lock）
```text
... pristine lead-white mineral impasto (#F8F8F8), toxic cold carbonate lead frost textures, pure white marble structures, mud-gold compass gridline engravings (#D4A017), 95 percent desaturated white monochrome palette, dramatic volumetric stage spotlights, solemn cold atmospheric mist ...
```

### 3. 里层大阁尊泣血自剖草稿锁（Bleeding Draft Dimension Lock）
```text
... delicate Song Dynasty baimiao single iron-wire line-art, 0.25mm clean ink contours, warm aged ivory Southern Tang Chengxingtang raw Xuan paper texture (#EFE9DA), visible mulberry plant fibers, frantic blood-red cinnabar cursive calligraphy confessions (#C3272B), weeping ink stains, volumetric god-rays bursting through torn paper rifts ...
```

### 4. 强制负向提示词（Universal Negative Prompt - 封死畸变与扁平纸片感）
```text
characters, people, warriors, monsters, fish-eye distortion, extreme wide-angle distortion, top-down bird-eye view, isometric grid, 3D plastic render, flat paper-cutout without floor depth, over-sharpened, digital noise, modern architecture, neon lights
```