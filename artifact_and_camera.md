# 《留白》（Ink & Void）主美视觉宪章与 2.5D 微俯视镜头工程总典

> **【总纲核心定位 · SOP 4.0 唯一真值基准】**：
> 本典整合《留白》（*Ink & Void*）序章至终章（含跨章过渡与尾声）的美术定调、**2.5D 微俯视透视（`Camera3D`）**光学法则、Godot 4.3+ 实战动态镜头参数、全 44 幕机位映射总表及 AI 长卷生图提示词库。
> 全作确立**“表层规矩浓墨实景（Top Ink）”**与**“里层白描宣纸底稿（Baimiao Draft）”**的双轨 3D 空间拓扑咬合机制，融合《雾山五行》的苍劲写意笔墨、宋代绘画法度与《ICEY》（艾希）的舞台剧场张力。

---

# 第一部分：主美视觉宪章与《雾山五行》美术校准

## 1.1 审美校准：彻底杜绝“儿童绘本化”
为确保《留白》作为成人暗黑国风动作游戏的肃穆感与史诗张力，全片视觉生产必须严格执行以下去卡通化准则：
1. **里层白描去“简笔画感”**：摒弃粗细均匀的现代矢量黑边与圆润卡通云纹，统一采用**南宋李公麟 $0.25\ \text{mm}$ 单线铁线描**与**宋代《营造法式》界画法度**刻画冷峻宏伟的盛唐古建与山水；纸面必须保留真实的宣纸帘纹、植物长纤维、撕裂毛边、朱砂血书批注与泣血水渍，远景大面积向苍茫水墨留白（“计白当黑”）自然消融。
2. **表层实景去“连环画描边”**：撤掉生硬的卡通封闭轮廓线，转向**《雾山五行》式的写意泼墨、李唐大斧劈皴与干裂飞白扫笔**，克制数字高频锐化，通过 `Camera3D` 真实 $Z$ 轴景深虚化（DoF）与墨雾空气透视拉开天然笔墨层次。
3. **长卷宽幅与台面厚度标准**：所有横向探索与跑图概念长卷统一采用 **`$21:9$` 超宽幅长卷比例**（无缝衔接周期锁定为 `$2048\ \text{px}$` 或 `$4096\ \text{px}$`），封闭 BOSS 擂台与机制深渊场景采用 **`$16:9$` 舞台剧场比例**；所有可行走舞台必须体现出微俯视视角下的**顶面纵深宽度（$3.2\ \text{m}$）与边缘立面厚度**。

---

## 1.2 双轨空间视觉特征总览

| 维度 | 表层：规矩浓墨实景（Top Ink） | 里层：白描宣纸底稿（Baimiao Draft） |
| :--- | :--- | :--- |
| **叙事隐喻** | 执笔阁以焦墨、生铁、重矿彩与铅白死霜强行伪造的“规矩牢笼”——沉重、窒息、充满杀戮与油垢。 | 被篡改掩埋的太虚古宣底本——纯净、空灵、悲悯，承载盛唐文心与先烈忏悔的真实底稿。 |
| **核心笔法** | 《雾山五行》写意泼墨、李唐大斧劈皴、怀素渴笔飞白扫笔、三寸厚堆矿物颜料、工笔泥金刻线。 | 南宋李公麟 `$0.25\ \text{mm}$` 单线铁线描、顾恺之春蚕吐丝描、汉魏金石碑刻线、怀素狂草题跋。 |
| **色彩体系** | 焦墨黑（`#0A0908`）、原矿朱砂（`#C3272B`）、泥金（`#D4A017`）、石绿（`#1F4E3F`）、石青（`#16355C`）、铅白（`#F8F8F8`）。 | 暖象牙桑皮生宣（`#EFE9DA`）、温州蠲纸（`#F6F2E9`）、硬黄古宣（`#F4E8C1`）、南唐澄心堂纸与太虚纯白（`#FFFFFF`）。 |
| **3D 台面与光影** | $3.2\ \text{m}$ 宽台面顶面覆盖积水、血斑、矿渣或霜花 `Decal`，高对比戏剧光影与局部冷光折射。 | 温润通透的汉白玉/古宣台面顶面，线条向远景薄雾与大面积纯白负空间（留白）柔和隐去。 |

---

## 1.3 3D 空间 $Z$ 轴七轨景深分布与防重复工程系统

全面废除 2D 伪视差 `scroll_scale`，所有关卡均构建于真实的 3D $Z$ 轴空间拓扑之上，配合 `WorldEnvironment` 的**物理景深虚化（Depth of Field）**与**远景空气透视雾效（Fog）**天然生成空间视差与纵深感：

```text
Z = +4.5m  ──► Layer -2 (极近景物理虚化): 垂落铁链/垂柳/断碑角/戒尺流苏（触发 Camera3D 近景 DoF 虚化）
Z = +2.2m  ──► Layer -1 (近景立体微粒层): 朱砂雨丝/石青飞沫/飞白炭屑/铅白毒粉（GPUParticles3D 立体飘落）
Z =  0.0m  ──► Layer  0 (主战斗与跑道舞台): 角色、怪物与 3.2m 纵深宽度的 3D 可行走台面（Z ∈ [-1.6m, +1.6m]）
Z = -4.5m  ──► Layer +1 (次近景建筑残垣): 断裂石经幢/生铁刑架/沉船龙骨/汉白玉华表
Z = -15.0m ──► Layer +2 (中景长卷主体):   大斧劈皴绝壁/青绿峰峦/倒插碑林/千手戒尺环（模块化无缝衔接）
Z = -38.0m ──► Layer +3 (极远景天顶气象): 翻滚雷云/暴雨长瀑/死霜虚空（触发远景空气透视雾效 Fog）
Z = -75.0m ──► Layer +4 (底板天幕宣纸胎): 4K 巨幅桑皮宣/温州蠲纸/硬黄纸/澄心堂宣帘纹暗斑底板
```

* **破除长卷重复感四大工程机制**：
  1. **Godot 原生 `Decal` 非周期贴花**：基于噪声函数向 $3.2\ \text{m}$ 宽的 3D 台面顶面与断壁立面投射朱砂血斑、焦墨油垢、石青矿渣结晶、龟裂纹、泥金九宫线以及主角破宣斩留下的白色生宣裂隙印记。
  2. **次级独立地标覆盖层**：每隔 `$5.0\ \text{m} \sim 8.0\ \text{m}$`（对应 `$500\ \text{px} \sim 800\ \text{px}$`）插入不可复用的 3D/2.5D 地标切片（断折生铁戒尺、倾覆沉船龙骨、断裂编钟架、无相跪像）。
  3. **Verlet / 物理骨骼动态垂挂**：`Layer -2` 悬空铁链、破败纸幡、垂柳、紧绷琴弦与白玉流苏绑定动态摆动骨骼，响应风压与角色冲刺气流。
  4. **体积光雾与局部灯光阻断**：利用半透明水墨烟云、毒雾粒子与 `OmniLight3D` / `SpotLight3D` 局部光斑交替遮挡中远景，打断人眼对贴图平铺周期的记忆。

---

# 第二部分：《ICEY》舞台张力与 2.5D 微俯视透视光学法则

## 2.1 三大视觉法则与四大核心镜头特征

| 视觉法则 | 对应的核心镜头特征 | 工程与美术执行标准 |
| :--- | :--- | :--- |
| **法则一：长焦微俯视透视** | **① `Camera3D` 长焦低畸变微俯视** | 启用透视投影（`Projection = Perspective`），锁定**标准探索 `FOV = 36°`、俯角 `Pitch = -15°`**（允许范围 `FOV 30°~46°`，`Pitch -10°~-18°`）。既能清晰展现 $3.2\ \text{m}$ 宽度的行走台面顶面与阶梯厚度，又利用长焦抑制广角边缘畸变，保持横版卷轴的端庄稳定感。 |
| **法则二：立体横剖舞台与框景** | **② 立体横剖面舞台台基**<br>**③ 左右对称“剧场幕布”框景** | 主战斗舞台（`Layer 0`）统一落在画面下方 `$1/3$` 处，呈现清晰的**路面顶面 + 前沿岩石/砖石/齿轮横剖厚度**，角色 `Sprite3D` 轴心设为 `Bottom-Center` 稳稳踩在台面之中。决斗与室内场景中，画面最左与最右边缘布置高耸石柱、屏风或断崖，形成剧场大幕般的左右锁边。 |
| **法则三：真实 $Z$ 轴景深虚化** | **④ 前景 $Z=+4.5\ \text{m}$ 物理虚化压暗角** | 在贴近镜头的极近景层（`Layer -2`，`$Z = +4.5\ \text{m}$`）布置受 `Camera3D` 物理景深（DoF）自然虚化的暗部或线描剪影（铁链、垂柳、残碑棱角、垂落戒尺流苏），遮挡画面四角或上下边缘约 `$12\% \sim 20\%$`，压出强烈的 2.5D 立体纵深层次。 |

---

## 2.2 三大核心实战机位规范与标准生图镜头词

### 机位一：横版长卷跑图机位（Horizontal Scroll & Exploration）
* **构图与光学特征**：具备清晰顶面宽度与前沿剖面厚度的水平跑道贯穿画面下 `$1/3$` 处，微俯视视角可清晰看见台面上的石阶落差、积水反光与 `Decal` 贴花；中远景山体与楼阁在真实 $Z$ 轴景深中按 `$2048\ \text{px} / 4096\ \text{px}$` 周期无缝衔接；前景 `$Z = +4.5\ \text{m}$` 布置失焦垂柳、铁链或残碑框景；主角占屏高约 `$1/6$`，前瞻视野（Lookahead）向行进方向偏置。
* **基础参数**：标准探索 **`FOV = 36°`、`Pitch = -15°`、相机相对偏移 `(0, +4.2m, +13.5m)`**，阻尼 `$X = 0.12 \sim 0.15, Y = 0.20 \sim 0.25$`；第一章江心极速跑打态 **`FOV = 44° ~ 46°`、`Pitch = -16°`、偏移 `(0, +5.8m ~ +6.5m, +18.5m ~ +21.0m)`**，沿 `$X$` 轴以 `$14.0\ \text{m/s}$` 强制匀速向右推进。
* **标准生图镜头头部词（Prompt Header）**：
  ```text
  2.5D side-scrolling action game environment art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), visible 3.2-meter-wide walkway top surface and cutaway stone ledge thickness in the lower third, subtle natural 3D perspective depth, out-of-focus foreground silhouettes framing the screen corners with bokeh DoF, crisp playable midground ground plane with surface decals and cast shadows, receding misty mountains and classical Chinese architecture with atmospheric distance fog, seamless horizontal composition --ar 21:9
  ```

### 机位二：BOSS 决斗擂台机位（Theatrical Duel Arena）
* **构图与光学特征**：画面最左与最右边缘布置高耸石柱、生铁闸门或泥金折叠屏风，像剧场大幕一样锁死左右视野；下方为跨度 `$14\ \text{m} \sim 22\ \text{m}$`（`$1400\ \text{px} \sim 2200\ \text{px}$`）的宽阔立体大擂台，微俯视可看清整个圆形或方形擂台顶面纹理、排水槽与前沿石雕台基横剖面；顶部垂落倒悬戒尺或挂轴压暗角，背景正中央放置对称图腾巨构（千手戒尺环、熔炉、沉沦残阳）。
* **基础参数**：**`FOV = 30°`、`Pitch = -13°`、相机相对偏移 `(0, +3.1m, +10.5m)`**，阻尼收紧至 `$X = 0.05, Y = 0.05 \sim 0.08$`，`Dead Zone` 归零。
* **标准生图镜头头部词（Prompt Header）**：
  ```text
  2.5D side-scrolling boss arena concept art, symmetrical theatrical stage composition, slight high-angle top-down perspective (13-degree downward camera tilt), wide playable arena floor top surface with visible architectural cutaway foundation underneath in the lower third, towering pillars and folding screens framing the far left and right edges like stage curtains, out-of-focus hanging banners and chains framing the top border, centered monumental background structure with subtle 3D depth --ar 16:9
  ```

### 机位三：峡谷断崖与机制跳跃机位（Abyss & Aerial Platforming）
* **构图与光学特征**：左右两侧悬崖断口之间横跨 `$5.0\ \text{m} \sim 8.0\ \text{m}$`（`$500\ \text{px} \sim 800\ \text{px}$`）的无底深渊，或完全移除地面，释放屏幕上方或下方超过 `$60\%$` 的**垂直负空间（Vertical Negative Space）**；微俯视视角清晰展现悬空墨桶、下沉浮桩、紧绷猩红琴弦、`$45^\circ$` 斜插断瑟或倾斜戒尺天平的立体顶面与空间前后纵深；`Layer -1` 强化沙暴、火星、落石与暴雪的 3D 粒子拉丝。
* **基础参数**：峡谷横跨为 **`FOV = 39° ~ 42°`、`Pitch = -16°`、偏移 `(0, +4.8m ~ +5.4m, +15.0m ~ +17.0m)`**；无地面高空战斗为 **`FOV = 43° ~ 48°`、`Pitch = -16°`**；垂直攀登模式放宽横向阻尼（`$X = 0.30 \sim 0.40$`）锁住竖井中轴，收紧纵向阻尼（`$Y = 0.10$`）敏锐跟随上升跳跃。
* **标准生图镜头头部词（Prompt Header）**：
  ```text
  2.5D side-scrolling platformer level art, slight high-angle top-down perspective (16-degree downward camera tilt), broken cliff ledges with visible top surfaces separated by a deep bottomless chasm, connected by suspended 3D aerial platforms and diagonal launching structures, vast vertical negative space for aerial traversal, out-of-focus foreground silhouettes and dynamic 3D wind particles streaking across the lens borders --ar 16:9
  ```

---

## 2.3 特殊演出衍生机位
1. **两段式终局处决机位（Two-Stage Epigraph Finisher）**：
   * **第 1 段（掀卷狂草连斩）**：镜头略微拉远至 **`FOV = 42°`、`Pitch = -15°`**，容纳表层画卷从左向右卷成纸筒吞噬弹幕，玩家连点攻击狂草成字（序章“折” $7$ 笔/$4.5\ \text{s}$、一章“直” $8$ 笔/$5.5\ \text{s}$、二章“藏” $17$ 笔/$7.0\ \text{s}$、终章“休” $6$ 笔/$10.0\ \text{s}$）。
   * **第 2 段（落卷近身按键处决）**：最后一笔落成后主角落地于瘫跪 Boss 身前半步，相机瞬间切入 **`FOV = 24°`、`Pitch = -10°`、距心核 `$3.8\ \text{m}$`** 的超近特写，按下近身处决键后触发 `$16 \sim 20$` 帧黑底白线金石拓片反相定格与狂草巨字引爆。
2. **跨章垂直高速导轨（Cross-Chapter Vertical Transition）**：序章飞瀑直坠（`FOV = 46°`、`Pitch = -18°`，终端速度 `$-40.0\ \text{m/s}$`）、第一章怒涛抽干直坠（`FOV = 47°`、`Pitch = -18°`，终端速度 `$-55.0\ \text{m/s}$`）、第二章乘狂草墨龙垂直仰冲破天门（`FOV = 48°`、`Pitch = -14°`，峰值速度 `$+50.0\ \text{m/s}$`）。
3. **尾声万里大留白拉远（Epilogue Grand Void）**：终章尾声从市井春雨（`FOV = 36°`、`Pitch = -15°`）经慢速垂升俯瞰山河（`FOV = 42°`、`Pitch = -17°`），最终拉远至 **`FOV = 45°`、`Pitch = -18°`、偏移 `(0, +14.0m, +42.0m)`**，山川缩小为长卷正中画心，全屏 `$80\%$` 空间转为纯净太虚大留白，右上角盖下朱砂巨印。

---

# 第三部分：Godot 4.3+ 实战动态镜头进阶参数（`Camera3D` 规范）

为兼顾《艾希》的凌厉刀感与《空洞骑士》的精准平台手感，在基础 `Camera3D` 参数之上必须配置以下四大实战动态机制：

## 3.1 跑图探索态增强
* **落地 `$Y$` 轴锚点吸附（Grounded Y-Snapping）**：设定空中高度容差阈值 `$2.5\ \text{m}$`。主角起跳或空中下劈时，只要高度变化在阈值内，相机锚点 `$Y$` 轴锁死在起跳前地面基准线，落地瞬间用 `$0.25\ \text{s}$` 平滑吸附，消除高频小跳导致的微俯视屏幕眩晕。
* **下探视野偏置（Downward Lookahead Bias）**：长按“下”键超过 `$0.30\ \text{s}$` 或垂直下落速度 `$V_y < -8.0\ \text{m/s}$` 时，相机目标锚点 `Y` 坐标平滑下移 `$1.8\ \text{m} \sim 2.4\ \text{m}$`（俯角微调至 `-17°`），提前暴露下方毒潭与悬空落脚点顶面，消除盲跳挫败感。
* **表里双轨撕裂 `FOV` 微脉冲（Dual-Layer Tear FOV Punch）**：出刀“破宣斩”撕开表层墨障瞬间，叠加持续 `$0.18\ \text{s}$` 的 `FOV` 缩放脉冲（`FOV` 瞬收 `$-1.2^\circ$` 后弹性回弹），并实时同步给里层白描 `SubViewport` 的副 `Camera3D`。
* **区域边界盒子软钳制（Room Bounds Smooth Clamp）**：进入切换区域 `Area3D` 触发器时，读取该区域定义的 3D 空间包围盒（`AABB`），使用 `Tween` 在 `$0.40\ \text{s}$` 内平滑过渡相机 `global_position.x / y` 的最大最小钳制范围，防止镜头越过关卡边缘露底。

## 3.2 常规打怪态增强
* **软战斗框与威胁质心偏移（Soft Threat Centroid Bias）**：半径 `$12\ \text{m}$` 内存在激活杂兵时，不锁死边界，将相机追踪焦点设为**主角 3D 坐标（权重 `$75\%$`）+ 活跃敌人质心（权重 `$25\%$`）**，并将 `FOV` 微扩 `$+2.0^\circ$`（`36°` $\to$ `38°`），兼顾身后远程偷袭预警与流畅跑打节奏。
* **矢量定向打击微震（Directional 3D Trauma Kick）**：摒弃全向随机抖动，改用沿刀光矢量局部偏移。横向挥刀命中时 `Camera3D.h_offset` 向挥刀方向瞬移 `$0.08\ \text{m} \sim 0.14\ \text{m}$` 并在 `$0.08\ \text{s}$` 内回弹；下劈踩中敌人或墨桶时 `v_offset` 向下微顿 `$0.10\ \text{m}$` 再上弹。
* **高速冲刺与钻缝滑行追焦（Dash & Rift Grind Lag）**：触发冲刺或进入“裂隙无敌墨线滑行”的最初 `$0.10\ \text{s}$` 内将水平阻尼放宽至 `0.35`（让狂草墨线先向前蹿出），随后在 `$0.15\ \text{s}$` 内收紧回 `0.12`，制造爆发速度差。

## 3.3 精英决斗态增强
* **非对称 `$6:4$` 权重与边缘安全区**：焦点锁定 `主角坐标 * 0.6 + 精英怪坐标 * 0.4`，并强制约束主角距离左右视口边缘始终保留至少 `$2.5\ \text{m}$` 闪避缓冲，防止被逼入死角时背后视野被裁切。
* **弹反金石拓片推拉特写（Parry Rubbing Zoom-In）**：精准弹反重盾、折叠屏风或黄金天平触发 `$16$` 帧全局黑底白线金石拓片反相定格瞬间，`FOV` 瞬收至 `25.5°`（推进 `$-4.5^\circ$`），定格结束配合重甲爆碎弹性回弹至 `30°`。
* **闸门/屏风闭锁缓动**：开场闸门落下时用 `$0.35\ \text{s}$` 缓动收束左右 3D 边界盒钳制范围。

## 3.4 BOSS 战与处决态增强
* **距离自适应无级 `FOV` 缩放（Distance-Driven FOV Zoom）**：当主角与 BOSS 水平距离 `$D > 8\ \text{m}$` 时，按 `$(D - 8) \times 0.85^\circ$` 平滑外扩 `FOV`（最大叠加 `$+8.0^\circ$`），防止 BOSS 瞬移至版边蓄力发波时脱离视野。
* **高空威胁头顶留白（Vertical Headroom Bias）**：BOSS 升空或召唤头顶弹道（如墨骨全空战、顾狂墨千手法环）时，追踪锚点向上抬升 `$+1.2\ \text{m} \sim +1.8\ \text{m}$`，将台面压低至画面下方 `$1/5$` 处以看清高空弹道。
* **离屏突进边缘磁吸（Off-Screen Telegraph Clamp）**：高机动 BOSS 短暂飞出视口时，焦点向 BOSS 所在侧额外偏移 `$1.5\ \text{m}$` 并触发边缘残影预警。

## 3.5 全局 5 级镜头优先级仲裁栈（`Camera3D` Priority Stack）

| 优先级 | 机位模式 | `FOV / Pitch` 标尺 | 阻尼（`$X / Y$`） | 核心控制权与打断规则 |
| :--- | :--- | :--- | :--- | :--- |
| **P4（最高）** | **落卷近身处决瞬切态** | `FOV 24° / Pitch -10°` | `0.00 / 0.00`（瞬切） | 无条件打断一切插值，锁定刀尖点心核（距 `$3.8\ \text{m}$`），演出结束后平滑退回 P0/P2。 |
| **P3** | **跨章转场 / 尾声大拉远** | `FOV 45°~48° / Pitch -18°` | 导轨强制锁死 | 接管全部输入偏移，执行垂直高速坠落/仰冲或万里拉远至 `(0, +14m, +42m)`。 |
| **P2** | **BOSS / 精英决斗机位** | `FOV 30° / Pitch -13°`（空战 `43°`） | `0.05 / 0.05 ~ 0.08` | 锁死左右剧场边界，启用 `$6:4$` 权重、距离自适应 `FOV` 缩放与拓片反相推拉脉冲。 |
| **P1** | **跑打推进 / 峡谷跳跃机位** | `FOV 39°~46° / Pitch -16°` | `0.00 ~ 0.40 / 0.10 ~ 0.15` | 强制横向推进或垂直攀登跟随，触发下探偏移与野外软战斗框。 |
| **P0（基础）** | **横版长卷标准探索机位** | `FOV 36°~38° / Pitch -15°` | `0.12 ~ 0.15 / 0.20 ~ 0.25` | 默认常驻状态，执行落地 `$Y$` 轴吸附、前方 `Lookahead` 与双轨撕裂 `FOV` 微脉冲。 |

---

# 第四部分：全游戏 44 幕（序章至尾声）`Camera3D` 机位 100% 映射总表

## 4.1 【起】序章：赤朱残阳 · 狂草破规（10 幕 + 1 过渡 · 试玩包核心区）

| 幕次与场景名称 | 归属机位类型 | `FOV / Pitch` | 相机偏移 `(\Delta Y, \Delta Z)` | 阻尼（`$X / Y$`） | 特殊运镜与触发规则 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **幕 0-1 死牢绝壁** | 机位一（标准探索） | `36° / -15°` | `(+4.2m, +13.5m)` | `0.12 / 0.25` | 展现 `$3.2\ \text{m}$` 宽玄武岩石阶顶面与朱砂 `Decal`，启用落地 `$Y$` 轴吸附。 |
| **幕 0-2 绝壁天堑** | 机位三（断崖/破壁） | `39° / -16°` | `(+4.8m, +15.0m)` | `0.12 / 0.25` | 强化八米焦墨死壁高耸感与深渊落差；破壁瞬间叠加 `$-1.2^\circ$` 缩放脉冲。 |
| **幕 0-3 生铁军械营** | 机位二（精英决斗） | `30° / -13°` | `(+3.1m, +10.5m)` | `0.05 / 0.05` | 死区归零，左右锁定生铁重型闸门，弹反镇峰狱尉触发 `25.5°` 拓片反相特写。 |
| **幕 0-4 宿墨绞盘井** | 机位三（垂直攀登） | `35° / -14°` | `(+3.8m, +12.8m)` | `0.40 / 0.10` | 横向阻尼放宽锁住竖井中轴，纵向阻尼收紧敏锐跟随上升跳跃。 |
| **幕 0-5 悬空墨桶** | 机位三（深渊跳跃） | `40° / -16°` | `(+5.0m, +15.6m)` | `0.12 / 0.25` | 展现 `$6.0\ \text{m}$` 沸墨池横向跨度，下劈墨桶或下落时激活下探视野偏置。 |
| **幕 0-6 生铁长廊** | 机位一（狭长探索） | `33° / -13°` | `(+3.5m, +11.8m)` | `0.12 / 0.25` | 配合 `$3.2\ \text{m}$` 矮顶天花板压低视角，强化上下夹逼压迫感。 |
| **幕 0-7 百丈碑林裂隙** | 机位一/三（阶梯断层） | `38° / -15°` | `(+4.4m, +14.2m)` | `0.12 / 0.25` | 应对 `$2.0\ \text{m}$` 断层台阶高差，阶梯跳落平滑过渡 `$Y$` 轴基准线。 |
| **幕 0-8 雷暴绝壁栈道** | 机位一（斜向导轨） | `39° / -15°` | `(+4.6m, +14.8m)` | `0.12 / 0.20` | 沿崖壁呈 `$25^\circ$` 平缓抬升，伴随雷暴微幅震屏与立体血雨粒子。 |
| **幕 0-9 先锋营门** | 机位一（死寂前奏） | `34° / -14°` | `(+3.8m, +12.5m)` | `0.10 / 0.20` | 镜头转为稳定推进感，死区极小，营造决战前夕压抑氛围。 |
| **幕 0-10 断云台死斗** | 机位二 + 两段式处决 | `30°` $\to$ `42°` $\to$ `24°` | `(+3.1m, +10.5m)` $\to$ `(+1.4m, +3.8m)` | `0.05` $\to$ `0.00` | 一二阶段 `$6:4$` 权重锁擂台；三阶段掀卷写“折”（`$7$` 笔/`$4.5\ \text{s}$`）后 `24°` 近身刺心。 |
| **幕 T-1/T-2 飞瀑洗血卷** | 衍生跨章垂直导轨 | `46° / -18°` $\to$ `36°` | `(+6.2m, +19.5m)` | `0.30 / 0.05` | 以 `$-40.0\ \text{m/s}$` 垂直直坠 `$3.0\ \text{s}$` 后经 `$90^\circ$` 弧形滑道切入第一章。 |

## 4.2 【承】第一章：青绿叠翠 · 墨竹狂澜（11 幕 + 1 过渡）

| 幕次与场景名称 | 归属机位类型 | `FOV / Pitch` | 相机偏移 `(\Delta Y, \Delta Z)` | 阻尼（`$X / Y$`） | 特殊运镜与触发规则 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **幕 1-1 青石浅滩** | 机位一（试玩包终点） | `36° / -15°` | `(+4.2m, +13.5m)` | `0.15 / 0.25` | 飞瀑滑跪定格于宋式青石浅滩顶面，触发试玩包通关定格与正式标题。 |
| **幕 1-2 界画围堰** | 机位一（大坝压迫） | `39° / -16°` | `(+4.8m, +15.0m)` | `0.15 / 0.25` | 适度拉远展现 `$20\ \text{m}$` 生铁重坝与内侧高位毒水的垂直压迫感。 |
| **幕 1-3 沉船万人坑** | 机位一/三（残骸跨越） | `38° / -15°` | `(+4.4m, +14.2m)` | `0.15 / 0.25` | 在沉船龙骨木梁顶面间跳跃，下探偏移防止误落石青流沙泥沼。 |
| **幕 1-4 石青泥沼** | 机位三（毒潭机制） | `36° / -15°` | `(+4.2m, +13.5m)` | `0.15 / 0.25` | 覆盖 `$5.0\ \text{m}$` 无落脚点毒潭与下沉浮桩，启用空中下劈微顿反馈。 |
| **幕 1-5 画屏水阁** | 机位二（精英决斗） | `30° / -13°` | `(+3.1m, +10.5m)` | `0.05 / 0.08` | 左右锁死泥金折叠屏风，死区归零，弹反伏波画督重屏触发 `25.5°` 拓片特写。 |
| **幕 1-6 千竿墨竹阵** | 机位一（竹林穿行） | `35° / -14°` | `(+3.8m, +12.8m)` | `0.15 / 0.25` | 前景 `$Z=+4.5\ \text{m}$` 巨竹形成虚化栅栏窥视感，遭遇飞刀时触发软战斗框。 |
| **幕 1-7 怒浪前哨** | 机位一（提速预告） | `41° / -16°` | `(+5.2m, +16.2m)` | `0.15 / 0.20` | 视野扩大展现 `$8.0\ \text{m/s}$` 湍急江势，为下一幕强制横推做视觉缓冲。 |
| **幕 1-8 碎木狂飙** | 机位一（极速跑打 I） | `44° / -16°` | `(+5.8m, +18.5m)` | `0.00 / 0.15` | 镜头强制沿 `$X$` 轴以 `$14.0\ \text{m/s}$` 匀速向右推进，清晰看清碎木排顶面落点。 |
| **幕 1-9 泼彩断江** | 机位一（极速跑打 II） | `45° / -16°` | `(+6.0m, +19.2m)` | `0.00 / 0.15` | 保持 `$14.0\ \text{m/s}$` 推进，容纳二十米突起焦墨死壁与挥毫墨竹。 |
| **幕 1-10 逆水应龙** | 机位一/三（跑打 III） | `46° / -16°` | `(+6.5m, +21.0m)` | `0.00 / 0.15` | 宏大宽幅视野，沿三百丈白描应龙宽阔龙鳞脊背起伏执行波浪形追踪。 |
| **幕 1-11 墨竹终局** | 机位二 + 两段式处决 | `30°` $\to$ `42°` $\to$ `24°` | `(+3.1m, +10.5m)` $\to$ `(+1.4m, +3.8m)` | `0.05` $\to$ `0.00` | 锁定龙头两角之间；掀卷写“直”（`$8$` 笔/`$5.5\ \text{s}$`）后 `24°` 近身刺心。 |
| **幕 T-1/T-2 怒涛抽干卷** | 衍生跨章垂直导轨 | `47° / -18°` $\to$ `36°` | `(+6.4m, +20.0m)` | 导轨锁死 | 随抽干的江水以 `$-55.0\ \text{m/s}$` 垂直直坠 `$3.5\ \text{s}$` 砸入第二章荒冢。 |

## 4.3 【转】第二章：飞白苍凉 · 枯笔断魂（10 幕 + 1 过渡）

| 幕次与场景名称 | 归属机位类型 | `FOV / Pitch` | 相机偏移 `(\Delta Y, \Delta Z)` | 阻尼（`$X / Y$`） | 特殊运镜与触发规则 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **幕 2-1 荒冢入口** | 机位一（标准探索） | `38° / -15°` | `(+4.4m, +14.2m)` | `0.15 / 0.25` | 展现龟裂焦土台面顶面与炭灰 `Decal`，营造荒原惨淡纵深。 |
| **幕 2-2 倒插墓碑林** | 机位一（碑林探索） | `41° / -16°` | `(+5.2m, +16.2m)` | `0.15 / 0.25` | 宽幅微俯视，展现上万座倒插黑色巨碑的方形碑底顶面与猩红琴弦网格。 |
| **幕 2-3 拓碑断壁** | 机位二（精英决斗） | `30° / -13°` | `(+3.1m, +10.5m)` | `0.05 / 0.08` | 左右锁定生铁拓碑屏风，弹反司弦刑官断头古瑟触发 `25.5°` 拓片特写。 |
| **幕 2-4 枯笔风沙峡谷** | 机位三（踏弦飞跃） | `39° / -16°` | `(+4.8m, +15.0m)` | `0.15 / 0.25` | 展现 `$5.0\ \text{m}$` 无底风沙裂谷与三根悬空生铁琴弦跳板的立体空间落差。 |
| **幕 2-5 残瑟断头台** | 机位三（`$45^\circ$` 弹射） | `40° / -16°` | `(+5.0m, +15.6m)` | `0.15 / 0.20` | 斩断主弦触发 `$32.0\ \text{m/s}$` 超音速弹射时，前瞻瞬间向右上 `$45^\circ$` 偏置。 |
| **幕 2-6 万古碑廊** | 机位一（狭长走廊） | `33° / -13°` | `(+3.5m, +11.8m)` | `0.15 / 0.25` | 配合 `$3.5\ \text{m}$` 低矮天花板与倒插铁凿，营造地下棺椁般的窒息纵深。 |
| **幕 2-7 韶乐金钟废墟** | 机位一/三（遗迹阶梯） | `38° / -15°` | `(+4.4m, +14.2m)` | `0.15 / 0.25` | 围绕倾覆的巨型青铜编钟架横梁上下跳跃，敲钟共鸣时释放全屏声波环。 |
| **幕 2-8 崩解绝壁** | 机位三（落石深渊） | `42° / -16°` | `(+5.4m, +17.0m)` | `0.15 / 0.20` | 超广角展现 `$6.0\ \text{m}$` 完全虚空断崖与持续下坠的崩塌巨石流。 |
| **幕 2-9 司碑古坛** | 机位二（BOSS 一阶段） | `30° / -13°` | `(+3.1m, +10.5m)` | `0.05 / 0.08` | 死区归零，锁定四方玄武岩古坛顶面，启用 `$6:4$` 权重与长鞭距离自适应缩放。 |
| **幕 2-10 凌空裂渊** | 机位三 + 两段式处决 | `43°` $\to$ `42°` $\to$ `24°` | `(+5.5m, +17.5m)` $\to$ `(+1.4m, +3.8m)` | `0.20` $\to$ `0.00` | 古坛砸碎后切入水袖空战；掀卷写“藏”（`$17$` 笔/`$7.0\ \text{s}$`）后 `24°` 近身点碑。 |
| **幕 T-1/T-2 狂草化龙破门** | 衍生跨章垂直导轨 | `48° / -14°` $\to$ `36°` | `(+6.5m, +21.0m)` | 导轨锁死 | 乘千丈狂草墨龙以 `$+50.0\ \text{m/s}$` 垂直仰冲撞碎天门，滑跪切入终章。 |

## 4.4 【合】第三章（终章）：白粉凝霜 · 天地留白（10 幕 + 3 尾声）

| 幕次与场景名称 | 归属机位类型 | `FOV / Pitch` | 相机偏移 `(\Delta Y, \Delta Z)` | 阻尼（`$X / Y$`） | 特殊运镜与触发规则 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **幕 3-1 铅白神道** | 机位一（神圣探索） | `36° / -15°` | `(+4.2m, +13.5m)` | `0.12 / 0.20` | 微俯视展现汉白玉神道顶面的泥金九宫格刻线与铅白霜花 `Decal` 的绝对对称。 |
| **幕 3-2 去色天门** | 机位一（门坊探索） | `41° / -16°` | `(+5.2m, +16.2m)` | `0.12 / 0.20` | 拉远展现三十米熔铅重门与自转的三百六十柄纯金戒尺法环。 |
| **幕 3-3 千手戒尺殿** | 机位二（精英决斗） | `30° / -13°` | `(+3.1m, +10.5m)` | `0.05 / 0.08` | 左右锁定金色华表，弹反平规衡司黄金天平触发 `25.5°` 拓片反相推拉特写。 |
| **幕 3-4 凝霜画壁** | 机位一（长卷探索） | `38° / -15°` | `(+4.4m, +14.2m)` | `0.12 / 0.20` | 平稳横移展现两百米冰封通天画壁，撕开底稿时触发 `$-1.2^\circ$` 缩放脉冲。 |
| **幕 3-5 虚空白塔** | 机位三（垂直升阶） | `39° / -15°` | `(+4.6m, +14.8m)` | `0.30 / 0.10` | 横向阻尼放宽锁死塔身中轴，纵向敏锐跟随 `$8.0\ \text{m}$` 下沉戒尺高空攀登。 |
| **幕 3-6 抹痕回廊** | 机位一（狭长探索） | `33° / -13°` | `(+3.5m, +11.8m)` | `0.12 / 0.20` | 配合 `$3.2\ \text{m}$` 矮顶与空白挂轴长阵，制造死寂停尸房般的窒息纵深。 |
| **幕 3-7 天道规矩坛** | 机位三（机械机关） | `39° / -16°` | `(+4.8m, +15.0m)` | `0.12 / 0.20` | 围绕三十米纯金浑天规矩仪交叉梁顶面跳跃，头顶留白规避活塞戒尺链。 |
| **幕 3-8 泣血深渊** | 机位三（暴雪裂渊） | `43° / -16°` | `(+5.5m, +17.5m)` | `0.20 / 0.20` | 超广角展现 `$6.0\ \text{m}$` 铅霜暴雪深渊与撕裂后露出的朱砂血书岩壁。 |
| **幕 3-9 弑神神坛** | 机位二（BOSS 一阶段） | `30° / -13°` | `(+3.1m, +10.5m)` | `0.05 / 0.05` | 锁定两千像素汉白玉擂台顶面与莲座，启用 `$6:4$` 权重与千手戒尺弹道留白。 |
| **幕 3-10 天下大去色** | 机位三 $\to$ 两段式处决 | `43°` $\to$ `42°` $\to$ `24°` | `(+5.5m, +17.5m)` $\to$ `(+1.4m, +3.8m)` | `0.20` $\to$ `0.00` | 二阶段 `43°` 应对 `$95\%$` 白化狂澜；掀卷写“休”（`$6$` 笔/`$10.0\ \text{s}$`）后 `24°` 轻点五彩火种。 |
| **幕 E-1 市井春雨** | 机位一（尾声探索） | `36° / -15°` | `(+4.2m, +13.5m)` | `0.12 / 0.20` | 回归平和温润的江南水乡青石板街巷横向漫步。 |
| **幕 E-2 千里山河复苏** | 衍生慢速升空导轨 | `42° / -17°` | `(+8.5m, +26.0m)` | 慢速垂升 | 镜头自江南市井向九霄高空缓缓垂直平移攀升，俯瞰五彩写意山河。 |
| **幕 E-3 万里乾坤大留白** | 衍生终极封卷机位 | `45° / -18°` | `(+14.0m, +42.0m)` | `$0.05\ \text{Hz}$` 缓拉 | 镜头拉远至宇宙长卷，全屏 `$80\%$` 转为太虚大留白，右上盖下朱砂巨印。 |

---

# 第五部分：四大篇章 8 张双轨大长卷完整英文生图提示词库（2.5D 微俯视修正版）

## 5.1 通用负向提示词（Universal Negative Prompt）
```text
characters, people, warriors, monsters, extreme fish-eye distortion, top-down 90-degree bird eye view, isometric 45-degree grid, flat 2D side-view without floor top surface, over-sharpened, digital noise, modern architecture, neon lights
```

## 5.2 【起】序章：赤朱残阳 · 狂草破规
* **序章 · 表层规矩浓墨实景**
  ```text
  2.5D side-scrolling action game environment art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing painterly ink wash style, natural soft brushwork. Visible 3.2-meter-wide walkable ground top surface and cutaway stone ledge thickness in the lower third, transitioning from wet Li Tang axe-cut black basalt prison stairs with mud-gold iron rulers and cinnabar blood puddles, across suspended octagonal iron ink buckets over a misty chasm, to a wide fractured white marble terrace bleeding dark cinnabar sap (#C3272B). Out-of-focus foreground raw iron chains and charred branches framing the screen borders with bokeh DoF. Receding sheer black cliffs, hanging iron cages, and a colossal dull cinnabar setting sun veiled in heavy charcoal storm clouds on aged mulberry Xuan paper texture. Seamless horizontal composition --ar 21:9
  ```
* **序章 · 里层白描宣纸底稿**
  ```text
  2.5D side-scrolling action game environment concept art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), subtle natural 3D perspective depth, Song Dynasty Li Gonglin 0.25mm single iron-wire baimiao line-art on warm aged ivory raw mulberry Xuan paper (#EFE9DA) with visible plant fibers. Visible wide walkable white jade walkway top surface and architectural cutaway foundation in the lower third, featuring carved celestial stairs, an ornate imperial archway, a cloud-supported stone bridge, and a wide stargazing terrace. Towering multi-story wooden Tang Dynasty library pavilions, bronze water-powered armillary sphere, and hanging temple bells in the midground. Softly blurred foreground silk tassels and pine boughs framing the corners, drifting calligraphy pages, tranquil misty mountains fading into paper grain. Seamless horizontal composition --ar 21:9
  ```

## 5.3 【承】第一章：青绿叠翠 · 墨竹狂澜
* **第一章 · 表层规矩浓墨实景**
  ```text
  2.5D side-scrolling action game environment art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing ink and heavy mineral pigment style, natural organic brushwork. Visible 3.2-meter-wide walkable ground top surface in the lower third, moving from wet mossy slate steps with mud-gold boundary posts and glossy mineral puddles, past a wide cast-iron river dam crest with bronze winches, across sunken black ship ribs and drifting timber rafts in toxic malachite-green (#1F4E3F) and azurite-blue (#16355C) rapids, into a lethal forest of barbed black cast-iron bamboo. Out-of-focus foreground dripping willow leaves and a broken iron anchor framing the borders with bokeh DoF. Monumental layered green-and-blue mineral impasto mountain peaks veiled in river mist. Seamless horizontal composition --ar 21:9
  ```
* **第一章 · 里层白描宣纸底稿**
  ```text
  2.5D side-scrolling action game environment concept art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), subtle natural 3D perspective depth, Song Dynasty 0.25mm single iron-wire baimiao line-art on warm off-white Wenzhou Xuan paper (#F6F2E9) with subtle watermarks. Visible wide walkable white marble terrace top surface and cutaway stone steps in the lower third, connecting a waterside pavilion with lotus balustrades, wooden aqueduct flumes, a carved stone sea-calming archway, floating lotus-leaf stepping stones, and an elegant scholar's bamboo garden. Gentle concentric water ripples, distant tiered river pavilions, and double-outlined misty mountain peaks fading softly into the paper substrate. Out-of-focus foreground outlined bamboo leaves framing the edges. Seamless horizontal composition --ar 21:9
  ```

## 5.4 【转】第二章：飞白苍凉 · 枯笔断魂
* **第二章 · 表层规矩浓墨实景**
  ```text
  2.5D side-scrolling action game environment art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing dry-brush feibai ink style, raw textured brushwork. Visible 3.2-meter-wide walkable ground top surface and cracked earth cutaway thickness in the lower third, composed of desiccated charcoal-black pavement (#0A0908), flat-topped inverted black tombstone platforms, tense blood-red iron zither wires (#8C1D20) spanning a sand chasm, a 45-degree inclined fractured cast-iron zither, and an overturned bronze Bianzhong bell rack half-buried in black quicksand cascades. Out-of-focus foreground jagged stele silhouettes and vibrating crimson cables framing the edges with bokeh DoF. Endless forest of upside-down black monoliths piercing a bleak lead-grey dust storm sky. Seamless horizontal composition --ar 21:9
  ```
* **第二章 · 里层白描宣纸底稿**
  ```text
  2.5D side-scrolling action game environment concept art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), subtle natural 3D perspective depth, 0.25mm Han-Jin stone-inscription iron-wire baimiao line-art on aged imperial hard-yellow Xuan paper (#F4E8C1). Visible wide walkable jade floor top surface and cutaway architectural base in the lower third, featuring an ornate celestial music stone gate, carved jade zither tables, floating golden Gongche musical notation stepping stones, a phoenix-head ancient zither, and an open Tang Dynasty hall housing intact white jade Bianzhong chimes and stone qing. Out-of-focus foreground flowing silk ribbons and drifting musical score pages framing the borders, distant multi-tiered bell towers amidst tranquil clouds. Seamless horizontal composition --ar 21:9
  ```

## 5.5 【合】第三章（终章）：白粉凝霜 · 天地留白
* **第三章 · 表层规矩浓墨实景**
  ```text
  2.5D side-scrolling action game environment art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing painterly texture with 95 percent desaturated lead-white frost (#F8F8F8) and mud-gold (#D4A017) order. Visible 3.2-meter-wide immaculate white marble roadway top surface engraved with gold mathematical gridlines and frost decals in the lower third, leading past a 30-meter molten-lead-sealed marble gate, interlocking brass armillary sphere beams, and a pure white jade lotus throne. Out-of-focus foreground frosted white silk tassels and lead icicles framing the borders with bokeh DoF. A monumental rotating halo of 360 golden executioner rulers and sterile white pillars fading into cold mist. Seamless horizontal composition --ar 21:9
  ```
* **第三章 · 里层白描宣纸底稿**
  ```text
  2.5D side-scrolling action game environment concept art, ultra-wide panoramic scroll, slight high-angle top-down perspective (15-degree downward camera tilt), subtle natural 3D perspective depth, Song Dynasty 0.25mm single iron-wire baimiao line-art on Southern Tang Chengxingtang raw Xuan paper (#EFE9DA) with visible mulberry fibers. Left side visible wide walkway top surface featuring stone brush-washing desks, a wooden armillary sphere model, floating scripture pages, and trembling blood-red cinnabar cursive confession calligraphy (#C3272B) with weeping ink stains. Transitioning smoothly toward the right into 80 percent expansive untouched pure white void (negative space) with faint distant mountain outlines, anchored by a square cinnabar-red seal stamp in the top-right corner. Seamless horizontal composition --ar 21:9
  ```