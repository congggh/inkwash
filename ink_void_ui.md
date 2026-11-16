# 《留白》（Ink & Void）全系统 UI 装裱美学与交互工程全典

> **【UI 设计总纲】**：“界面即装裱，交互即落印；局内隐于画理，局外展卷入梦。”
>
> **【核心体验目标】**：彻底摒弃现代动作游戏的霓虹光效、半透明毛玻璃与角落数值状态条。在局内战斗中，将 $90\%$ 的信息转化为贴合 `$2.5\text{D}$` 微俯视舞台的“画内物”（Diegetic UI），保证画布的绝对纯净与沉浸感；在局外与暂停交互中，将整块屏幕还原为一套完整的**宋代书画装裱形制**（乌木卷轴、素绢绫锦、生宣册页、原矿朱砂闲章与竹简算筹），让每一次菜单切换都如同在案头翻阅千年古籍。
>
> **【工程渲染基准】**：Godot Engine 4.3+ · 分辨率 `$1920 \times 1080$`（`canvas_items` / `expand`）· 渲染层严格隔离于 `CanvasLayer (layer = 110)`（免疫 `layer = 100` 的全屏金石拓片反相 Shader 污染）· 所有交互动画与声学反馈对齐**真实墙钟毫秒（`$\text{ms}$`）**。

---

## 第一部分：东方装裱视觉规范与材质色彩宪章

### 1.1 材质体系与五色矿彩规范

所有 UI 控件的贴图与着色器均取材于宋代内府书画装裱工艺，严禁使用纯数字矢量色块或现代科幻高光：

| 材质组件 | 色值与物理肌理 | 装裱形制隐喻与应用场景 |
| :--- | :--- | :--- |
| **陈年桑皮生宣** | 暖象牙白 `#EFE9DA` / 温州蠲纸 `#F6F2E9`；带真实手工竹帘纹与植物长纤维边缘。 | 暂停册页内页底托、招式心诀卷面、图鉴底稿、键盘键帽底托。 |
| **宋代素绢绫锦** | 青灰绢 `#6E7773` / 牙黄绫 `#D8CEB8`；细密经纬织物纹理与暗花云纹。 | 标题主界面卷轴“天头、地脚、隔水”装裱边框、册页右侧分类书签（Tab）。 |
| **乌木卷轴与竹简** | 沉乌木 `#1A1817` / 焦墨黑 `#0A0908`；干涩木纹与渴笔飞白拉丝。 | 标题手卷左右两端立体轴头、关底主宰单笔书法血条、战绩统计算筹。 |
| **原矿朱砂印泥** | 硫化汞正红 `#C3272B`；厚重矿石颗粒质感，边缘带微弱宣纸渗墨晕染。 | 按钮悬停落印、精英虚线撕甲裁切线、处决阳文印章、弹反暴击数字、濒死`【生】`字印。 |
| **工笔泥金刻线** | 古铜泥金 `#D4A017`；`$1.5\ \text{px}$` 高锐度细线，折射内敛金属微光。 | 装裱界画分割线、钻缝滑行磁吸准星、手柄金石键帽边框、已解锁能力印匣边框。 |

### 1.2 书法字体分级与排版铁律

* **一级标题与狂草爆发字（怀素狂草 / 行草手书体）**：
  * 用于主界面《留白》题额、关底主宰名号、弹反暴击数字以及 Boss 终局处决巨字（**「折」「直」「藏」「休」**），强调笔走龙蛇的枯润变化与破屏张力。
* **二级正文与菜单条目（宋徽宗瘦金体 / 馆阁体楷书）**：
  * 用于主菜单选项、暂停册页正文、系统设置项与 Boss 战引导提示。瘦金体横画收笔带顿点、竖画挺拔如铁，在 `$1080\text{p}$` 分辨率下具备极高的锐度与古雅辨识度。
* **印章篆刻体（汉印缪篆 / 宋元朱文白文印）**：
  * 用于所有确认提示（`[入画]`、`[处决]`、`[撕甲]`）、朱砂印台存档提示及封卷落款。

---

## 第二部分：局内「零 HUD · 画中物」动态交互系统

在 `$2.5\text{D}$` 微俯视镜头（`FOV = 36^\circ$`、`Pitch = -15^\circ$`）下，屏幕四角不放置任何常规血条、能量槽或小地图，全部交互信号直接融入战斗空间。

```text
+-----------------------------------------------------------------------------------+
|                        [关底主宰单笔枯墨横画血条] (仅Boss战显示)                    |
|                                                                                   |
|   (屏幕边缘：仅在血梅≤1朵时渗出焦墨侵蚀暗角)                                           |
|                                                                                   |
|              [钻缝泥金顿点准星]        [折纸暗红菱形角标 ×]                         |
|                    \                         /                                    |
|        [主角周身5朵悬浮朱砂血梅] ---> [白描刮白裂隙力场] <--- [敌方朱砂裁纸虚线/处决印]  |
|                                                                                   |
| ========================== [3.2m 纵深宽度 3D 行走台面] ============================ |
+-----------------------------------------------------------------------------------+
```

### 2.1 生命体征与濒死感知（无左上角血条）

1. **五瓣朱砂血梅（生命值显示）**：
   * 主角周身自然悬浮的 **$5$ 朵原矿朱砂结晶血梅**（由独立弹簧组件 `PlumBlossomOrbitRig` 驱动）即为全部生命显示。
   * **受击反馈**：扣除 `$1$` 点生命时，对应血梅在 `$100\ \text{ms}$` 内如晶簇碎裂般瓦解为纯白纸屑飞散；每完成 `$2$` 次【抽纸·处决】或 `$1$` 次【精英虚线撕甲】时，一缕朱砂流光飞回主角身侧重新凝结血梅。
2. **濒死心跳脉冲与焦墨暗角**：
   * 当血梅仅剩最后 **$1$ 朵**时，主角腰间悬挂的朱文白玉小印**`【生】`**随 `$110\ \text{BPM}$` 心跳频率迸发暗红强光脉冲。
   * 同步在 `CanvasLayer` 边缘向内蔓延出带有干燥飞白毛刺的**焦墨侵蚀暗角**（遮挡外围约 `$15\%$` 边缘视野），并触发 `AudioServer` 对环境音施加轻微低通滤波，制造窒息压迫感；恢复至 `$2$` 朵血梅后暗角瞬间如墨迹蒸发般退散。

### 2.2 四维撕裂玩法的画内提示准星（In-World Signifiers）

所有画理交互提示均通过 `Camera3D.unproject_position()` 实时锁定在 `$3.2\ \text{m}$` 台面或敌方关节坐标上，零视线转移：

| 交互机制 | 触发条件 | 画内 UI 视觉表现 | 消失与反馈机制 |
| :--- | :--- | :--- | :--- |
| **钻缝无敌滑行磁吸准星** | 主角距离已有白描裂隙 `$\le 0.45\ \text{m}$` 且冲刺就绪 | 裂隙中点浮现一枚微小的**工笔泥金毛笔顿点准星**（带内收呼吸环），提示按冲刺键可直接潜入纸缝。 | 潜入纸缝化作狂草墨线瞬间，准星化作一圈白描水纹散开。 |
| **折纸·绞杀交叉角标** | 场上存在 `$2$` 条及以上交叉白描裂隙 | 裂隙交叉点处亮起一枚暗红菱形**折纸角标（`×` 折痕虚线框）**，提示可按 `K` / `LB` 触发空间坍缩聚怪。 | 发动折纸坍缩瞬间，角标随画面向心折叠并炸碎为纸屑。 |
| **精英虚线撕甲裁切线** | 累计两次 `$160\ \text{ms}$` 完美弹反震碎重盾护甲后 | `$260\ \text{ms}$` 拓片反相定格期间，敌方重盾/甲胄表面亮起发光**原矿朱砂裁纸虚线**与微型刻刀印章 **`[撕甲]`**。 | 定格结束首帧自动执行居合拔刀撕甲，虚线随断盾一同被撕飞。 |
| **杂兵抽纸·处决印记** | 杂兵削韧清零陷入纸片化硬直或 HP `$\le 30\%$` | 敌人胸口命核处浮现一枚旋转的朱砂阳文小印 **`[处决]`**，提示按冲刺/交互键错身扯下表层墨皮。 | 错身撕下表层墨皮瞬间，印章化作漫天纯白纸蝶消散。 |
| **拓片反相朱砂暴击数字** | 仅在**完美弹反解冻爆发**或**裂隙滑行背刺暴击**时触发 | 从伤口向斜上方喷射大号原矿朱砂（`#C3272B`）狂草手书暴击数字（带白描描边防背景粘连）；普通平砍**不弹任何数字**。 | 数字在 `$550\ \text{ms}$` 内随重力微沉并如墨迹渗入纸背般淡出。 |

### 2.3 关底主宰「单笔枯墨横画」书法血条

* **杂兵与精英**：一律不显示任何头顶或屏幕血条，完全通过表层墨甲的褪色程度（去色破甲态）与体态踉跄判断状态。
* **四大关底主宰（墨梅、墨竹、墨骨、顾狂墨）**：
  * 仅在 Boss 战开场亮出名号印章后，于屏幕正上方居中浮现**一道水平浓墨飞白横画**（宽 `$720\ \text{px}$`，高 `$18\ \text{px}$`）。
  * **动态枯笔衰减**：随着 Boss 生命值削减，横画从右向左如毛笔蘸墨耗尽般逐渐干涸、裂开为细腻的飞白丝缕（通过 UV 遮罩与焦墨燥波贴图驱动）；横画左侧竖排瘦金体题写主宰名号（如**「先锋镇将 · 墨梅」**）并盖一枚朱文小印。
  * **阶段节点顿点**：在墨梅 `$950\ \text{HP}$` 与 `$200\ \text{HP}$` 等转阶段阈值处，横画上点有一枚微小泥金顿点，击破该阈值时顿点迸发金石碎裂特效。

### 2.4 两段式 Boss 终局交互专用 UI

当关底主宰进入终局濒死阶段、玩家按下交互键一刀掀翻表层画卷后，UI 切换为极简书法交互态：

1. **第 $1$ 段 · 掀卷狂草连斩 UI（`time_scale = 0.30`）**：
   * **四边墨迹燃烧引信**：屏幕最外圈镶嵌一圈宽度 `$12\ \text{px}$` 的宣纸边框，框内一条赤红火星引信沿顺时针方向燃烧吞噬焦墨，直观映射当前剩余连斩时间窗口（序章墨梅 **`$4.5\ \text{s}$`** / 第一章墨竹 **`$5.5\ \text{s}$`** / 第二章墨骨 **`$7.0\ \text{s}$`** / 终章顾狂墨 **`$10.0\ \text{s}$`**）。
   * **顶部字帖描红进度**：屏幕上方居中浮现半透明浅灰字帖底稿（如序章**「折」**字 `$7$` 笔、第一章**「直」**字 `$8$` 笔、第二章**「藏」**字 `$17$` 笔、终章**「休」**字 `$6$` 笔）。玩家每点击一次攻击键挥出狂草斩击，字帖底稿便用苍劲浓墨实打实填满一笔并伴随轻微震动。
2. **第 $2$ 段 · 落卷近身按键处决 UI（`FOV = 24^\circ$` 特写）**：
   * 最后一笔落成、主角轻盈落地于白描 Boss 身前半步瞬间，字帖与燃烧边框全部隐去，仅在 Boss 胸口命核正上方亮起一枚高对比度阳文朱砂大印 **`[处决]`**（附带当前外设按键提示），按下瞬间触发 `$300 \sim 340\ \text{ms}$` 全屏金石拓片反相与狂草巨字引爆。

---

## 第三部分：全流程古籍装裱界面设计（局外与局内呼出）

### 3.1 标题主界面：《宋代横披手卷 · 展卷入画》

* **开卷动态演播**：
  * 启动游戏时，案头置于一幅合拢的宋代素绢乌木手卷，卷首签条竖书瘦金体**《留白》**。
  * 伴随一声清越古琴泛音，左右两侧乌木轴头向屏幕两边平稳滚动展开（耗时 `$850\ \text{ms}$`），卷心露出序章断云台暮色血雨的 `$2.5\text{D}$` 动态实机远景，左右保留素绢“天头、地脚”装裱边。
* **竖排菜单与落印交互**：
  * 画面左侧绫锦隔水内竖排排列五个瘦金体选项：**`【入画】`**（继续游历 / 新开画卷）、**`【择章】`**（幕段直选）、**`【画谱】`**（全生态图鉴）、**`【规矩】`**（音画与键位设置）、**`【掩卷】`**（退出游戏）。
  * **印泥渗墨悬停反馈**：当光标或摇杆选中任意选项时，文字右侧实时“盖下”一枚朱文小印，印泥在 `$120\ \text{ms}$` 内沿桑皮纸纤维产生自然的微小渗墨扩散。
  * 画面右侧大面积太虚留白处，竖题怀素狂草**《留白》**巨幅题额及制作组朱文闲章。

### 3.2 暂停与画理图鉴：《宋代蝴蝶装册页》

局内按下 `Esc` / `Start` 时，背景 `$2.5\text{D}$` 战斗画面瞬间定格并转为低饱和度泛黄古宣底纹，一本对开宣纸**宋代蝴蝶装册页**自屏幕中央优雅翻开；册页右侧边缘伸出四枚不同矿彩的**绫锦书签（Tab）**：

| 书签名称与矿彩 | 页面布局（左页 / 右页） | 核心特色交互 |
| :--- | :--- | :--- |
| **1. `【心诀】`（原矿朱砂签）** | **左页**：动态水墨线描招式演示小窗；<br>**右页**：瘦金体出招心法与四维循环图解。 | 完整展示**「划纸/掠地铺路 $\to$ 钻缝无敌滑行 $\to$ 折纸向心绞杀 $\to$ 抽纸处决回血」**及**「金石弹反 $\to$ 虚线撕甲」**按键组合，实时响应当前外设键帽。 |
| **2. `【画谱】`（石青矿彩签）** | **左页**：已遭遇杂兵、精英与主宰的名录索引；<br>**右页**：等比例动态角色立绘与薄弱命核解析。 | **【交互式“刮白剥甲”图鉴】**：右页敌方立绘默认披挂表层焦墨重甲，玩家可直接按住鼠标左键或推动右摇杆在图鉴纸面上**亲自“刮开”其表层浓墨**，实时揭露底下 `$0.25\ \text{mm}$` 单线白描木偶骨相与破甲要害！ |
| **3. `【印匣】`（工笔泥金签）** | **左页**：紫檀木九宫格印匣；<br>**右页**：选中印章的画理典故与机制说明。 | 收录已解锁的画道能力印章（如**「破宣」「掠地」「折纸」「拓片」「太虚」**），选中时印章翻起展示底部朱文篆刻。 |
| **4. `【规矩】`（陈年焦墨签）** | **左页**：音画参数滑块（毛笔墨迹拖拽条）；<br>**右页**：键鼠与手柄全键位自定义表。 | 支持调节音乐/音效/器乐音量、震屏强度（`$0\% \sim 100\%$`)、拓片反相闪光柔和度保护开关及键位重映射。 |

### 3.3 择章选关界面：《万里长卷缩略图谱》

* 以横向滚动的**青绿/焦墨缩略手卷**呈现全篇四章（序章赤朱残阳、第一章青绿叠翠、第二章飞白苍凉、终章白粉凝霜）及各幕朱砂印台落位。
* **首个试玩包（Demo v0.1）视觉封印**：在第一幕**「幕 1-1 青石浅滩」**之后，画卷边缘覆盖一道加盖**「执笔阁封卷泥金印」**的素绢封条，清晰标识首个试玩包体验边界与正式版后续篇章预告。

### 3.4 朱砂印台零黑屏复活与 Demo v0.1 封卷结算

1. **朱砂印台零黑屏回溯（`$650\ \text{ms}$` 画内重塑）**：
   * 主角五朵血梅碎尽阵亡时，**绝不弹出任何黑屏失败弹窗**。屏幕四周焦墨快速向中心合拢的同时，画面如倒放的墨水长河般沿地面在 `$650\ \text{ms}$` 内疾速倒卷回最近一枚**「朱砂印台」**，印台迸发红光主角重塑起身，全程零加载黑屏。
   * **防挫败自适应微提示**：仅当玩家在同一精英或关底 Boss 战连续阵亡 **`$3$` 次**后，复活起身的 `$3.0\ \text{s}$` 内于画面底角浮现一行极小的浅灰瘦金体锦囊（例如：*“墨梅三连突末式红光亮起时，挥錾格挡可触发拓片反相碎其血梅”*）。
2. **试玩包封卷落款（Demo v0.1 通关定格）**：
   * 主角经万丈飞瀑洗去血垢、滑跪定格于第一章**幕 1-1 青石浅滩**濯缨水榭前瞬间，镜头微推定格，画面右侧素绢留白处自上而下依次盖下朱砂巨印**`【留白 · 序章完】`**。
   * 印章左侧以古代**竹简算筹（横竖笔画计数）**与瘦金体呈现本局核心数据：**「破宣撕甲次数」「金石拓片反相次数」「最大连斩数」**，底部提供**`【重游序章】`**与**`【返回题卷】`**两枚印章按钮。

---

## 第四部分：多端外设自适应键位印章与声学交互规范

### 4.1 双端键帽造型规范（自动热切换）

系统实时监听最近一次有效输入事件，在两套传统材质键帽间零延迟切换（严禁出现 Xbox 与键鼠图标混杂显示）：

* **键鼠模式（生宣墨字键帽）**：方正毛边生宣小纸签（`#EFE9DA` 底色 + `$1\ \text{px}$` 焦墨细框 + 瘦金体黑字），如 `[J]`、`[K]`、`[Shift]`、`[左键]`、`[右键]`。
* **手柄模式（金石拓片键帽）**：黑底白线圆角碑刻小印（`#0A0908` 底色 + `$1.5\ \text{px}$` 泥金/纯白描边），自动识别 Xbox（`[X]`、`[Y]`、`[A]`、`[RB]`、`[RT]`、`[LB]`）与 PlayStation（`[□]`、`[△]`、`[×]`、`[R1]`、`[R2]`、`[L1]`）图标。

### 4.2 纯粹传统书画与器乐声学反馈表

所有 UI 交互音效均走独立总线且配置 `process_mode = PROCESS_MODE_ALWAYS`，播放时长严格对齐真实墙钟毫秒数：

| UI 交互事件 | 声学采样材质 | 播放时长<br>*(真实墙钟)* | 听觉质感要求 |
| :--- | :--- | :--- | :--- |
| **菜单选项悬停** | 干狼毫毛笔轻扫生宣纸面 | **`$80\ \text{ms}$`** | 清脆干爽的“沙”声，音高随选项上下位置有 `$\pm 4\%$` 微调。 |
| **选项确认 / 落印** | 青田石印章重顿朱砂印泥 | **`$180\ \text{ms}$`** | 沉稳厚重的玉石闷响伴随极短促的余振。 |
| **暂停册页翻开 / 切页** | 厚桑皮生宣翻折抖动 | **`$240\ \text{ms}$`** | 富有纸张纤维张力的清脆“哗啦”翻书声。 |
| **返回 / 取消操作** | 乌木竹简轻叩案几 | **`$110\ \text{ms}$`** | 短促干脆的硬木轻叩“笃”声。 |
| **图鉴刮白剥甲交互** | 篆刻刀轻刮宣纸表面 | 循环采样 | 随鼠标/摇杆移动速度实时调制滤波频率的沙沙刮纸声。 |

---

## 第五部分：Godot 4.3+ UI 工程架构、Shader 与核心脚本实现

### 5.1 `CanvasLayer` 渲染层级隔离架构

为防止 `stone_rubbing_inverse.gdshader`（弹反与处决时的全屏黑白负片反相）将局内按键提示与 Boss 书法血条误反相成刺眼色块，全工程严格执行以下节点分层：

```text
MainScene (Node3D)
├── StageCamera3D & 3D World (Layer 0)
├── PostProcessLayer (CanvasLayer, layer = 100)
│   ├── CanvasShreddingOverlay (ColorRect: 屏幕撕裂遮罩合成)
│   ├── StoneRubbingInverseRect (ColorRect: stone_rubbing_inverse.gdshader 全屏拓片反相)
│   └── LowHPInkVignette (ColorRect: 濒死焦墨侵蚀暗角)
└── MasterUILayer (CanvasLayer, layer = 110, process_mode = PROCESS_MODE_ALWAYS)
    ├── InWorldSignifiers (Control: 钻缝顿点准星、折纸角标、处决阳文印、朱砂暴击数字)
    ├── BossCalligraphyHPBar (Control: 关底主宰单笔枯墨横画血条)
    ├── FinisherScrollUI (Control: 四边墨迹燃烧引信 + 顶部字帖描红进度)
    ├── ButterflyAlbumPauseMenu (Control: 宋代蝴蝶装四签册页暂停与刮白图鉴)
    └── ScrollSealTransition (Control: 标题横披手卷与 Demo v0.1 封卷落款)
```

### 5.2 印泥生宣渗墨悬停着色器 (`ink_bleed_hover.gdshader`)

挂载于主界面及册页选项右侧的朱砂闲章 `TextureRect` 上，悬停聚焦时由 `Tween` 将 `bleed_progress` 在 `$120\ \text{ms}$` 内从 `0.0` 推至 `1.0`，模拟朱砂印泥沿桑皮纸纤维自然渗开的效果：

```glsl
shader_type canvas_item;

uniform float bleed_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 cinnabar_color : source_color = vec4(0.765, 0.153, 0.169, 1.0); // #C3272B
uniform sampler2D paper_fiber_noise; // 桑皮纸纤维噪波纹理

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float fiber = texture(paper_fiber_noise, UV * 2.5).r;
	
	// 计算距离印章中心的径向距离，结合纸纤维噪波产生不规则毛刺边缘
	vec2 centered_uv = UV - vec2(0.5);
	float dist = length(centered_uv) * 2.0;
	float edge_mask = smoothstep(bleed_progress * 1.15, bleed_progress * 1.15 - 0.25, dist + (fiber - 0.5) * 0.28);
	
	// 边缘形成比中心略深的“积墨环”质感
	float rim_darken = smoothstep(0.15, 0.0, abs(dist - bleed_progress * 0.95)) * 0.22;
	vec3 final_rgb = mix(tex.rgb, cinnabar_color.rgb - vec3(rim_darken), edge_mask);
	float final_alpha = max(tex.a, edge_mask * 0.92) * step(0.01, bleed_progress + tex.a);
	
	COLOR = vec4(final_rgb, final_alpha);
}
```

### 5.3 多端动态键位印章组件 (`InputGlyphSeal.gd`)

自动检测玩家最新一次有效输入来自键鼠还是手柄，无缝切换生宣键帽与金石拓片键帽：

```gdscript
class_name InputGlyphSeal
extends Control

@export var action_name: StringName = &"attack"
@export var display_label: String = "破宣斩"

@onready var keycap_bg: PanelContainer = $HBox/KeycapPanel
@onready var glyph_label: Label = $HBox/KeycapPanel/GlyphLabel
@onready var action_text: Label = $HBox/ActionText

var _is_using_gamepad: bool = false

func _ready() -> void:
	action_text.text = display_label
	_refresh_glyph()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion and absf(event.axis_value) < 0.35:
			return
		if not _is_using_gamepad:
			_is_using_gamepad = true
			_refresh_glyph()
	elif event is InputEventKey or event is InputEventMouseButton:
		if _is_using_gamepad:
			_is_using_gamepad = false
			_refresh_glyph()

func _refresh_glyph() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	for ev in events:
		if _is_using_gamepad and ev is InputEventJoypadButton:
			glyph_label.text = _format_joy_button(ev.button_index)
			_apply_style(true)
			return
		elif not _is_using_gamepad and (ev is InputEventKey or ev is InputEventMouseButton):
			glyph_label.text = _format_kbm_event(ev)
			_apply_style(false)
			return

func _apply_style(gamepad: bool) -> void:
	# 手柄切换为金石拓片黑底白字风格，键鼠切换为生宣黑字风格
	keycap_bg.self_modulate = Color("#0A0908") if gamepad else Color("#EFE9DA")
	glyph_label.add_theme_color_override("font_color", Color("#FFFFFF") if gamepad else Color("#0A0908"))

func _format_joy_button(btn: JoyButton) -> String:
	match btn:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		_: return "BTN"

func _format_kbm_event(ev: InputEvent) -> String:
	if ev is InputEventMouseButton:
		return "左键" if ev.button_index == MOUSE_BUTTON_LEFT else "右键"
	return OS.get_keycode_string(ev.physical_keycode)
```

### 5.4 关底主宰单笔枯墨血条控制器 (`BossCalligraphyHPBar.gd`)

通过插值平滑追踪 Boss 生命比例，驱动飞白枯墨笔触的干涸消退与受击微震：

```gdscript
class_name BossCalligraphyHPBar
extends Control

@onready var title_label: Label = $BossTitleLabel
@onready var ink_stroke_rect: TextureRect = $InkStrokeBar
@onready var trailing_ink_rect: TextureRect = $TrailingCinnabarBar

var _target_ratio: float = 1.0
var _display_ratio: float = 1.0

func setup_boss(boss_name: String) -> void:
	title_label.text = boss_name
	_target_ratio = 1.0
	_display_ratio = 1.0
	visible = true

func update_hp(current_hp: float, max_hp: float) -> void:
	_target_ratio = clampf(current_hp / maxf(max_hp, 1.0), 0.0, 1.0)
	# 更新主墨迹宽度，同步更新飞白枯笔遮罩阈值
	ink_stroke_rect.material.set_shader_parameter("fill_ratio", _target_ratio)

func _process(delta: float) -> void:
	if not visible:
		return
	# 朱砂残血延迟槽平滑追赶主墨迹（使用未缩放 delta 保持视觉节奏稳定）
	var unscaled_delta: float = delta / maxf(Engine.time_scale, 0.001)
	_display_ratio = lerpf(_display_ratio, _target_ratio, clampf(unscaled_delta * 8.0, 0.0, 1.0))
	trailing_ink_rect.material.set_shader_parameter("fill_ratio", _display_ratio)
```