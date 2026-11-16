# 《留白》（Ink & Void）主美视觉宪章与《ICEY》式 2.5D 舞台机位及演出总典

> **【总纲核心定位】**：
> 本典整合《留白》（*Ink* & *Void*）序章至终章（含跨章过渡与尾声）的美术定调、**《ICEY》（艾希）式 2.5D 微俯视立体舞台光学法则**、**“打破第四面墙”戏剧演戏演出机制**、**Godot 4 真 3D 双轨动态光雾渲染管线**、`StageCamera3D` 实战动态镜头参数、全 44 幕舞台调度映射总表及 AI 长卷生图提示词库。
> 全作确立**“表层伪造戏台·规矩浓墨实景（Top Ink Stage）”**与**“里层真实底本·白描宣纸底稿（Baimiao Manuscript）”**的双轨空间拓扑咬合机制——执笔阁用焦墨、生铁与铅白强行搭建出一座压抑死板的“规矩戏台”，而主角的每一次挥刀“刮白”，都是当众撕破舞台布景、揭露后方真实宣纸底稿的戏剧性反叛。

---

# 第一部分：主美视觉宪章与《雾山五行》$\times$《ICEY》舞台美学校准

## 1.1 审美校准：去“儿童绘本化”与去“扁平纸片化”

为确保《留白》兼具成人暗黑国风的肃穆史诗感与《ICEY》高速动作戏台的纵深张力，全片视觉生产必须严格执行以下四维校准准则：

1. **里层白描去“简笔画感”**：摒弃粗细均匀的现代矢量黑边与圆润卡通云纹，统一采用**南宋李公麟 `$0.25\ \text{mm}$` 单线铁线描**与**宋代《营造法式》界画法度**刻画冷峻宏伟的盛唐古建与山水；纸面保留真实的宣纸帘纹、植物长纤维、撕裂毛边、朱砂血书批注与泣血水渍，远景向苍茫水墨留白（“计白当黑”）自然消融。
2. **表层实景去“连环画描边”**：撤掉生硬的卡通封闭轮廓线，转向**《雾山五行》式的写意泼墨、李唐大斧劈皴与干裂飞白扫笔**，克制数字高频锐化，通过前、中、远景的墨雾空气透视拉开天然笔墨层次。
3. **舞台空间去“纯平面纸片感”**：全面升级为《ICEY》标志性的 **2.5D 微俯视立体舞台构图**——交互地面保持绝对水平直线，但 `Camera3D` 略微抬高并下俯 `$5.5^\circ \sim 9.0^\circ$`，清晰展现廊道、石板街、栈道与擂台向内延伸的**地面厚度与纵深宽度（Visible Floor Depth）**，宛如一座横向切开的精密微缩戏剧舞台。
4. **长卷宽幅标准**：所有横向探索与跑图概念长卷统一采用 **`$21:9$` 超宽幅长卷比例**（无缝衔接周期锁定为 `$20.48\ \text{m}$` / `$2048\ \text{px}$` 或 `$40.96\ \text{m}$` / `$4096\ \text{px}$`），封闭 BOSS 决斗戏台与深渊空战场景采用 **`$16:9$` 剧场宽银幕比例**。

---

## 1.2 双轨空间视觉特征与“演戏”叙事隐喻总览

| 维度 | 表层：伪造戏台·规矩浓墨实景（Top Ink Stage） | 里层：真实底本·白描宣纸底稿（Baimiao Manuscript） |
| :--- | :--- | :--- |
| **戏剧与叙事隐喻** | 执笔阁以焦墨、生铁、重矿彩与铅白死霜强行搭建的**“虚假戏台布景”**——沉重、窒息、一切皆按既定剧本杀戮与轮回。 | 被戏台幕布掩埋的**“太虚古宣原始底稿”**——纯净、空灵、悲悯，承载盛唐文心与先烈血书忏悔的真实世界。 |
| **破幕互动演出** | 角色出刀“刮白”或“破宣斩”时，刀光如利刃划开戏台画布，边缘卷起焦墨飞白残屑，暴露出后方的宣纸骨架与建筑界画结构线。 | 撕裂遮罩内物理规则与光雾渲染同步切换，原本致命的生铁机关在里层还原为温润的白玉石阶、木构水车或琴台。 |
| **核心笔法** | 《雾山五行》写意泼墨、李唐大斧劈皴、怀素渴笔飞白扫笔、三寸厚堆矿物颜料、工笔泥金刻线。 | 南宋李公麟 `$0.25\ \text{mm}$` 单线铁线描、顾恺之春蚕吐丝描、汉魏金石碑刻线、怀素狂草题跋。 |
| **色彩体系** | 焦墨黑（`#0A0908`）、原矿朱砂（`#C3272B`）、泥金（`#D4A017`）、石绿（`#1F4E3F`）、石青（`#16355C`）、铅白（`#F8F8F8`）。 | 暖象牙桑皮生宣（`#EFE9DA`）、温州蠲纸（`#F6F2E9`）、硬黄古宣（`#F4E8C1`）、南唐澄心堂纸与太虚纯白（`#FFFFFF`）。 |
| **舞台光影法则** | 强对比剧场追光（`SpotLight3D`）与体积光束（God Rays），暴雨、毒雾、沙暴与铅霜制造强烈的压迫感与冷光边缘勾勒。 | 温润通透的古纸漫射天光，线条向远景薄雾与大面积纯白负空间（留白）柔和隐去。 |

---

## 1.3 Godot 4 真 3D 空间 7 轨纵深拓扑与渲染管线规范

所有关卡均构建于 Godot 4 真 3D 空间（`Node3D` + `Sprite3D`）的 7 层 `$Z$` 轴深度拓扑之上。所有角色、敌人与地形物理节点（`CharacterBody3D` / `StaticBody3D` + `CollisionShape3D`）严格锁定在 `$Z = 0$` 平面（启用 `Axis Lock: Linear Z` 与 `Angular X/Y/Z`），配合窄视场角透视摄像机（`StageCamera3D`）产生真实的近大远小视差与地面纵深：

```text
├── Layer -2 (Z = +4.5m ~ +7.5m): 极近景虚化框景 (失焦铁链/垂柳/断碑角/戒尺流苏，压四角暗角)
├── Layer -1 (Z = +1.5m ~ +3.0m): 近景动态微粒层 (GPUParticles3D / Sprite3D：朱砂雨丝/石青飞沫/炭屑/毒粉)
│
├── Layer  0 (Z =  0.0m 绝对锁定): 主战斗与戏台平面 (下 1/3 横剖面 + XZ 平面铺设 3.5m~5.0m 立体纵深地板)
│
├── Layer +1 (Z = -4.0m ~ -9.0m): 次近景舞台布景 (刑架/泥金界桩/折叠屏风/汉白玉华表)
├── Layer +2 (Z = -22m ~ -45m)  : 中远景长卷主体 (大斧劈皴绝壁/青绿峰峦/倒插碑林/千手戒尺环)
├── Layer +3 (Z = -85m ~ -140m) : 极远景天顶气象 (残阳墨云/暴雨长瀑/死霜虚空，叠加深度墨雾)
└── Layer +4 (Z = -180m 巨幅天幕): 底层宣纸胎体天幕 (4K 桑皮宣/温州蠲纸/硬黄纸/澄心堂宣帘纹)
```

### 1.3.1 3D 渲染排序与双轨透视同步硬性规范
* **双 `SubViewport` 同矩阵透视遮罩**：表层实景（`TopInk_World`）与里层底稿（`Baimiao_World`）分别渲染于两张与主窗口等分辨率的 `SubViewport` 中，两者内部子 `Camera3D` 每帧严格同步主 `StageCamera3D` 的 `global_transform`、`fov` 与 `h_offset / v_offset`，确保在微俯视角横向移动或动态变焦时，表里两套 3D 场景的透视视差 `$1:1$` 严丝合缝，绝不产生滑动错位。
* **`Sprite3D` 深度缓冲与透明排序规则**：
  * **硬边缘景片**（角色、立体地板、建筑立面、前景暗影剪影）：统一将 `Alpha Cut` 设为 **`Discard`**（或 `Opaque Pre-Pass`），强制写入深度缓冲（Z-Buffer），彻底杜绝微俯角下前后景片交错导致的透明穿帮。
  * **半透明光效与粒子**（跨层体积光束、刀光残影、烟雾、雨水拉丝）：保持 `Alpha Cut = Disabled`，光束类将 `Blend Mode` 设为 **`Add`**，并按 `$Z$` 轴从远到近递增设置 `Render Priority`（远景雾 `-10` $\to$ 中景光 `-5` $\to$ 主平面特效 `+2` $\to$ 前景粒子 `+10`）。
  * **纹理过滤与边缘采样**：统一启用 `Linear Mipmap` 过滤并开启 `Clamp` 边缘采样，防止远景水墨景片在摄像机横移时产生像素闪烁或拼接黑线。

### 1.3.2 破除长卷重复感四大工程机制
1. **3D 空间队列无缝循环（`InfiniteScroll3D`）**：中远景 `Sprite3D` 切片按世界宽度 `$20.48\ \text{m}$`（`$2048\ \text{px}$`）或 `$40.96\ \text{m}$`（`$4096\ \text{px}$`）首尾队列排布，摄像机越过单个切片中心后自动将尾片平移至队首，实现零卡顿无限长卷延伸。
2. **DECO 非周期贴花**：基于噪声函数在跑道表面投射朱砂血斑、焦墨油垢、石青矿渣结晶、龟裂纹与泥金九宫线。
3. **次级独立地标覆盖层**：每隔 `$5.0\ \text{m} \sim 8.0\ \text{m}$`（`$500\ \text{px} \sim 800\ \text{px}$`）插入不可复用的舞台道具切片（断折生铁戒尺、倾覆沉船龙骨、断裂编钟架、无相跪像）。
4. **Verlet 动态垂挂物理**：`Layer -2` 与 `Layer +1` 悬空铁链、破败戏幡、垂柳、紧绷琴弦与白玉流苏绑定弹簧骨骼，响应风压与角色冲刺气流。

---

## 1.4 增强舞台立体感的三大核心渲染技法与“刮白”逐材质 Shader 动态联动

为彻底消除 2.5D 舞台中常见的前后景“纸片割裂感”，并让渲染规则直接服务于《留白》核心的“刮白 / 破宣斩”表里双轨切换玩法，所有场景 `Sprite3D` 统一挂载自定义 **`SpatialShader`**，严格执行以下三大渲染与实时联动规范：

1. **空气透视与色彩衰减（Atmospheric Perspective）—— 逐材质 Shader 双轨瞬切**：
   * **基础渲染法则**：人眼判断 2.5D 纵深的核心依据不仅是移动速度，更是**对比度衰减**。弃用无法局部关闭的全局 `WorldEnvironment` 雾，改由逐材质 `SpatialShader` 根据节点 `$Z$` 轴深度（`$Z = -22\ \text{m} \sim -140\ \text{m}$`），将中远景图层（`Layer +2` 与 `Layer +3`）向章节主色调（如序章焦墨残阳 `#241414`、第一章深青绿 `#122B28`、第二章荒原沙灰 `#2B2A27`、第三章极寒铅白 `#DCE3E8`）混合 **`$30\% \sim 60\%$`**，确保背景水墨细节丰富但绝不与 `$Z = 0$` 前景角色争抢视觉焦点。
   * **【玩法深度耦合 · 刮白瞬切】**：当玩家挥刀“刮白”或释放“破宣斩”撕开表层浓墨画布时，Shader 采样屏幕空间撕裂遮罩（Tear Mask），**撕裂区域内部的空气透视在 `$0.15\ \text{s}$` 内瞬间切换为温润的古宣漫射天光（雾气混合度降至 `$< 5\%$`）**。表层压抑的暗雾/毒雾被刀光驱散，隐藏在里层的白描建筑界画与山水骨架以极高通透度浮现。
2. **动态前景暗影框定（Foreground Framing）—— 冲刺张力与破幕消融**：
   * **基础渲染法则**：在极近景层（`Layer -2`，`$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$`），每隔一段距离布置带景深模糊的暗部虚化剪影（悬空生铁锁链、垂柳枝条、断碑棱角与垂落戒尺流苏）。当角色触发《ICEY》式高速冲刺（`Cam Z` 瞬退 `$+1.8\ \text{m}$`）经过时，前景剪影快速掠过屏幕边缘，瞬间放大速度爆发感与戏剧窥视感。
   * **【玩法深度耦合 · 破幕消融】**：在“刮白”撕裂区域的有效时间窗口与空间范围内，**前景暗部剪影同步触发 Shader 水墨消融（Alpha Dissolve）**，转化为极淡的游丝白描线条或暂时隐去，彻底解除前景遮挡对里层机关判定的视觉干扰。
3. **跨层体积光（Volumetric Light Shafts）—— 裂缝透光与安全机关指引**：
   * **基础渲染法则**：在主交互层（`$Z = 0$`）与次近背景层（`Layer +1`）之间（`$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$`）穿插半透明（**`Blend Mode = Add`**）的斜向丁达尔光束面片，将原本割裂的 2D 景片在视觉上“缝合”进同一个具有空气微粒感的立体空间。
   * **【玩法深度耦合 · 裂缝追光指引】**：表层常规状态下，体积光束作为冷峻压抑的剧场顶光；**一旦玩家劈开表层布景，体积光束直接沿着“画布撕裂卷边裂缝”向外迸射（God-Ray Burst），并精准投射打亮里层转化出的安全可交互机关**（如还原出的白玉石阶、木构水车、浮莲石墩或完好琴台）。玩家无需依赖任何 UI 图标，仅凭跨层光束的落点即可在高速战斗中一眼识别“哪块致命陷阱已转化为安全落脚点”。

| 渲染维度 | 表层浓墨实景态（Top Ink） | 里层“刮白”撕裂态（Baimiao Tear） | 玩法服务目标 |
| :--- | :--- | :--- | :--- |
| **空气透视混色** | 逐材质 Shader 向暗调/寒霜主色混合 `$30\% \sim 60\%$` | 撕裂区内切为温润宣纸漫射天光（雾效 `$< 5\%$`） | 强化表层窒息压迫感，赋予里层破障通透感 |
| **极近景暗影框** | `$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$` 密集暗影高速掠过 | 撕裂窗口内水墨消融，解除前景视觉遮挡 | 放大表层冲刺速度感，保障里层跳跃无盲区 |
| **跨层体积光束** | `$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$` 斜向追光缝合图层 | 从画布撕裂裂缝迸射，精准打亮里层安全机关 | 以纯粹光影直觉引导玩家识别双轨机关状态 |

---

## 1.5 2.5D 微俯视透视下的 `$Z = 0$` 机制碰撞中心线校准规范

采用《ICEY》式 `$5.5^\circ \sim 9.0^\circ$` 微俯视角后，地面与平台获得了真实的 2.5D 立体纵深（`$Z$` 轴宽度 `$3.5\ \text{m} \sim 5.0\ \text{m}$`）。但《留白》包含大量高频空中下劈（Pogo）、窄琴弦落脚与下沉浮桩跳跃，若立体厚度绘制不当，极易导致玩家对 `$Z = 0$` 实际物理碰撞面产生视差误判。全项目美术与程序必须严格执行以下三条校准铁律：

1. **`$Z = 0$` 交互轴线高对比视觉引导线（Mandatory `$Z = 0$` Hitbox Guideline）**：
   * 所有悬浮机关、深渊跳板与危险边缘，其 2.5D 立体纵深统一向内侧（`$Z < 0$`）延伸，而**严格对应 `$Z = 0$` 碰撞体顶面的前沿轴线，必须绘制高对比度特征引导线**，作为玩家落脚与下劈判定的绝对视觉靶心：
     * **悬空墨桶（幕 0-5）**：桶身呈现 2.5D 椭圆顶面与宿墨波纹，但桶口正前方（`$Z = 0$` 轴线）必须镶嵌一道亮泥金包边（`#D4A017`），锁定空中下劈（Pogo）命中点。
     * **沉船龙骨与下沉浮桩（幕 1-3 / 1-4）**：湿滑木桩在 `$Z = 0$` 踩踏面前沿刻画高亮石青/泥金界线，与后方（`$Z < 0$`）偏暗的浸水木纹形成清晰明暗分界。
     * **猩红琴弦与断瑟（幕 2-4 / 2-5）**：紧绷铁弦严格居中于 `$Z = 0$` 平面，弦身叠加高频猩红高光（`#FF3B3F`）与微幅声波震颤粒子，彻底消除微俯角下细弦的“踩空错觉”。
     * **下沉戒尺与浑天仪横梁（幕 3-5 / 3-7）**：纯金戒尺在 `$Z = 0$` 碰撞刃口保留锐利冷白高光边缘，后方立体厚度做微暗金属衰减。
2. **碰撞箱“主结构锋线” `$1:1$` 像素对齐（Front-Edge Alignment）**：
   * 水平铺设于 `$Z = -2.5\ \text{m} \sim +1.5\ \text{m}$` 的 2.5D 立体地板贴图，程序物理碰撞箱（`CollisionShape3D`）的顶面水平线与左右悬崖断口，必须与贴图中最锐利的主结构承重线（`$Z = 0$` 切片线）保持 `$1:1$` 像素级重合。
3. **动作特效严格锁定 `$Z = 0$` 极窄切片**：
   * 角色挥刀刀光、空中下劈命中星火与受击判定盒统一锁定在 `$Z \in [-0.15\ \text{m}, +0.15\ \text{m}]$` 切片区间内，确保视觉受击点与物理命中框零偏差。

---

# 第二部分：《ICEY》式 2.5D 舞台光学法则与三大核心实战机位

## 2.1 三大核心视觉法则与四大镜头特征

| 视觉法则 | 对应的《ICEY》镜头特征 | 工程与美术执行标准 |
| :--- | :--- | :--- |
| **法则一：水平交互 + 窄视角微俯透视** | **① 2.5D 立体舞台透视**<br>**（Visible Floor Depth）** | 启用 Godot 4 **`StageCamera3D`（`Projection = Perspective`，`FOV = 26° ~ 28°`）**配合全局 `pixel_size = 0.01`（`$Z = 0$` 处与 `$1080\text{p}$` 像素 `$1:1$` 对齐）。主地面交互线严格保持水平，摄像机抬高 `+1.8m ~ +3.6m` 并向下微俯 **`5.5° ~ 9.0°`**，使横跨 `$Z$` 轴铺设的地板贴图呈现出清晰的向内纵深厚度，同时窄 `FOV` 压缩边缘畸变，确保空中跳跃落点 `$1:1$` 精准。 |
| **法则二：超广角远景与戏台剖面** | **② 超广角远景构图**<br>**③ 左右大幕与横剖面台基** | 镜头拉远至 `Cam Z = +22.0m` 基准距离，主角在屏幕垂直高度中仅占 **`15% ~ 18%`（约 `$1/6$`）**，画面上方留出超过 `$65\%$` 的高空浮空连招空间与巨构压迫感；舞台下 `$1/3$` 露出地基岩层或木构梁架横剖面，决斗场景左右边缘布置高柱或屏风如剧场大幕。 |
| **法则三：强虚化前景与空气墨雾** | **④ 四角虚化前景压暗角** | 贴近镜头的极近景层（`$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$`）布置带景深模糊（DOF Bokeh）的暗部或线描剪影（铁链、垂柳、残碑、垂落戒尺流苏），遮挡画面四角或上下边缘约 `$12\% \sim 20\%$`，以物理遮挡压出极深的空间层次。 |

---

## 2.2 三大核心实战机位规范与标准生图镜头词

### 机位一：横版长卷跑图机位（2.5D Horizontal Scroll & Exploration）
* **构图与光学特征**：横向无限延展的水平通道贯穿画面下 `$1/3$` 处，镜头微俯 `$6.5^\circ$` 展现台阶、石板路或栈道向内延伸的地面纵深与下方地基横剖面；主角占屏高约 `$1/6$`，前瞻视野（Lookahead）向行进方向偏置，留出前方 `$65\%$` 以上的路径预判空间；四角布置失焦垂柳、铁链或残碑框景；中远景山体与楼阁在空气墨雾中层层退远。
* **Godot 4 `StageCamera3D` 基准参数**（统一 `FOV = 28°`, `pixel_size = 0.01`）：
  * 标准探索：`Cam Z = +22.0m`（第二章荒原为 `+22.8m`），抬高 `Offset Y = +2.2m`，俯角 `Pitch = -6.5°`，阻尼 `$X = 0.12 \sim 0.15, Y = 0.20 \sim 0.25$`。
  * 第一章江心极速跑打态：`Cam Z = +29.2m ~ +32.5m`，俯角 `Pitch = -8.0°`，阻尼 `$X = 0.00, Y = 0.15$`，沿 `$X$` 轴以 `$14.0\ \text{m/s}$` 强制匀速向右推进。
* **标准生图镜头头部词（Prompt Header）**：
  ```text
  2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible floor depth and walkway width, narrow telephoto perspective without fish-eye distortion, horizontal cutaway stage in the lower third with visible subterranean foundation thickness, distinct multi-layered parallax depth, out-of-focus dark foreground silhouettes framing the screen corners, crisp playable midground corridor, receding misty mountains and classical Chinese architecture in deep atmospheric fog, seamless horizontal composition --ar 21:9
  ```

### 机位二：BOSS 戏剧决斗舞台机位（Theatrical Duel Stage）
* **构图与光学特征**：画面最左与最右边缘布置高耸石柱、生铁闸门或泥金折叠屏风，像剧场大幕一样锁死左右视野；下方为跨度 `$1400\ \text{px} \sim 2200\ \text{px}$` 的平整大戏台，微俯角清晰展现石雕擂台地面纵深与下方排水槽/齿轮横剖面；顶部垂落倒悬戒尺或挂轴压暗角，舞台正中央打下斜向体积追光灯（`SpotLight3D` Spotlight Shaft），聚焦主角与 BOSS 的对峙张力。
* **Godot 4 `StageCamera3D` 基准参数**（`FOV = 26°` 窄长焦特写感）：
  * `Cam Z = +16.5m ~ +17.0m`，抬高 `Offset Y = +1.8m`，俯角 `Pitch = -5.5°`，阻尼收紧至 `$X = 0.05, Y = 0.05 \sim 0.08$`，`Dead Zone` 归零。
* **标准生图镜头头部词（Prompt Header）**：
  ```text
  2D side-scrolling boss arena concept art, symmetrical theatrical stage composition, 2.5D stage perspective, side-view camera with a slight 5.5-degree elevated angle revealing deep horizontal stage floor surface and stone cross-section base underneath, towering architectural pillars and folding screens framing the far left and right edges like theater curtains, out-of-focus hanging banners and chains framing the top border, dramatic volumetric stage spotlights illuminating the center duel platform, centered monumental background structure receding into atmospheric mist --ar 16:9
  ```

### 机位三：深渊断崖与高空浮空演武机位（Abyss & Aerial Choreography）
* **构图与光学特征**：左右两侧悬崖断口之间横跨 `$500\ \text{px} \sim 800\ \text{px}$` 的无底深渊，或完全移除地面，释放屏幕上方或下方超过 `$60\%$` 的**垂直负空间（Vertical Negative Space）**供《ICEY》式高速浮空连招与下劈踩踏施展；镜头拉远并略微加大俯角（`-8.5°`）以同时兼顾空中落脚点与深渊底部的危险提示；`Layer -1` 强化沙暴、火星、落石与暴雪的动态拉丝。
* **Godot 4 `StageCamera3D` 基准参数**（`FOV = 28°`）：
  * 峡谷横跨：`Cam Z = +23.5m ~ +26.5m`，俯角 `Pitch = -8.5°`；无地面高空战斗：`Cam Z = +27.5m ~ +34.0m`，俯角 `Pitch = -2.5°`（调平俯角释放高空弹幕视野）；垂直攀登模式放宽横向阻尼（`$X = 0.30 \sim 0.40$`）锁住竖井中轴，收紧纵向阻尼（`$Y = 0.10$`）。
* **标准生图镜头头部词（Prompt Header）**：
  ```text
  2D side-scrolling platformer level art, 2.5D stage perspective, far-back side-view camera with a slight 8.5-degree elevated top-down angle showing ledge thickness and chasm depth, narrow telephoto perspective without fish-eye distortion, broken cliff platforms separated by a deep bottomless abyss, connected by suspended aerial stepping stones and diagonal launching structures, vast vertical negative space for high-speed aerial combat, out-of-focus foreground silhouettes and dynamic wind particles streaking across the lens borders --ar 16:9
  ```

---

## 2.3 《ICEY》式“演戏演出”四大戏剧衍生机位

1. **“破幕刮白”打破第四面墙演出（Stage Scenery Tear / Meta-Glitch）**：
   * **触发时机**：角色出刀撕开表层浓墨障壁，或揭露执笔阁篡改历史的伪造布景时。
   * **视听演出**：镜头 `Cam Z` 在 `$0.18\ \text{s}$` 内瞬推 `$-1.5\ \text{m}$` 后弹性回弹，撕裂区域周围出现剧场画布被利刃划破的卷边特效与宣纸帘纹闪烁，表层剧场追光熄灭，里层温润白描天光透出，形成强烈的“戏台穿帮/揭穿谎言”元叙事（Meta）震撼。
2. **题跋处决电影宽银幕瞬切机位（Epigraph Execution Theatrical Cut）**：
   * **触发时机**：在墨梅（“折”）、墨竹（“直”）、墨骨（“藏”）、顾狂墨（“休”）触发终极处决瞬间。
   * **视听演出**：屏幕上下边缘瞬间压入 **`$2.39:1$` 电影宽银幕黑边（Cinematic Letterbox）**，`Cam Z` 无插值瞬切至 **`+12.2m ~ +13.0m`（`FOV = 24°`）**，死锁长刀贯心交接点，全屏瞬间抽色反相为“底黑线白”的金石拓片负片，配以一声金石断裂与狂草题字挥毫音效，定格 `$0.45\ \text{s}$` 后碎裂退场。
3. **跨章垂直高速舞台导轨（Cross-Chapter Vertical Stage Path3D）**：
   * 依托 Godot 4 `Path3D + PathFollow3D` 导轨驱动：序章飞瀑直坠（`Cam Z = +30.0m`, `Pitch = -10.0°`，终端速度 `$-40.0\ \text{m/s}$`）、第一章怒涛抽干直坠（`Cam Z = +31.5m`, `Pitch = -10.0°`，终端速度 `$-55.0\ \text{m/s}$`）、第二章乘狂草墨龙垂直仰冲破天门（`Cam Z = +34.5m`, `Pitch = +4.0°` 微仰视，峰值速度 `$+50.0\ \text{m/s}$`）。
4. **尾声万里大留白落幕拉远（Epilogue Grand Curtain Call）**：
   * 终章尾声从市井春雨（`Cam Z = +22.0m`）经慢速垂升俯瞰山河（`Cam Z = +34.5m`, `Pitch = -9.0°`），最终拉远至 **`Cam Z = +48.0m`（`Pitch = -5.0°`）**，整座戏台山川缩小为长卷正中画心，全屏 `$80\%$` 空间转为纯净太虚大留白，右上角盖下朱砂巨印，完成全剧“落幕”。

---

# 第三部分：Godot 4（`StageCamera3D`）实战动态镜头与《ICEY》式动作演出机制

为兼顾《ICEY》的凌厉高速连招快感、舞台戏剧张力与硬核平台判定精度，在 `StageCamera3D` 基础参数之上必须配置以下五大实战动态机制：

## 3.1 跑图探索态增强
* **落地 `$Y$` 轴舞台基准线吸附（Grounded Y-Snapping）**：设定空中高度容差阈值 `$2.5\ \text{m}$`。主角起跳或空中下劈时，只要高度变化在阈值内，镜头 `$Y$` 轴锁死在起跳前地面舞台基准线，落地瞬间用 `$0.25\ \text{s}$` `Tween` 平滑吸附，消除高频小跳导致的地面透视角度频繁抖动。
* **下探视野与俯角联动（Downward Lookahead & Pitch Bias）**：长按“下”键超过 `$0.30\ \text{s}$` 或垂直下落速度 `$V_y < -8.0\ \text{m/s}$` 时，`Offset Y` 平滑下移 `$1.8\ \text{m} \sim 2.4\ \text{m}$`，同时俯角 `Pitch` 额外下压 `$2.0^\circ$`（如 `-6.5°` $\to$ `-8.5°`），提前暴露下方毒潭与悬空落脚点，消除盲跳挫败感。
* **房间/幕次切换软过渡（Stage Area3D Blending）**：触发幕次切换 `Area3D` 时，使用 `Tween` 在 `$0.40\ \text{s}$` 内平滑过渡 `Cam Z`、`Pitch` 与左右边界限制，如剧场换景般流畅自然。

## 3.2 《ICEY》式高速战斗演出增强
* **高速冲刺滞后与 `$Z$` 轴拉远张力（Dash Lag & Z-Pullback）**：触发《ICEY》式高速残影冲刺的最初 `$0.10\ \text{s}$` 内，将水平阻尼放宽至 `$0.35$`（让角色率先化作墨影向前蹿出），同时 `Cam Z` 平滑后退 `$+1.8\ \text{m}$`（`+22.0m` $\to$ `+23.8m`），使极近景（`$Z = +6.0\ \text{m}$`）的失焦铁链与垂柳剪影高速掠过屏幕边缘，放大速度爆发感；冲刺结束 `$0.15\ \text{s}$` 内回弹复位。
* **受击顿帧 + 定向打击微震（Hit-Stop & Directional Trauma Kick）**：
  * 命中精英或破甲瞬间触发 `$0.05\ \text{s} \sim 0.08\ \text{s}$` 动作顿帧（`Engine.time_scale` 微调）；
  * 摒弃全向随机抖动，改用沿刀光矢量反冲：`h_offset` / `v_offset` 向挥刀方向瞬移 `$0.08\ \text{m} \sim 0.14\ \text{m}$` 并在 `$0.08\ \text{s}$` 内回弹；空中下劈（Pogo）踩中敌人或墨桶时向下微顿 `$0.12\ \text{m}$` 再上弹。
* **软战斗框与威胁质心偏移（Soft Threat Centroid Bias）**：半径 `$12\ \text{m}$` 内存在激活杂兵时，不锁死左右边界，将焦点设为**主角坐标（权重 `$75\%$`）+ 活跃敌人质心（权重 `$25\%$`）**，并将 `Cam Z` 微退 `$+1.4\ \text{m}$`（`+22.0m` $\to$ `+23.4m`），兼顾身后偷袭预警与流畅跑打节奏。

## 3.3 精英与 BOSS 戏剧舞台演出增强
* **剧场大幕闭锁与追光灯入场（Curtain Lock & `SpotLight3D` Cue）**：进入精英/BOSS 擂台 `Area3D` 时，左右生铁闸门或泥金折叠屏风用 `$0.35\ \text{s}$` 轰然合拢锁死视野，屏幕上下压入微幅电影黑边（`$6\%$` 高度），同时舞台上方 `SpotLight3D` 体积追光束依次打亮 BOSS 与主角，完成标准剧场开场仪式。
* **非对称 `$6:4$` 舞台构图与边缘安全区**：焦点锁定 `主角坐标 * 0.6 + BOSS 坐标 * 0.4`，并强制约束主角距离左右屏边始终保留至少 `$2.5\ \text{m}$` 闪避缓冲，防止被逼入幕布死角时视野被裁切。
* **弹反破甲 `$Z$` 轴瞬推抽色（Parry Freeze Z-Punch）**：精准弹反重盾、折叠屏风或黄金天平触发 `$12$` 帧全局黑白抽色定格瞬间，`Cam Z` 瞬推至 `+15.2m`（推进 `$1.8\ \text{m}$`），定格结束配合外甲炸裂与墨汁飞溅回弹至 `+17.0m`。

## 3.4 距离自适应缩放与高空留白（BOSS 战专用）
* **距离自适应 `$Z$` 轴后退（Distance-Driven Z-Pullback）**：当主角与 BOSS 水平距离 `$D > 8\ \text{m}$` 时，按 `$(D - 8) \times 0.60$` 平滑增加 `Cam Z`（最大叠加 `$+5.5\ \text{m}$`），防止高机动 BOSS 瞬移至版边蓄力发波时脱离视野。
* **高空威胁头顶留白（Vertical Headroom Bias）**：BOSS 升空或召唤头顶弹道（如墨骨全空战、顾狂墨千手法环）时，`Offset Y` 向上抬升至 `+3.4m ~ +3.6m`，俯角 `Pitch` 由 `-5.5°` 调平至 `-2.5°`，将地平线压低至画面下方 `$1/5$` 处以看清高空弹幕。

## 3.5 全局 5 级镜头与演出优先级仲裁栈（Camera & Stage Priority Stack）

| 优先级 | 机位与演出模式 | `Cam Z` 标尺（`FOV 28°`） | 俯角 `Pitch` / 阻尼（`$X / Y$`） | 核心控制权与演出打断规则 |
| :--- | :--- | :--- | :--- | :--- |
| **P4（最高）** | **题跋处决电影瞬切态** | `+12.2m ~ +13.0m`（`FOV 24°`） | `-3.0°` / `$0.00 / 0.00$`（瞬切） | 无条件打断一切插值，压入 `$2.39:1$` 电影黑边，死锁刀尖点心核并全屏反相负片。 |
| **P3** | **跨章转场 / 尾声落幕拉远** | `+30.0m ~ +48.0m` | `-10.0° ~ +4.0°` / `Path3D` 锁死 | 接管全部输入偏移，执行垂直高速坠落/化龙仰冲或万里大留白落幕封卷。 |
| **P2** | **BOSS / 精英剧场决斗机位** | `+16.5m ~ +17.0m`（空战 `+27.5m~+28.5m`） | `-5.5°`（空战 `-2.5°`）/ `$0.05 / 0.05$` | 锁死左右剧场大幕边界，启用 `SpotLight3D`、`$6:4$` 权重、距离自适应后退与弹反瞬推。 |
| **P1** | **跑打推进 / 深渊跳跃机位** | `+23.5m ~ +32.5m` | `-7.0° ~ -8.5°` / `$0.00~0.40 / 0.10$` | 强制横向推进或垂直攀登跟随，触发下探俯角偏置与高空浮空连招留白。 |
| **P0（基础）** | **2.5D 长卷标准探索机位** | `+22.0m ~ +22.8m` | `-6.5°` / `$0.12~0.15 / 0.20~0.25$` | 默认常驻状态，展现立体地面纵深，执行落地 `$Y$` 轴吸附与“破幕刮白”微脉冲。 |

---

# 第四部分：全游戏 44 幕（序章至尾声）2.5D 舞台机位与演出映射总表

## 4.1 【起】序章：赤朱残阳 · 狂草破规（10 幕 + 1 过渡）

| 幕次与场景名称 | 归属机位类型 | `Cam Z` / 俯角 `Pitch` | 阻尼（`$X / Y$`） | 特殊运镜与《ICEY》式演戏演出规则 |
| :--- | :--- | :--- | :--- | :--- |
| **幕 0-1 死牢绝壁** | 机位一（标准探索） | `+22.0m` / `-6.5°` | `$0.12 / 0.25$` | 微俯角展现玄武岩囚廊地面厚度；首次出刀“刮白”触发破幕脉冲与里层天光初现。 |
| **幕 0-2 绝壁天堑** | 机位三（断崖/破壁） | `+23.5m` / `-7.5°` | `$0.12 / 0.25$` | 强化八米焦墨死壁高耸感与深渊落差；破壁瞬间 `Cam Z` 瞬推 `$-1.5\ \text{m}$` 配合碎墨飞溅。 |
| **幕 0-3 生铁军械营** | 机位二（剧场决斗） | `+16.8m` / `-5.5°` | `$0.05 / 0.05$` | 左右生铁重闸如大幕落下锁死视野，`SpotLight3D` 打亮擂台，弹反镇峰狱尉触发 `+15.2m` 瞬推抽色。 |
| **幕 0-4 宿墨绞盘井** | 机位三（垂直攀登） | `+21.2m` / `-4.0°` | `$0.40 / 0.10$` | 横向阻尼放宽锁住竖井中轴，纵向敏锐跟随高速跳跃，极近景垂落铁链产生高速下掠残影。 |
| **幕 0-5 悬空墨桶** | 机位三（深渊跳跃） | `+24.5m` / `-8.5°` | `$0.12 / 0.25$` | 加大俯角展现 `$600\ \text{px}$` 沸墨池横向跨度与墨桶泥金靶心，空中下劈触发向下微顿回弹。 |
| **幕 0-6 生铁长廊** | 机位一（狭长压迫） | `+19.5m` / `-5.0°` | `$0.12 / 0.25$` | 配合 `$3.2\ \text{m}$` 矮顶天花板与走廊地面纵深，营造钢铁牢笼夹逼感，遭遇伏兵启动软战斗框。 |
| **幕 0-7 百丈碑林裂隙** | 机位一/三（阶梯断层） | `+22.8m` / `-7.0°` | `$0.12 / 0.25$` | 应对 `$2.0\ \text{m}$` 断层台阶高差，阶梯跳落平滑过渡 `$Y$` 轴舞台基准线。 |
| **幕 0-8 雷暴绝壁栈道** | 机位一（斜向导轨） | `+23.5m` / `-6.5°` | `$0.12 / 0.20$` | 沿栈道呈 `$25^\circ$` 平缓抬升，微俯角展现木栈道纵深宽度，伴随雷电闪光与逆流朱砂雨丝。 |
| **幕 0-9 先锋营门** | 机位一（死寂前奏） | `+20.4m` / `-5.5°` | `$0.10 / 0.20$` | 镜头收紧，风声骤停，远景残阳血光透过营门缝隙拉出长影，营造登台决战前夕压抑氛围。 |
| **幕 0-10 断云台死斗** | 机位二 + 电影处决 | `+17.0m` $\to$ `+19.5m` $\to$ `+12.2m` | `$0.05` $\to$ `0.00$` | 一二阶段 `$6:4$` 权重锁戏台；三阶段墨梅狂草“折”字处决压入宽银幕黑边，`+12.2m` 瞬切反相。 |
| **幕 T-1/T-2 飞瀑洗血卷** | 衍生跨章垂直 `Path3D` | `+30.0m` $\to$ `+22.0m` | `$0.30 / 0.05$` | 戏台坍塌，随飞瀑以 `$-40.0\ \text{m/s}$` 垂直直坠 `$3.0\ \text{s}$` 后经 `$90^\circ$` 弧形滑道切入第一章戏台。 |

## 4.2 【承】第一章：青绿叠翠 · 墨竹狂澜（11 幕 + 1 过渡）

| 幕次与场景名称 | 归属机位类型 | `Cam Z` / 俯角 `Pitch` | 阻尼（`$X / Y$`） | 特殊运镜与《ICEY》式演戏演出规则 |
| :--- | :--- | :--- | :--- | :--- |
| **幕 1-1 青石浅滩** | 机位一（标准探索） | `+22.0m` / `-6.5°` | `$0.15 / 0.25$` | 微俯角展现青石板与浅水波纹的立体纵深，远景垂直运动阻尼压缩防止水面晃动。 |
| **幕 1-2 界画围堰** | 机位一（大坝压迫） | `+23.5m` / `-6.0°` | `$0.15 / 0.25$` | 拉远展现 `$20\ \text{m}$` 生铁重坝的立面压迫感与上方蓄水池的垂落水帘。 |
| **幕 1-3 沉船万人坑** | 机位一/三（残骸跨越） | `+22.8m` / `-7.5°` | `$0.15 / 0.25$` | 微俯角看清沉船龙骨木梁的 `$Z = 0$` 高亮落脚边，下探偏置防止误落石青流沙泥沼。 |
| **幕 1-4 石青泥沼** | 机位三（毒潭机制） | `+22.0m` / `-8.0°` | `$0.15 / 0.25$` | 覆盖 `$500\ \text{px}$` 无落脚点毒潭与下沉浮桩，踩踏下沉瞬间叠加微幅镜头下坠缓冲。 |
| **幕 1-5 画屏水阁** | 机位二（剧场决斗） | `+16.8m` / `-5.5°` | `$0.05 / 0.08$` | 左右泥金折叠屏风合拢如戏台围幕，水阁地板倒映波光，弹反伏波画督重屏触发瞬推抽色。 |
| **幕 1-6 千竿墨竹阵** | 机位一（竹林穿行） | `+21.2m` / `-6.0°` | `$0.15 / 0.25$` | 极近景巨竹形成高速掠过的舞台栅栏，遭遇铁竹飞刀伏击时触发软战斗框与冲刺残影。 |
| **幕 1-7 怒浪前哨** | 机位一（提速预告） | `+25.2m` / `-7.0°` | `$0.15 / 0.20$` | 视野外扩展现 `$8.0\ \text{m/s}$` 湍急江势与木筏厚度，为下一幕强制横推跑打做视觉铺垫。 |
| **幕 1-8 碎木狂飙** | 机位一（极速跑打 I） | `+29.2m` / `-8.0°` | `$0.00 / 0.15$` | 镜头强制沿 `$X$` 轴以 `$14.0\ \text{m/s}$` 匀速向右推进，前瞻让位于高速劈砍浮木与跃迁节奏。 |
| **幕 1-9 泼彩断江** | 机位一（极速跑打 II） | `+30.5m` / `-8.0°` | `$0.00 / 0.15$` | 保持 `$14.0\ \text{m/s}$` 推进，广角容纳二十米突起焦墨死壁与漫天挥毫墨竹剪影。 |
| **幕 1-10 逆水应龙** | 机位一/三（跑打 III） | `+32.5m` / `-7.5°` | `$0.00 / 0.15$` | 宏大舞台视野，沿三百丈白描应龙龙脊起伏执行波浪形 2.5D 追踪，戏感拉满。 |
| **幕 1-11 墨竹终局** | 机位二 + 电影处决 | `+16.5m` $\to$ `+12.2m` | `$0.05` $\to$ `0.00$` | 追光灯聚焦龙头两角之间；墨竹狂草“直”字处决压黑边，`+12.2m` 瞬切全屏金石负片。 |
| **幕 T-1/T-2 怒涛抽干卷** | 衍生跨章垂直 `Path3D` | `+31.5m` $\to$ `+22.8m` | `Path3D` 锁死 | 随抽干的江水以 `$-55.0\ \text{m/s}$` 垂直直坠 `$3.5\ \text{s}$` 砸穿舞台底板落入第二章荒冢。 |

## 4.3 【转】第二章：飞白苍凉 · 枯笔断魂（10 幕 + 1 过渡）

| 幕次与场景名称 | 归属机位类型 | `Cam Z` / 俯角 `Pitch` | 阻尼（`$X / Y$`） | 特殊运镜与《ICEY》式演戏演出规则 |
| :--- | :--- | :--- | :--- | :--- |
| **幕 2-1 荒冢入口** | 机位一（标准探索） | `+22.8m` / `-6.5°` | `$0.15 / 0.25$` | 微俯角展现焦裂黑土与残碑散落的荒原纵深，远景垂直随动压缩烘托苍凉死寂。 |
| **幕 2-2 倒插墓碑林** | 机位一（碑林探索） | `+25.2m` / `-6.0°` | `$0.15 / 0.25$` | 广角展现上万座倒插黑色巨碑与横跨舞台的猩红琴弦网格，风沙微粒斜掠镜头。 |
| **幕 2-3 拓碑断壁** | 机位二（剧场决斗） | `+17.0m` / `-5.5°` | `$0.05 / 0.08$` | 左右生铁拓碑屏风锁死戏台，弹反司弦刑官断头古瑟触发音爆震屏与 `+15.2m` 瞬推特写。 |
| **幕 2-4 枯笔风沙峡谷** | 机位三（踏弦飞跃） | `+23.5m` / `-8.5°` | `$0.15 / 0.25$` | 加大俯角看清 `$500\ \text{px}$` 无底风沙裂谷与三根 `$Z = 0$` 高亮生铁琴弦跳板的深度落差。 |
| **幕 2-5 残瑟断头台** | 机位三（`$45^\circ$` 弹射） | `+24.5m` / `-7.0°` | `$0.15 / 0.20$` | 斩断主弦触发 `$32.0\ \text{m/s}$` 超音速弹射时，前瞻瞬间向右上 `$45^\circ$` 偏置并拉远 `Cam Z`。 |
| **幕 2-6 万古碑廊** | 机位一（狭长走廊） | `+19.5m` / `-5.0°` | `$0.15 / 0.25$` | 配合 `$3.5\ \text{m}$` 低矮天花板与倒插铁凿，营造地下棺椁般的窒息舞台纵深。 |
| **幕 2-7 韶乐金钟废墟** | 机位一/三（遗迹阶梯） | `+22.8m` / `-7.0°` | `$0.15 / 0.25$` | 围绕倾覆的巨型青铜编钟架横梁上下跳跃，挥刀敲钟共鸣时释放全屏声波扭曲环。 |
| **幕 2-8 崩解绝壁** | 机位三（落石深渊） | `+26.5m` / `-8.5°` | `$0.15 / 0.20$` | 超广角展现 `$600\ \text{px}$` 完全虚空断崖与持续下坠的崩塌巨石流，下劈落石借力腾空。 |
| **幕 2-9 司碑古坛** | 机位二（BOSS 一阶段） | `+17.0m` / `-5.5°` | `$0.05 / 0.08$` | 死区归零，锁定四方玄武岩古坛立体台面，启用 `$6:4$` 权重与长鞭距离自适应后退。 |
| **幕 2-10 凌空裂渊** | 机位三 + 电影处决 | `+27.5m` $\to$ `+13.0m` | `$0.20` $\to$ `0.00$` | 古坛碎裂坠落，调平俯角（`-2.5°`）切入无地面高空水袖战；狂草“藏”字 `+13.0m` 瞬切反相。 |
| **幕 T-1/T-2 狂草化龙破门** | 衍生跨章垂直 `Path3D` | `+34.5m` $\to$ `+22.0m` | `Path3D` 锁死 | 乘千丈狂草墨龙以 `$+50.0\ \text{m/s}$` 垂直仰冲撞碎南天门戏台穹顶，滑跪切入终章。 |

## 4.4 【合】第三章（终章）：白粉凝霜 · 天地留白（10 幕 + 3 尾声）

| 幕次与场景名称 | 归属机位类型 | `Cam Z` / 俯角 `Pitch` | 阻尼（`$X / Y$`） | 特殊运镜与《ICEY》式演戏演出规则 |
| :--- | :--- | :--- | :--- | :--- |
| **幕 3-1 铅白神道** | 机位一（神圣探索） | `+22.0m` / `-6.5°` | `$0.12 / 0.20$` | 微俯角展现汉白玉神道与泥金九宫格地砖的冰冷秩序，脚步声在空旷神殿产生回响。 |
| **幕 3-2 去色天门** | 机位一（门坊探索） | `+25.2m` / `-5.5°` | `$0.12 / 0.20$` | 拉远展现三十米熔铅重门与自转的三百六十柄纯金戒尺法环，压迫感极强。 |
| **幕 3-3 千手戒尺殿** | 机位二（剧场决斗） | `+17.0m` / `-5.5°` | `$0.05 / 0.08$` | 左右锁定金色华表大幕，冷白顶光打下，弹反平规衡司黄金天平触发抽色瞬推特写。 |
| **幕 3-4 凝霜画壁** | 机位一（破幕探索） | `+22.8m` / `-6.0°` | `$0.12 / 0.20$` | 平稳横移展现两百米冰封通天画壁，连续出刀撕开伪造画壁露出后方泣血白描底稿。 |
| **幕 3-5 虚空白塔** | 机位三（垂直升阶） | `+23.5m` / `-4.5°` | `$0.30 / 0.10$` | 横向阻尼放宽锁死塔身中轴，纵向敏锐跟随 `$800\ \text{px}$` 下沉戒尺（`$Z = 0$` 冷白刃口）高空攀登。 |
| **幕 3-6 抹痕回廊** | 机位一（狭长探索） | `+19.5m` / `-5.0°` | `$0.12 / 0.20$` | 配合 `$3.2\ \text{m}$` 矮顶与空白挂轴长阵，制造死寂停尸房般的窒息舞台纵深。 |
| **幕 3-7 天道规矩坛** | 机位三（机械机关） | `+23.5m` / `-7.5°` | `$0.12 / 0.20$` | 围绕三十米纯金浑天规矩仪交叉梁跳跃，抬高头顶留白规避活塞戒尺链。 |
| **幕 3-8 泣血深渊** | 机位三（暴雪裂渊） | `+27.5m` / `-8.5°` | `$0.20 / 0.20$` | 超广角展现 `$600\ \text{px}$` 铅霜暴雪深渊与撕裂后露出的朱砂血书岩壁。 |
| **幕 3-9 弑神神坛** | 机位二（BOSS 一阶段） | `+17.0m` / `-5.5°` | `$0.05 / 0.05$` | 锁定两千像素汉白玉擂台与莲座立体台基，启用 `$6:4$` 权重与千手戒尺弹道留白。 |
| **幕 3-10 天下大去色** | 机位三 $\to$ 二 $\to$ 处决 | `+28.5m` $\to$ `+16.5m` $\to$ `+12.2m` | `$0.20` $\to$ `0.00$` | 二阶段 `+28.5m`（`Pitch = -2.5°`）应对 `$95\%$` 白化狂澜；三阶段推至 `+16.5m`；“休”字 `+12.2m` 瞬切。 |
| **幕 E-1 市井春雨** | 机位一（尾声探索） | `+22.0m` / `-6.5°` | `$0.12 / 0.20$` | 戏台规矩瓦解，回归平和温润的江南水乡青石板街巷横向漫步，微俯角映出雨巷水光。 |
| **幕 E-2 千里山河复苏** | 衍生慢速升空 `Path3D` | `+34.5m` / `-9.0°` | 慢速垂升 | 镜头自江南市井向九霄高空缓缓垂直平移攀升，俯瞰五彩写意山河复苏。 |
| **幕 E-3 万里乾坤大留白** | 衍生终极落幕机位 | `+48.0m` / `-5.0°` | `$0.05\ \text{Hz}$` 缓拉 | 镜头拉远至宇宙长卷，全屏 `$80\%$` 转为太虚大留白，右上盖下朱砂巨印，剧终落幕。 |

---

# 第五部分：四大篇章 8 张双轨大长卷完整英文生图提示词库（《ICEY》2.5D 舞台透视版）

## 5.1 通用负向提示词（Universal Negative Prompt）
```text
characters, people, warriors, monsters, fish-eye distortion, extreme wide-angle distortion, top-down bird-eye view, isometric grid, 3D plastic render, over-sharpened, digital noise, modern architecture, neon lights, flat paper-cutout without floor depth
```

## 5.2 【起】序章：赤朱残阳 · 狂草破规
* **序章 · 表层伪造戏台：规矩浓墨实景**
  ```text
  2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible floor depth and walkway width, narrow telephoto perspective without fish-eye distortion, Wu Shan Wu Xing painterly ink wash style, natural soft brushwork. Horizontal cutaway stage in the lower third transitioning from Li Tang axe-cut black basalt prison walkways with mud-gold iron rulers, across suspended octagonal iron ink buckets with mud-gold rims over a misty chasm, to a fractured white marble terrace bleeding dark cinnabar sap (#C3272B) with visible subterranean stone foundation underneath. Out-of-focus foreground raw iron chains and charred branches framing the screen borders. Receding sheer black cliffs, hanging iron cages, dramatic volumetric stage spotlights, and a colossal dull cinnabar setting sun veiled in heavy charcoal storm clouds on aged mulberry Xuan paper texture. Seamless horizontal composition --ar 21:9
  ```
* **序章 · 里层真实底本：白描宣纸底稿**
  ```text
  2D side-scrolling action game environment concept art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated angle revealing visible floor depth of carved stone corridors, narrow telephoto perspective without fish-eye distortion, Song Dynasty Li Gonglin 0.25mm single iron-wire baimiao line-art on warm aged ivory raw mulberry Xuan paper (#EFE9DA) with visible plant fibers. Horizontal architectural cutaway stage featuring carved white jade celestial stairs, an ornate imperial archway, a cloud-supported stone bridge, and a stargazing terrace. Towering multi-story wooden Tang Dynasty library pavilions, bronze water-powered armillary sphere, and hanging temple bells receding into misty depth. Softly blurred foreground silk tassels and pine boughs framing the corners, drifting calligraphy pages, tranquil mountains fading into paper grain. Seamless horizontal composition --ar 21:9
  ```

## 5.3 【承】第一章：青绿叠翠 · 墨竹狂澜
* **第一章 · 表层伪造戏台：规矩浓墨实景**
  ```text
  2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible wet stone floor depth and water surface breadth, narrow telephoto perspective without fish-eye distortion, Wu Shan Wu Xing ink and heavy mineral pigment style, natural organic brushwork. Horizontal cutaway stage in the lower third moving from wet mossy slate paths with mud-gold boundary posts, past a cast-iron river dam with bronze winches, across sunken black ship ribs and drifting timber rafts with highlighted front edges in toxic malachite-green (#1F4E3F) and azurite-blue (#16355C) rapids, into a lethal forest of barbed black cast-iron bamboo. Out-of-focus foreground dripping willow leaves and a broken iron anchor framing the borders. Monumental layered green-and-blue mineral impasto mountain peaks veiled in deep river mist. Seamless horizontal composition --ar 21:9
  ```
* **第一章 · 里层真实底本：白描宣纸底稿**
  ```text
  2D side-scrolling action game environment concept art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated angle showing visible floor depth of waterside terraces and lotus ponds, narrow telephoto perspective without fish-eye distortion, Song Dynasty 0.25mm single iron-wire baimiao line-art on warm off-white Wenzhou Xuan paper (#F6F2E9) with subtle watermarks. Horizontal cutaway stage connecting a white marble waterside pavilion with lotus balustrades, wooden aqueduct flumes, a carved stone sea-calming archway, floating lotus-leaf stepping stones, and an elegant scholar's bamboo garden. Gentle concentric water ripples, distant tiered river pavilions, and double-outlined misty mountain peaks fading softly into the paper substrate. Out-of-focus foreground outlined bamboo leaves framing the edges. Seamless horizontal composition --ar 21:9
  ```

## 5.4 【转】第二章：飞白苍凉 · 枯笔断魂
* **第二章 · 表层伪造戏台：规矩浓墨实景**
  ```text
  2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible cracked earth path width and chasm depth, narrow telephoto perspective without fish-eye distortion, Wu Shan Wu Xing dry-brush feibai ink style, raw textured brushwork. Horizontal cutaway stage in the lower third composed of desiccated cracked charcoal-black ground (#0A0908), inverted black tombstone tops, tense blood-red iron zither wires (#FF3B3F) spanning a sand chasm, a 45-degree inclined fractured cast-iron zither, and an overturned bronze Bianzhong bell rack half-buried in black quicksand cascades. Out-of-focus foreground jagged stele silhouettes and vibrating crimson cables framing the edges. Endless forest of upside-down black monoliths piercing a bleak lead-grey dust storm sky. Seamless horizontal composition --ar 21:9
  ```
* **第二章 · 里层真实底本：白描宣纸底稿**
  ```text
  2D side-scrolling action game environment concept art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated angle showing visible floor depth of stone music terraces, narrow telephoto perspective without fish-eye distortion, 0.25mm Han-Jin stone-inscription iron-wire baimiao line-art on aged imperial hard-yellow Xuan paper (#F4E8C1). Horizontal cutaway stage featuring an ornate celestial music stone gate, carved jade zither tables, floating golden Gongche musical notation stepping stones, a phoenix-head ancient zither, and an open Tang Dynasty hall housing intact white jade Bianzhong chimes and stone qing. Out-of-focus foreground flowing silk ribbons and drifting musical score pages framing the borders, distant multi-tiered bell towers amidst tranquil clouds. Seamless horizontal composition --ar 21:9
  ```

## 5.5 【合】第三章（终章）：白粉凝霜 · 天地留白
* **第三章 · 表层伪造戏台：规矩浓墨实景**
  ```text
  2D side-scrolling action game environment art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated top-down angle showing visible glossy marble roadway depth and gold gridlines, narrow telephoto perspective without fish-eye distortion, Wu Shan Wu Xing painterly texture with 95 percent desaturated lead-white frost (#F8F8F8) and mud-gold (#D4A017) order. Horizontal cutaway stage in the lower third featuring an immaculate white marble roadway engraved with gold mathematical gridlines, a 30-meter molten-lead-sealed marble gate, interlocking brass armillary sphere beams, and a pure white jade lotus throne. Out-of-focus foreground frosted white silk tassels and lead icicles framing the borders. A monumental rotating halo of 360 golden executioner rulers and sterile white pillars fading into cold mist. Seamless horizontal composition --ar 21:9
  ```
* **第三章 · 里层真实底本：白描宣纸底稿**
  ```text
  2D side-scrolling action game environment concept art, ultra-wide panoramic scroll, 2.5D theatrical stage perspective, far-back side-view camera with a slight 6.5-degree elevated angle showing visible stone terrace depth on the left, narrow telephoto perspective without fish-eye distortion, Song Dynasty 0.25mm single iron-wire baimiao line-art on Southern Tang Chengxingtang raw Xuan paper (#EFE9DA) with visible mulberry fibers. Left side cutaway stage featuring stone brush-washing desks, a wooden armillary sphere model, floating scripture pages, and trembling blood-red cinnabar cursive confession calligraphy (#C3272B) with weeping ink stains. Transitioning smoothly toward the right into 80 percent expansive untouched pure white void (negative space) with faint distant mountain outlines, anchored by a square cinnabar-red seal stamp in the top-right corner. Seamless horizontal composition --ar 21:9
  ```