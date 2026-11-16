# 《留白》（Ink & Void）场景原画与《ICEY》式 2.5D 舞台工程全典

## 【起】序章：赤朱残阳 · 狂草破规（2.5D 舞台重构版）

> **【主美执行总则与《ICEY》式 2.5D 舞台宪章】**：
> “表层绝非简单的‘上了色’，里层更非廉价的‘褪了色’。
> 表层是执笔阁用万钧焦墨、生铁戒尺、大斧劈皴与原矿朱砂强行搭建的**‘虚假戏台牢笼’**——冰冷、沉重、窒息、充满后天涂抹的杀戮与油垢；
> 里层则是那卷被烈火与篡改掩埋的太虚古宣深处，未被污染的**‘盛唐万卷藏书天阁’**——纯净、空灵、浩瀚，通体由 `$0.25\ \text{mm}$` 南宋李公麟铁线单线勾勒，浮动着百年手工桑皮生宣的植物长纤维与帘纹暗斑。
> 镜头全面升级为《ICEY》（艾希）标志性的**长焦窄视角微俯视 2.5D 舞台透视**（`FOV = 26° ~ 28°`，微俯角 `Pitch = -4.0° ~ -10.0°`）：所有动作判定与物理碰撞严格死锁于 `$Z = 0$` 平面，同时清晰展现玄武岩囚廊、木栈道与断云台向内延伸的地面纵深厚度（Visible Floor Depth），以“挥刀破幕、拆穿伪画”的戏剧张力记录这场破狱史诗。”

---

# 第一部分：Godot 4 真 3D 空间 2.5D 舞台与动态渲染规范

```text
├── Layer -2 (Z = +4.5m ~ +7.5m): 极近景虚化框景 (失焦生铁绞链/断裂竹帘/飞白残枝，压四角暗角)
├── Layer -1 (Z = +1.5m ~ +3.0m): 近景动态微粒层 (GPUParticles3D / Sprite3D：朱砂血雨雨丝/漂浮纸屑/墨滴)
│
├── Layer  0 (Z =  0.0m 绝对锁定): 主战斗与戏台平面 (下 1/3 横剖面 + XZ 平面铺设 3.5m~5.0m 立体纵深地板)
│
├── Layer +1 (Z = -4.0m ~ -9.0m): 次近景舞台布景 (生铁刑架/断矛拒马/熔炉/里层汉白玉石栏)
├── Layer +2 (Z = -22m ~ -45m)  : 中远景长卷主体 (李唐大斧劈皴削壁 / 里层通天白描万卷书架)
├── Layer +3 (Z = -85m ~ -140m) : 极远景天顶气象 (翻滚焦墨雷云/下沉残阳/盛唐白描星野，叠加逐材质雾)
└── Layer +4 (Z = -180m 巨幅天幕): 底层宣纸胎体天幕 (固定不动的 4K 泛黄手工老桑皮纸帘纹暗斑)
```

## 1.1 《ICEY》式 2.5D 舞台机位四大核心模式（Godot 4 `StageCamera3D`）

全章统一采用 `Projection = Perspective` 透视摄像机配合全局贴图比例 `pixel_size = 0.01`（实现 `$Z = 0$` 交互面与 `$1080\text{p}$` 屏幕像素 `$1:1$` 对齐）：

| 模式类别 | `Cam Z` 纵深 / `FOV` | 高度偏移 `Offset Y` 与微俯角 `Pitch` | 阻尼系数（`$X / Y$`） | 适用场景与戏剧演出表达 |
| :--- | :--- | :--- | :--- | :--- |
| **2.5D 囚廊标准探索** | **`+22.0m`** / `FOV = 28°` | `Offset Y = +2.2m`；`Pitch = -6.5°` | `$X = 0.12, Y = 0.25$` | 幕 0-1 至 幕 0-9 常规跑图。清晰展现玄武岩石阶地面厚度，启用落地 `$Y$` 轴锚点吸附与冲刺 `Cam Z` 后退（`$+1.8\ \text{m}$`）。 |
| **剧场大幕高压决斗** | **`+16.8m ~ +17.0m`** / `FOV = 26°` | `Offset Y = +1.8m`；`Pitch = -5.5°` | `$X = 0.05, Y = 0.05$`（死区归零） | 幕 0-3 镇峰狱尉战与 幕 0-10 墨梅前两阶段。左右铁闸如剧场大幕闭锁，顶部 `SpotLight3D` 追光打亮舞台中央，`$6:4$` 非对称构图。 |
| **题跋处决电影瞬切** | **`+12.2m`** / `FOV = 24°` | 死锁刀尖贯胸交接点；`Pitch = -3.0°` | `$X = 0.00, Y = 0.00$`（无插值瞬切） | 墨梅第三阶段狂草“折”字处决。压入 `$2.39:1$` 电影宽银幕黑边，全屏反相为底黑线白的金石拓片负片。 |
| **飞瀑跨章垂直直坠** | **`+30.0m`** / `FOV = 28°` | 沿 `Path3D` 垂直下追踪（`$-40.0\ \text{m/s}$`）；`Pitch = -10.0°` | `$X = 0.30, Y = 0.05$` | 幕 T-1 断云台崩塌百丈飞瀑直坠。超广角俯瞰天地孤影与飞瀑剥离血污。 |

## 1.2 序章 3D 空间长卷无缝循环、渲染排序与防重复机制

* **3D 空间长卷无缝循环（`InfiniteScroll3D`）**：
  * 中远景李唐大斧劈皴削壁面片（`Sprite3D`）按世界单位宽度 `$20.48\ \text{m}$`（对应 `$2048\ \text{px}$`）进行多段队列无缝衔接调度；
  * 当 `StageCamera3D` 沿 `$X$` 轴推进超过单个切片宽度时，后方切片自动平移至队列最前端，实现零卡顿无限长卷延伸；导入选项启用 `Linear Mipmap` 与 `Clamp` 采样，杜绝横移时远景像素闪烁或拼接黑线。
* **双 `SubViewport` 与深度缓冲排序**：
  * 表里两套 3D 场景分别渲染于共享同一 `Camera3D` 变换矩阵的 `SubViewport` 中；所有硬边缘 `Sprite3D` 启用 `Alpha Cut = Discard` 写入深度缓冲，半透明体积光束设为 `Blend Mode = Add` 并按 `$Z$` 轴递增设置 `Render Priority`。
* **破除长卷重复感四大工程机制**：
  1. **DECO 非周期贴花**：在玄武岩地面上基于噪声函数随机投射暗红硫化汞血斑（`#C3272B`）、焦墨沥青油垢与龟裂石皮贴花。
  2. **次级独立地标覆盖层**：每隔 `$6.0\ \text{m} \sim 8.0\ \text{m}$`（`$600\ \text{px} \sim 800\ \text{px}$`）穿插不可复用的舞台道具（折断的生铁戒尺桩、斜插的生铁巨矛、倒塌的囚笼残骸）。
  3. **Verlet 动态垂挂物理**：`Layer -2` 极近景的生铁绞索与破败生宣纸幡绑定弹簧骨骼，受玩家跑动与高速冲刺气流驱动产生 `$0.4\ \text{Hz}$` 滞后荡漾。
  4. **跨层舞台追光与雨幕阻断**：在 `$Z = -2.0\ \text{m} \sim +2.0\ \text{m}$` 穿插斜向体积光束与垂直倾盆暴雨帘幕，切断长卷周期的视觉记忆。

## 1.3 序章三大立体渲染技法与“刮白”逐材质 Shader 动态联动

1. **空气透视与色彩衰减（Atmospheric Perspective）—— 焦墨血雾双轨瞬切**：
   * **表层常规态**：通过逐材质 `SpatialShader` 根据节点 `$Z$` 轴深度（`$Z = -22\ \text{m} \sim -140\ \text{m}$`），将中远景图层（`Layer +2` / `Layer +3`）向序章主色调**焦墨残阳暗雾（`#241414`）**混合 **`$35\% \sim 55\%$`**，压低远山对比度，确保 `$Z = 0$` 舞台上的角色刀光绝对醒目。
   * **【刮白瞬切联动】**：当玩家出刀“刮白”撕开表层浓墨画布时，Shader 采样屏幕空间撕裂遮罩，撕裂区域内部的空气透视在 **`$0.15\ \text{s}$`** 内瞬切为**温润古宣漫射天光（雾气混合度降至 `$< 5\%$`）**，隐藏在里层的盛唐藏书天阁与白描山峦以极高通透度浮现。
2. **动态前景暗影框定（Foreground Framing）—— 冲刺残影掠过与破幕消融**：
   * **表层常规态**：在 `$Z = +5.0\ \text{m} \sim +7.5\ \text{m}$` 密集布置纯黑虚化剪影（粗重生铁绞链、焦黑残枝、断裂竹帘）。玩家触发《ICEY》式冲刺（`Cam Z` 瞬退 `$+1.8\ \text{m}$`）时，前景剪影高速掠过屏幕边缘，放大速度爆发感。
   * **【破幕消融联动】**：在“刮白”撕裂区域的有效窗口内，前景暗影剪影同步触发 Shader **水墨消融（Alpha Dissolve）**，转化为极淡的游丝白描线条或暂时隐去，保障里层机关跳跃的绝对无遮挡视野。
3. **跨层体积光（Volumetric Light Shafts）—— 裂缝迸射与里层安全路径指引**：
   * **表层常规态**：在 `$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$` 穿插 `Blend Mode = Add` 的斜向冷白丁达尔光束，缝合前后景水墨景片。
   * **【裂缝追光联动】**：一旦劈开表层焦墨死壁或布景，体积光束直接沿着“画布撕裂卷边裂缝”向外迸射，精准打亮里层转化出的安全可交互结构（白玉天阶、通仙仙桥、浮屠经塔），以纯粹光影直觉引导玩家前行。

## 1.4 2.5D 微俯视透视下的 `$Z = 0$` 机制碰撞中心线校准

针对序章 `$6.5^\circ \sim 8.5^\circ$` 微俯视角下地面与悬浮物产生的立体厚度，全章交互机关必须严格执行以下 `$Z = 0$` 视觉靶心校准：

* **悬空铸铁墨桶（幕 0-5）**：桶身展现 2.5D 椭圆顶面与翻滚宿墨，但**桶口正前方（`$Z = 0$` 碰撞轴线）必须镶嵌一道高亮泥金包边（`#D4A017`）**，为玩家连续空中下劈（Pogo）提供零偏差视觉靶心。
* **断崖跳板与玄武岩台阶（幕 0-1 / 0-2 / 0-7 / 0-8）**：水平铺设的立体走廊地板向 `$Z < 0$` 延伸 `$4.0\ \text{m}$` 纵深，程序碰撞箱（`CollisionShape3D`）顶面与悬崖断口必须与贴图中最锐利的**前沿承重石锋线（`$Z = 0$` 切片线）**实现 `$1:1$` 像素对齐。

---

# 第二部分：序章全 10 幕与跨章过渡 2.5D 舞台场景工程全典

```text
[幕 0-1: 死牢石阶] ──► [幕 0-2: 绝壁天堑] ──► [幕 0-3: 生铁军械营] ──► [幕 0-4: 宿墨绞盘井]
 (苏醒/万卷天阶)       (破死壁/通仙仙门)      (擦盾/天工校勘阁)       (垂直攀登/倒悬天象仪)
        │
        ▼
[幕 0-5: 悬空墨桶] ──► [幕 0-6: 生铁回廊] ──► [幕 0-7: 碑林裂隙] ──► [幕 0-8: 怒雷绝壁]
 (泥金靶心Pogo/飞天桥)  (铁栅/御画院内阁)      (断碑/先贤题跋石窟)     (暴雨断流/流水游廊)
        │
        ▼
[幕 0-9: 先锋营门] ──► [幕 0-10: 断云台死斗] ──► [幕 T-1/T-2: 飞瀑洗血卷 (跨章过渡)]
 (死寂前奏/白描洗笔台)   (墨梅三阶/“折”字宽银幕)    (千丈垂直直坠 -40m/s -> 无缝切入第一章江滩)
```

---

## 幕 0-1：死牢绝壁（破狱苏醒）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.0m`，`FOV = 28°`，`Offset Y = +2.2m`，微俯角 `Pitch = -6.5°`，阻尼 `$X = 0.12, Y = 0.25$`。
* **戏剧演戏演出**：开场镜头自残阳墨云缓缓下摇聚焦囚廊，主角挣断生铁锁链起身；首次出刀触发“刮白”教学时，镜头执行 `$0.18\ \text{s}$` 破幕缩放脉冲（`Cam Z` 瞬推 `$-1.5\ \text{m}$` 后回弹），裂口处迸射温润白描天光，揭示“铁牢不过是执笔阁涂抹的伪画”。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 焦墨铁牢）**：通体由南宋李唐大斧劈皴雕凿的黑色玄武岩条石砌成，微俯角清晰展现石阶向内延伸的纵深宽度与下方岩层横剖面；石缝渗出暗红硫化汞原矿朱砂浆液（`#C3272B`），每隔三丈嵌有填金无刃生铁戒尺。
* **里层（Baimiao Draft: 盛唐天阶）**：褪去焦墨后展现北宋手工桑皮生宣底色（`#EFE9DA`），李公麟 `$0.25\ \text{mm}$` 单线铁线描勾勒【盛唐汉白玉万卷天阶】，后方矗立依云而建的千丈通天雕花藏书架，散落浮空书法散页。

### 3. 长卷五段式工程设计与生图 Prompt
* **镜头定位**：2.5D 舞台微俯视机位，`Cam Z = +22.0m`，微俯角 `Pitch = -6.5°`，展现玄武岩石阶纵深宽度与下方岩基横剖面。
* **视差分层**：
  * `Layer -2`（`$Z = +6.0\ \text{m}$`）：失焦纯黑剪影，垂挂粗重生铁绞链与焦黑残枝。
  * `Layer -1`（`$Z = +2.0\ \text{m}$`）：垂直掠过的暗红朱砂雨丝与干炭屑。
  * `Layer 0`（`$Z = 0.0\ \text{m}$`）：玄武岩石阶立体廊道，边缘渗出朱砂血泥，泥金度量戒尺桩。
  * `Layer +1`（`$Z = -6.0\ \text{m}$`）：生铁刑架残垣与李唐大斧劈皴断石。
  * `Layer +2`（`$Z = -30.0\ \text{m}$`）：千仞立轴绝壁削面与悬空墨桶（逐材质 Shader 混入 `$45\%$` 焦墨暗雾）。
  * `Layer +3 / +4`（`$Z = -110\ \text{m} \sim -180\ \text{m}$`）：翻滚焦墨雷云、下沉血红残阳与古法手工桑皮生宣底板。

```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible basalt floor depth and walkway width, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third with subterranean rock foundation underneath, inspired by ICEY and Wu Shan Wu Xing, Stage 0-1 Prison Stairs.
- THEME: Ancient Chinese ink-wash brutalist prison cliff with Li Tang axe-cut rock textures and dripping cinnabar rainwater.
- FOREGROUND: Highly defocused raw iron chains, dripping ropes, and charred branch silhouettes framing the screen corners.
- MIDDLE-GROUND (Playable Stage): Wet black basalt corridor steps showing clear floor surface breadth, decaying iron executioner rulers with mud-gold runes, cinnabar blood decals pooling in cracks.
- BACKGROUND: Receding layers of sheer axe-cut black cliffs and suspended iron cages fading into volumetric charcoal-crimson fog and torrential rain, colossal dull blood-red setting sun on aged mulberry Xuan paper texture.
- PALETTE: Charred black (#0A0908), cold iron grey, mud gold (#D4A017), and cinnabar red (#C3272B). Seamless horizontal composition --ar 21:9
```

---

## 幕 0-2：绝壁天堑（刮白穿墙大教学）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +23.5m`，`FOV = 28°`，微俯角 `Pitch = -7.5°`，拉远视野展现八米焦墨死壁的高耸压迫与右侧万仞深渊落差。
* **戏剧演戏演出**：玩家挥刀劈开焦墨死壁瞬间，撕裂边缘卷起焦墨飞白残屑，前景暗影铁链同步水墨消融，跨层丁达尔光束直接从画布撕裂裂缝迸射而出，照亮里层通仙拱门与悬空仙桥。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 绝命焦壁）**：横亘八米高的致密焦墨死壁阻断右侧道路，墙体覆盖硬化浓墨与干裂油漆，正中悬挂工笔泥金敕令铁牌；断崖边缘 `$Z = 0$` 轴线镶嵌生铁包边，防止微俯视下起跳边缘误判。
* **里层（Baimiao Draft: 御笔仙门）**：出刀刮白后，边缘呈现粗纤维撕裂微距态，门洞内露出【盛唐御笔雕花白描通仙门】，后方为生宣祥云托举的汉白玉悬空仙桥与白描古铜大钟。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game level art, 2.5D theatrical stage perspective, far-back side-view camera with a slight 7.5-degree elevated angle showing wooden cliff walkway depth and chasm drop, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 0-2 The Great Ink Wall.
- THEME: Broken cliff path blocked by an insurmountable 8-meter-high charred-ink solid wall, torn open with a jagged hand-torn paper rift revealing a luminous baimiao celestial marble archway.
- FOREGROUND: Defocused iron chains and torn paper debris framing the edges.
- MIDDLE-GROUND (Playable Stage): Wet fractured wooden cliff walkway with visible plank depth, colossal pitch-black ink wall split open with volumetric god-rays bursting through the tear onto a white marble cloud-bridge.
- BACKGROUND: Sheer Li Tang axe-cut abyss walls receding into deep charcoal-crimson mist, floating ancient calligraphy characters inside the ivory Xuan paper void.
- PALETTE: Heavy asphalt black (#0A0908), raw iron, and luminous ivory white (#EFE9DA). --ar 16:9
```

---

## 幕 0-3：生铁军械营（弹反擦盾破防）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +16.8m`，`FOV = 26°`，`Offset Y = +1.8m`，微俯角 `Pitch = -5.5°`，阻尼 `$X = 0.05, Y = 0.05$`（死区归零）。
* **戏剧演戏演出**：玩家踏入擂台 `Area3D` 后，左右两侧生铁重型闸门用 `$0.35\ \text{s}$` 轰然落下如剧场大幕锁死视野，屏幕上下压入微幅电影黑边；舞台上方 `SpotLight3D` 体积追光打亮镇峰狱尉；精准弹反大盾触发 `$12$` 帧黑白抽色定格与 `Cam Z` 瞬推至 `+15.2m`。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 嗜血铁栅）**：封闭生铁格栅斗室，微俯角展现铁篦板地面纵深与下方熔渣池红光。镇峰狱尉手持一丈高的生铁方圆大盾（泥金《九章算术》同心圆），正面坚不可摧。
* **里层（Baimiao Draft: 校勘机关天阁）**：弹反擦除大盾后，生铁外甲化作纸灰散落，显露【盛唐天工校勘阁】，大盾原为白描浑天仪投影浑象总图，内部为缓缓自转的木质鲁班锁榫卯轴心。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a slight 5.5-degree elevated angle revealing perforated iron grating floor surface and red ember pit cross-section underneath, towering iron portcullises framing the far left and right edges like stage curtains, out-of-focus downward iron ruler spikes framing the top border, dramatic volumetric stage spotlights illuminating the center duel platform, inspired by ICEY and Wu Shan Wu Xing, Stage 0-3 Armory Duel.
- THEME: Claustrophobic iron execution chamber with suspended iron rulers and smelting furnaces leaking molten cinnabar slag.
- PALETTE: Industrial iron black, dull copper bronze, mud-gold highlights (#D4A017), and cinnabar red glow (#C3272B). --ar 16:9
```

---

## 幕 0-4：宿墨绞盘井（垂直跳跃与下坠气流）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +21.2m`，`FOV = 28°`，微俯角 `Pitch = -4.0°`，横向阻尼放宽至 `$X = 0.40$` 锁死竖井中轴，纵向阻尼收紧至 `$Y = 0.10$` 敏锐跟随高速攀登。
* **戏剧演戏演出**：角色连续踏跳上升时，极近景（`$Z = +5.5\ \text{m}$`）垂落的粗重生铁绞索产生高速向下掠过的速度残影，配合上升热气流微粒放大垂直攀升张力。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 夺命生铁井）**：垂直通天生铁深井，内壁呈弧形立体纵深，天顶巨大绞盘缓缓咬合转动，每隔 `$2.0\ \text{s}$` 垂直滴落高压沸墨重滴；两侧伸出的生铁戒尺跳板在 `$Z = 0$` 刃口处镶嵌亮泥金高光边缘。
* **里层（Baimiao Draft: 倒悬水运天台）**：里层转化为【盛唐倒悬文渊水运仪象台】，毒墨滴化作白描铜龙口中落下的甘露水滴，井壁化作盘旋上升的宋代白描飞天楼阁回廊。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, side-view camera with a slight 4-degree elevated angle showing iron platform depth inside a monumental vertical mining shaft, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 0-4 The Ink Winch Well.
- THEME: Vertical iron shaft with massive interlocking rotating bronze gears in the deep misty background, ascending horizontal iron ruler platforms bolted to curved iron walls, and dripping boiling ink droplets.
- FOREGROUND: Defocused vertical cable lines and rising hot steam particles framing the edges.
- PALETTE: Deep soot black, corroded green bronze patina, mud-gold platform edges, charcoal dust grey. --ar 16:9
```

---

## 幕 0-5：悬空墨桶（空中造桥与 Pogo 踏墨大考）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +24.5m`，`FOV = 28°`，微俯角 `Pitch = -8.5°`，阻尼 `$X = 0.12, Y = 0.25$`。加大俯角与拉远距离，同时纳入悬空墨桶顶面与深渊底部的沸墨黑池。
* **戏剧演戏演出**：玩家空中下劈（Pogo）命中墨桶瞬间，触发 `$0.05\ \text{s}$` 动作顿帧与垂直向下 `$0.12\ \text{m}$` 定向微震回弹；落地 `$Y$` 轴锚点吸附确保连续踩桶时镜头不剧烈上下颠簸。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 绝望沸墨渊）**：跨度达 `$600\ \text{px}$` 的无底断口，底部为沸腾的浓黑化骨池；空中悬挂两只八角铸铁墨桶，**桶口 `$Z = 0$` 轴线镶嵌亮泥金包边（`#D4A017`）作为强制下劈视觉靶心**，上方盘旋朱砂铁刃纸鸢。
* **里层（Baimiao Draft: 飞天连云圣桥）**：毒渊化作【万丈白描卷云海】，生铁墨桶对应祥云托举的单线白描汉白玉飞天浮屠经塔，朱砂纸鸢对应白描青鸾神鸟。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with an 8.5-degree elevated top-down angle showing octagonal bucket tops and chasm depth, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 0-5 The Void Chasm.
- THEME: 600-pixel-wide chasm over a boiling pitch-black ink lake, broken stone precipices connected by swaying octagonal cast-iron ink buckets with bright mud-gold rims on chains.
- FOREGROUND: Defocused iron chain links swinging across screen corners, swirling paper ash particles.
- BACKGROUND: Sheer Li Tang axe-cut chasm walls receding into deep charcoal-crimson mist, churning black ink geysers below.
- PALETTE: Pitch black (#0A0908), cinnabar red accents (#C3272B), mud gold (#D4A017), cold ivory stone. --ar 16:9
```

---

## 幕 0-6：生铁长廊（规矩回廊与白描画史）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +19.5m`，`FOV = 28°`，微俯角 `Pitch = -5.0°`，配合 `$3.2\ \text{m}$` 低矮天花板压低视口，强化上下夹逼的钢铁牢笼感；遭遇盲眼狱卒伏兵时启动软战斗框（主角 `$75\%$` + 敌人质心 `$25\%$`，自动微退 `$+1.4\ \text{m}$`）。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 窒息回廊）**：厚重黑铁方砖走廊展现清晰地板纵深，天花板密布倒垂生铁尖矛，墙壁挂满滴血黑色方木刑牌。
* **里层（Baimiao Draft: 翰林丹青秘卷廊）**：回廊舒展为高阔轩敞的【盛唐翰林御画长弄】，木质刑牌背后显现一轴轴丈二高的大师白描单线自画像，地面化作纯白汉麻编织长毯。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, side-view camera with a slight 5-degree elevated angle showing black iron tiled floor depth, horizontal cutaway corridor in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 0-6 The Iron Gallery.
- THEME: Claustrophobic low-ceiling iron execution corridor lined with hanging black wooden execution tags dripping blood and downward-pointing iron spearheads overhead.
- FOREGROUND: Out-of-focus iron spearhead silhouettes framing the top border.
- BACKGROUND: Receding identical iron gateway frames fading into smoky charcoal fog with warm furnace underglow.
- PALETTE: Charcoal black, oxidized iron brown, sparks of gold, cinnabar red stains. Seamless horizontal composition --ar 21:9
```

---

## 幕 0-7：百丈碑林裂隙（断裂界画残碑）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.8m`，`FOV = 28°`，微俯角 `Pitch = -7.0°`，阶梯跳落时通过 `$0.25\ \text{s}$` `Tween` 落地 `$Y$` 轴平滑吸附过渡基准线。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 破损荒冢碑石）**：地表呈现 `$2.0\ \text{m}$` 落差断层台阶，由斜插在绝壁上的断裂黑色玄武岩界碑组成，微俯角清晰展现断碑顶面平台厚度，地缝倾泻焦墨流沙瀑布。
* **里层（Baimiao Draft: 摩崖白描石窟）**：碎石断崖转化为【盛唐先贤题跋摩崖石窟】，满壁镌刻盛唐飞仙天女与画仙白描线刻，乱石化作白描篆刻朱文方印托举的浮空经台。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 7-degree elevated angle showing stepped basalt stele tops and depth, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 0-7 The Shattered Stele Rift.
- THEME: Collapsed black boundary steles across a cracked chasm with dry charcoal sandfalls and stepped cliff platforms.
- FOREGROUND: Angular fractured stele corners in sharp out-of-focus black silhouette framing the corners.
- BACKGROUND: Colossal split boundary monuments tilted at chaotic angles, rivers of black ink sand pouring into atmospheric mist.
- PALETTE: Weathered basalt black, flaking mud-gold inscriptions (#D4A017), dry stone grey, faded raw Xuan paper. Seamless horizontal composition --ar 21:9
```

---

## 幕 0-8：雷暴绝壁栈道（飞瀑前夕）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +23.5m`，`FOV = 28°`，微俯角 `Pitch = -6.5°`，沿崖壁栈道呈 `$25^\circ$` 平缓抬升，伴随雷电闪光与微幅环境震屏。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 破损天堑危栈）**：悬挂于万仞黑壁外的倾斜腐木栈道，微俯角展现木板走廊宽度与下方深渊落差；暴风裹挟暗红朱砂血雨斜掠镜头，岩壁布满猩红雷火焦痕。
* **里层（Baimiao Draft: 凌云听雨飞阁）**：危栈化作【凌云避风飞阁】，单线白描琉璃避风窗隔绝暴风雨，飞檐悬挂三十六枚白描古铜风铃。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6.5-degree elevated angle showing wooden cliffside plank path depth, diagonal ascending cutaway stage, inspired by ICEY and Wu Shan Wu Xing, Stage 0-8 Thunderstorm Cliff.
- THEME: Treacherous rotting wooden cliffside plank path fastened by rusted iron brackets into sheer axe-cut basalt cliff, exposed to torrential cinnabar rain and scarlet lightning.
- FOREGROUND: Slanted dark rain sheets and broken rope silhouettes framing the borders.
- BACKGROUND: Grand mountain wall receding in volumetric charcoal-crimson storm clouds, boiling ink sea far below.
- PALETTE: Ink black (#0A0908), violent cinnabar scarlet (#C3272B), muted wet pine wood. Seamless horizontal composition --ar 21:9
```

---

## 幕 0-9：先锋营门（死斗前奏）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +20.4m`，`FOV = 28°`，微俯角 `Pitch = -5.5°`，阻尼收紧至 `$X = 0.10, Y = 0.20$`。风声骤停，远景血红残阳透过营门缝隙在地面拉出长影，营造登台决战前的剧场静默张力。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 肃杀前哨）**：平整焦黑大理石广场展现开阔台面纵深，横亘带刺生铁拒马与六瓣血梅战旗，两根生铁蟠龙柱耸立，山门紧锁。
* **里层（Baimiao Draft: 寒林折梅仙池）**：化为清幽雅致的【折梅洗笔池】，生铁拒马对应玲珑单线白描太湖石假山，地表立有一株枝干遒劲的白描古梅老桩，繁花如雪。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 5.5-degree elevated angle showing cold basalt plaza floor depth, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 0-9 Vanguard Gate.
- THEME: Grim military outpost plaza blocked by spiked iron barricades and tattered black pennants painted with blood-red plum blossoms, coiling dragon pillars flanking a barred iron gate.
- FOREGROUND: Tattered edges of black banners in close bokeh framing the upper corners.
- BACKGROUND: Iron fortress battlements and frozen barracks receding into atmospheric mist under an oppressive crimson sunset glow.
- PALETTE: Frigid black, bone-white frost, weathered iron, cinnabar red accents (#C3272B). Seamless horizontal composition --ar 21:9
```

---

## 幕 0-10：断云台死斗（墨梅三阶段天顶决战）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：动态剧场变焦：`一阶段 Cam Z = +17.0m`（`FOV = 26°`, `Pitch = -5.5°`）$\to$ `二阶段 Cam Z = +19.5m`（应对全屏梅枝刺阵）$\to$ `三阶段题跋处决 Cam Z = +12.2m`（`FOV = 24°` 无插值瞬切）。
* **戏剧演戏演出**：左右断裂玉栏如戏台大幕锁死边界，背景占据半屏的暗红残阳投射强烈逆光；三阶段触发狂草**“折”**字处决瞬间，上下压入 `$2.39:1$` 电影黑边，全屏反相为底黑线白的金石拓片负片。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层（Top Ink: 猩红终局）**：长达 `$2200\ \text{px}$` 的汉白玉断云台，微俯角展现台面裂隙与下方岩基横剖面；墨梅身覆六相晶体血梅与万劫焦墨梅披风。
* **里层（Baimiao Draft: 摘星归真台）**：五代南唐澄心堂纸神品底色（`#F4EFE6`），断云台化作【白描摘星归真露台】，天际浮动千丈北宋李成单线白描卷轴，处决引爆怀素狂草“折”字，化作漫天梅花与白蝶。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle revealing cracked white marble arena floor depth and stone cross-section base underneath, shattered carved marble balustrades framing the far left and right edges like theater curtains, sharp jagged dry-brush thorn branches framing the top corners, dramatic volumetric stage light shafts, inspired by ICEY and Wu Shan Wu Xing, Stage 0-10 Broken Cloud Terrace.
- THEME: Grand fractured white marble dueling terrace suspended over the void, bleeding cinnabar sap from floor cracks, under thunderous ink clouds and a colossal dying blood-red setting sun.
- PALETTE: Pure marble white, pitch-black ink (#0A0908), deep mineral cinnabar (#C3272B). --ar 16:9
```

---

## 幕 T-1 / T-2：飞瀑洗血卷（跨章无缝过渡幕）

### 1. 2.5D 舞台机位与物理运动学演变
* **幕 T-1（失重垂直下坠）**：断云台从中轴线崩解，镜头沿 `Path3D` 导轨拉远至 `Cam Z = +30.0m`（`FOV = 28°`, `Pitch = -10.0°`），角色以 `$V_{y\text{max}} = -40.0\ \text{m/s}$` 垂直俯冲，两侧李唐黑岩飞速倒退，千万顷纯白山泉飞瀑冲刷剥离全身焦墨血垢。
* **幕 T-2（减速弧形滑行）**：下坠 `$3.0\ \text{s}$` 后进入 `Path3D` 抛物线滑道，`$0.6\ \text{s}$` 内完成 `$90^\circ$` 垂直-水平圆弧转角，动能转化为水平滑行（`$V_x = 18.0\ \text{m/s}$`），滑停在第一章青石浅滩起点，`Cam Z` 收回 `+22.0m`（`Pitch = -6.5°`），色调无缝切入王希孟石青石绿。

### 2. 生图 Prompt 规约
```text
2D side-scrolling action game transition art, 2.5D theatrical stage perspective, far-back side-view camera with a 10-degree elevated angle showing sheer cliff depth and rushing waterfall volume, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage T-1 Waterfall Descent.
- THEME: Monumental vertical plunge down a thousand-foot mountain waterfall, collapsing white marble slabs and rushing pure mountain spring water washing away charred ink into faint azurite-green mist below.
- FOREGROUND: Vertical torrential water speed-lines and mist spray framing the screen borders.
- BACKGROUND: Sheer vertical Li Tang axe-cut rock walls receding into atmospheric waterfall mist.
- PALETTE: Transitioning from pitch black and cinnabar into luminous mountain spring white and faint azurite tints (#16355C). --ar 16:9
```