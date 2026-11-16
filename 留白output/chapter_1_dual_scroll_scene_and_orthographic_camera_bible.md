# 《留白》（Ink & Void）场景原画与《ICEY》式 2.5D 舞台工程全典

## 【承】第一章：青绿叠翠 · 墨竹狂澜（2.5D 舞台重构版）

> **【主美执行总则与《ICEY》式 2.5D 舞台宪章】**：
> “世人皆赞叹王希孟《千里江山图》的石青石绿辉煌灿烂，却不知那厚堆三寸的矿物厚彩之下，是执笔阁为筑‘永恒江山’而水淹七十二县的累累白骨与三万艘沉船龙骨。
> 表层是浓艳到令人作呕、窒息黏稠的**矿彩死泽与生铁界画围堰戏台**；
> 里层则是那卷被大水沉埋的太虚古宣深处，未被污染的**‘上古白描沧浪水府’**——澄澈、辽远、神圣，通体由 `$0.25\ \text{mm}$` 南宋单线铁线描勾勒，浮动着宋代手工麻纸的粗粝帘纹与清冽水波。
> 镜头全面升级为《ICEY》（艾希）标志性的**长焦窄视角微俯视 2.5D 舞台透视**（`FOV = 26° ~ 28°`，微俯角 `Pitch = -5.5° ~ -10.0°`）：物理判定严格死锁于 `$Z = 0$` 平面，微俯视角清晰展现青石浅滩水波宽度、沉船龙骨厚度与 `$14.0\ \text{m/s}$` 奔涌江面的立体纵深，在高速踏浪跑打与斩竹破壁中演出一场撕裂矿彩的江河逆旅。”

---

# 第一部分：Godot 4 真 3D 空间 2.5D 舞台与动态渲染规范

```text
├── Layer -2 (Z = +4.5m ~ +7.5m): 极近景碎浪与竹帘 (石青墨水飞沫/垂落水草/生铁巨竹，压四角暗角)
├── Layer -1 (Z = +1.5m ~ +3.0m): 近景动态微粒层 (GPUParticles3D / Sprite3D：矿物微粒/气泡/铁竹叶拉丝)
│
├── Layer  0 (Z =  0.0m 绝对锁定): 主战斗与戏台平面 (下 1/3 横剖面 + XZ 平面铺设 3.5m~5.0m 立体江滩/木排)
│
├── Layer +1 (Z = -4.0m ~ -9.0m): 次近景水障布景 (折断生铁桅杆/泥金界桩/白描汉白玉水榭护栏)
├── Layer +2 (Z = -22m ~ -45m)  : 中远景长卷主体 (厚堆石绿千仞立轴绝壁 / 里层通天白描避水经阁)
├── Layer +3 (Z = -85m ~ -140m) : 极远景天顶气象 (翻滚绿云阴霾/倒悬暴雨长瀑/上古太虚星野，叠加逐材质雾)
└── Layer +4 (Z = -180m 巨幅天幕): 底层宣纸胎体天幕 (固定不动的 4K 温州蠲纸水渍暗斑底板)
```

## 1.1 《ICEY》式 2.5D 舞台机位四大核心模式（Godot 4 `StageCamera3D`）

全章统一采用 `Projection = Perspective` 透视摄像机配合全局贴图比例 `pixel_size = 0.01`（`$Z = 0$` 交互面与 `$1080\text{p}$` 屏幕像素 `$1:1$` 对齐）：

| 模式类别 | `Cam Z` 纵深 / `FOV` | 高度偏移 `Offset Y` 与微俯角 `Pitch` | 阻尼系数（`$X / Y$`） | 适用场景与戏剧演出表达 |
| :--- | :--- | :--- | :--- | :--- |
| **2.5D 浅滩大堤探索** | **`+22.0m ~ +23.5m`** / `FOV = 28°` | `Offset Y = +2.2m`；`Pitch = -6.5°` | `$X = 0.15, Y = 0.25$` | 幕 1-1 至 幕 1-7。微俯角展现青石浅滩水波与泥沼宽度，启用落地 `$Y$` 轴锚点吸附与冲刺 `Cam Z` 后退（`$+1.8\ \text{m}$`）。 |
| **水阁画屏剧场决斗** | **`+16.5m ~ +16.8m`** / `FOV = 26°` | `Offset Y = +1.8m`；`Pitch = -5.5°` | `$X = 0.05, Y = 0.08$`（死区归零） | 幕 1-5 伏波画督战与 幕 1-11 墨竹终局。左右泥金屏风或龙角如大幕锁死舞台，顶部 `SpotLight3D` 体积追光聚焦中心。 |
| **江心 `$14.0\ \text{m/s}$` 跑打** | **`+29.2m ~ +32.5m`** / `FOV = 28°` | `Offset Y = +2.6m`；`Pitch = -8.0°` | `$X = 0.00, Y = 0.15$`（强制匀速横推） | 幕 1-8 至 幕 1-10 狂飙跑打。超广角微俯视展现翻滚石青巨浪与三百丈白描应龙龙脊纵深，前景飞沫高速掠屏。 |
| **狂草“直”字电影处决** | **`+12.2m`** / `FOV = 24°` | 死锁长刀贯心交接点；`Pitch = -3.0°` | `$X = 0.00, Y = 0.00$`（无插值瞬切） | 幕 1-11 墨竹终极处决。压入 `$2.39:1$` 电影宽银幕黑边，全屏反相为金石拓片负片。 |

## 1.2 第一章 3D 空间长卷无缝循环、渲染排序与防重复机制

* **3D 空间长卷无缝循环（`InfiniteScroll3D`）**：
  * 远景千仞青绿峰峦面片（`Sprite3D`）按世界单位宽度 `$40.96\ \text{m}$`（`$4096\ \text{px}$`）队列循环调度；中景急流水网与沉船废墟面片按 `$20.48\ \text{m}$`（`$2048\ \text{px}$`）无缝循环拼接，导入启用 `Linear Mipmap` 与 `Clamp` 采样，消除横向高速卷动时的像素摩尔纹与拼接黑线。
* **双 `SubViewport` 与深度缓冲排序**：
  * 表里两套 3D 场景共享同一 `Camera3D` 变换矩阵；硬边缘 `Sprite3D` 启用 `Alpha Cut = Discard` 写入深度缓冲，半透明蓝绿水雾与丁达尔光束设为 `Blend Mode = Add` 并按 `$Z$` 轴递增设置 `Render Priority`。
* **破除长卷重复感四大工程机制**：
  1. **DECO 非周期贴花**：在碎木排与石堤表面随机投射黏稠石青（`#16355C`）与石绿（`#1F4E3F`）矿渣结晶贴花、湿滑绿苔与油污反光膜。
  2. **次级独立地标覆盖层**：每隔 `$5.0\ \text{m} \sim 8.0\ \text{m}$`（`$500\ \text{px} \sim 800\ \text{px}$`）穿插不可复用的独立道具（倾覆沉船龙骨、半截生铁桅杆、断裂泥金水闸、散落竹简算筹）。
  3. **Verlet 动态垂挂物理**：`Layer -2` 极近景垂挂的青黑箬竹叶、湿漉垂柳与断裂船缆绑定弹簧骨骼，受江风与高速冲刺气流扰动产生大幅后摆。
  4. **跨层蓝绿水雾与追光阻断**：在 `$Z = -2.0\ \text{m} \sim +2.0\ \text{m}$` 穿插半透明水汽雾面片与斜向光束，打破循环周期记忆。

## 1.3 第一章三大立体渲染技法与“刮白”逐材质 Shader 动态联动

1. **空气透视与色彩衰减（Atmospheric Perspective）—— 矿彩毒雾双轨瞬切**：
   * **表层常规态**：通过逐材质 `SpatialShader` 根据节点 `$Z$` 轴深度（`$Z = -22\ \text{m} \sim -140\ \text{m}$`），将中远景图层向第一章主色调**深青绿矿彩瘴雾（`#122B28`）**混合 **`$35\% \sim 55\%$`**，压低三寸厚堆青绿山峦的刺眼饱和度，使 `$Z = 0$` 主角的黑白水墨身法与刀光在蓝绿背景前形成强烈视觉剥离。
   * **【刮白瞬切联动】**：挥刀“刮白”撕开表层矿彩布景时，Shader 采样屏幕空间撕裂遮罩，撕裂区域内部的空气透视在 **`$0.15\ \text{s}$`** 内瞬切为**温润温州蠲纸漫射天光（雾气混合度降至 `$< 5\%$`）**，表层黏稠绿瘴散去，里层清澈的沧浪水府白描楼阁与荷塘水波瞬间透亮显现。
2. **动态前景暗影框定（Foreground Framing）—— 冲刺竹影掠过与破幕消融**：
   * **表层常规态**：在 `$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$` 布置湿漉垂柳、断裂生铁巨锚与垂直贯穿视野的生铁巨竹剪影。角色冲刺或 `$14.0\ \text{m/s}$` 江心狂飙时，前景剪影高速掠过屏幕边缘，强化速度感与丛林窥视感。
   * **【破幕消融联动】**：在“刮白”撕裂窗口内，遮挡视线的铁竹与垂柳暗影同步触发 Shader **水墨消融（Alpha Dissolve）**，确保里层荷叶石台与水闸跳跃毫无视野遮挡。
3. **跨层体积光（Volumetric Light Shafts）—— 裂缝透光与避水安全路径指引**：
   * **表层常规态**：在 `$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$` 穿插 `Blend Mode = Add` 的斜向水汽丁达尔光束，缝合江面与远山图层。
   * **【裂缝追光联动】**：劈开表层生铁水坝或矿彩障壁后，体积光束直接从画布撕裂裂缝迸射，精准打亮里层转化出的安全落脚结构（白玉荷叶石台、木构引水飞渠、白描龙舟甲板与应龙龙鳞）。

## 1.4 2.5D 微俯视透视下的 `$Z = 0$` 机制碰撞中心线校准

针对第一章 `$6.5^\circ \sim 8.0^\circ$` 微俯视角下水面、木排与沉浮机关的立体厚度，全章交互机关必须严格执行以下 `$Z = 0$` 视觉靶心校准：

* **沉船龙骨与下沉生铁浮桩（幕 1-3 / 1-4）**：木梁与圆桩在 `XZ` 平面呈现浸水立体厚度，但**严格对应 `$Z = 0$` 碰撞体顶面的前沿踩踏轴线，必须刻画高亮泥金/石青界线（`#D4A017` / `#3B82F6`）**，与后方（`$Z < 0$`）偏暗的湿滑木纹形成清晰明暗分界，杜绝踩空或下劈偏差。
* **顺流漂移碎木排与龙舟甲板（幕 1-8 / 1-9 / 1-10）**：高速狂飙状态下，碎木排前沿与应龙龙脊 `$Z = 0$` 中心线附加高频白描高光描边，确保 `$14.0\ \text{m/s}$` 极速跳跃时的落点预判清晰锐利。

---

# 第二部分：第一章全 11 幕与跨章过渡 2.5D 舞台场景工程全典

```text
[幕 1-1: 青石浅滩] ──► [幕 1-2: 界画围堰] ──► [幕 1-3: 沉船万人坑] ──► [幕 1-4: 石青泥沼]
 (飞瀑余生/碧苔初醒)     (泥金闸门/工笔分水规矩)  (三万沉船/沧浪石坊)     (泥金靶心浮桩/曲水流觞)
        │
        ▼
[幕 1-5: 画屏水阁] ──► [幕 1-6: 千竿墨竹阵] ──► [幕 1-7: 怒浪前哨] ──► [幕 1-8: 碎木狂飙 (跑打I)]
 (弹反破屏/天工水闸)     (生铁竹矛/淇奥修竹苑)    (江流提速/避水石矶)     (14m/s 碎木排/跳浪造桥)
        │
        ▼
[幕 1-9: 泼彩断江 (跑打II)] ──► [幕 1-10: 逆水应龙 (跑打III)] ──► [幕 1-11: 墨竹终局] ──► [幕 T-1/T-2: 怒涛抽干卷]
 (20米黑墙/草书水波路)           (踏三百丈应龙龙脊)              (题跋处决狂草“直”)     (抽干江水直坠画圣荒冢)
```

---

## 幕 1-1：青石浅滩（初入青绿）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.0m`，`FOV = 28°`，`Offset Y = +2.2m`，微俯角 `Pitch = -6.5°`，阻尼 `$X = 0.15, Y = 0.25$`。
* **戏剧演戏演出**：主角自飞瀑滑停入场，镜头微俯角清晰展现青石浅滩与矿彩水面交界的纵深宽度；首次触发“刮白”时，泥瘴水面瞬间化为清澈白描溪流，锦鲤跃出涟漪。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 碧翠死水）**：长方形太湖青石板横向铺就，表面覆有湿滑绿苔与油润矿彩反光，石滩前沿 `$Z = 0$` 边缘保留清晰石棱；水边每隔五丈插有泥金包边朱漆戒律木桩。
* **里层白描宣纸底稿（Baimiao Draft: 濯缨仙榭）**：底板呈现宋代温州蠲纸底色（`#F6F2E9`），展现【盛唐沧浪濯缨水榭】，界桩化为汉白玉双勾单线莲花望柱，水榭中央摆放白描石琴案，数尾白描幼鲤在水草间游弋。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6.5-degree elevated top-down angle showing visible wet slate riverbank depth and mineral water breadth, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third, inspired by ICEY and Wang Ximeng's A Thousand Li of Rivers and Mountains, Stage 1-1 Verdant Shallows.
- THEME: Wet blue-green slate riverbank covered in toxic moss, stagnant mineral water reflecting azurite-malachite paint, mud-gold imperial boundary posts.
- FOREGROUND: Defocused dripping willow leaves and swaying bamboo silhouettes with water droplets framing the screen corners.
- MIDDLE-GROUND (Playable Stage): Glistening slate stone walkway with clear surface breadth, stagnant mineral puddle decals, mud-gold boundary posts.
- BACKGROUND: Monumental layered green mountain peaks coated in thick malachite mineral pigment impasto, veiled in deep azurite-green river mist.
- PALETTE: Malachite green (#1F4E3F), azurite blue (#16355C), iron black, mud gold (#D4A017). Seamless horizontal composition --ar 21:9
```

---

## 幕 1-2：界画围堰（生铁分水规矩）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +23.5m`，`FOV = 28°`，微俯角 `Pitch = -6.0°`，拉远构图展现 `$20\ \text{m}$` 生铁重坝的工业立面压迫感与顶部坝道纵深。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 铁壁断江）**：重逾万斤的铸铁闸门以工笔泥金（`#D4A017`）绘制水道度量网格，高压石青水线从铁缝激射而出，坝顶走道展现金属板拼接深度。
* **里层白描宣纸底稿（Baimiao Draft: 广济鱼嘴金刚堤）**：显现【盛唐都江广济白描鱼嘴堤】，冰冷生铁转化为竹笼卵石与木构引水飞渠，清流自然分流。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 6-degree elevated angle showing dam crest walkway depth and bronze winches, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 1-2 The Bound Water Dam.
- THEME: 20-meter cast-iron river dam locking back high-pressure toxic azurite-blue water with mud-gold mathematical gridlines.
- FOREGROUND: Heavy vertical iron gear teeth hanging from the top border, splashing water droplets.
- MIDDLE-GROUND (Playable Stage): Industrial cast-iron walkway across the dam crest, high-pressure water-jet leaks, bronze winches.
- BACKGROUND: Swollen green reservoir held by the iron wall, sheer malachite rock faces receding into atmospheric mist.
- PALETTE: Industrial iron black, deep copper bronze, azurite blue (#16355C), mud gold (#D4A017). Seamless horizontal composition --ar 21:9
```

---

## 幕 1-3：沉船万人坑（石青泥沼）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.8m`，`FOV = 28°`，微俯角 `Pitch = -7.5°`，加大俯角使玩家在跳跃跨越沉船龙骨木梁时，能清晰判断梁柱的立体宽度与下方石青流沙危险区。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 矿彩死泽）**：沉船肋骨由被宿墨浸透发黑的千年乌木制成，表面结满石绿矿物结晶（`#1F4E3F`）；**每根龙骨木梁的 `$Z = 0$` 踩踏面前沿刻画高亮泥金/石青界线**，确保落脚判定精准。
* **里层白描宣纸底稿（Baimiao Draft: 沧浪水府仙阁）**：转化为洁白的【上古白描巨灵镇海石坊】与雕梁画栋水榭长廊，虚空中游弋十丈长的单线白描锦鲤充当跳台。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 7.5-degree elevated angle showing wet ship rib beam depth over mineral sludge, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 1-3 Sunken Ship Graveyard.
- THEME: Ancient Chinese shipwreck timbers submerged in toxic malachite-green and azurite-blue mineral sludge, chained skeletons.
- FOREGROUND: Silhouette of an enormous fractured iron anchor and rotting seaweed framing the screen corners.
- MIDDLE-GROUND (Playable Stage): Wet charred-wood ship ribs acting as precarious bridges with highlighted front edges, thick green mineral crust decals.
- BACKGROUND: Dense forest of broken masts and half-sunken hull silhouettes fading into deep green-blue river fog.
- PALETTE: Malachite green (#1F4E3F), azurite blue (#16355C), pitch black, bone white. Seamless horizontal composition --ar 21:9
```

---

## 幕 1-4：石青泥沼（空中下劈造梁）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +22.0m`，`FOV = 28°`，微俯角 `Pitch = -8.0°`，启用下探视野偏置与空中下劈微顿回弹。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 恶臭化骨潭）**：跨度 `$500\ \text{px}$` 的无落脚点毒潭，漂浮三枚上下沉浮的生铁圆桩（踩踏后 `$1.2\ \text{s}$` 下沉）；**浮桩在 `$Z = 0$` 轴线上镶嵌高亮泥金防滑环**，防止微俯视角下产生踩偏错觉。
* **里层白描宣纸底稿（Baimiao Draft: 兰亭流觞雅苑）**：显现【盛唐曲水流觞白描诗台】，下沉铁桩化为祥云托举的单线白描汉白玉荷叶石台，水面漂浮青花瓷羽觞与《兰亭序》残卷。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling platformer level art, 2.5D theatrical stage perspective, far-back side-view camera with an 8-degree elevated top-down angle showing circular iron stepping post tops and bubbling sludge depth, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 1-4 The Mineral Sludge Pit.
- THEME: Treacherous 500-pixel-wide sludge pit of bubbling azurite-blue and malachite-green toxic mineral sludge, sinking rusted iron posts with mud-gold top rims, grotesque green jade toad statues.
- FOREGROUND: Defocused toxic droplets and floating water-lily silhouettes framing the borders.
- BACKGROUND: Eroded white marble bridge ruins choked by thick mineral crusts, distant waterfalls of azurite pigment in misty fog.
- PALETTE: Toxic azurite blue (#16355C), malachite green (#1F4E3F), tarnished bronze, mud gold (#D4A017). --ar 16:9
```

---

## 幕 1-5：画屏水阁（精英怪：伏波画督战）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +16.8m`，`FOV = 26°`，`Offset Y = +1.8m`，微俯角 `Pitch = -5.5°`，阻尼 `$X = 0.05, Y = 0.08$`（死区归零）。
* **戏剧演戏演出**：进入水阁 `Area3D` 时，左右生铁泥金折叠屏风如剧场大幕轰然合拢锁死视野，大理石地板清晰倒映窗外破窗而入的 `SpotLight3D` 体积天光；精准弹反伏波画督折叠重屏触发 `$12$` 帧黑白抽色定格与 `Cam Z` 瞬推至 `+15.2m`。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 泥金画牢）**：伏波画督手持高逾一丈的生铁泥金重屏（《江山永固图》），推盾前冲时从地面掀起高逾两米的石青泥金毒浪。
* **里层白描宣纸底稿（Baimiao Draft: 营造天工总图）**：显现【盛唐天工水闸机械控制枢纽】，生铁屏风原为双向水闸启闭连杆白描图谱，弹反擦除后露出内部单线白描木偶人骨架。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle revealing reflective marble hall floor depth, massive four-panel folding iron shields engraved with gold-mineral paintings framing the far left and right edges like theater curtains, defocused hanging wet silk scrolls framing the top border, dramatic volumetric stage light shafts, inspired by ICEY and Wu Shan Wu Xing, Stage 1-5 Duel in the Screen Pavilion.
- THEME: Enclosed Chinese waterside hall with azurite pigment puddles on marble floor, latticed windows shaking under exterior green tidal waves, bronze machinery cogs visible in walls.
- PALETTE: Heavy mud gold (#D4A017), deep malachite green (#1F4E3F), azurite blue (#16355C), pitch black. --ar 16:9
```

---

## 幕 1-6：千竿墨竹阵（穿林断铁）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +21.2m`，`FOV = 28°`，微俯角 `Pitch = -6.0°`。极近景（`$Z = +5.0\ \text{m}$`）排列碗口粗的焦黑生铁巨竹剪影，角色高速冲刺穿林时，前景竹竿如栅栏般高速掠过屏幕边缘，配合飞刀铁竹叶拉丝制造极强动作张力。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 生铁杀戮竹海）**：黑石跑道展现清晰地表深度，其间斜刺尖锐生铁竹桩陷阱（`$Z = 0$` 刃口泛惨绿毒光），狂风吹过竹林攒射飞刀铁竹叶。
* **里层白描宣纸底稿（Baimiao Draft: 淇奥君子修竹苑）**：铁竹转化为苏轼、文同笔下潇洒挺拔的宋代单线白描秀竹，飞刀竹叶化为飘落的白描竹叶，地刺化为柔软的白描松针软垫。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, side-view camera with a 6-degree elevated angle showing wet charcoal stone path depth, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 1-6 The Iron Bamboo Forest.
- THEME: Lethal forest of pitch-black rigid cast-iron bamboo stalks with sharp barbed blades at every node and angled iron punji stick traps on the path.
- FOREGROUND: Defocused vertical thick iron bamboo trunks framing the left and right edges.
- BACKGROUND: Infinite dense layers of metallic bamboo stalks fading into deep malachite-green rain mist.
- PALETTE: Pitch black, raw iron grey, poisoned malachite green highlights (#1F4E3F). Seamless horizontal composition --ar 21:9
```

---

## 幕 1-7：怒浪前哨（江流提速）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +25.2m`，`FOV = 28°`，微俯角 `Pitch = -7.0°`，外扩视野展现 `$8.0\ \text{m/s}$` 湍急江势与码头的立体结构，为下一幕强制横推跑打做视觉铺垫。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 崩解绝流）**：突出于江心的黑色玄武岩礁石，码头生铁系缆桩被巨力撕裂，前方江水化为翻滚石青石绿洪流。
* **里层白描宣纸底稿（Baimiao Draft: 白龙避水矶）**：破损缆桩处矗立一尊单线白描汉白玉镇江石犀神兽，鼻息化作悬空长卷引渡仙桥。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 7-degree elevated angle showing wet basalt river rock promontory depth and rushing rapids breadth, horizontal cutaway stage in the lower third, inspired by ICEY and Wu Shan Wu Xing, Stage 1-7 The Torrential Outpost.
- THEME: Crumbling black basalt river rock jutting into an 8 m/s raging torrent of toxic malachite-green water, snapped mooring posts and collapsed iron pier pilings.
- FOREGROUND: Splashing green water foam and frayed iron cables framing the borders.
- BACKGROUND: Churning emerald river torrent and towering green peaks veiled in storm lightning and mist.
- PALETTE: Deep basalt black, malachite green (#1F4E3F), azurite foam (#16355C), stormy sky grey. Seamless horizontal composition --ar 21:9
```

---

## 幕 1-8：碎木狂飙（极速跑打第一阶段）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +29.2m`，`FOV = 28°`，`Offset Y = +2.6m`，微俯角 `Pitch = -8.0°`，阻尼 `$X = 0.00, Y = 0.15$`。`StageCamera3D` 沿 `Path3D` 强制以 **`$14.0\ \text{m/s}$`** 匀速向右推进。
* **戏剧演戏演出**：超广角微俯视展现辽阔翻滚的石青江面纵深，极近景（`$Z = +5.5\ \text{m}$`）石青浪头飞沫高速掠过镜头边缘，放大极速顺流跑打的肾上腺素张力。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 狂飙碎木劫）**：松木排在 `$14.0\ \text{m/s}$` 激流中顺流漂移（踩踏后 `$1.5\ \text{s}$` 下沉），**木排 `$Z = 0$` 前沿边缘刻画泥金防滑高光**；迎面高速撞来生铁浮标与十米石青断头浪。
* **里层白描宣纸底稿（Baimiao Draft: 龙舟泛雪仙境）**：显现平稳航行于太虚的【盛唐皇家单线白描龙舟】，碎木排化为雕花甲板，暗礁浮标化为展开琴谱的白描竹筏诗台。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with an 8-degree elevated top-down angle showing drifting wooden timber raft tops and wide rushing rapids surface, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage 1-8 River Rafting Rush.
- THEME: High-speed rafting rush across torrential malachite-green and azurite-blue rapids, jumping across breaking wooden timber rafts with highlighted front edges, iron razor buoys, and broken cargo boxes.
- FOREGROUND: High-speed horizontal water spray streaks and splashing green foam framing the camera edges.
- BACKGROUND: Blue-green canyon walls, massive iron water gates, and distant waterfalls receding into river mist.
- PALETTE: Dynamic malachite green (#1F4E3F), azurite blue (#16355C), foam white, iron black. Seamless horizontal composition --ar 21:9
```

---

## 幕 1-9：泼彩断江（极速跑打第二阶段）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +30.5m`，`FOV = 28°`，微俯角 `Pitch = -8.0°`，保持 `$14.0\ \text{m/s}$` 横向推进。冲撞二十米焦墨死壁前 `$0.2\ \text{s}$` 挥刀施展【顺流留白斩】破壁瞬间，叠加破幕缩放脉冲与画布撕裂飞白爆发。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 墨竹横江截杀）**：督监墨竹踏双枪在前方浪尖挥毫，每隔 `$3.0\ \text{s}$` 筑起高达二十米的纯黑焦墨死壁横截江面，死墙中央 `$Z = 0$` 弱点处闪烁泥金虚线。
* **里层白描宣纸底稿（Baimiao Draft: 狂草水波仙门）**：死壁转化为倒挂天地的【太虚白描狂草水波经门】，弱点处显现单线草书“截断巫山云雨，高峡出平湖”，破壁穿门而过带出漫天金色字符碎屑。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with an 8-degree elevated angle showing river surface depth and timber rafts heading toward a monumental 20-meter-high solid pitch-black ink wall with glowing mud-gold cutlines, inspired by ICEY and Wu Shan Wu Xing, Stage 1-9 Piercing the Black Wall.
- FOREGROUND: Swirling razor-sharp iron bamboo leaves streaking across the screen borders.
- BACKGROUND: Steep blue-green mountain cliffs, boiling azurite river torrents, and stormy clouds in deep atmospheric mist.
- PALETTE: Heavy ink black (#0A0908), toxic malachite green (#1F4E3F), azurite blue (#16355C), flashing mud gold (#D4A017). Seamless horizontal composition --ar 21:9
```

---

## 幕 1-10：逆水应龙（极速跑打第三阶段）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：`Cam Z = +32.5m`，`FOV = 28°`，微俯角 `Pitch = -7.5°`，沿三百丈白描应龙起伏的龙脊执行波浪形 2.5D 动态追踪。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 困龙锁江）**：应龙龙躯钉满生铁灭水锥，墨竹化为四丈高青绿竹节修罗在龙角上方投掷矿浆水雷，大江掀起百米巨澜。
* **里层白描宣纸底稿（Baimiao Draft: 太虚应龙真身）**：龙背生铁枷锁被斩断，单线汉白玉龙鳞化作宽阔坚实的白描踏台（**`$Z = 0$` 龙脊中轴线泛温润宣纸金光**），应龙喷薄辟水神光撞碎前方生铁战船。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a 7.5-degree elevated angle showing the broad serpentine white marble spine scales of a colossal mythological baimiao water dragon rising out of a raging river, inspired by ICEY and Wu Shan Wu Xing, Stage 1-10 Riding the Baimiao Dragon.
- FOREGROUND: Flying dragon whisker line-art and lightning sparks slicing across the screen corners.
- BACKGROUND: Churning malachite-green and azurite-blue river abyss far below, shattered iron warships, stormy mountain horizons veiled in mist.
- PALETTE: Radiant white dragon line-art, toxic malachite green (#1F4E3F), azurite blue (#16355C), dark storm clouds. Seamless horizontal composition --ar 21:9
```

---

## 幕 1-11：墨竹终局（题跋处决：狂草“直”）

### 1. 2.5D 舞台机位与戏剧演出控制
* **镜头参数**：剧场决斗 `Cam Z = +16.5m`（`FOV = 26°`, `Pitch = -5.5°`），死锁应龙龙头两角之间；终极题跋处决瞬间无插值瞬切至 `Cam Z = +12.2m`（`FOV = 24°`）。
* **戏剧演戏演出**：左右两只巨大单线白描龙角如剧场大幕框定舞台，两岸千丈石绿巨浪凝固如翡翠冰川；触发狂草“直”字处决瞬间，上下压入 `$2.39:1$` 电影黑边，全屏反相为底黑线白的金石拓片负片。

### 2. 双轨空间咬合与 `$Z = 0$` 校准
* **表层规矩浓墨实景（Top Ink: 狂暴剥离）**：墨竹周身生铁竹甲被纵劈炸飞，露出焦黑枯萎躯干与中空剧毒画芯，断裂狼牙竹枪斜插龙头。
* **里层白描宣纸底稿（Baimiao Draft: 止水归真仙台）**：宋代白鹿纸底色（`#FAF6ED`），墨竹显现清癯文士单线白描真容；处决引爆怀素狂草巨字——**“直”**，墨竹化作亿万白描竹叶与白蝶消散。

### 3. 长卷五段式工程设计与生图 Prompt
```text
2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a 5.5-degree elevated angle showing the flat white jade dragon-head terrace surface, two colossal baimiao single-line dragon horns framing the far left and right edges like stage curtains, floating outlined bamboo leaves framing the top corners, dramatic golden god-rays breaking through clearing storm clouds, inspired by ICEY and Wu Shan Wu Xing, Stage 1-11 Mo Zhu's Execution Terrace.
- THEME: Immaculate white marble dragon-head dueling arena with shattered green bamboo armor splinters, flanked by frozen crystalline malachite waves standing like emerald walls in the misty distance.
- PALETTE: Pure ivory white (#FAF6ED), ink black (#0A0908), vibrant emerald green (#1F4E3F), radiant gold (#D4A017). --ar 16:9
```

---

## 幕 T-1 / T-2：怒涛抽干卷（跨章无缝过渡幕）

### 1. 2.5D 舞台机位与物理运动学演变
* **幕 T-1（江底裂宣与江水抽干）**：墨竹遗留的提斗大笔垂直砸穿江底太虚宣纸底板，裂开千丈十字口。视角沿 `Path3D` 拉远至 `Cam Z = +31.5m`（`FOV = 28°`, `Pitch = -10.0°`），以 **`$-55.0\ \text{m/s}$`** 终端速度垂直下冲，亿万吨青绿江水被负压抽干。
* **幕 T-2（急速脱水与垂直俯冲）**：两侧青绿主峰急速脱水氧化剥落为焦黑死石。主角伴随碎石直坠 `$3.5\ \text{s}$`，双足稳稳砸在第二章倒插汉白玉残碑断面上（`Cam Z` 恢复 `+22.8m`, `Pitch = -6.5°`），无缝切入第二章《飞白苍凉》。

### 2. 生图 Prompt 规约
```text
2D side-scrolling action game transition art, 2.5D theatrical stage perspective, far-back side-view camera with a 10-degree elevated angle showing vertical chasm depth and swirling vortex volume, narrow telephoto perspective without fish-eye distortion, inspired by ICEY and Wu Shan Wu Xing, Stage T-1 River Desiccation.
- THEME: Colossal riverbed paper tear sucking down millions of tons of green mineral water, towering malachite mountains rapidly desiccating and flaking into parched cracked black rock steles.
- FOREGROUND: Water vortex speed-lines, falling desiccated stone boulders, and drying mud flakes framing the edges.
- PALETTE: Fading from malachite green (#1F4E3F) into parched charcoal grey (#0A0908) and dry-brush bone white. --ar 16:9
```