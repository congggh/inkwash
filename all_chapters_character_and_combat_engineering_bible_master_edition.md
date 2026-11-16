# 《留白》（Ink & Void）全章节角色造像、战斗数值与画理工程全典

> **【主美与主程联合执行宪章 · SOP 4.0 唯一真值基准】**：
> “天地被万钧规矩涂满，唯有你是那道未竟的草稿。
> 主角不是传统意义上循规蹈矩的侠客，而是一张自执笔阁牢笼中觉醒逃逸的‘活体白描底稿’；全篇所有敌对生灵与守关主宰，亦非生来残虐，皆是被后天强加的厚重焦墨、工笔界画、剧毒矿彩与沉重生铁所窒息异化的纸偶傀儡。
> 玩家挥出的每一次**破宣斩**，都在物理层面实时剥皮、撕裂表层的焦墨世界；每一次**钻缝滑行**与**折纸绞杀**，是以画理法则重构空间拓扑；每一次**两段式题跋处决**，是将沉沦于伪史长卷的残魂，完好无损地超度回素宣大明！”
>
> **【渲染与镜头底座】**：Godot Engine 4.3+ · **2.5D 长焦微俯视透视（`Camera3D`，标准机位 `FOV = 36°`、`Pitch = -15°`）** · 战斗与地形刚体通过 `Axis Lock` 严格锁死于 `$Z = 0$` 平面 · 匹配 **`$3.2\ \text{m}$` 纵深宽度的 3D 可行走台面（`$Z \in [-1.6\ \text{m}, +1.6\ \text{m}]$`）** · 双时钟（真实墙钟毫秒级判定 vs 世界演算钟）独立仲裁。

---

# 第一部分：全系统画道生态、核心战斗循环与数值架构

## 1.1 主角与敌对势力的“表里对立”四层物理拓扑

全游戏所有生命体的视觉图层与渲染管线，均严格绑定于**双 `Camera3D` 镜像同步撕纸管线**（主相机渲染表层 3D 浓墨世界，副 `SubViewport` 内的同参数 `Camera3D` 实时渲染里层 3D 白描世界），确保角色脚点（`Sprite3D` 轴心 `Bottom-Center`）在微俯视台面上严丝合缝：

```text
                    ┌─── 玩家角色【墨痕】：永恒里白（活体宣纸底稿）
                    │    · 0.25mm 纯黑单线铁线描 + 泛黄手工老桑皮生宣肌理
                    │    · 皮下隐性搏动的暗红硫化汞原矿朱砂经络 + 兵刃【断铁錾 · 裁云】
                    │    · 能力：实时刮画剥皮、钻入白描裂隙化墨穿刺、折纸坍缩空间、沿虚线撕飞敌甲
                    │
【生命体画道对立】 ─┤
                    │
                    └─── 敌对势力（杂兵 / 精英 / 守关主宰）：四层复合“表层涂抹体”
                         · 顶层（Layer 1 - Top Ink）：工笔焦墨、生铁重甲、厚堆矿彩（提供 45%~60% 物理减伤护甲）
                         · 夹层（Layer 2 - Frayed Transition）：踏入刮白力场或被折纸挤压时，墨甲去色软化并掉落墨渣
                         · 底层（Layer 3 - Baimiao Core）：被困在其内的李公麟单线白描纸偶骨架与榫卯连杆木偶
                         · 命核（Layer 4 - Calligraphic Heart）：跳动的纯白宣纸画心 / 朱砂小印 / 封印的古谱火种
```

## 1.2 核心战斗闭环与破甲伤害公式（废除旧版数值槽）

全面废除旧版“全屏留白率（`0~100%`）数值槽”与“被动举盾格挡”。战斗以**「划纸铺路 $\to$ 钻缝穿刺 $\to$ 折纸聚怪 $\to$ 抽纸刷新」**及**「弹反金石拓片反相 $\to$ 虚线撕甲 Pogo」**为双核驱动：

### 1. 四大核心交互法则
1. **划纸·化墨（刮白绝对领域）**：主角挥刀与冲刺会在屏幕及 `$3.2\ \text{m}$` 宽的 3D 台面顶面（投射纯白生宣 `Decal`）留下滞留 **`$4.0\ \text{s}$`** 的白描裂隙。任何敌人踏入裂隙范围，表层墨甲瞬间去色软化：**物理防御力骤降 `$40\%$`，移动与攻击速度强制降低 `$30\%$`（拖曳水墨晕染重影）**。
2. **裂隙无敌滑行（Rift Grind）**：在白描裂隙附近按冲刺键，主角实体隐藏并融进纸缝，化作贴地疾驰的狂草墨线（**全程无敌 + 移速 `$31.25\ \text{m/s}$`**），高速穿刺沿途所有敌人触发背刺暴击与高额削韧。
3. **折纸·绞杀（Spatial Fold）**：当屏幕存在两条及以上交叉裂隙时按下技能键，触发 **`$200\ \text{ms}$`** 慢动作蓄势（`time_scale = 0.20`）与 **`$240\ \text{ms}$`** 屏幕向心坍缩畸变，将周围敌人强行扯向交叉点撞击，瞬间震碎杂兵表层焦墨护甲。
4. **抽纸·处决（Rip-Out Finisher）**：当敌方削韧条（Poise）清空陷入“纸片化硬直”或生命值低于 **`$30\%$`** 时，冲刺穿过敌人即可反手将其表层浓墨形态整张撕下，瞬间斩杀并**立刻刷新冲刺与折纸冷却**，同时恢复 **`$0.5$` 朵朱砂血梅**（每处决 `$2$` 名杂兵恢复 `$1$` 点生命）。

### 2. 统一伤害与护甲计算公式
$$\text{实际造成伤害} = \text{技能基础伤害} \times \left(1 - \text{有效减伤率}\right) \times \text{背刺/暴击倍率}$$
* **常态带甲状态**：杂兵与精英身披表层浓墨重甲时，拥有 **`$45\% \sim 60\%$`** 的高额物理减伤。若玩家不利用撕纸机制而硬砍，击杀一名普通杂兵需 `$10 \sim 14$` 刀，节奏沉闷。
* **刮白力场破甲状态（核心爽点）**：一旦将敌人逼入白描裂隙（防御 `$-40\%$`）或用**折纸·绞杀**震碎其表层墨甲，敌方减伤率归零并转为 **`$1.35\times$` 易伤状态**——此时配合裂隙滑行背刺（`$1.5\times$` 暴击）与抽纸处决，一套流畅连携即可在 `$2.5\ \text{s}$` 内轰杀整群重甲杂兵！

## 1.3 双时钟统一动作计时与打击感（Juice）规范

为避免 `Engine.time_scale` 缩放污染输入判定与冻结时长，全系统严格划分**真实墙钟（Unscaled Wall Clock，基于硬件微秒时间戳 `Time.get_ticks_usec()` 与 `ignore_time_scale = true`）**与**世界演算钟（Scaled Game Clock，基于 `delta * Engine.time_scale`）**，所有逻辑计时对齐 `$50\ \text{Hz}$` 物理步（`$1\ \text{Tick} = 20\ \text{ms}$`）：

| 战斗事件 / 机制 | 时钟归属 | 输入 / 判定窗口<br>*(真实墙钟)* | 实际冻结时长<br>*(真实墙钟)* | 动画视觉时长<br>*(60 FPS 基准)* | 声学与镜头反馈（`Camera3D`） |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **土狼时间 / 跳跃缓冲** | 真实墙钟 | 土狼 **`$100\ \text{ms}$`**（`$5$` 步）<br>缓冲 **`$120\ \text{ms}$`**（`$6$` 步） | 无 | 落地 `$2$` 帧压扁弹性 | 踏石/踏水轻响（`$80\ \text{ms}$`）；接地 `$Y$` 轴锚点平滑吸附（`$0.25\ \text{s}$`）。 |
| **破宣斩 · 轻击 1~2 段** | 局部冻结走墙钟<br>挥刀走演算钟 | 判定激活 **`$80\ \text{ms}$`**（`$4$` 步）<br>连招缓冲 **`$140\ \text{ms}$`**（`$7$` 步） | 局部顿帧 **`$60\ \text{ms}$`**<br>*($3$ 物理步)* | 全程 **`$267\ \text{ms}$`**（`$16$` 帧）：<br>前摇 `$4$` / 判定 `$5$` / 后摇 `$7$` | 干生宣撕裂“刺啦”声（`$180\ \text{ms}$`）；镜头沿出刀矢量微推 `$0.08\ \text{m}$`。 |
| **破宣斩 · 重击 3 段** | 局部冻结走墙钟<br>挥刀走演算钟 | 判定激活 **`$100\ \text{ms}$`**（`$5$` 步） | 局部顿帧 **`$80\ \text{ms}$`**<br>*($4$ 物理步)* | 全程 **`$367\ \text{ms}$`**（`$22$` 帧）：<br>前摇 `$7$` / 判定 `$6$` / 后摇 `$9$` | 厚宣裂帛 + 气爆声（`$260\ \text{ms}$`）；台面烙下白色划痕 `Decal`。 |
| **裂隙无敌墨线滑行** | 演算钟主导<br>出缝缓冲走墙钟 | 距裂隙 `$0.45\ \text{m}$` 内按冲刺吸附；全程无敌 | 穿刺敌人触发局部 **`$40\ \text{ms}$`**（不冻结主角） | 按裂隙长度动态持续（`$31.25\ \text{m/s}$` 疾驰） | 干毛笔疾书“沙沙”摩擦声 + 出缝爆音（`$150\ \text{ms}$`）。 |
| **折纸·绞杀 / 空中撕裂** | 真实墙钟控窗<br>世界按 `0.20` 缩放 | 最长蓄势窗口 **`$200\ \text{ms}$`**（`$10$` 步） | 慢动作 `time_scale = 0.20`（无全冻结） | 空间向心坍缩畸变持续 **`$240\ \text{ms}$`**（墙钟） | 纸张折叠挤压闷响（`$240\ \text{ms}$`），BGM 瞬时高通滤波。 |
| **完美弹反 · 金石拓片** | 真实墙钟<br>*(覆盖一切慢动作)* | 有效招架窗口 **`$160\ \text{ms}$`**（`$8$` 物理步） | 全局定格 **`$260\ \text{ms}$`**<br>*($13$ 物理步 / `~16` 帧)* | 黑底白线拓片负片维持 **`$260\ \text{ms}$`**；重甲爆碎 **`$350\ \text{ms}$`** | 青铜编钟裂帛爆鸣（`$450\ \text{ms}$`）；`Camera3D` 对角线推近至 `FOV = 31°` 并震屏。 |
| **Boss 掀卷破阵** | 真实墙钟 | 虚线亮起后 **`$1500\ \text{ms}$`** 交互窗口 | 掀卷瞬间全局定格 **`$200\ \text{ms}$`**（`$10$` 步） | 翻书卷页 Shader 从左至右卷起 **`$450\ \text{ms}$`** | 厚巨幅画卷翻卷“呼啦”声 + 古筝崩弦重音（`$600\ \text{ms}$`）。 |
| **落卷近身按键处决** | 真实墙钟 | 落地近身亮起 `[处决]` 提示 | 序章~二章 **`$300\ \text{ms}$`**<br>终章顾狂墨 **`$340\ \text{ms}$`** | 贯心刺入 + 拓片反相 **`$300 \sim 340\ \text{ms}$`**；狂草炸裂 **`$600\ \text{ms}$`** | 镜头瞬切特写 **`FOV = 24°`、`Pitch = -10°`**；洪钟大吕重音（`$1200\ \text{ms}$`）。 |

---

# 第二部分：主角【墨痕】—— 活体白描修律者完整设定与数值

```text
                  ┌─── 头部：散乱焦墨长发 + 下颌暗红血符勒带 + 冷澈双眸
                  │
【墨痕】造像解构 ──┼─── 躯干：右半身焦墨死肉 (沥青开裂) vs 左半身纯净生宣 (0.25mm 铁线经络)
                  │
                  ├─── 佩刃：【断铁錾 · 裁云】（秦汉古铜残錾 + 焦墨硬化断锋 + 飞白裂帛物理）
                  │
                  └─── 机制：【破宣斩刮白】+【钻缝狂草滑行】+【折纸坍缩聚怪】+【金石拓片反相】
```

## 2.1 角色基础属性与生命续航机制

| 属性维度 | 数值规格 | 机制说明 |
| :--- | :--- | :--- |
| **生命值（无 HUD）** | **`$5$` 朵原矿朱砂血梅** | 悬浮于主角身周 3D 空间；每次受击扣除 `$1$` 朵并触发 **`$1000\ \text{ms}$`** 受击无敌帧与 `$80\ \text{ms}$` 局部顿帧；仅剩 `$1$` 朵时腰间朱文印【生】高频红光搏动。 |
| **生命恢复途径** | **进攻型以战养战** | 取消站桩回血。每完成 **`$2$` 次【抽纸·处决】** 或 **`$1$` 次【精英虚线撕甲】**，周身凝聚恢复 **`$1$` 朵朱砂血梅**。 |
| **基础运动参数** | 奔跑 **`$12.5\ \text{m/s}$`**<br>起跳初速 **`$+17.15\ \text{m/s}$`** | 满跳高度 `$3.0\ \text{m}$`（上升重力 `$-49.0\ \text{m/s}^2$`，下落重力 `$-65.0\ \text{m/s}^2$`）；$3.2\ \text{m}$ 纵深台面内支持小幅 `$Z$` 轴微调闪避（`$Z \in [-1.2\ \text{m}, +1.2\ \text{m}]$`）。 |
| **地面冲刺 / 裂隙滑行** | 常规冲刺 **`$20.0\ \text{m/s}$`**<br>裂隙滑行 **`$31.25\ \text{m/s}$`** | 常规冲刺持续 `$180\ \text{ms}$（前 `$140\ \text{ms}$` 无敌，CD `$450\ \text{ms}$`）；进入白描裂隙触发**裂隙无敌滑行**，穿刺敌人刷新冲刺 CD。 |

## 2.2 全套技能招式数值与输入映射（SOP 4.0 标准键位）

| 技能名称 | 输入指令<br>*(键鼠 / 手柄)* | 基础伤害 / 削韧 | 耗时与冻结<br>*(真实墙钟)* | 核心画理特效与物理交互 |
| :--- | :--- | :--- | :--- | :--- |
| **破宣斩 · 一段横抹** | `J` / 鼠标左键 / `X` | 伤害 **`$25$`**<br>削韧 **`$20$`** | 全程 `$267\ \text{ms}$`<br>顿帧 `$60\ \text{ms}$` | 向前微突 `$1.2\ \text{m}$`，在屏幕与台面刮出宽 `$0.48\ \text{m}$` 白描裂隙（存留 `$4.0\ \text{s}$`），赋予敌人“防御 `$-40\%$` + 减速 `$30\%$`”。 |
| **破宣斩 · 二段倒卷帘** | `J` 连按 | 伤害 **`$25$`**<br>削韧 **`$25$`** | 全程 `$267\ \text{ms}$`<br>顿帧 `$60\ \text{ms}$` | 斜挑 `$45^\circ$` 飞白刀光；若与一段裂隙交叉，交叉点生成旋转“宣纸破洞漩涡”。 |
| **破宣斩 · 三段枯笔断岳** | `J` 连按 | 伤害 **`$45$`**<br>削韧 **`$45$`** | 全程 `$367\ \text{ms}$`<br>顿帧 `$80\ \text{ms}$` | 竖直重劈砸地，台面烙下白色裂隙 `Decal`；命中“宣纸破洞”时引爆负压聚怪并震碎杂兵硬壳。 |
| **踏墨穿石（下劈 Pogo）** | 空中 `S` + `J` / 摇杆下 + `X` | 伤害 **`$25$`**<br>削韧 **`$30$`** | 判定 `$100\ \text{ms}$`<br>顿帧 `$60\ \text{ms}$` | 命中敌人、墨桶或切落的 3D 断盾残骸时，自身垂直反弹 **`$V_y = +18.0\ \text{m/s}$`**，目标头顶绽开白莲印并**刷新空中冲刺与空中撕裂**。 |
| **钻缝无敌滑行（Rift Grind）** | 裂隙旁 `Left Shift` / `RT` | 穿刺伤害 **`$40$`**<br>背刺削韧 **`$40$`** | 按裂隙长度动态持续；穿刺微顿 `$40\ \text{ms}$` | 肉身化作狂草墨线沿裂隙 `$31.25\ \text{m/s}$` 疾驰（全程无敌），穿过敌人触发背刺暴击与交叉小裂隙。 |
| **折纸·绞杀 / 手撕空间** | `K` / 手柄 `LB` | 坍缩伤害 **`$35$`**<br>范围削韧 **`$55$`** | 蓄势窗 `$200\ \text{ms}$`<br>坍缩畸变 `$240\ \text{ms}$` | **地面/双裂隙**：沿交叉裂隙触发屏幕向心坍缩，强行聚怪并震碎表层墨甲；<br>**空中单次**：扯开半月形撕裂口蓄力，按 `Space`/`A` 向八向爆冲 `$4.5\ \text{m}$（穿过旧裂隙触发“破纸连环爆”并刷新冲刺）。 |
| **瞬时留白（金石弹反）** | `F` / 鼠标右键 / `RB` | 反震削韧 **`$80$`**<br>（直接破防） | 有效窗 **`$160\ \text{ms}$`**<br>全局定格 **`$260\ \text{ms}$`** | 招架红光“危”字重击瞬间触发全屏黑底白线“金石拓片负片”反相与 `Camera3D` 对角线推近；精英甲胄亮起朱砂裁切虚线，解冻首帧出刀可直接撕飞重盾化为可 Pogo 的 3D 物理残骸。 |
| **抽纸·处决** | 对虚弱/残血敌按 `Shift` 或 `E` | **即死斩杀（`$999$`）** | 处决演出 `$180\ \text{ms}$`（无敌帧） | 错身瞬间将敌人表层浓墨形态整张撕下，化作漫天纯白纸蝶；**立刻刷新冲刺与折纸 CD**，并恢复 `$0.5$` 朵朱砂血梅。 |

---

# 第三部分：序章【赤朱残阳】角色与敌对数值机制全典（Demo v0.1 核心实装）

* **环境与机位基准**：`Camera3D` 标准机位 `FOV = 36°`、`Pitch = -15°`；李唐大斧劈皴玄武岩台面（`$3.2\ \text{m}$` 纵深）+ 原矿朱砂血雨。

## 3.1 杂兵：【盲眼巡卒】（The Blind Patrol）

* **数值面板**：
  * **生命值（HP）**：**`$150$`**（常态带甲减伤 `$45\%$`，硬砍需 `$11$` 刀；踏入刮白力场去色后减伤归零且易伤 `$1.35\times$`，连携只需 `$3 \sim 4$` 刀即可进入抽纸处决线）。
  * **削韧值（Poise）**：**`$60$`**（削韧清零陷入 `$2.5\ \text{s}$` 纸片化僵直，可直接触发【抽纸·处决】）。
  * **抽纸斩杀线**：生命值 `$\le 45\ \text{HP}$（$30\%$）` 或削韧清零。
  * **移动速度**：巡逻 `$3.2\ \text{m/s}$`，索敌冲锋 `$6.8\ \text{m/s}$`。
* **表里造像拆解**：
  * **表层外甲**：面部缠绕浸透暗红血泥的粗麻符布，身披厚两寸的生铁焦墨硬坎肩，手持三尺二寸生铁戒尺；
  * **里层骨相**：撕去外层后显露 `$0.25\ \text{mm}$` 纯黑单线铁线描皮影纸人，关节由微型木质鲁班锁咬合。
* **技能与 AI 行为机制**：
  1. **戒尺前劈（Ruler Cleave）**：前摇 **`$640\ \text{ms}$`**（额前墨引亮起暗红警示点），向前跨步劈砍（伤害 `$1$ 朵血梅`，判定 `$120\ \text{ms}$`，后摇 `$500\ \text{ms}$`）。
  2. **血符扑抓（Talisman Lunge — 危）**：当主角在 `$4.0\ \text{m}$` 外释放技能时触发，前摇 **`$700\ \text{ms}$`**（亮起红光“危”字），以 `$13.0\ \text{m/s}$` 跃起扑抓；可用 `160 ms` 弹反直接震碎其坎肩。
  3. **宿墨涂抹（Ink Smear — 战场对抗技）**：当巡卒脚下踩到主角留下的白描裂隙 `Decal` 时，若 `$1.5\ \text{s}$` 内未被击杀，会抬脚重踏地面泼出黑墨，提前覆盖缩短该段白描裂隙的持续时间，迫使主角主动抢攻。

## 3.2 精英：【镇峰狱尉】（The Peak Warden · 幕 0-3 军械营）

* **数值面板**：
  * **生命值（HP）**：**`$580$`**（全游戏首个精英检验官）。
  * **表层甲胄减伤**：正面持盾时**绝对弹刀霸体（减伤 `$90\%$`）**；背面/侧面常态减伤 `$50\%$`；大盾被虚线撕除后本体减伤归零，进入脆弱白描木偶态。
  * **大盾结构耐久（Shield Poise）**：**`$120$`**（每次完美弹反造成 `$60$` 点结构破坏，累计 `$2$` 次弹反触发【虚线撕盾】）。
* **表里造像拆解**：
  * **表层外甲**：高两丈，头戴青铜狴犴重盔，手持两米高【工笔泥金六角方圆生铁大盾】；
  * **里层骨相**：大盾沿朱砂裁切虚线被一分为二撕飞后，外甲粉化，露出内部极度佝偻、由数根黑铁丝悬吊的**白描老画工木偶**，胸腔内跳动着一颗暗红朱砂引首方印。
* **技能与机制拆解**：
  1. **金石盾冲（Basalt Shield Charge — 危）**：前摇 **`$600\ \text{ms}$`**（盾面泥金线条转为暴怒深红），以 `$16.5\ \text{m/s}$` 沿 `$Z = 0$` 轴线发起全屏横冲（伤害 `$1$` 朵血梅）。弹反窗口内招架成功触发 **`$260\ \text{ms}$` 全局拓片负片定格**。
  2. **戒尺震地波（Ruler Shockwave）**：举盾重砸 `$3.2\ \text{m}$` 宽铁栅地面，沿地表向前释放一道高 `$1.1\ \text{m}$` 的熔渣火浪（需跳跃或空中裂隙越过）。
  3. **铁锁拘魂（Chain Pull）**：向 `$Z = 0$` 空中斜向甩出粗重生铁绞索，命中将把主角拉至身前接横扫。
  4. **核心机制【虚线撕盾 & 断盾 Pogo】**：累计两次弹反后，拓片定格期间盾面亮起发光朱砂裁切虚线，解冻首帧主角自动拔刀将重盾一分为二撕飞！切落的半截生铁大盾化作 **3D 物理刚体残骸（`RigidBody3D`）**在空中翻滚下坠，玩家可踩踏断盾施展 **下劈（Pogo）** 二次腾空，或一脚踢飞断盾砸向狱尉造成 **`$140\ \text{DMG}$` 巨额眩晕**！

## 3.3 守关主宰：【先锋镇将 · 墨梅】（General Mo Mei · 幕 0-10 断云台）

* **数值面板**：
  * **总生命值（HP）**：**`$1,600$`**（一阶段 `$650\ \text{HP}$` / 二阶段 `$750\ \text{HP}$` / 三阶段进入两段式终局处决 `$200\ \text{HP}$` 演播线）。
  * **常态减伤**：一阶段六相血梅护体时减伤 **`$45\%$`**；二阶段展开焦墨梅披风时减伤 **`$35\%$`**；处于主角刮白力场内额外削减 `$40\%$` 防御。
* **三阶段战斗行为与两段式终局交互**：
  * **Phase 1：工笔严规（`$1,600 \to 950\ \text{HP}$`）**
    * 身周公转 `$6$` 朵多面体原矿朱砂血梅结晶（每朵提供 `$7.5\%$` 减伤）。
    * **落梅三连突**：第一刺前摇 `$300\ \text{ms}$`，第二刺前摇 `$220\ \text{ms}$`，第三刺亮起红光“危”字（前摇 `$420\ \text{ms}$`，突刺速度 `$24.0\ \text{m/s}$`）。精准弹反第三刺触发 `$260\ \text{ms}$` 金石拓片反相，直接震碎 `$2$` 朵血梅（每次碎梅造成 `$90\ \text{DMG}$` 真实破甲伤害）。
    * **梅花剑雨**：腾空向 `$3.2\ \text{m}$` 宽的汉白玉台面投射 `$5$` 枚朱砂晶簇，触地炸开十字形焦墨刺阵；玩家可利用裂隙滑行无敌穿刺，或用**折纸·绞杀**将晶簇聚拢引爆。
  * **Phase 2：狂草暴走（`$950 \to 200\ \text{HP}$`）**
    * 墨梅撕裂战袍，背后爆出数百根狂乱【万劫焦墨老梅披风】，全场地表布满间歇性突刺的黑色梅枝荆棘（迫使玩家高频滞空）。
    * **旋风墨针阵**：墨梅悬浮半空高速旋转，向四周泼洒漫天墨针弹幕。玩家需在空中连续挥刀织出“白描减速网”，并施展**【空中手撕空间】**八向爆冲绕至墨梅天顶，接**下劈（Pogo）**踩击其剑尖后释放纵向重劈，一刀将焦墨披风自中轴线裁开撕飞！
  * **Phase 3：两段式终局处决（`$200 \to 0\ \text{HP}$` · 试玩包最高潮）**
    1. **绝境铺垫与掀卷破阵**：墨梅残血狂暴，漫天血梅与焦墨巨浪从屏幕四周淹没台面，屏幕边缘亮起贯穿天地的**朱砂裁纸虚线**。玩家按下重斩/交互键，主角将断铁錾插入画布底层发力掀翻——表层焦墨与弹幕如巨幅宣纸般从左向右卷成纸筒，将墨梅与弹幕死死压扁在屏幕右侧，露出 **`$100\%$ 纯净南唐澄心堂生宣里层世界`**（触发 `$200\ \text{ms}$` 全局定格与古筝崩弦重音）。
    2. **第 1 段交互 · 狂草七笔成「折」（`$4.5\ \text{s}$` 窗口）**：里层时间流速降至 `0.30`，玩家连续点击攻击键 **`$7$` 次**（对应“折”字七画：`一、亅、㇀、丿、丿、一、丨`）。每按一次，主角化作狂草墨线瞬移穿屏挥出一笔并劈砍右侧纸筒（局部顿帧 `$40\ \text{ms}$` + 定向微震）；若超时未按满，剩余笔画自动高速补全。
    3. **第 2 段交互 · 落卷近身按键处决**：第七笔落成瞬间，右侧纸筒炸裂为漫天纯白纸蝶，主角精准落地在瘫跪于擂台中央、显露单线白描剑仙真容的墨梅身前半步，镜头瞬切至 **`FOV = 24°`、`Pitch = -10°`** 超近特写。玩家按下近身 **`[处决]`** 键，触发 **`$300\ \text{ms}$` 全屏黑底白线“金石拓片负片”反相定格**，断铁錾贯心而入，全屏狂草巨字**「折」**轰然引爆！随后断云台崩塌，进入幕 T-1 以 `$-40.0\ \text{m/s}$` 垂直坠入万丈飞瀑。

---

# 第四部分：第一章【青绿叠翠】角色与敌对数值机制全典

* **环境与机位基准**：王希孟《千里江山图》式厚堆石青石绿矿彩；常规探索 `FOV = 36°`、`Pitch = -15°`；幕 1-8~1-10 江心极速跑打切换为宽幅追焦 **`FOV = 44°`、`Pitch = -13°`、`V_x = 14.0\ \text{m/s}$`**。

## 4.1 杂兵：【巡水工偶】（Water-Dredging Laborer）

* **数值面板**：
  * **生命值（HP）**：**`$180$`**（常态矿彩硬壳减伤 `$50\%$`；踏入白描裂隙去色后减伤归零并易伤 `$1.35\times$`）。
  * **削韧值（Poise）**：**`$75$`** | **抽纸斩杀线**：`$\le 54\ \text{HP}$（$30\%$）` 或削韧清零。
* **技能与 AI 行为机制**：
  1. **浚河毒钩横扫**：前摇 **`$520\ \text{ms}$`**，挥动丈二三棱生铁长钩横扫 `$2.6\ \text{m}$` 范围，命中附带 `$2.5\ \text{s}$` 矿毒粘滞（移速 `$-20\%$`）。
  2. **石绿矿浆喷吐**：中距离喷射三枚弧形石绿黏液弹，落地在 `$3.2\ \text{m}$` 台面顶面生成腐蚀性毒潭 `Decal`（持续 `$4.0\ \text{s}$`）；可用**空中手撕空间**吞噬或裂隙滑行无敌穿过。
  3. **沉锚固守**：当受到正面连续轻击时架起生铁钩柄进入招架姿态，诱导玩家使用**折纸·绞杀**从背后聚怪破防。

## 4.2 精英：【伏波画督】（Wave-Subduing Magistrate · 幕 1-5 画屏水阁）

* **数值面板**：
  * **生命值（HP）**：**`$680$`** | **四扇折叠画屏护甲值**：**`$150$`**（需累计 `$2$` 次弹反或 `$1$` 次三重折纸引爆破除）。
  * **常态减伤**：持屏正面霸体减伤 `$90\%$`；屏风撕飞后本体减伤归零。
* **技能与机制拆解**：
  1. **画屏推浪（Screen Tidal Push — 危）**：前摇 **`$640\ \text{ms}$`**，推盾前冲并掀起一道高 `$1.6\ \text{m}$` 的石青泥金毒浪向前推进。
  2. **界画水闸镇压**：跃起重砸地面，在 `$Z = 0$` 台面两侧升起两道泥金水幕封锁走位，并落下三道高压水柱。
  3. **提线木偶连斩**：外甲剥落后，内部白描皮影人受天顶黑丝牵引，发动高速三连刺。
  4. **核心机制【虚线撕屏 & 屏风滑板 Pogo】**：两次完美弹反后，画屏亮起朱砂裁切虚线，一刀将四扇折叠屏风横向腰斩！切落的半截泥金屏风落入水中成为可踩踏的 **3D 浮空滑板跳台**，玩家可踩屏风腾空施展全屏破宣斩。

## 4.3 守关主宰：【画院督监 · 墨竹】（Supervisor Mo Zhu · 幕 1-11 墨竹终局）

* **数值面板**：
  * **总生命值（HP）**：**`$2,400$`**（一阶段画阁竹阵 `$800\ \text{HP}$` / 二阶段 `$14.0\ \text{m/s}$` 碎木狂飙与应龙脊背空战 `$1,350\ \text{HP}$` / 三阶段两段式终局处决 `$250\ \text{HP}$`）。
* **三阶段战斗行为与两段式终局交互**：
  * **Phase 1：泼墨竹阵（`$2,400 \to 1,600\ \text{HP}$`）**
    * **修竹贯心枪**：高速突进三连刺，第三刺带红光“危”字（前摇 `$460\ \text{ms}$`）。弹反第三刺触发 `$260\ \text{ms}$` 拓片反相，直接削去其双臂老竹甲胄。
    * **千竿铁竹笋**：提斗大笔点地，台面依次刺出带倒刺的生铁竹笋阵。
  * **Phase 2：怒涛狂飙与逆水应龙（`$1,600 \to 250\ \text{HP}$`）**
    * 镜头拉远至 `FOV = 44°` 宽幅追焦，全速沿 `$14.0\ \text{m/s}$` 洪流推进。墨竹脚踏双枪在前方浪尖滑行，每 `$3.0\ \text{s}$` 挥毫筑起一道 `$20\ \text{m}$` 高的焦墨死壁；玩家需发动**顺流破宣斩**切穿死壁，随后跃上三百丈【太虚白描逆水应龙】起伏的汉白玉龙鳞脊背，躲避矿浆炸弹并贴身输出。
  * **Phase 3：两段式终局处决（`$250 \to 0\ \text{HP}$`）**
    1. **掀卷破阵**：墨竹狂暴掀起百丈石青石绿翡翠巨浪压顶，主角插刀掀翻青绿矿彩画卷，将巨浪卷成纸筒压扁在右侧，露出白描应龙龙头天台。
    2. **第 1 段交互 · 狂草八笔成「直」（`$5.5\ \text{s}$` 窗口）**：慢动作下连续点击攻击键 **`$8$` 次**，狂草墨线八笔纵横劈开天地。
    3. **第 2 段交互 · 落卷近身按键处决**：主角落地应龙龙头近身半步，镜头切至 `FOV = 24°` 特写，按下 **`[处决]`** 触发 **`$300\ \text{ms}$` 金石拓片反相**，一錾贯穿其中空竹心，全屏狂草巨字**「直」**轰然炸裂！随后提斗大笔砸穿江底宣纸，抽干亿万吨江水以 `$-55.0\ \text{m/s}$` 坠入第二章。

---

# 第五部分：第二章【飞白苍凉】角色与敌对数值机制全典

* **环境与机位基准**：倒插万座黑色无字墓碑林与干燥墨流沙；探索 `FOV = 36°`、`Pitch = -15°`；幕 2-10 无地面高空空战切为广角仰视微俯机位 **`FOV = 46°`、`Pitch = -8°`**。

## 5.1 杂兵：【守碑阴傀】（Stele-Guarding Shade）

* **数值面板**：
  * **生命值（HP）**：**`$210$`**（常态石碑外壳减伤 `$50\%$`；刮白力场内减伤归零且易伤 `$1.35\times$`）。
  * **削韧值（Poise）**：**`$90$`** | **抽纸斩杀线**：`$\le 63\ \text{HP}$（$30\%$）` 或削韧清零。
* **技能与 AI 行为机制**：
  1. **开山重凿（Chisel Slam）**：前摇 **`$700\ \text{ms}$`**，双手举生铁短錾重砸地面，溅射三颗带物理抛物线的飞白流沙石粒。
  2. **残碑格挡（Stele Guard）**：正面举起胸前镶嵌的黑色汉白玉残碑格挡轻击（触发弹刀）；必须利用**裂隙无敌滑行**穿体背刺，或用**折纸·绞杀**从背后破防。
  3. **沙暴隐匿**：受击后向后跳步并掀起一团干燥炭粉烟幕，短暂脱离锁定。

## 5.2 精英：【司弦刑官】（String-Inquisitor Officer · 幕 2-3 拓碑断壁）

* **数值面板**：
  * **生命值（HP）**：**`$760$`** | **血弦缠甲护盾值**：**`$160$`**。
* **技能与机制拆解**：
  1. **绝命挑弦（Sonic String Slash — 危）**：前摇 **`$500\ \text{ms}$`**，挑动横跨全场的猩红生铁古瑟弦，释放一道贯穿全屏的高速音波切割线；在音波命中前 `$160\ \text{ms}$` 内弹反，可将音波反弹震碎刑官瑟刃。
  2. **断头瑟旋风斩**：挥舞半截焦黑古瑟改装的巨斧旋转突进 `$6.0\ \text{m}$`，沿途留下带倒钩的血弦陷阱。
  3. **核心机制【音律共鸣裂隙 & 断瑟弹射】**：刑官周身缠绕的铁弦被两次弹反后亮起朱砂虚线，一刀裁断所有血弦，刑官外甲崩解露出白描盲眼乐师真身，同时场中残瑟主弦绷断，主角可踩踏断瑟触发 **`$45^\circ$` 超音速弹射（`$32.0\ \text{m/s}$`）**俯冲重创刑官！

## 5.3 守关主宰：【司碑宗师 · 墨骨】（Grandmaster Mo Gu · 幕 2-10 凌空裂渊）

* **数值面板**：
  * **总生命值（HP）**：**`$3,200$`**（一阶段司碑古坛 `$1,100\ \text{HP}$` / 二阶段无地面千丈深渊水袖空战 `$1,800\ \text{HP}$` / 三阶段两段式终局处决 `$300\ \text{HP}$`）。
* **三阶段战斗行为与两段式终局交互**：
  * **Phase 1：拓碑点卯（`$3,200 \to 2,100\ \text{HP}$`）**
    * **生铁拓碑长鞭**：长逾十丈的铁鞭三连抽（第三鞭亮红光“危”字，前摇 `$500\ \text{ms}$`）。弹反鞭梢触发 `$260\ \text{ms}$` 拓片反相，震碎其胸口一块《永寿诏书》罪碑。
    * **墨印镇压**：抛出五十斤开山錾砸击古坛，在台面形成扩大扩散的黑色拓印震荡波。
  * **Phase 2：凌空裂渊千丈空战（`$2,100 \to 300\ \text{HP}$`）**
    * 墨骨一錾砸碎整座玄武岩古坛，**地面彻底消失**！深渊两侧伸出万千乐仙的白描单线水袖天网作为空中跳台，镜头切为 `FOV = 46°` 广角空战视野。
    * **四翼石碑俯冲**：墨骨展开四扇倒插墓碑黑色石翼，以极速在空中交错俯冲并召唤落石风暴。玩家需借助水袖起跳，高频使用**【空中手撕空间】**与**【裂隙无敌滑行】**在空中穿梭，下劈（Pogo）踩击石翼边缘并释放破宣斩，将四扇石翼逐一劈裂！
  * **Phase 3：两段式终局处决（`$300 \to 0\ \text{HP}$`）**
    1. **掀卷破阵**：墨骨掀起遮天蔽日的干裂风沙与碎碑风暴，主角插刀掀翻枯笔风沙画卷，露出纯粹的白描万仙水袖仙境。
    2. **第 1 段交互 · 狂草十七笔成「藏」（`$7.0\ \text{s}$` 窗口）**：慢动作下高速连点攻击键 **`$17$` 次**，狂草墨线在虚空中织成繁复磅礴的“藏”字笔画狂轰右侧纸筒。
    3. **第 2 段交互 · 落卷近身按键处决**：主角踏水袖落地近身，镜头推至 `FOV = 24°` 特写，按下 **`[处决]`** 触发 **`$300\ \text{ms}$` 金石拓片反相**，断铁錾轻触其肋下纯白无字宣纸碑，全屏狂草巨字**「藏」**引爆！万座墓碑共鸣崩解化作千丈五彩狂草墨龙，驮负主角以 `$+50.0\ \text{m/s}$` 冲霄撞碎铅白天门。

---

# 第六部分：终章【白粉凝霜】角色与敌对数值机制全典

* **环境与机位基准**：`$95\%$` 大去色汉白玉神宫与铅白死霜；神圣探索 `FOV = 36°`、`Pitch = -15°`；幕 3-10 二阶段 `$95\%$` 白化绝境切为 **`FOV = 44°`、`Pitch = -15°`**。

## 6.1 杂兵：【去色司祝】（Desaturating Deacon）

* **数值面板**：
  * **生命值（HP）**：**`$240$`**（常态铅白硬丝绸袍减伤 `$55\%$`；刮白力场内减伤归零且易伤 `$1.35\times$`）。
  * **削韧值（Poise）**：**`$100$`** | **抽纸斩杀线**：`$\le 72\ \text{HP}$（$30\%$）` 或削韧清零。
* **技能与 AI 行为机制**：
  1. **铅拂扫霜（Lead-Frost Sweep）**：前摇 **`$560\ \text{ms}$`**，挥动刮霜铅拂释放宽 `$2.0\ \text{m}$` 的去色毒粉雾（持续 `$4.0\ \text{s}$`）；**毒粉雾会以 `$2.0\times$` 速率加速愈合主角砍出的白描裂隙**，迫使玩家加快连招节奏。
  2. **死白禁锢环**：在主角脚下台面投射泥金九宫格法阵，延迟 `$0.8\ \text{s}$` 后升起铅白晶体囚笼。
  3. **铅粉震爆**：面具破碎后向四周释放一圈短距铅霜冲击波。

## 6.2 精英：【平规衡司】（Balance-Keeper Praetor · 幕 3-3 千手戒尺殿）

* **数值面板**：
  * **生命值（HP）**：**`$880$`** | **黄金戒尺天平护甲值**：**`$180$`**。
* **技能与机制拆解**：
  1. **天平倾泻（Scale Deluge — 危）**：前摇 **`$720\ \text{ms}$`**，巨大黄金天平左倾倾泻粘稠焦墨、右倾倾泻致盲铅粉，随后轴心喷射贯穿全屏的泥金工笔冲击波（需跳跃或裂隙滑行规避）。
  2. **千尺雨落**：召唤殿顶倒悬的十二柄黄金戒尺垂直插落台面，形成限时物理障碍柱。
  3. **绝对度量横扫**：持天平横梁作大范围 `$180^\circ$` 横扫；弹反窗口内招架成功触发 `$260\ \text{ms}$` 金石拓片反相。
  4. **核心机制【虚线断衡 & 黄金天平 Pogo】**：两次完美弹反后，天平悬梁亮起朱砂裁切虚线，主角拔刀斩断悬绳，巨大的黄金天平秤盘砸落舞台化作可踩踏弹跳的 **3D 金属踏板**，内部白描盲眼大匠木偶彻底暴露。

## 6.3 终极大主宰：【大阁尊 · 顾狂墨】（Grandmaster Gu Kuangmo · 幕 3-9 ~ 3-10 弑神神坛）

* **数值面板**：
  * **总生命值（HP）**：**`$4,500$`**（一阶段千手戒尺法环 `$1,600\ \text{HP}$` / 二阶段 `$95\%$` 天下大去色狂澜 `$2,400\ \text{HP}$` / 三阶段悲悯殉道两段式终局处决 `$500\ \text{HP}$`）。
* **三阶段战斗行为与终极两段式交互**：
  * **Phase 1：铅白神明 · 千手戒尺（`$4,500 \to 2,900\ \text{HP}$`）**
    * 顾狂墨足踏两丈高汉白玉莲台，背后自转三百六十柄纯金生铁戒尺组成的【千手规矩法环】（提供 `$60\%$` 神圣减伤）。
    * **千尺剑雨与九宫激光网**：发射密集工笔金光剑阵，并在 `$3.2\ \text{m}$` 宽的汉白玉台面投射交错泥金规矩网格。玩家需连续 **`$3$` 次**精准弹反飞射而来的金色主尺，触发 `$260\ \text{ms}$` 拓片反相逐层瓦解千手法环，剥落其无垢神袍！
  * **Phase 2：天下大去色 · 万夜自剖（`$2,900 \to 500\ \text{HP}$`）**
    * 神袍碎裂，顾狂墨化身狂乱水墨老者，手持五丈焦墨枯笔挥洒**【天下大去色】**——全屏白化率飙升至 **`$95\%$`**（严重致盲暴雪），且常规白描裂隙会在 `$1.5\ \text{s}$` 内被铅霜吞噬。
    * 玩家需在此阶段觉醒**【太虚破宣】**，连续挥刀撕开厚重的铅白死霜表层，露出底层大阁尊万夜泣血自剖的朱砂血书草稿长廊（永久视野通路），在草稿走廊内利用**裂隙无敌滑行**与**折纸·绞杀**避开铅粉暴风，一刀劈开层层白纸包裹的胸口【五彩原谱火种】！
  * **Phase 3：悲悯殉道 · 终极两段式处决（`$500 \to 0\ \text{HP}$`）**
    1. **掀卷破阵**：顾狂墨在最后挣扎中释放灭世死白狂澜吞没全屏，主角插刀掀起整张 `$95\%$` 死白神域画卷卷成纸筒，露出纯粹无垢的太虚素宣天坛。
    2. **第 1 段交互 · 狂草六笔成「休」（`$10.0\ \text{s}$` 完整自由暴走）**：解锁全游戏最长、最自由的 **`$10.0\ \text{s}$`** 暴走窗口！主角脱离重力束缚化为纯粹狂草墨锋，每次按攻击键在屏幕任意位置瞬移出刀，在素宣上书写苍劲释怀的狂草六笔**「休」**字狂斩右侧纸筒。
    3. **第 2 段交互 · 落卷近身按键处决**：第六笔落成，右侧纸筒化作漫天光羽消散。顾狂墨褪尽铅白与焦墨，显露单线白描粗布长衫、瘦骨嶙峋的古稀老人真容，瘫跪于素宣地表。主角收刀缓步近身，镜头缓缓推至 **`FOV = 24°`、`Pitch = -10°`** 极近景特写。按下 **`[处决]`** 键，主角以断铁錾轻点老人胸膛中跳动的五彩原谱火种，触发 **`$340\ \text{ms}$` 全屏金石拓片负片反相定格**，狂草巨字**「休」**横贯九重天穹轰然引爆！老人微笑化作亿万点素宣光羽，解放的五彩墨浪浩浩荡荡席卷万里还彩人间，开启尾声【万里乾坤大留白】。

---

# 第七部分：全篇 2.5D 微俯视概念原画与帧动画 Sprite-Sheet 生图 Prompt 体系

> **【AI 资产生产统一光学铁律】**：
> 1. 彻底废除旧版 2D 纯平正交提示词，所有概念图与角色 `Sprite3D` 动作帧序列图均严格统一为 **2.5D 微俯视透视（`15-degree downward camera tilt`, `visible 3.2m walkway ground depth`）**，确保角色与 `$3.2\ \text{m}$` 纵深台面的脚点透视完全吻合。
> 2. 审美基准锁定为**《雾山五行》苍劲写意笔墨 + 南宋李公麟 `$0.25\ \text{mm}$` 单线铁线描 + 宋代金石拓片反相**，杜绝现代科幻霓虹光效与儿童绘本卡通描边。

## 7.1 核心角色与四大主宰 2.5D 微俯视概念原画 Prompt

### 1. 主角【墨痕】2.5D 微俯视战斗立绘与撕纸力场 (Protagonist Mo Hen)
```text
2.5D side-scrolling action game character concept art, slight high-angle top-down perspective (15-degree downward camera tilt), visible 3.2m wide dark basalt walkway ground depth and stepping surface, inspired by Wu Shan Wu Xing and Hollow Knight.

Male ink martial artist Mo Hen standing on a wet stone platform: his body is fundamentally an ancient Song Dynasty baimiao manuscript with delicate 0.25mm iron-wire black outlines on warm aged ivory raw Xuan paper (#EFE9DA), visible mulberry bark fibers, and glowing cinnabar red (#C3272B) meridians pulsing beneath the skin. The right side of his torso is corrupted by pitch-black charred ink with cracked stone textures. Wearing a ragged sleeveless charcoal overcoat with frayed dry-brush feibai edges, five small floating crimson cinnabar plum blossoms orbiting his shoulders.

Wielding a fractured bronze chisel blade with a razor edge formed by solidified charred-ink strokes. He has just slashed across the screen, physically peeling back the dark rainy ink surface to reveal a glowing white baimiao paper rift slit with 3D curled mulberry paper fiber edges and a white paper decal projected onto the stone floor beneath his feet.

Painterly ink brushwork, natural atmospheric depth, no modern neon, masterpiece, 8k resolution --ar 16:9 --v 6.1 --style raw
```

### 2. 序章主宰【先锋镇将 · 墨梅】三阶段蜕变 (Prologue Boss Mo Mei)
```text
2.5D side-scrolling action game boss concept art, slight high-angle top-down perspective (15-degree downward camera tilt), visible fractured white marble terrace ground plane bleeding cinnabar sap (#C3272B), Wu Shan Wu Xing ink-wash style.

Three transformative phases of Boss Mo Mei arranged from left to right across the 3D stage:
- Phase 1: Elegant Song Dynasty swordsman in rigid mud-gold (#D4A017) gongbi robes holding a flexible iron rapier, haloed by six orbiting faceted raw cinnabar crystal plum blossoms.
- Phase 2: Robes torn open, bursting with hundreds of wild charred-ink old plum branches forming a spiked iron cloak, summoning black thorny brambles across the marble floor.
- Phase 3: Pure Southern Song Dynasty baimiao single iron-wire line-art ethereal swordsman in simple white Xuan paper robes, kneeling in peaceful surrender as the outer ink shell dissolves into white paper butterflies.

Dramatic lighting, curled torn paper borders between phases, 8k resolution --ar 16:9 --v 6.1 --style raw
```

### 3. 第一章主宰【画院督监 · 墨竹】江心狂飙与应龙空战 (Chapter 1 Boss Mo Zhu)
```text
2.5D side-scrolling action game boss battle concept art, slight high-angle top-down perspective (15-degree downward camera tilt), wide 16:9 stage framing, Wu Shan Wu Xing painterly ink and heavy mineral pigment style.

Supervisor Mo Zhu wearing heavy samurai-scholar armor crafted from deep malachite-green (#1F4E3F) and azurite-blue (#16355C) bamboo stalks with mud-gold trims, wielding a giant barbed iron bamboo lance and a colossal calligraphy brush.

He surfs atop roaring hundred-foot waves painted in thick Qianli Jiangshan blue-green mineral pigment impasto. Facing him, the ink swordsman leaps off the serpentine white marble scales of a hundred-foot baimiao single-line water dragon, tearing open a white paper rift slit in mid-air.

Dynamic splashed mineral pigment droplets, mist depth, masterpiece, 8k resolution --ar 16:9 --v 6.1 --style raw
```

### 4. 第二章主宰【司碑宗师 · 墨骨】无地面裂渊空战 (Chapter 2 Boss Mo Gu)
```text
2.5D side-scrolling action game boss fight concept art, slight high-angle top-down perspective (8-degree downward camera tilt) overlooking a vast bottomless desiccated canyon, Wu Shan Wu Xing dry-brush feibai ink style.

Grandmaster Mo Gu, an enormous skeletal scholar entity encased in black stone tombstone rubbings with ancient Chinese inscriptions, spreading four massive wings made of inverted cracked black stone tablets, brandishing a heavy iron chisel and barbed whip.

The dark sandstorm chasm is slashed open to reveal the underlying golden baimiao draft dimension: floating white silk sleeves forming aerial suspension walkways and golden Gongche musical notation rings.

Coarse dry-brush feibai strokes, stark monochrome with aged imperial yellow paper (#F4E8C1) and mud-gold accents, 8k resolution --ar 16:9 --v 6.1 --style raw
```

### 5. 终章大主宰【大阁尊 · 顾狂墨】千手神坛与自剖 (Finale Boss Gu Kuangmo)
```text
2.5D side-scrolling action game climax boss concept art, slight high-angle top-down perspective (15-degree downward camera tilt), visible sterile white marble altar floor with gold compass gridlines, Wu Shan Wu Xing tragic ink aesthetic.

Grand Master Gu Kuangmo as a divine tragedy: a towering deity draped in immaculate lead-white frost (#F8F8F8) robes, seated on a white jade lotus haloed by 360 rotating golden architectural compass rulers.

The center of the canvas is violently peeled open by an ink warrior's blade: the sterile lead-white god is being stripped away, exposing his underlying true form—a weeping, frail old calligrapher in delicate 0.25mm baimiao robes with an open chest housing a glowing five-color mineral flame, surrounded by thousands of desperate handwritten cinnabar-red cursive apology scrolls on ivory paper.

95 percent desaturated white monochrome contrasted with raw cinnabar red and gold, sacred and heartbreaking, 8k resolution --ar 16:9 --v 6.1 --style raw
```

---

## 7.2 动作帧序列动画（Sprite-Sheet）生图专用 Prompt 库

> **【Godot 4 `Sprite3D` 序列帧生产规范】**：
> * 所有帧动画提示词均锁定为 **横向水平排列的动作关键帧序列图（Horizontal Sprite Sheet）**，统一匹配主相机 **`15°` 微俯视视角** 与 **`Bottom-Center` 脚点对齐基准**；
> * 背景强制锁定为 **`solid neutral light grey (#E0E0E0)` 无阴影纯色背景**，方便程序组通过脚本一键批量裁切并生成透明通道（`Alpha Cut = Discard`），防止纯白背景误伤主角生宣底色。

### 1. 主角【墨痕】核心动作帧动画序列 Prompts

* **A. 普攻三连 · 破宣斩序列（6 Keyframes: 裁纸 $\to$ 飞白 $\to$ 裂帛）**
  ```text
  2D game character animation sprite sheet, 6 sequential horizontal keyframes from left to right showing a 3-hit sword combo, slight high-angle top-down perspective (15-degree downward camera tilt) to match a 2.5D stage, Wu Shan Wu Xing ink-wash style. Male ink swordsman Mo Hen (half ivory baimiao Xuan paper body with 0.25mm black outlines, half cracked charred-ink right arm) wielding a fractured bronze chisel blade. Frame 1: low crouched anticipation draw; Frame 2: wide horizontal slash leaving a jagged white paper-tear arc; Frame 3: upward 45-degree diagonal slash with dry-brush feibai streaks; Frame 4: mid-air somersault apex; Frame 5: heavy two-handed vertical overhead slam; Frame 6: grounded follow-through with splattered black ink drops and cinnabar sparks. Consistent character proportions and foot baseline, isolated on a flat solid neutral light grey (#E0E0E0) background, clean edges, 8k --ar 21:9 --v 6.1 --style raw
  ```

* **B. 疾跑与裂隙无敌墨线滑行序列（6 Keyframes: 起步 $\to$ 疾驰 $\to$ 融纸化墨穿刺）**
  ```text
  2D game character animation sprite sheet, 6 sequential horizontal keyframes from left to right showing a run-to-ink-dash transformation, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing painterly ink brushwork. Frames 1-3: agile forward sprint cycle of ink swordsman Mo Hen leaning forward, ragged charcoal overcoat trailing feibai strokes; Frame 4: diving headfirst into a glowing white paper rift tear; Frame 5: body completely dissolved into a razor-sharp horizontal Huaisu cursive ink stroke with flying white paper butterflies; Frame 6: emerging from the rift in a sharp backstab lunge pose. Consistent scale and alignment, isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

* **C. 金石拓片弹反与虚线撕甲处决序列（5 Keyframes: 招架 $\to$ 负片定格 $\to$ 拔刀撕飞重甲）**
  ```text
  2D game character animation sprite sheet, 5 sequential horizontal keyframes from left to right showing a parry counter and armor-peeling execution, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing style. Frame 1: defensive cross-guard stance with fractured bronze chisel; Frame 2: impact frame with explosive cinnabar-gold sparks and concentric white calligraphy shockwave ring; Frame 3: high-contrast black-and-white stone rubbing negative silhouette freeze pose; Frame 4: explosive iaido-style horizontal draw-slash tearing a sheet of black ink armor with curled paper edges; Frame 5: victorious low-stance sheathing pose. Consistent proportions, isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

### 2. 杂兵与精英核心动作帧动画序列 Prompts

* **D. 序章杂兵【盲眼巡卒】戒尺劈砍与外甲剥离序列（5 Keyframes）**
  ```text
  2D game enemy animation sprite sheet, 5 sequential horizontal keyframes from left to right, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing dark ink style. Blind Patrol puppet soldier wrapped in blood-stained hemp talismans over the eyes, wearing heavy charred-ink iron armor, holding a heavy iron ruler. Frame 1: shuffling patrol walk; Frame 2: overhead wind-up with a glowing crimson warning dot on forehead; Frame 3: heavy downward ruler slam with ink splash; Frame 4: staggered state as outer black ink armor peels off like torn paper, revealing an underlying 0.25mm baimiao line-art wooden mortise-and-tenon puppet skeleton; Frame 5: collapsing into burnt yellow paper ash. Isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

* **E. 序章精英【镇峰狱尉】金石盾冲与虚线破盾序列（5 Keyframes）**
  ```text
  2D game elite boss animation sprite sheet, 5 sequential horizontal keyframes from left to right, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing style. Towering 9-foot Peak Warden in basalt axe-cut armor carrying a massive hexagonal iron shield engraved with mud-gold geometry. Frame 1: heavy shielded guard stance; Frame 2: glowing red-gold charging wind-up; Frame 3: high-speed bulldozing shield bash; Frame 4: shield split cleanly in half along a glowing cinnabar dotted cut-line, flying apart with curled paper edges; Frame 5: vulnerable hunched baimiao wooden puppet core kneeling with a pulsing red seal in its chest. Isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

### 3. 四大守关主宰核心战斗帧动画序列 Prompts

* **F. 序章主宰【墨梅】落梅三连突与狂草披风爆发序列（5 Keyframes）**
  ```text
  2D game boss animation sprite sheet, 5 sequential horizontal keyframes from left to right, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing ink-wash style. Boss Mo Mei in mud-gold robes with six orbiting crimson cinnabar crystal plum blossoms. Frame 1: poised fencer stance; Frame 2: blur-speed horizontal lunge thrust with iron rapier; Frame 3: mid-air spinning tempest slash; Frame 4: Phase 2 transformation bursting with hundreds of wild charred-ink plum branches forming a jagged thorn cloak; Frame 5: Phase 3 kneeling pure baimiao single line-art swordsman in white robes after outer ink is stripped away. Isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

* **G. 第一章主宰【墨竹】竹枪突刺与泼墨筑墙序列（5 Keyframes）**
  ```text
  2D game boss animation sprite sheet, 5 sequential horizontal keyframes from left to right, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing mineral pigment style. Supervisor Mo Zhu in malachite-green and azurite-blue bamboo armor holding a barbed iron bamboo lance and giant brush. Frame 1: spear-surfing gliding pose; Frame 2: lightning-fast piercing lance thrust; Frame 3: sweeping the giant brush upward to summon a wall of black ink and green mineral splashes; Frame 4: heavy overhead lance slam; Frame 5: staggered defeat revealing a hollow baimiao scholar torso with a bamboo core. Isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

* **H. 第二章主宰【墨骨】拓碑铁鞭与四翼俯冲序列（5 Keyframes）**
  ```text
  2D game boss animation sprite sheet, 5 sequential horizontal keyframes from left to right, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing dry-brush feibai style. Grandmaster Mo Gu, skeletal colossus clad in black stone rubbings with a heavy chisel and barbed iron whip. Frame 1: towering whip-coiling stance; Frame 2: whipping lash creating jagged dry-brush shockwaves; Frame 3: spreading four massive wings made of inverted black tombstones; Frame 4: high-speed aerial dive-bomb thrusting the giant iron chisel downward; Frame 5: peaceful palms-together baimiao skeleton surrender pose. Isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```

* **I. 终章大主宰【顾狂墨】千手戒尺与自剖真容序列（5 Keyframes）**
  ```text
  2D game final boss animation sprite sheet, 5 sequential horizontal keyframes from left to right, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing style. Grand Master Gu Kuangmo. Frame 1: floating lead-white frost deity on a white jade lotus haloed by rotating golden compass rulers; Frame 2: commanding gesture launching golden ruler beams; Frame 3: Phase 2 frantic ink-madman swinging a giant dry brush in a blinding white blizzard; Frame 4: outer white shell tearing open; Frame 5: Phase 3 frail weeping old calligrapher in 0.25mm baimiao robes kneeling on one knee, chest open revealing a glowing five-color mineral flame. Isolated on a flat solid neutral light grey (#E0E0E0) background, 8k --ar 21:9 --v 6.1 --style raw
  ```