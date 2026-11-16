# 《留白》（Ink & Void）全系统打击音效与交互式音律设计全典

> **【声学设计总纲】**：“大音希声，留白听响；刃过生宣裂，钟鸣金石开；入墨如坠深渊，出宣似鹤唳九霄。”
>
> **【核心声学信条】**：彻底摒弃现代动作游戏中的科幻电子合成器（Sci-Fi Synth）、塑料感金属互砍白噪与无意义重低音轰炸。《留白》的一切打击音效（SFX）、环境拟音（Foley）与交互式配乐（Adaptive BGM），均严格取材于**中国传统书画的物理材质与宋代金石雅乐器物**——出刀即是裁纸利刃撕开手工桑皮生宣的干脆纤维爆裂，冲刺即是重剑拖地犁纸的疾风沙响，重击即是秦汉青铜断錾敲击玄武岩的清越金石交鸣，施法即是狼毫饱蘸焦墨扫过粗糙纸面的沙沙摩擦，而完美弹反则通过**“极端声学留白（全局静音真空）+ 青铜编钟裂帛爆鸣”**制造直击天灵盖的听觉反差。
>
> **【工程音频与时钟基准 · SOP 4.0 唯一真值】**：Godot Engine 4.3+ · 匹配 `$2.5\text{D}$` 微俯视舞台（`Camera3D`，`FOV = 36^\circ$`、`Pitch = -15^\circ$`）的 `AudioStreamPlayer3D` 空间声像定位 · 多总线动态闪避（Dynamic Bus Ducking） · `AudioStreamRandomizer` 防听觉疲劳池 · **严格对齐真实墙钟毫秒级（`$\text{ms}$`）双时钟架构**（全局定格与慢动作期间核心打击音强制锁定 `PROCESS_MODE_ALWAYS` 与 `pitch_scale = 1.0`，彻底免疫 `Engine.time_scale` 变调拖慢）。

---

## 第一部分：东方画理声学材质、五大原矿频段与双时钟音频架构

### 1.1 五大画理声学材质与频段宪章

为确保高速战斗中各类音效互不产生频段掩蔽（Frequency Masking），全游戏所有角色、敌怪与环境的声学设计必须严格对应视觉五大材质体系，锁定各自的物理拟音（Foley）源与核心频段分布：

| 材质体系 | 物理拟音（Foley）核心音源 | 核心频段与包络特征 | 适用对象与听觉语义 |
| :--- | :--- | :--- | :--- |
| **1. 太虚生宣白** | 干爽手工桑皮纸撕裂、硬毫毛笔渴笔擦纸、折扇急开、纸蝶振翅。 | 高频空气感（`$2.5\ \text{kHz} \sim 9.0\ \text{kHz}$`）；瞬态极快（`Attack` `$< 5\ \text{ms}$`），干脆无拖尾。 | 主角破宣斩刀风、掠地冲刺剑尖犁纸、刮白力场边缘卷纸声、钻缝滑行狂草摩擦、里层白描清风。 |
| **2. 陈年焦墨黑** | 浓稠墨汁倾泼、端砚重墨研磨低频摩擦、湿泥陷足粘滞气泡声。 | 中低频包裹感（`$60\ \text{Hz} \sim 400\ \text{Hz}$`）；偏湿润粘稠，带明显阻尼感。 | 敌方重甲受击闷响、泼墨弹幕轨迹、水墨晕染减速力场、低血量焦墨窒息暗角。 |
| **3. 原矿朱砂红** | 天然矿石晶体碎裂、琉璃珠坠地、低沉心脏单次重搏、印泥重盖闷响。 | 尖锐提示中高频（`$1.5\ \text{kHz} \sim 4.5\ \text{kHz}$`）叠加超低频重击（`$45\ \text{Hz}$`）。 | 五朵血梅碎裂、敌方“危”字突刺预警、拓片反相后的朱砂巨型暴击数字、印台落印。 |
| **4. 工笔泥金黄** | 秦汉青铜编钟、生铁戒尺敲击、青铜断錾凿石、古琴钢弦崩断。 | 高 `$Q$` 值金属泛音（`$3.0\ \text{kHz} \sim 12.0\ \text{kHz}$`）；冷硬锐利，带悠长金属残响。 | 精英怪重盾格挡弹刀、弹反瞬间的金石裂帛爆鸣、界画结界光束嗡鸣、裂隙磁吸准星。 |
| **5. 矿物重彩与铅霜** | 孔雀石绿釉瓷器炸裂、风化碑灰簌簌崩塌、铅白暴雪高频风啸。 | 沙砾颗粒感与高频白噪（`$4.0\ \text{kHz} \sim 14.0\ \text{kHz}$`）；干燥、荒凉、具压迫感。 | 第一章石青毒浆溅射、第二章墓碑粉尘飓风、终章 `$95\%$` 白色暴盲耳鸣风压。 |

### 1.2 双时钟音频免疫与时间缩放仲裁铁律

在 Godot 4.3+ 中，修改 `Engine.time_scale` 会默认影响常规节点计时与部分混响节奏。为保证打击感的极端清脆穿透力，所有音频播放严格执行以下三条引擎铁律：

1. **核心打击音效免疫时间缩放（Unscaled SFX）**：
   * 完美弹反（`PARRY_FREEZE`，真实墙钟 **`$260\ \text{ms}$`**）、落卷近身处决（`EXECUTION_FREEZE`，真实墙钟 **`$300 \sim 340\ \text{ms}$`**）以及折纸慢动作（`RIFT_SLOWMO`，`time_scale = 0.20`）期间触发的刀剑碰撞、编钟裂帛与撕纸音效，其播放器节点必须配置 **`process_mode = Node.PROCESS_MODE_ALWAYS`**，且 **`pitch_scale` 严禁绑定 `Engine.time_scale`**。
2. **定格期 BGM 瞬时声学留白（Instant Acoustic Vacuum）**：
   * 完美弹反触发 `$260\ \text{ms}$` 金石拓片负片定格的 `$0.01\ \text{s}$` 内，`BGM_Master` 与 `SFX_Enemy_3D` 总线音量在 `$15\ \text{ms}$` 内瞬切至 **`$-42\ \text{dB}$`（近乎绝对寂静）**，只留下一声穿透耳膜的青铜编钟裂帛爆鸣与 `$40\ \text{Hz}$` 心脏暗涌；`$260\ \text{ms}$` 定格结束、重甲炸裂的瞬间，全轨音量伴随一记重鼓炸点猛然推回 `$0.0\ \text{dB}$`。
3. **随机轮询防疲劳与复音限流（Polyphony Cap）**：
   * 挥刀、受击与脚步拟音统一挂载 `AudioStreamRandomizer` 配置 `$\pm 4\% \sim 8\%$` 微小音高抖动与多样本轮询池（Round-Robin），并在 `CombatAudioDirector` 中设置同源音效 `$40\ \text{ms}$` 触发冷却，防止“折纸·绞杀”同时聚拢 `$6$` 名杂兵碎甲时产生数字削波爆音。

### 1.3 Godot 4.3+ 7 总线拓扑与 `$2.5\text{D}$` 空间声像规范

```text
Master (0.0 dB, 挂载 AudioEffectLimiter 限幅器防止多段爆鸣削波)
├── BGM_Master (-2.0 dB, 挂载 AudioEffectAmplify, AudioEffectLowPassFilter, AudioEffectHighPassFilter)
│   ├── BGM_TopInk (表层规矩浓墨音轨：低沉大鼓、生铁打击、压迫性低音弦乐)
│   └── BGM_Baimiao (里层白描底稿音轨：空灵古琴泛音、清越竹笛、温润编磬，与 TopInk 实时交叉淡化)
├── SFX_Combat_Core (+1.5 dB, PROCESS_MODE_ALWAYS, 最高优先级免疫 time_scale：弹反爆鸣/处决/重音)
├── SFX_Foley_Material (0.0 dB, 画理材质拟音总线：撕纸/泼墨/拓片碎屑/血梅碎裂/武侠步法)
├── SFX_Enemy_3D (-1.0 dB, 2.5D 空间定位：杂兵木偶声/精英重器/Boss语音与“危”字预警音)
├── Ambience_Weather (-8.0 dB, 挂载 AudioEffectPanner：暴雨/江涛/沙暴/死霜，掀卷时右推 +1.0 压缩)
└── SFX_UI (0.0 dB, PROCESS_MODE_ALWAYS, 展卷/落印/蝴蝶装翻页/竹简算筹)
```

* **`$2.5\text{D}$` 微俯视空间声像（`AudioStreamPlayer3D`）**：
  * 战斗音效挂载于 `$Z = 0$` 舞台实体上，统一设置 `attenuation_model = INVERSE_DISTANCE`、`unit_size = 6.0`、`max_distance = 22.0`、`panning_strength = 0.75`（保留 `$25\%$` 中置能量防止耳机极端单边偏音，同时清晰传达 `$3.2\ \text{m}$` 纵深台面左右两侧敌人偷袭的方向感）。

---

## 第二部分：主角【墨痕】武侠身法与四维撕裂战斗声学

主角墨痕的武器为折断的秦汉青铜篆刻断铁錾【裁云】。其音效设计的核心在于**“金属厚重质感”与“纸张撕裂脆感”的双层叠加（Layering）**，让玩家听出“以铁为笔、裁纸为刃”的独特触感。

### 2.1 普攻三连 · 【破宣斩】（`$267\ \text{ms}$` / `$267\ \text{ms}$` / `$367\ \text{ms}$`）

每一斩均由**【挥空破风层】+【撕纸材质层】+【命中反馈层】**三轨实时混合而成：

* **第一斩 · 弓步平抹（裁纸 · `$267\ \text{ms}$`）**：
  * **挥刀与撕裂**：断铁錾平拉破风的低沉铜鸣，紧随一道持续 `$180\ \text{ms}$`、高频明亮（`$4.0\ \text{kHz}$`）的干生宣“刺啦——”长纤维撕裂声（立体声声像随刀锋横扫产生平移扫动）。
  * **命中反馈（`$60\ \text{ms}$` / `$3$` 物理步局部顿帧）**：撞击瞬间触发一记短促的“硬毫重顿点墨闷响 + 纸纤维绷断脆响”。
* **第二斩 · 虚步撩剑（飞白 · `$267\ \text{ms}$`）**：
  * **挥刀与撕裂**：音高较第一斩提升 `$+1.5$` 半音，突出三道平行裂隙的“渴笔枯锋快速扫纸沙沙声”。
  * **交叉破洞联动**：当第二斩刀痕与第一斩残留裂隙交叉生成**“宣纸破洞漩涡”**时，触发一段 `$350\ \text{ms}$` 的“空气向内抽吸低频负压涡流声（Reverse Suction Whoosh）”，营造吸怪的空间引力听感。
* **第三斩 · 腾空劈山（裂帛 · `$367\ \text{ms}$`）**：
  * **挥刀与撕裂**：双手下砸的沉重呼啸，刀尖触及 `$3.2\ \text{m}$` 台面瞬间触发 **`$80\ \text{ms}$`（`$4$` 物理步）** 局部顿帧，爆发“青铜凿击玄武岩”的清脆金石撞击与火星噼啪声。
  * **破甲引爆**：若重劈命中前两斩制造的“宣纸破洞”，破洞轰然炸开——叠加“厚宣纸绷紧到极限后的爆鼓裂帛巨响”与敌甲褪色瓦解的“干泥剥落碎响”。

### 2.2 核心力场 · 【刮白绝对领域】（`$4.0\ \text{s}$` 滞留力场）

主角在画布与 `$3.2\ \text{m}$` 台面上刮出的白描裂隙会滞留 **`$4.0\ \text{s}$`**，其听觉设计承担着**“无需看 UI 即可感知领域状态”**的交互职责：

* **裂隙滞留与愈合预警**：裂隙存在期间，空间中持续散发微弱的“微风拂过纸隙的空灵白噪”；在裂隙即将愈合的最后 **`$800\ \text{ms}$`**，该白噪的共振峰频率向上平滑扫频（Pitch Rise），提示玩家白描掩体即将闭合。
* **敌人踏入（去色软化，防御 `$-40\%$`）**：敌人踩入白描轨迹瞬间，触发一记“炙热墨水被瞬间抽干蒸发的嘶嘶声”与“厚重铁甲瞬间化为空洞纸壳的空响”，头顶浮现朱砂破甲符印时伴随清脆的骨牌落桌声。
* **水墨晕染迟缓（减速 `$30\%$`）**：所有进入白描裂隙内的敌人动作音效与敌方飞行道具（墨弹、飞刃）的呼啸声，实时挂载**动态低通滤波器（Low-Pass Filter 截止频率降至 `$800\ \text{Hz}$`）**并下调播放速率（`pitch_scale = 0.75`），听感上如同声音被浓墨水渍浸湿、变得沉重迟缓。

### 2.3 武侠身法位移 · 【掠地疾行】与【钻缝无敌滑行】

* **掠地疾行 · 双臂后掠冲刺（`$180\ \text{ms}$` / `$20.0\ \text{m/s}$`）**：
  * **踏雪掠风与剑尖犁纸**：起手瞬间发出急促的“武侠大氅破风振袖声”与足尖蹬地纸灰爆响；冲刺过程中低垂的断铁錾剑尖贴地拖行，发出持续 `$180\ \text{ms}$` 的“裁纸刀锋高速犁开厚宣纸的锐利撕裂声”（对应台面犁出 `$0.85\ \text{m}$` 宽白描裂隙 `Decal`）。
* **钻缝无敌滑行（Rift Grind · `$31.25\ \text{m/s}$`）**：
  * **入缝变身**：角色潜入白描裂隙、化作“怀素狂草墨线”的瞬间，`Ambience_Weather` 环境音下潜 `$-8\ \text{dB}$` 且 `BGM_Master` 开启高通滤波（`$650\ \text{Hz}$`），取而代之的是疾风骤雨般的**“干枯狼毫在粗糙宣纸上极速狂草疾书的连续摩擦声”**（音高随滑行速度实时调制）。
  * **穿刺背刺**：狂草墨线高速穿过敌人身体时，触发 `$40\ \text{ms}$` 局部顿帧，爆出一连串高频清脆的“金石拓片斜切裂帛声”与朱砂血花飞溅声。

### 2.4 空间折叠与空中特技 · 【千斤坠下劈】【云手折纸】【凌空撕纸】

* **千斤坠下劈（Pogo · `$200\ \text{ms}$`）**：断铁錾垂直下刺命中目标头顶瞬间，【五瓣生宣白莲印】绽放出一声空灵清越的**“古琴七徽泛音”**，叠加极具弹性的“厚宣纸鼓面回弹砰响”。
* **云手折纸·绞杀（`$200\ \text{ms}$` 蓄势 / `$240\ \text{ms}$` 墙钟坍缩）**：触发低通滤波（`$450\ \text{Hz}$`）水下真空感，伴随“厚宣纸沿着折痕被强行揉皱挤压的沉闷摩擦与骨节脆响”，聚怪撞击瞬间爆出干泥碎甲声。
* **凌空撕纸弹弓（`$200\ \text{ms}$` 蓄势 / `$180\ \text{ms}$` 爆冲 `$4.50\ \text{m}$`）**：双手扯开半月形裂隙时发出“双层厚宣纸强行撕扯纤维断裂声”，推摇杆蓄力时裂口边缘发出紧绷的“低频纸弦震颤嗡鸣”，松手瞬间如强弓回弹“嘣”地爆射破空。

### 2.5 终极防御反击 · 【全局瞬刹 · 金石拓片】（`$160\ \text{ms}$` 窗口 / `$260\ \text{ms}$` 冻结）

当主角在 **`$160\ \text{ms}$`（`$8$` 物理步）** 完美窗口内弹反红光“危”字重击时，音频管线与视觉 Shader 同步执行剧烈的“反相冲击”：

```text
[160ms 完美弹反判定] ──► [0.00s ~ 0.01s 声学核爆切入]
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
[BGM 与环境音瞬间硬静音]   [青铜编钟裂帛极高频尖啸]    [空间碑石碎裂声]
· 全轨背景音压制 -42 dB   · 编钟重击叠加古琴断弦脆响  · 模拟时间与画布被一刀劈裂
        │
        ▼
[260ms (13物理步 / ~16帧) 全局定格期: 极致“声学留白”真空]
· 万物无声，仅保留 40 Hz 超低频心脏暗涌与细微碑刻刷拓沙沙声，制造窒息张力
        │
        ▼
[定格结束: 反相炸裂与重甲爆碎]
· BGM 轰然恢复 (0.0 dB) + 重低音 Sub-bass Drop (45 Hz) 冲击波
· 敌甲炸碎为“古陶瓦片与青铜片连锁崩碎声” + 原矿朱砂暴击的“印泥重盖闷响”
```

### 2.6 生命与受击反馈 · 【五朵原矿朱砂血梅】

* **受击碎散**：主角受击瞬间，一朵硫化汞血梅在刺耳的**“琉璃矿晶清脆炸裂声”**中碎散，紧随矿砂簌簌坠地声；完成 `$2$` 次【抽纸·处决】凝聚新血梅时，响起温润的“玉珠落盘清音”。
* **濒死压迫（仅剩 `$1$` 朵血梅）**：屏幕四周涌出“焦墨窒息暗角”时，主总线动态启用**“窒息感双耳滤波”**——高频环境细节被逐步滤除，玩家的听觉被浓稠的低频心跳鼓点（`$110\ \text{BPM}$`）与低沉的墨汁涌动声包裹。

---

## 第三部分：敌对生态（杂兵、四大精英、四大关底主宰）全景声学

### 3.1 四大章杂兵移动、污染与受击解构音效

杂兵的音效设计不仅体现其攻击威胁与木偶移动步态，更突出其**“污染画布”**的材质特性，以及被主角“刮白力场”克制后的声学瓦解过程：

| 小怪名称与出现章节 | 移动步态与画布污染音效 | 踏入“刮白力场”后的声学异化 | 抽纸处决与死亡解构音效 |
| :--- | :--- | :--- | :--- |
| **盲眼巡卒**<br>*(序章 · 焦墨死牢)* | 拖尺木偶步时生铁戒尺拖拽玄武岩的刺耳金属刮擦声；重砸与宿墨涂抹时爆出黏稠沉闷的**“焦墨黑油泥浆泼溅声”**。 | 踏入白描裂隙后，沉重的铁链拖地声瞬间变成轻飘空洞的**“干瘪纸壳摩擦声”**，行动音效降速变钝。 | 错身抽纸时整张黑墨被撕下的“干脆揭画声”，随后鲁班锁木偶散架、化为纯白纸蝶振翅消散。 |
| **巡水工偶 / 绿玉石蟾**<br>*(第一章 · 石青泥沼)* | 涉水拔泥步的粘滞水泡声；喷吐“石青矿浆炮弹”的粘稠气泡爆裂声与落地毒胶腐蚀“滋滋”声。 | 踩入白描裂隙后，体表厚重的孔雀石绿釉层发出密集的**“瓷器冰裂纹扩展脆响”**。 | 整只石蟾如上好绿釉瓷瓶摔碎般发出清越的**“瓷器炸裂声”**，随后化作清澈泉水潺潺流淌。 |
| **守碑阴傀 / 古琴傀儡**<br>*(第二章 · 墓碑林)* | 负碑重踏步的闷响与流沙摩擦声；拨动生铁断弦发射“猩红音波切割线”时的**“金属锯齿高频啸叫”**。 | 音波切割线穿过白描裂隙时，刺耳的金属啸叫被抚平，转化为柔和悠扬的**“古琴散音工尺涟漪”**。 | 五根铁弦齐声崩断的清脆回弹声，身躯化作一叠《韶乐总谱》古纸散落满地的翻书沙响。 |
| **去色司祝**<br>*(终章 · 铅白神宫)* | 僵直仪仗滑步的硬袍摩擦声；挥动硬马尾大帚扬起“铅白矿粉雾”的**“硬帚刮墙沙沙声”**，加速愈合裂隙。 | 踏入《泣血自剖草稿》裂隙时，铅白僧袍被朱砂血泪腐蚀，发出热铁入水的**“剧烈沸腾冒烟声”**。 | 身体凝固成石膏白玉像的闷响，随后在风中风化坍塌为细碎粉尘的簌簌流沙声。 |

### 3.2 四大界画精英 · 重器格挡与 3D 结构截割交互音效

精英怪是展现**“金石弹刀”**与**“结构截割物理残骸二次利用”**的核心舞台：

1. **序章精英 · 【镇峰狱尉】（幕 0-3 军械营）**：
   * **重盾蟹步与弹刀**：侧身横推蟹步时重甲铿锵与盾底撞石闷响；主角普攻劈中方圆生铁大盾触发震耳欲聋的**“巨型生铁钟鼎受击弹刀声（高音金属回弹 + 火星迸溅）”**，同时抑制撕纸音效。
   * **虚线撕盾与断盾 Pogo**：累计两次 `$160\ \text{ms}$` 完美弹反后，拓片定格解冻瞬间出刀，将**“极高频裁纸利刃声”**与**“厚重生铁一刀劈断的金属断裂啸叫”**完美融合；切落的半截 3D 物理断盾翻滚坠地时触发金属砸地碰撞音，主角踩上断盾施展下劈（Pogo）时叠加清脆的**“踩踏铁盾借力金属颤音”**。
2. **第一章精英 · 【伏波画督】（幕 1-5 画屏水阁）**：
   * **提线官步与毒浪**：迈步时无形悬丝轻提的木偶咔哒声；推屏掀起石青泥金毒浪伴随**“浓稠矿浆巨浪咆哮声”**。
   * **断屏与提线崩断**：弹反腰斩画屏轴心，发出四道挂轴画被同时撕裂的连续脆响；暴露内部白描皮影后，挥刀斩断悬空提线触发一连串清脆的**“丝弦崩断声”**与木构件散落声。
3. **第二章精英 · 【司弦刑官】（幕 2-3 拓碑断壁）**：
   * **踏弦折线步与音波刃**：脚尖点地的清脆弦鸣；挑弦发射三道“猩红真空音波刃”发出**“超音速弦音爆鸣”**。
   * **五弦齐断与残瑟弹射**：弹反震碎血弦后，五根血弦齐声崩断引发长达 `$1.2\ \text{s}$` 的**“五音阶古瑟共鸣爆裂气浪”**；踩踏残瑟触发 `$45^\circ$` 超音速弹射（`$32.0\ \text{m/s}$`）时伴随冲天筝鸣。
4. **终章精英 · 【平规衡司】（幕 3-3 千手戒尺殿）**：
   * **水平御空平移与天平光束**：四面佛汉白玉神像低频石磨共鸣声；左盘焦墨沸腾与右盘铅粉倾泻沙响交织；喷射“泥金界画光束”时发出高能量的**“编钟高频持续谐振嗡鸣”**。
   * **斩绳与阴阳中和**：劈断天平悬绳后，左右两盘焦墨与铅粉在半空相撞中和，发出一声柔和而宏大的**“水火相济蒸汽消融长音”**，黄金秤盘砸落舞台化作 3D 金属踏板重响。

### 3.3 四大关底主宰（Boss）与【两段式终局处决】声学全景

每一章关底 Boss 战的音效均遵循**“一/二阶段音墙压迫递增 $\to$ 掀卷破阵瞬间清空全频音墙 $\to$ 第 1 段狂草成字可操作连斩 $\to$ 第 2 段 `FOV = 24^\circ$` 落卷近身按键处决”**的戏剧性声学曲线：

```text
[Boss 濒死狂暴: 灭世弹幕音墙淹没全频段] ──► [朱砂裁纸虚线亮起: 极高频金属丝绷紧提示音]
                                                               │
                                                               ▼ (玩家按下破阵键)
                  [峰值时刻: “一刀掀翻整张画卷” (200ms 全局定格 + 450ms Page-Curl)]
                  · 断铁錾插入画布底层的沉重金石入木声 + 古筝崩弦重音 (600ms)
                  · 巨幅厚宣画卷从左向右卷起的“厚重卷纸滚筒轰鸣”
                  · AudioEffectPanner 将表层环境音与 Boss 咆哮强制压缩推向最右侧声道 (Pan = +1.0)
                                                               │
                                                               ▼ (露出 100% 纯净里层白描世界)
                  [第 1 段交互: 狂草成字可操作连斩 (time_scale = 0.30)]
                  · 嘈杂环境音 100% 消失，进入“太虚白描声学圣殿”
                  · 每斩一笔伴随 40ms 顿笔 + 苍劲“怀素狂草巨笔挥毫 + 编钟单音重击”
                                                               │
                                                               ▼ (最后一笔落成，纸筒炸裂化蝶)
                  [第 2 段交互: 落卷近身按键处决 (FOV = 24° 特写 + 300~340ms 拓片反相)]
                  · 断铁錾贯心刺入 + 全屏黑底白线拓片负片绝对静音冲击
                  · 解冻瞬间狂草巨字引爆 + 万千纯白纸蝶振翅与五彩流光交响还彩
```

* **序章主宰 · 【先锋镇将 · 墨梅】**：一阶段冷峻剑客滑步的冰冷晶体风铃与细软剑啸；二阶段焦墨梅枝刺破汉白玉擂台的巨石崩裂声；三阶段掀卷卷走血雨后，`$4.5\ \text{s}$` 七笔书写狂草**「折」**字（金石刻字崩石声），落卷近身按键贯心触发 **`$300\ \text{ms}$`** 拓片反相，化作漫天梅花瓣与纸蝶飘散，紧接幕 T-1 以 `$-40.0\ \text{m/s}$` 坠入万丈飞瀑洗血轰鸣。
* **第一章主宰 · 【画院督监 · 墨竹】**：一阶段修竹贯心枪破风声；二阶段 `$14.0\ \text{m/s}$` 狂飙江涛与斗笔画出焦墨死壁的沉重刷墨声、白描应龙龙脊上的低沉龙吟；三阶段掀卷卷走青绿巨浪后，`$5.5\ \text{s}$` 八笔书写狂草**「直」**字，落卷近身一錾贯穿中空竹心响起清亮彻骨的**“翠竹劈裂清响”**（`$300\ \text{ms}$` 反相），随后大江抽干直坠地底。
* **第二章主宰 · 【司碑宗师 · 墨骨】**：一阶段十丈拓碑铁鞭音爆抽击声；二阶段古坛崩塌坠入千丈深渊的失重风啸与四扇倒插墓碑石翼扇动的**“枯笔飞白炭粉飓风”**；三阶段掀卷卷走沙暴后，`$7.0\ \text{s}$` 十七笔书写狂草**「藏」**字，落卷近身刀尖轻触无字宣纸小碑触发深沉的**“古琴十徽泛音与厚纸轻触声”**（`$300\ \text{ms}$` 反相），万座墓碑共鸣化为千丈五彩墨龙仰冲破天门。
* **终章大主宰 · 【大阁尊 · 顾狂墨】**：一阶段三百六十柄千手泥金戒尺法环的密集金属扇动与编钟和谐齐鸣；二阶段 `$95\%$` 天下大去色白盲风暴中抽干低频，陷入**“高频铅白风雪呼啸与单频耳鸣音”**，撕开泣血自剖草稿后透出微弱笔锋沙沙声；三阶段掀卷破除死白神域后，`$10.0\ \text{s}$` 完整自由暴走书写狂草**「休」**字，随后收刀缓步上前，铁链拖地轻响清晰可闻，断铁錾轻点老人胸膛五彩原谱火种瞬间响起温润的**“玉磬清音”**，在 **`$340\ \text{ms}$`** 极致金石拓片反相后，编钟、古琴、箫、鼓与滔滔五彩墨浪轰然交响还彩山河；尾声拉远至 `$80\%$` 太虚大留白，最后盖下朱砂巨印**【画满则滞 · 留白则生】**时，仅留一记干脆利落的**“青铜印章重落宣纸声”**与一缕清风。

---

## 第四部分：表里双轨自适应配乐（Adaptive BGM）与古籍装裱 UI 音效

### 4.1 双轨实时交互混音矩阵（`BGM_TopInk` vs `BGM_Baimiao`）

全游戏每一章的配乐均由完全同步节拍与调式的双轨音流（`BGM_TopInk` 与 `BGM_Baimiao`）并行播放，随玩家在战场上的画理操作实时改变混音比例与滤波器状态：

| 游戏交互状态 | `BGM_TopInk`（表层浓墨轨） | `BGM_Baimiao`（里层白描轨） | 总线滤波器与听觉体验 |
| :--- | :--- | :--- | :--- |
| **常规探索与带甲接战** | **`$0.0\ \text{dB}$`**（主导前景） | **`$-18.0\ \text{dB}$`**（隐约底色） | 滤波器全开（Lowpass `$20000\ \text{Hz}$`），大鼓与低音弦乐营造沉重规矩压迫感。 |
| **大面积刮白 / 处于刮白力场** | **`$-6.0\ \text{dB}$`** | **`$-3.0\ \text{dB}$`**（明显浮现） | 随场上白描裂隙面积增大，空灵的古琴与竹笛旋律穿透浓墨压制，给予玩家“掌控战场”的正向听觉回馈。 |
| **钻缝无敌墨线滑行（`$31.25\ \text{m/s}$`）** | **`$-24.0\ \text{dB}$`** | **`$+2.0\ \text{dB}$`**（独奏高亮） | 开启高通滤波（Highpass **`$650\ \text{Hz}$`**）瞬时削去一切沉重低频，仅余清冽古琴泛音与干毛笔疾书“沙沙”声；破缝而出瞬间低频重鼓炸裂回归。 |
| **云手折纸 / 凌空撕纸慢动作** | **`$-12.0\ \text{dB}$`** | **`$-4.0\ \text{dB}$`** | 开启低通滤波（Lowpass **`$450\ \text{Hz}$`**），营造空间被强行折叠挤压的水下真空闷响。 |
| **濒死窒息态（血梅 `$\le 1$` 朵）** | **`$-3.0\ \text{dB}$`** | **`$-36.0\ \text{dB}$`**（完全淹没） | Lowpass 压低至 **`$450\ \text{Hz}$`**，叠加 `$110\ \text{BPM}$` 心跳低频脉冲，制造窒息危机感。 |
| **完美弹反拓片定格（`$260\ \text{ms}$`）** | **`$-42.0\ \text{dB}$`**（硬静音） | **`$-42.0\ \text{dB}$`**（硬静音） | 制造极端“声学留白”真空，突出编钟裂帛爆鸣；定格结束 `$80\ \text{ms}$` 内炸裂弹回全轨音量。 |

### 4.2 全四章动态配乐编制与节奏规划

* **序章【赤朱残阳 · 狂草破规】**：`$112\ \text{BPM}$`（Boss 战升至 `$136\ \text{BPM}$`）。表层轨以宋代军旅战鼓、低音大提琴拨弦与生铁打击为主，背景辅以低沉血雨白噪；里层轨为清冷孤傲的古琴散音与洞箫独奏。
* **第一章【青绿叠翠 · 墨竹狂澜】**：`$124\ \text{BPM}$`（幕 1-8~1-10 江心极速跑打升至 `$148\ \text{BPM}$`）。表层轨融合汹涌江涛打击乐、低音唢呐与厚重铜锣；里层轨转为王希孟《千里江山图》般的清越竹笛、编磬与古筝流水琶音。
* **第二章【飞白苍凉 · 枯笔断魂】**：`$96\ \text{BPM}$`（无地面空战转为不规则 `$7/8$` 拍 `$132\ \text{BPM}$`）。表层轨采用干燥风沙白噪、破损残瑟刮弦与沉重石磬；里层轨还原盛唐《韶乐总谱》的雅正编钟与排箫合奏。
* **终章【白粉凝霜 · 天地留白】**：`$84\ \text{BPM}$` 庄严圣咏 $\to$ 二阶段大去色抽干低频仅留极寒风啸与高频单音持续音（Drone） $\to$ 终局**「休」**字引爆后转为全编制中国民族管弦乐（编钟、古琴、竹笛、琵琶、大鼓）宏大交响，最终渐弱收束于尾声【万里乾坤大留白】的单一古琴泛音。

### 4.3 宋代书画装裱 UI 拟音规范（`SFX_UI`）

* **宋代横披手卷展卷（主界面启动）**：清越古琴泛音起手 + 乌木卷轴在案头平稳滚动展开的厚宣纸摩擦声（`$850\ \text{ms}$`）。
* **按钮悬停与落印确认**：悬停时播放干毛笔轻扫生宣的短促“沙”声（`$80\ \text{ms}$`）；确认点击播放**青田石印章重顿朱砂印泥的玉石闷响**（`$180\ \text{ms}$`）；返回/取消播放**竹简轻叩声**。
* **蝴蝶装册页翻页与图鉴“刮白”**：呼出暂停界面播放厚桑皮纸册页翻折声；玩家在图鉴页用光标/摇杆刮开敌人表层重墨查看里层白描骨相时，实时触发微缩版的“干生宣刮白沙沙声”。
* **朱砂印台零黑屏复活（`$< 0.8\ \text{s}$`）**：角色血梅碎尽阵亡时，播放“墨水倒卷回吸的反向水墨流动声（`$650\ \text{ms}$`）”与“朱砂印台微光重燃清音”。

---

## 第五部分：Godot 4.3+ 核心代码实现、全战斗声学调试矩阵与 AI 拟音 Prompt 库

### 5.1 统一声学调度器实现（`CombatAudioDirector.gd` - Autoload）

本脚本整合了双时钟免疫（`PROCESS_MODE_ALWAYS` 与 `ignore_time_scale = true`）、`$260\ \text{ms}$` 金石拓片声学留白真空、`$450\ \text{ms}$` 掀卷右侧声道压缩（`AudioEffectPanner`）以及表里双轨自适应 BGM 交叉淡化：

```gdscript
extends Node
class_name CombatAudioDirector

@onready var sfx_parry_chime: AudioStreamPlayer = $SFX_ParryChime
@onready var sfx_shatter_release: AudioStreamPlayer = $SFX_ShatterRelease
@onready var sfx_page_curl: AudioStreamPlayer = $SFX_PageCurl
@onready var bgm_top_ink: AudioStreamPlayer = $BGM_TopInk
@onready var bgm_baimiao: AudioStreamPlayer = $BGM_Baimiao

var _bus_bgm_master: int
var _bus_top_ink: int
var _bus_baimiao: int
var _bus_enemy_3d: int
var _bus_ambience: int
var _bgm_lpf: AudioEffectLowPassFilter
var _bgm_hpf: AudioEffectHighPassFilter
var _last_play_usec: Dictionary = {}

func _ready() -> void:
	# 最高优先级免疫 Engine.time_scale 冻结与慢动作缩放
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_bus_bgm_master = AudioServer.get_bus_index("BGM_Master")
	_bus_top_ink = AudioServer.get_bus_index("BGM_TopInk")
	_bus_baimiao = AudioServer.get_bus_index("BGM_Baimiao")
	_bus_enemy_3d = AudioServer.get_bus_index("SFX_Enemy_3D")
	_bus_ambience = AudioServer.get_bus_index("Ambience_Weather")
	
	_bgm_lpf = AudioServer.get_bus_effect(_bus_bgm_master, 1) as AudioEffectLowPassFilter
	_bgm_hpf = AudioServer.get_bus_effect(_bus_bgm_master, 2) as AudioEffectHighPassFilter

## 0. 免疫 time_scale 的通用音效播放（带防削波冷却与微音高随机）
func play_unscaled(player: AudioStreamPlayer, cooldown_ms: float = 40.0, pitch_jitter: float = 0.04) -> void:
	if not player or not player.stream:
		return
	var id: int = player.get_instance_id()
	var now_usec: int = Time.get_ticks_usec()
	if _last_play_usec.has(id) and (now_usec - _last_play_usec[id]) / 1000.0 < cooldown_ms:
		return
	_last_play_usec[id] = now_usec
	
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	player.play()

## 1. 触发【全局瞬刹 · 金石拓片】（严格按真实墙钟 260ms 声学留白真空）
func trigger_stone_rubbing_parry(freeze_duration_ms: float = 260.0) -> void:
	# 0.00s 瞬时切断 BGM 与敌怪嘈杂音墙，制造极端“声学留白”
	AudioServer.set_bus_volume_db(_bus_bgm_master, -42.0)
	AudioServer.set_bus_volume_db(_bus_enemy_3d, -36.0)
	
	# 播放青铜编钟裂帛爆鸣（免疫 time_scale，保持 1.0 原速清脆穿透）
	play_unscaled(sfx_parry_chime, 0.0, 0.02)
	
	# 第4个参数 true = ignore_time_scale，严格走真实墙钟毫秒数！
	await get_tree().create_timer(freeze_duration_ms / 1000.0, true, false, true).timeout
	
	# 定格结束瞬间：恢复全轨音量并引爆重甲爆碎 45Hz Sub-bass
	var tween := create_tween().set_parallel(true)
	tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_bgm_master, db), -42.0, -2.0, 0.08)
	tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_enemy_3d, db), -36.0, -1.0, 0.05)
	play_unscaled(sfx_shatter_release, 0.0, 0.02)

## 2. 触发巅峰【一刀掀翻整张画卷】右侧声道卷缩演出（450ms）
func trigger_page_curl_audio(duration_ms: float = 450.0) -> void:
	var duration_sec: float = duration_ms / 1000.0
	play_unscaled(sfx_page_curl, 0.0, 0.0)
	
	# 将表层天象环境音与 Boss 音墙推向最右侧纸筒 (Pan = +1.0) 并压扁淡出
	var pan_effect := AudioServer.get_bus_effect(_bus_ambience, 0) as AudioEffectPanner
	var tween := create_tween().set_parallel(true)
	if pan_effect:
		tween.tween_property(pan_effect, "pan", 1.0, duration_sec)
	tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_ambience, db), -8.0, -60.0, duration_sec)
	# 切入纯白圣殿：表层浓墨轨隐去，里层白描古琴轨高亮
	tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_top_ink, db), 0.0, -32.0, duration_sec)
	tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_baimiao, db), -18.0, 0.0, duration_sec)

## 3. 钻缝无敌墨线滑行滤波切换（开启/关闭 650Hz 高通滤波）
func set_rift_grind_audio_state(active: bool) -> void:
	var tween := create_tween().set_parallel(true)
	if active:
		if _bgm_hpf:
			tween.tween_property(_bgm_hpf, "cutoff_hz", 650.0, 0.06)
		tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_top_ink, db), 0.0, -24.0, 0.06)
		tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_baimiao, db), -18.0, 2.0, 0.06)
	else:
		if _bgm_hpf:
			tween.tween_property(_bgm_hpf, "cutoff_hz", 20.0, 0.08)
		tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_top_ink, db), -24.0, 0.0, 0.08)
		tween.tween_method(func(db: float): AudioServer.set_bus_volume_db(_bus_baimiao, db), 2.0, -18.0, 0.08)
```

### 5.2 全战斗打击感（Juice）声学量化调试矩阵

| 战斗交互事件 | 真实墙钟与顿帧同步 | 核心频段与 `$2.5\text{D}$` 声像 | BGM 与环境音动态 | 核心拟音与器乐组合 |
| :--- | :--- | :--- | :--- | :--- |
| **普通破宣斩命中** | 命中零延迟触发，局部顿帧 `$60\ \text{ms}$`（重击 `$80\ \text{ms}$`） | 高频撕纸 `$4.0\ \text{kHz}$` + 随刀势 Pan 扫动 | 无闪避，保持平稳 | 干生宣长纤维撕裂“刺啦”声（`$180\ \text{ms}$`）+ 硬毫点墨闷响。 |
| **交叉刀痕破洞引爆** | `$60\ \text{ms}$` 顿帧前先吸气，解冻瞬间爆开 | 低频涡流 `$120\ \text{Hz}$` + 中频纸爆 `$1.5\ \text{kHz}$` | BGM 瞬时下潜 `$-3\ \text{dB}$` | 负压空气抽吸声（`$350\ \text{ms}$`）+ 厚宣纸绷紧爆鼓裂帛声。 |
| **武侠掠地疾行（双臂后掠）** | 持续 `$180\ \text{ms}$`（前 `$140\ \text{ms}$` 无敌） | 高频犁纸 `$3.5\ \text{kHz}$` + 大氅低频振风 | 环境音下潜 `$-4\ \text{dB}$` | 断铁錾剑尖拖地犁开 `$0.85\ \text{m}$` 宣纸裂隙 + 八字尘浪破空声。 |
| **钻缝无敌滑行背刺** | 滑行期间持续摩擦，穿体触发 `$40\ \text{ms}$` 局部顿帧 | 高频狼毫扫纸 `$5.0\ \text{kHz}$` 贴耳立体声 | **HPF 切至 `$650\ \text{Hz}$`**，白描轨高亮 `$+2\ \text{dB}$` | 怀素狂草干笔疾书声 + 拓片斜切裂帛脆响。 |
| **完美弹反（拓片瞬刹）** | **`$260\ \text{ms}$`（`$13$` 物理步）声学留白真空** | 编钟极高频 `$8.0\ \text{kHz}$` 贯穿全声场 | **BGM 硬静音 `$-42\ \text{dB}$`** | 秦汉青铜编钟裂帛爆鸣（`$450\ \text{ms}$` 原速）+ 碑石空间碎裂声。 |
| **定格结束重甲爆碎** | 定格结束第 `$1$` 帧爆发 Sub-bass Drop | 超低频 `$45\ \text{Hz}$` 冲击 + 碎屑全频段散射 | BGM `$80\ \text{ms}$` 内弹回 `$-2\ \text{dB}$` | 古陶青铜片连锁崩碎声 + 朱砂印泥重盖闷响。 |
| **Boss 掀卷破阵** | **`$200\ \text{ms}$` 定格后 `$450\ \text{ms}$` 声像右推** | 表层环境音 Pan 强制推向最右侧 `$+1.0$` | 表层天象环境音彻底归零 | 巨幅画卷卷筒轰鸣 + 古筝崩弦重音（`$600\ \text{ms}$`）。 |
| **落卷近身按键处决** | **`$300 \sim 340\ \text{ms}$` 拓片静音后民乐齐鸣** | 全频段壮阔混响 + 纯白纸蝶高频振翅 | 传统民乐合奏宏大收束（`$1200\ \text{ms}$`） | 断铁錾贯心入石 + 狂草巨字炸裂 + 万千白蝶散开。 |

### 5.3 AI 拟音与民乐配乐生成 Prompt 库（Foley & Adaptive BGM）

以下英文 Prompt 可直接用于 **ElevenLabs Sound Effects / AudioGen / Suno** 批量生成去电子化的纯正东方拟音与双轨配乐素材：

1. **破宣斩 · 干生宣长纤维撕裂（`sfx_paper_slash.wav`）**：
   ```text
   Crisp organic sound effect of a sharp bronze blade slicing cleanly through thick handmade raw mulberry Xuan paper, fast high-frequency fibrous rip (4kHz) layered with a subtle heavy calligraphy brush ink thud, dry studio Foley, zero sci-fi synth, punchy transient, 0.2s --no reverb, electronic
   ```
2. **完美弹反 · 宋代青铜编钟裂帛爆鸣（`sfx_parry_bianzhong_shatter.wav`）**：
   ```text
   Dramatic ancient Chinese bronze Bianzhong bell struck by a heavy iron chisel, shattering into piercing metallic harmonic overtones layered with a snapping silk guqin string and cracking stone tablet, extreme dynamic impact, dry and piercing, 0.5s --no synth, laser
   ```
3. **钻缝无敌滑行 · 怀素狂草干笔疾书摩擦（`sfx_rift_grind_brush_loop.wav`）**：
   ```text
   Continuous seamless loop of a large dry wolf-hair calligraphy brush furiously scrubbing across coarse textured handmade paper at ultra-high speed, rhythmic raspy dry-brush friction with subtle fluttering white paper butterflies, pure organic Foley --no music, wind
   ```
4. **Boss 掀卷破阵 · 巨幅画卷翻卷与古筝崩弦（`sfx_scroll_page_curl.wav`）**：
   ```text
   Heavy thick ancient Chinese silk-mounted paper scroll violently rolling up from left to right with a deep papery whoosh, punctuated by a dramatic snapping guzheng zither string and stone chisel impact, theatrical Foley, 0.6s
   ```
5. **古籍装裱 UI · 青田石印章重顿印泥（`sfx_ui_seal_stamp.wav`）**：
   ```text
   Tactile Foley sound of a heavy carved Qingtian stone seal stamping firmly onto thick cinnabar ink paste and raw Xuan paper, deep resonant jade-stone thud followed by subtle paper fiber compression, crisp and dignified, 0.2s
   ```
6. **序章自适应双轨配乐 · 表层焦墨战鼓轨（`bgm_ch0_top_ink.wav`）**：
   ```text
   Dark Chinese wuxia action game battle music, 136 BPM, heavy Song Dynasty war drums, ominous low bowed cello ostinato, clashing cast-iron rulers, driving tension in a rainstorm, traditional Chinese percussion and dark strings, seamless loop --no modern EDM, synth
   ```
7. **序章自适应双轨配乐 · 里层白描古琴轨（`bgm_ch0_baimiao.wav`）**：
   ```text
   Ethereal minimalist Song Dynasty solo guqin zither harmonics and mournful bamboo xiao flute melody, 136 BPM matching pulse, spacious silent pauses (liubai), pure acoustic traditional Chinese instruments, serene yet tragic, seamless loop --no drums, synth
   ```