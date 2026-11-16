# 《留白》（Ink & Void）Godot 4.3+ 2.5D 立体舞台全流程标准作业程序（Master SOP 4.0）

> **【工程唯一真值基线环境】**：
>
> * **引擎版本**：Godot Engine 4.3+ 稳定版
> * **渲染后端**：Forward+（支持双 `Camera3D` + 多 `SubViewport` 镜像透视同步、`Decal` 地表力场投影与全屏后处理反相/翻页 Shader）
> * **物理核心**：Godot 原生 3D 物理引擎，`physics_ticks_per_second = 50`（`$0.02\ \text{s}$` 物理步长），所有角色、敌人与地形刚体通过 `Axis Lock` 严格锁死于 `$Z = 0$` 战斗平面
> * **视口分辨率**：`$1920 \times 1080$`，拉伸模式：`mode = "canvas_items"`, `aspect = "expand"`
> * **帧率与同步**：`Engine.max_fps = 60`，开启 VSync（垂直同步）防止画面撕裂与高刷屏物理运算紊乱
> * **相机与全生态序列帧标尺**：`$1.0\ \text{m} = 100\ \text{px}$`（全局 `Sprite3D` 统一设置 `pixel_size = 0.01`）。主舞台相机 `StageCamera3D` 采用 **2.5D 长焦微俯视透视**：标准探索 **`FOV = 36^\circ$`、俯角 `Pitch = -15^\circ$`、相机偏移 `(X, Y + 4.2\ \text{m}, +13.5\ \text{m})`**，匹配 **`$3.2\ \text{m}$` 纵深宽度的 3D 可行走台面（`$Z \in [-1.6\ \text{m}, +1.6\ \text{m}]$`）**。全角色序列帧按体量分级锁定单格尺寸与零净空 `Bottom-Center` 锚点（主角 `$512 \times 320\ \text{px}$`、杂兵 `$320 \times 320\ \text{px}$`、精英 `$448 \times 384\ \text{px}$`、Boss `$512 \times 448\ \text{px}$`）。
> * **双时钟仲裁铁律**：所有输入缓冲、判定窗口与定格冻结时长一律以**真实墙钟毫秒（`$\text{ms}$`，对齐 `$20\ \text{ms}$` 物理步）**为唯一真值，彻底免疫 `Engine.time_scale` 缩放污染，且慢动作下主角活跃斩击自动执行 `AnimationPlayer.speed_scale` 逆向倍速补偿。
> * **首个试玩包（Demo v0.1）体量边界**：锁定为 **序章全篇（幕 0-1 至 幕 0-10）** $\to$ **跨章飞瀑过渡（幕 T-1/T-2）** $\to$ **第一章开篇定格（幕 1-1 青石浅滩）**（约 `$15 \sim 20$` 分钟高密度心流体验）。

---

# 第零章：技术红线与阶段过门门禁体系（Gate A ～ Gate F）

为杜绝“旧版数值槽残留、2D/3D 相机口径打架、序列帧与代码双重抬升导致浮空、负缩放破面、机制未验证即堆量”的恶性返工，全流程推行**阶段过门（Stage-Gate）机制**。上一阶段未通过量化验收前，严禁推进至下一阶段。

```text
[Gate A: 规格与数学锁死] --> [Gate B: 3D白盒核心玩法实验室] --> [Gate C: 机制闭环与防卡死容错]
 (Camera3D 36°/-15°基准)     (破宣斩/双臂后掠冲刺/钻缝)        (拓片260ms反相/朱砂印台0.8s回溯)
                                                                       |
                                                                       v
[Demo v0.1 封版交付] <-- [Gate F: 核显60FPS与盲测] <-- [Gate E: 两段式终局与跨章演播] <-- [Gate D: 7轨3D布景与Shader]
 (独立运行安装包归档)     (Iris Xe/680M稳60帧)        (掀卷成字->近身处决->飞瀑1-1)      (分级切图/双Camera3D/Decal)
```

| 阶段门禁 | 核心审核目标 | 否决项（一票打回指标） |
| :--- | :--- | :--- |
| **Gate A（规格锁定）** | Godot 3D 坐标系（`$+Y$` 向上）、双时钟毫秒计时、`StageCamera3D`（`FOV = 36^\circ$`, `Pitch = -15^\circ$`）与全生态分级单格规范完全闭环。 | 仍残留旧版 `Ortho Size` 或 `CanvasBreath` 数值槽代码；起跳高度偏离 `$3.0\ \text{m}$`。 |
| **Gate B（白盒实验室）** | `$3.2\ \text{m}$` 纵深 `XZ` 地板白盒下，跑通「破宣斩刮白 $\to$ 武侠掠地疾行（双臂后掠贴地冲刺）犁纸 $\to$ 钻缝滑行 $\to$ 折纸聚怪 $\to$ 抽纸刷新」核心循环。 | 平跳能越过幕 0-5 深渊；冲刺出现不自然的物理浮空或遇台阶卡脚；裂隙滑行穿墙卡死。 |
| **Gate C（机制与容错）** | `$160\ \text{ms}$` 弹反触发 `$260\ \text{ms}$` 金石拓片反相、虚线撕盾 Pogo、敌方移动与去色破甲/纸片化硬直、朱砂印台（`$< 0.8\ \text{s}$` 零黑屏回溯）跑通。 | `$260\ \text{ms}$` 定格期间吞掉攻击输入；慢动作与弹反叠加后解冻未恢复 `1.00` 全速。 |
| **Gate D（资产与 Shader）** | 四级规范序列帧导入（零底部留白）、`Sprite3D.flip_h` 转向（禁用负 `scale.x`）、`PlumBlossomOrbitRig` 独立血梅、双 `Camera3D` 撕纸遮罩与台面 `Decal` 校准。 | 使用负 `scale.x` 导致 3D 法线异常；序列帧画死血梅导致转身瞬移；狂草刀光被裁切。 |
| **Gate E（终局与跨章）** | 墨梅两段式终局交互（掀卷 `$4.5\ \text{s}$` 七笔成“折” $\to$ 落卷近身按键处决）与飞瀑坠入幕 1-1 定格跑通。 | 掀卷翻页 Shader 穿帮；慢动作连斩期间主角动作卡顿未做 `speed_scale` 补偿。 |
| **Gate F（终极交付）** | 主流核显轻薄本（Iris Xe / 680M / 780M）真机运行 Demo v0.1 全流程平稳无报错。 | 帧率低于 `$60\ \text{FPS}$`；Debugger 出现红色 Error；3D Draw Calls `$> 55$`；外部盲测卡关。 |

---

# 第一章：Godot 3D 物理运动学与 2.5D 关卡几何数学闭环

针对 Godot 3D **`$+Y$` 垂直向上** 与 `$1.0\ \text{m} = 100\ \text{px}$` 米制标尺，所有运动学参数经由物理方程严格锁死，确保在 `FOV = 36^\circ$`、`Pitch = -15^\circ$` 微俯视镜头下具备精准的起落脚点读数。

## 1.1 跳跃物理参数推导公式（Godot 3D 坐标系）

设定满蓄跳跃目标高度 `$H_{\text{max}} = 3.0\ \text{m}$`（对应 `$300\ \text{px}$`），起跳至顶峰目标时间 `$t_{\text{apex}} = 0.35\ \text{s}$`：

* **上升段重力加速度（向上减速，Godot 3D 中重力为负值向下压迫）**：
  $$g_{\text{up}} = -\frac{2 \cdot H_{\text{max}}}{(t_{\text{apex}})^2} = -\frac{2 \cdot 3.0}{(0.35)^2} \approx -48.98\ \text{m/s}^2 \implies \mathbf{-49.0\ \text{m/s}^2}$$
* **起跳初速度（向上弹射，Godot 3D 中速度为正值）**：
  $$V_{y0} = -(g_{\text{up}} \cdot t_{\text{apex}}) = -(-49.0 \cdot 0.35) = \mathbf{+17.15\ \text{m/s}}$$
* **轻按小跳截断（Variable Jump Cutoff）**：上升过程中（`$V_y > 0$`）提前松开跳跃键，瞬时将垂直速度截断为 `$V_y = V_y \cdot 0.40$`，最小跳跃高度 `$H_{\text{min}} \approx 1.2\ \text{m}$`。
* **过峰下落重力强化（Falling Gravity）**：越过跳跃波峰（`$V_y \le 0$`）后，下落重力切换为 `$g_{\text{down}} = \mathbf{-65.0\ \text{m/s}^2}$`，下落耗时 `$t_{\text{fall}} = \sqrt{\frac{2 \cdot 3.0}{65.0}} \approx 0.304\ \text{s}$`，消除滞空漂浮感。

## 1.2 位移速度、武侠掠地疾行（双臂后掠冲刺）与裂缝滑行运动学参数

> **【工程规范 #1 · 取消物理浮空，确立“美术帧零净空 + 贴地疾掠”唯一标准】**：
> 冲刺（掠地疾行）并非离地悬浮飞行，而是中国武侠“双臂后掠、低身踏雪掠地”的贴地高速突进！美术序列帧保持脚底紧贴单帧底边 **`(256, 320)`（`$0\ \text{px}$` 留白）**，程序端亦**不抬升 `global_position.y`**，而是通过向下短距 `RayCast3D` 与贴地吸附让角色双足紧贴 `$3.2\ \text{m}$` 台面高速滑行（遇斜坡或低矮石阶平滑贴合坡度），同时用低垂的断铁錾剑尖在地面犁出宽 **`$0.85\ \text{m}$`** 的白描裂隙 `Decal`。

| 运动状态 | 水平/切向速度 | 持续时间与位移 | 核心物理与判定规则 |
| :--- | :--- | :--- | :--- |
| **基础奔跑** | `$V_x = 12.5\ \text{m/s}$` | 持续移动，松键 `$60\ \text{ms}$`（`$3$` 步）线性刹停 | 角色 `Sprite3D` 轴心锁定 `Bottom-Center` `(256, 320)`，支持 `$Z \in [-1.2\ \text{m}, +1.2\ \text{m}]$` 纵深微调闪避。 |
| **掠地疾行 · 双臂后掠冲刺**<br>*(Wuxia Ground-Skimming Dash)* | `$V_x = 20.0\ \text{m/s}$` | 持续 **`$180\ \text{ms}$`**（`$9$` 个物理步），水平位移 **`$3.60\ \text{m}$`** | 躯干大幅前倾 `$38^\circ$`、双臂向正后方掠展、右手反握断铁錾剑尖低垂拖地；双足紧贴地面高速掠行（**零物理浮空**），前 `$140\ \text{ms}$`（`$7$` 步）无敌，CD `$450\ \text{ms}$`；飞出悬崖边缘时保持水平御风滑翔（`$V_y = 0$`）不立即下坠；剑尖在台面顶面犁出宽 **`$0.85\ \text{m}$`** 的白描裂隙 `Decal`（破甲 `$40\%$` + 减速 `$30\%$`），双足两侧投射对称八字尘浪与气旋阴影。 |
| **钻缝无敌墨线滑行**<br>*(Rift Grind)* | `$V_{\text{grind}} = 31.25\ \text{m/s}$` | 依据白描裂隙长度动态持续 | 冲刺轨迹撞入已有裂隙或于裂隙 `$0.45\ \text{m}$` 内按冲刺吸附触发；肉身化作狂草墨线沿裂隙中轴疾驰（**全程无敌**），穿刺沿途敌人触发背刺暴击（`$1.5\times$`）与局部 `$40\ \text{ms}$` 顿帧，并**立即刷新冲刺与折纸冷却**。 |
| **凌空撕纸弹弓**<br>*(Aerial Rift Slingshot)* | `$V_{\text{slingshot}} = 25.0\ \text{m/s}$` | 蓄势窗 `$200\ \text{ms}$`，爆冲 **`$180\ \text{ms}$`**（位移 **`$4.50\ \text{m}$`**） | 空中按下 `K`/`LB` 进入 `time_scale = 0.20` 慢动作并扯开半月形撕裂口，推方向按 `Space`/`A` 向八向爆冲；若穿过旧裂隙则触发“破纸连环爆”并刷新空中冲刺。 |

## 1.3 关卡几何尺寸防逃避与 `$Z = 0$` 靶心验证（幕 0-5 悬空墨桶深渊）

* **深渊净宽与高程差**：横向开阔距离设计为 **$\mathbf{6.2\ \text{m}}$**（对应 `$620\ \text{px}$`），且对岸高程抬升 `$+1.5\ \text{m}$`。
* **极限跳跃平飞距离验证**：因对岸高程 `$+1.5\ \text{m}$`，有效滞空时间仅为 `$t_{\text{eff}} = 0.35 + \sqrt{\frac{2 \times (3.0 - 1.5)}{65.0}} \approx 0.565\ \text{s}$`，实际跳跃越障极限 `$S_{\text{eff}} = 12.5 \times 0.565 = \mathbf{7.06\ \text{m}}$`。扣除起跳点 `$1.2\ \text{m}$` 倒刺死区后，安全平跳跨距仅为 **$\mathbf{5.86\ \text{m}} < 6.2\ \text{m}$**。
* **2.5D 微俯视 `$Z = 0$` 靶心校准**：在 `Pitch = -15^\circ$` 微俯角下，空中两只八角铸铁墨桶的 `CollisionShape3D` 严格居中于 `$Z = 0$` 平面，桶口 `$Z = 0$` 前沿镶嵌亮泥金包边（`#D4A017`），防止俯视纵深导致下劈（Pogo）踩空。
* **数学结论**：**玩家单凭常规跳跃或单次冲刺无法跨越深渊**；必须通过“起跳 $\to$ 凌空撕纸弹弓（八向爆冲 `$4.50\ \text{m}$`） $\to$ 千斤坠下劈墨桶/朱砂纸鸢（Pogo 垂直反弹 `$V_y = +18.0\ \text{m/s}$` 刷新空中冲刺） $\to$ 凌空冲刺滑翔”链条方可登岸。

---

# 第二章：Godot 3D 核心节点树架构、六大工程规范与代码实现

## 2.1 完整主角节点树架构（`Player.tscn` · 工程规范 #2 & #3）

所有角色、敌人与地形物理刚体均开启 `Axis Lock`（锁定 `Linear Z` 与 `Angular X / Y / Z`），确保物理运算严格限制在 `$Z = 0$` 战斗平面：

```text
Player (CharacterBody3D) - 挂载 player_controller_3d.gd (Axis Lock: Linear Z, Angular X/Y/Z)
├── CollisionShape3D (CapsuleShape3D, radius=0.16m, height=0.90m, 偏置至脚底上方 +0.45m)
├── GroundSnapRay (RayCast3D, target_position=Vector3(0, -0.35, 0), collision_mask=1, 贴地冲刺坡度贴合测距)
├── VisualRoot (Node3D) - 【严禁负 scale.x，左右转向一律使用 Sprite3D.flip_h】
│   ├── Sprite3D (pixel_size=0.01, alpha_cut=Discard, 单帧规格 512x320px, offset=Vector2(0, 160), 脚底锁定 Bottom-Center)
│   ├── PlumBlossomOrbitRig (Node3D) - 挂载 plum_blossom_orbit_rig.gd (5个独立弹簧延迟 Sprite3D 朱砂血梅晶簇)
│   ├── DashWakeDecal (Decal, size=Vector3(1.6, 0.4, 1.4), 贴地冲刺时激活八字墨浪与气旋阴影)
│   ├── AnimationPlayer (控制 60FPS 序列帧、活跃帧 Hitbox 尺寸关键帧与武侠音效，支持慢动作逆向 speed_scale 补偿)
│   └── FeibaiParticles (GPUParticles3D, 掠地冲刺八字尘浪与狂草墨线拖尾)
├── Hitbox (Area3D, collision_layer=4, collision_mask=0)
│   └── CollisionShape3D (BoxShape3D, Z轴厚度锁定 0.30m, 随狂草涂抹帧动态缩放并按 facing_dir 镜像 X 坐标)
├── Hurtbox (Area3D, collision_layer=0, collision_mask=8)
│   └── CollisionShape3D (CapsuleShape3D)
├── RiftDetector (Area3D, collision_layer=0, collision_mask=16, 半径 0.45m 磁吸检测白描裂隙)
└── StateMachine (Node) - 完整 12 态武侠状态机管理逻辑
    ├── IdleState (虚步待机 8帧)
    ├── RunState (踏墨疾奔 8帧)
    ├── TurnaroundBrakeState (拧腰甩袖急停折返 4帧)
    ├── JumpState (纵云梯起跳/滞空/下落/弓步落地 13帧)
    ├── AttackState (破宣斩三连 16/16/22帧 + 千斤坠下劈 12帧)
    ├── WuxiaDashState (掠地疾行·双臂后掠冲刺 6帧)
    ├── RiftGrindState (钻缝无敌墨线滑行 6帧)
    ├── SpatialFoldState (云手折纸·绞杀 14帧)
    ├── RiftSlingshotState (凌空撕纸弹弓 12帧)
    ├── ParryAndTearState (金石拓片弹反与居合拔刀撕甲 14帧)
    ├── PaperRipFinisherState (错身抽纸·处决 10帧)
    └── ScrollFlipFinisherState (Boss 两段式掀卷七笔与落卷近身贯心处决 16帧)
```

## 2.2 全角色分级单帧画布与动作工程铁律（工程规范 #3、#4、#5）

1. **全生态四级单帧画布尺寸与零净空底边铁律（规范 #3）**：
   为完美容纳《雾山五行》式超长狂草刀光、双臂后掠大氅飘带以及敌方重器长兵，全游戏序列帧按角色体量分级锁定单格（Cell）尺寸，所有地面动作的支撑脚底均紧贴底边中点（`$0\ \text{px}$` 底部净空）：

   | 角色分级 | 单帧画布像素尺寸 | 对应 3D 空间包络 | `Sprite3D.offset` 设置 | `Bottom-Center` 锚点 |
   | :--- | :--- | :--- | :--- | :--- |
   | **主角【墨痕】** | **`$512 \times 320\ \text{px}$`** | `$5.12\ \text{m} \times 3.20\ \text{m}$` | `Vector2(0, 160)` | `(256, 320)` |
   | **四大章杂兵（Mobs）** | **`$320 \times 320\ \text{px}$`** | `$3.20\ \text{m} \times 3.20\ \text{m}$` | `Vector2(0, 160)` | `(160, 320)` |
   | **四大章精英（Elites）** | **`$448 \times 384\ \text{px}$`** | `$4.48\ \text{m} \times 3.84\ \text{m}$` | `Vector2(0, 192)` | `(224, 384)` |
   | **四大关底主宰（Bosses）** | **`$512 \times 448\ \text{px}$`** | `$5.12\ \text{m} \times 4.48\ \text{m}$` | `Vector2(0, 224)` | `(256, 448)` |

   * 在活跃判定帧（`$80\ \text{ms}$` / `$100\ \text{ms}$`）内，`AnimationPlayer` 同步驱动 `Hitbox/CollisionShape3D` 的包络盒大小，并每物理步采样刀尖世界坐标经 `Camera3D.unproject_position()` 写入 `SubViewport_TearMask` 生成 `Line2D` 撕纸遮罩。
2. **严禁 `Node3D` 负缩放，强制采用 `Sprite3D.flip_h` 镜像（规范 #4）**：
   * 因主角左右半身非对称（右臂焦墨握断铁錾、左半身生宣白描经络），全工程**严禁执行 `VisualRoot.scale.x = -1` 或 `scale.x = -1`**（防止 3D 法线翻转与背面剔除异常）。
   * 角色转向一律通过 **`sprite_3d.flip_h = (facing_dir < 0)`** 实现，同时由脚本对 `Hitbox.position.x`、`FeibaiParticles.position.x` 等非对称子节点乘以 `signf(facing_dir)` 进行坐标镜像。
3. **双时钟与 `AnimationPlayer.speed_scale` 逆向倍速补偿（规范 #5）**：
   * 全局时间缩放由 `TimeScaleManager` 按真实墙钟毫秒数仲裁。当处于全局冻结（`PARRY_FREEZE` `$260\ \text{ms}$` / `EXECUTION_FREEZE` `$300 \sim 340\ \text{ms}$`）时，全场动画静止；
   * 当处于可控慢动作（`RIFT_SLOWMO` `time_scale = 0.20` 或 `FINISHER_SLASH` `time_scale = 0.30`）且主角正在执行玩家触发的斩击、扯纸或狂草成字动作时，自动设置 **`anim_player.speed_scale = 1.0 / Engine.time_scale`**，实现“万象凝滞、主角出剑如电”的武侠宗师视听反差；动作结束或解冻后立即归位 `speed_scale = 1.0`。

## 2.3 InputMap 键位绑定与双时钟动作计时唯一真值表

| 战斗事件 / 机制 | 输入指令<br>*(键鼠 / 手柄)* | 时钟归属 | 输入 / 判定窗口<br>*(真实墙钟)* | 实际冻结时长<br>*(真实墙钟)* | 动画视觉时长<br>*(60 FPS 基准)* |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **移动 / 急停折返** | `A` / `D` / 左摇杆 | 演算钟 | 松键 `$60\ \text{ms}$` 刹停 | 无 | 疾奔 `$8$` 帧循环；反向输入触发 `$4$` 帧拧腰甩袖急停。 |
| **纵云梯跳跃 / 下探** | `Space` / `A`；<br>长按 `S` 下探 | 真实墙钟 | 土狼 **`$100\ \text{ms}$`**<br>缓冲 **`$120\ \text{ms}$`** | 无 | 完整 `$13$` 帧跳跃周期；长按 `S` `$300\ \text{ms}$` 触发 `Pitch` 下压 `$2.0^\circ$`。 |
| **破宣斩 · 轻击 1~2 段** | `J` / 左键 / `X` | 局部冻结走墙钟<br>挥刀走演算钟 | 判定激活 **`$80\ \text{ms}$`**<br>连招缓冲 **`$140\ \text{ms}$`** | 局部顿帧 **`$60\ \text{ms}$`**<br>*($3$ 物理步)* | 全程 **`$267\ \text{ms}$`**（`$16$` 帧）：<br>弓步平抹 `$16$` 帧 $\to$ 虚步撩剑 `$16$` 帧。 |
| **破宣斩 · 重击 3 段** | `J` 连按 | 局部冻结走墙钟<br>挥刀走演算钟 | 判定激活 **`$100\ \text{ms}$`** | 局部顿帧 **`$80\ \text{ms}$`**<br>*($4$ 物理步)* | 全程 **`$367\ \text{ms}$`**（`$22$` 帧）：<br>凌空翻腾力劈华山 + 台面烙白描裂隙 `Decal`。 |
| **千斤坠下劈（Pogo）** | 空中 `S` + `J` / `X` | 局部冻结走墙钟 | 判定激活 **`$100\ \text{ms}$`** | 局部顿帧 **`$60\ \text{ms}$`** | 全程 **`$200\ \text{ms}$`**（`$12$` 帧）：绽开白莲印反弹 `$V_y = +18.0\ \text{m/s}$`。 |
| **掠地疾行 · 双臂后掠冲刺** | `Left Shift` / `RT` | 演算钟主导<br>无敌帧走墙钟 | 前 **`$140\ \text{ms}$`** 无敌<br>CD `$450\ \text{ms}$` | 无 | 全程 **`$180\ \text{ms}$`**（`$6$` 帧）：双臂后掠贴地疾驰 `$3.60\ \text{m}$`，犁出 `$0.85\ \text{m}$` 宽白描裂隙 `Decal`。 |
| **钻缝无敌墨线滑行** | 裂隙旁 `Shift` / `RT` | 演算钟主导 | 距裂隙 `$0.45\ \text{m}$` 内吸附；全程无敌 | 穿刺敌人触发局部 **`$40\ \text{ms}$`**（不冻结主角） | `$6$` 帧入缝/出缝 + 狂草墨线 `$31.25\ \text{m/s}$` 疾驰，刷新冲刺与折纸 CD。 |
| **云手折纸 / 凌空撕纸** | `K` / 手柄 `LB` | 真实墙钟控窗<br>世界按 `0.20` 缩放 | 最长蓄势窗 **`$200\ \text{ms}$`** | 慢动作 `time_scale = 0.20`（主角 `speed_scale = 5.0` 补偿） | 折纸 `$14$` 帧（坍缩畸变 `$240\ \text{ms}$`）；空中撕纸 `$12$` 帧八向爆冲 `$4.50\ \text{m}$`。 |
| **金石拓片弹反与撕甲** | `F` / 右键 / `RB` | 真实墙钟<br>*(覆盖慢动作)* | 有效招架窗 **`$160\ \text{ms}$`** | 全局定格 **`$260\ \text{ms}$`**<br>*($13$ 物理步 / `~16` 帧)* | `$14$` 帧十字架刀 + 拓片负片反相 + 居合拔刀沿虚线撕飞重甲。 |
| **错身抽纸·处决** | 虚弱敌旁 `Shift`/`E` | 真实墙钟 | 斩杀线 `$\le 30\%\ \text{HP}$` 或纸片化硬直 | 处决无敌 **`$180\ \text{ms}$`** | `$10$` 帧掠影错身反手扯下表层墨皮化蝶，刷新冲刺 CD 并回 `$0.5$` 血梅。 |
| **Boss 两段式终局处决** | 重斩掀卷 $\to$ 连斩 $\to$ `[处决]` | 真实墙钟 | 掀卷窗 `$1500\ \text{ms}$`；连斩 `time_scale = 0.30` | 掀卷定格 **`$200\ \text{ms}$`**<br>贯心处决 **`$300 \sim 340\ \text{ms}$`** | `$16$` 帧（掀卷 `$8$` 帧狂草成字 + 落卷 `$8$` 帧 `FOV = 24^\circ$` 近身贯心反相）。 |

## 2.4 武侠掠地疾行（双臂后掠贴地冲刺）物理实现 (`WuxiaDashState.gd`)

```gdscript
class_name WuxiaDashState
extends Node

const DASH_SPEED: float = 20.0
const DASH_DURATION_MS: float = 180.0   # 9 个 50Hz 物理步
const INVULN_DURATION_MS: float = 140.0 # 7 个 50Hz 物理步
const SKIM_RIFT_WIDTH: float = 0.85     # 剑尖拖地犁出的加宽刮白力场宽度

var player: CharacterBody3D
var ground_snap_ray: RayCast3D
var dash_wake_decal: Decal
var rift_detector: Area3D

var _facing_dir: float = 1.0
var _start_time_usec: int = 0

func enter(facing_dir: float) -> void:
	_facing_dir = signf(facing_dir) if absf(facing_dir) > 0.01 else 1.0
	_start_time_usec = Time.get_ticks_usec()
	
	# 1. 严格使用 Sprite3D.flip_h 转向，禁止负 scale.x（工程规范 #4）
	player.apply_facing_direction(_facing_dir)
	
	# 2. 开启无敌帧与地面八字尘浪/气旋阴影 Decal
	player.set_hurtbox_enabled(false)
	if dash_wake_decal:
		dash_wake_decal.visible = true
	
	# 3. 播放 6 帧武侠“双臂后掠贴地冲刺”动画与踏雪掠风音效
	player.anim_player.play("wuxia_ground_dash")
	AudioManager.play_unscaled("sfx_wuxia_dash_skim")

func physics_update(_delta: float) -> void:
	var elapsed_ms: float = (Time.get_ticks_usec() - _start_time_usec) / 1000.0
	
	# 1. 真实墙钟控制无敌帧结束（140ms）与冲刺总时长结束（180ms）
	if elapsed_ms >= INVULN_DURATION_MS:
		player.set_hurtbox_enabled(true)
	if elapsed_ms >= DASH_DURATION_MS:
		player.state_machine.transition_to("Fall" if not player.is_on_floor() else "Idle")
		return
	
	# 2. 检测冲刺路径上是否撞入已有白描裂隙 -> 无缝俯身潜入“钻缝无敌墨线滑行”
	var overlapping_rifts: Array[Area3D] = rift_detector.get_overlapping_areas()
	if overlapping_rifts.size() > 0:
		player.state_machine.transition_to("RiftGrind", {"rift": overlapping_rifts[0], "dir": Vector2(_facing_dir, 0)})
		return
	
	# 3. 水平保持 20.0 m/s 极速贴地突进（锁死 Z=0 战斗平面，零物理浮空抬升）
	player.velocity.x = _facing_dir * DASH_SPEED
	player.velocity.z = 0.0
	
	# 4. 贴地坡度自适应：双足紧贴地面高速掠行，飞出悬崖时保持水平御风滑翔不立即下坠
	if ground_snap_ray.is_colliding():
		var floor_pt: Vector3 = ground_snap_ray.get_collision_point()
		player.velocity.y = -2.0 # 轻微向下贴地压力，确保顺滑贴合斜坡与低阶
		
		if dash_wake_decal:
			dash_wake_decal.global_position = Vector3(player.global_position.x, floor_pt.y + 0.02, player.global_position.z)
		# 低垂的断铁錾剑尖在 3.2m 台面顶面实时犁出 0.85m 宽白描裂隙 Decal
		RiftManager.stamp_ground_skim_rift(floor_pt, SKIM_RIFT_WIDTH)
	else:
		player.velocity.y = 0.0
		if dash_wake_decal:
			dash_wake_decal.visible = false
	
	player.move_and_slide()
	
	# 5. 撞墙脱困：若正面撞击未破除的焦墨死壁，提前结束冲刺防止卡死
	if player.is_on_wall():
		player.velocity.x = 0.0
		player.state_machine.transition_to("Idle")

func exit() -> void:
	player.set_hurtbox_enabled(true)
	if dash_wake_decal:
		dash_wake_decal.visible = false
```

---

# 第三章：双 `Camera3D` 镜像同步与全屏金石拓片渲染管线

为使 `2.5D` 微俯视舞台（`FOV = 36^\circ$`、`Pitch = -15^\circ$`）下的“表里双轨撕纸”与“双臂后掠犁纸”严丝合缝，执行以下三层渲染管线：

1. **双 `Camera3D` 同矩阵镜像同步**：
   * 场景中并行维护表层主相机 `StageCamera3D` 与里层白描视口相机 `BaimiaoCamera3D`（置于 `SubViewport_Baimiao` 内），每帧通过 `DualCameraRig.gd` 严格同步 `global_transform`、`fov`、`h_offset` 与 `v_offset`，确保透过白描裂隙看到的里层 3D 世界无任何透视滑动偏差。
2. **屏幕撕裂遮罩与 `$3.2\ \text{m}$` 台面 `Decal` 双重映射**：
   * 每次破宣斩（宽 `$0.48\ \text{m}$`）或掠地疾行冲刺（宽 `$0.85\ \text{m}$`）划过舞台时，一方面通过 `Camera3D.unproject_position()` 将刀锋与剑尖轨迹投影至 `SubViewport_TearMask` 绘制锯齿纤维白线；另一方面在 `$3.2\ \text{m}$` 宽的 3D 台面顶面投射纯白生宣 `Decal`，确保玩家在 `$-15^\circ$` 微俯角下清晰辨认敌我脚点是否踏入刮白力场。
3. **顶层 `CanvasLayer` 金石拓片反相与 Boss 掀卷 Shader（`layer = 100`）**：
   * 完美弹反触发 `$260\ \text{ms}$`（真实墙钟）与落卷近身处决触发 `$300 \sim 340\ \text{ms}$` 时，全屏瞬时反相为**底黑如夜、线条莹白如雪的宋代金石拓片负片**；
   * 关底 Boss 进入终局濒死阶段触发**两段式终局交互**时，顶层 `TextureRect` 启用 2D 翻书卷页 Shader（Page Curl），将表层浓墨画面与漫天弹幕从左向右卷成纸筒压扁在屏幕右侧，暴露出底下 `$100\%$` 纯净的白描世界供玩家执行狂草连斩。

---

# 第四章：敌对状态机、全生态移动身法映射与朱砂印台复活体系

## 4.1 敌方 8 帧一体化切片规范与状态机（工程规范 #6）

为防止分次生图导致角色体型与墨色深浅不一致，所有杂兵、精英与 Boss 的常规移动均采用**单行 `8` 帧一体化合并表（`Sprite3D.hframes = 8`，索引 `0..3` 为待机呼吸循环，索引 `4..7` 为标志性移动循环）**，并通过 `Sprite3D.flip_h` 执行朝向镜像。

### 1. 受击破甲与处决核心状态
* **`DesaturatedWeakState`（去色破甲状态）**：当敌人脚点踏入主角刮白力场 `Decal` 时触发——材质 `SpatialShader` 将表层浓墨重甲褪色为惨灰白（减伤清零且物理防御 `$-40\%$`），移动与攻击动画 `speed_scale` 降至 `0.70`，并定时释放水墨晕染重影粒子。
* **`PaperizedStaggerState`（纸片化硬直状态）**：当敌人削韧条（Poise）被破宣斩、折纸绞杀或裂隙背刺清空（或 HP `$\le 30\%$`）时，强制播放“纸偶散架跪地颤抖”循环帧（持续 `$2.5\ \text{s}$`），头顶亮起朱砂处决印记，允许主角直接发动 `PaperRipFinisherState`（错身抽纸处决）整张扯下表层墨皮并**立即刷新冲刺冷却**。

### 2. 全生态移动身法物理与视觉映射表

| 敌方分级与名称 | 切片规格 | 移动动作名称与步态特征 | Godot 4 物理与视觉实现细节 |
| :--- | :--- | :--- | :--- |
| **杂兵 · 盲眼巡卒**<br>*(序章)* | `$320 \times 320\ \text{px}$` | **拖尺木偶步**（巡逻 `$1.5\ \text{m/s}$`）<br>**前倾急趋步**（追击 `$3.8\ \text{m/s}$`） | 拖尺移动时，尺尖挂点每隔 `$0.25\ \text{m}$` 向台面顶面投射微小焦墨划痕 `Decal`；追击时身体前倾 `$30^\circ$` 高频碎步。 |
| **杂兵 · 巡水工偶**<br>*(第一章)* | `$320 \times 320\ \text{px}$` | **涉水拔泥步** / **扛钩冲锋步** | 巡逻速度曲线加入正弦顿挫调制（模拟拔泥停顿感），脚踝同步喷射石青水花粒子。 |
| **杂兵 · 守碑阴傀**<br>*(第二章)* | `$320 \times 320\ \text{px}$` | **负碑重踏步** / **暴走掠地步** | 每完成半个步态周期触发 `$0.03\ \text{m}$` 轻微相机本地微震并溅射飞白沙尘粒子。 |
| **杂兵 · 去色司祝**<br>*(终章)* | `$320 \times 320\ \text{px}$` | **僵直仪仗滑步** / **凌空掠影疾飘** | 追击时 `VisualRoot.position.y` 平滑抬升 `$+0.10\ \text{m}$`，消除垂直起伏实现无声鬼魅滑行。 |
| **精英 · 镇峰狱尉**<br>*(幕 0-3)* | `$448 \times 384\ \text{px}$` | **侧身横推蟹步**（`$2.2\ \text{m/s}$`） | 保持重盾正面朝向主角，`flip_h` 仅在主角越过头顶 `$0.4\ \text{s}$` 后延迟翻转；每步伴随盾底撞石沉闷音效。 |
| **精英 · 伏波画督**<br>*(幕 1-5)* | `$448 \times 384\ \text{px}$` | **提线顿挫官步**（`$2.6\ \text{m/s}$`） | 迈步瞬间 `VisualRoot.position.y` 向上产生 `$+0.08\ \text{m}$` 弹性跳动，模拟无形悬丝提拉感。 |
| **精英 · 司弦刑官**<br>*(幕 2-3)* | `$448 \times 384\ \text{px}$` | **踏弦鬼魅折线步**（`$4.8\ \text{m/s}$`） | 采用短促高频小跳位移拉扯距离，落地瞬间释放微弱音波涟漪。 |
| **精英 · 平规衡司**<br>*(幕 3-3)* | `$448 \times 384\ \text{px}$` | **绝对水平御空平移**（`$3.0\ \text{m/s}$`） | 悬浮高度锁定 `$+0.20\ \text{m}$`，加速度变化率驱动黄金天平托盘惯性倾角。 |
| **主宰 · 墨梅**<br>*(序章)* | `$512 \times 448\ \text{px}$` | 一阶段**冷峻剑客滑步**；<br>二阶段**焦墨梅枝疾掠**；三阶段**白描半跪** | 一阶段平稳滑步接近，独立的 `PlumBlossomOrbitRig` 驱动 `$6$` 朵朱砂血梅公转；二阶段低身高速突进拖曳狂草黑枝粒子。 |
| **主宰 · 墨竹 / 墨骨 / 顾狂墨** | `$512 \times 448\ \text{px}$` | 墨竹**破浪弓步/踏浪疾行**；<br>墨骨**四翼滑翔**；顾狂墨**狂草疾掠** | 墨骨二阶段切换为无重力 `8` 帧浮空御风滑翔；顾狂墨二阶段在 `$95\%$` 死白风暴中执行折线瞬步疾掠。 |

## 4.2 朱砂印台（Cinnabar Seal）零黑屏复活与跨章飞瀑过渡

* **零黑屏 `$< 0.8\ \text{s}$` 重塑**：主角血梅耗尽阵亡时，身躯化作一团散开的宿墨沿地面高速倒卷回最近一枚朱砂印台重塑（耗时 `$650\ \text{ms}$`），重置杂兵状态、恢复 `$5$` 朵朱砂血梅（由 `PlumBlossomOrbitRig` 重新凝聚）并强制将 `Engine.time_scale` 归位为 `1.00`。
* **首个试玩包（Demo v0.1）跨章飞瀑过渡**：击败序章断云台主宰【墨梅】（完成 `$4.5\ \text{s}$` 七笔成“折”与 `FOV = 24^\circ$` 落卷近身按键处决）后，擂台崩塌直坠幕 T-1 万丈飞瀑（`$-40.0\ \text{m/s}$`），冲刷血垢后经 `$90^\circ$` 圆弧滑跪停在第一章【幕 1-1 青石浅滩】濯缨水榭前，全屏主色调丝滑蜕变为王希孟青绿山水并盖下朱砂印【留白 · Demo v0.1 完】。

---

# 第五章：21 天敏捷冲刺执行排期与 DoD 终极验收标准

## 5.1 三周冲刺里程碑

* **Week 1（Day 1 ～ Day 7 · 3D 白盒与武侠核心手感底座）**：搭建 Godot 4.3+ Forward+ 工程，实装双时钟管理器（`InputBufferManager` + `TimeScaleManager`）、`$3.2\ \text{m}$` 纵深台面跑道、破宣斩三连、**武侠掠地疾行（双臂后掠贴地冲刺 + `$0.85\ \text{m}$` 犁纸）**、钻缝无敌墨线滑行与云手折纸绞杀，通过 **Gate A / Gate B**。
* **Week 2（Day 8 ～ Day 14 · 序章全生态与墨梅两段式终局）**：实装杂兵【盲眼巡卒】（含拖尺木偶步、`DesaturatedWeakState` 与 `PaperizedStaggerState`）、精英【镇峰狱尉】（重盾蟹步、`$160\ \text{ms}$` 弹反触发 `$260\ \text{ms}$` 金石拓片负片 + 虚线撕盾 Pogo）、关底主宰【墨梅】三阶段（含剑客滑步与两段式终局处决），实装朱砂印台复活与跨章飞瀑过渡至幕 1-1，通过 **Gate C / Gate E**。
* **Week 3（Day 15 ～ Day 21 · 四级武侠序列帧装配与核显压测）**：按四级单帧规范（主角 `$512 \times 320$`、杂兵 `$320 \times 320$`、精英 `$448 \times 384$`、Boss `$512 \times 448$`）导入 `$15^\circ$` 微俯视序列帧（含 `8` 帧待机+移动一体化合并表），启用 `flip_h` 镜像与独立 `PlumBlossomOrbitRig` 血梅节点，装配 7 轨 `$Z$` 轴布景与双 `Camera3D` 撕纸遮罩，在 Intel Iris Xe / AMD Radeon 680M 核显轻薄本上执行 `$60\ \text{FPS}$` 锁帧压测与 `$5$` 人外部盲测，封版导出 **Demo v0.1**（通过 **Gate D / Gate F**）。

## 5.2 DoD 4.0 终极交付验收清单

* [ ] **四级序列帧切分与物理脚点零偏差**：主角（`$512 \times 320\ \text{px}$`）、杂兵（`$320 \times 320\ \text{px}$`）、精英（`$448 \times 384\ \text{px}$`）与 Boss（`$512 \times 448\ \text{px}$`）全部严格锁死 `Bottom-Center` 零底部留白；双臂后掠冲刺贴地疾行零浮空并犁出 `$0.85\ \text{m}$` 宽白描裂隙 `Decal`；左右转身仅使用 `Sprite3D.flip_h`，`PlumBlossomOrbitRig` 血梅自然拖尾无瞬移。
* [ ] **敌方移动身法与状态机闭环**：盲眼巡卒拖尺划痕、镇峰狱尉重盾蟹步、墨梅冷傲剑客滑步与受击去色破甲（防御 `$-40\%$`）/纸片化抽纸处决状态机 `$100\%$` 跑通。
* [ ] **双时钟与逆向动画补偿零偏差**：所有输入缓冲（跳跃 `$120\ \text{ms}$`、连招 `$140\ \text{ms}$`）、弹反窗口（`$160\ \text{ms}$`）与全局冻结（弹反 `$260\ \text{ms}$`、处决 `$300 \sim 340\ \text{ms}$`）严格走真实墙钟毫秒数；慢动作期间主角活跃斩击自动应用 `speed_scale = 1.0 / Engine.time_scale` 补偿。
* [ ] **性能与真机稳定性**：`$1920 \times 1080$` 分辨率下主流核显轻薄本稳定 **`$60\ \text{FPS}$`**，3D Draw Calls `$\le 55$`，Debugger 零红色报错，外部玩家盲测通关率 `$\ge 80\%$`。