# 《留白》（Ink & Void）全角色帧动画设计与序列帧 Prompt 全典

> **【动画视觉总纲】**：“形如游龙惊鸿，势若狂草裂帛；静如古松立雪，动似剑客掠风。”
>
> **【核心审美标尺 · 纯正中国武侠与东方木偶律动】**：彻底摒弃欧美奇幻的沉重挥砍与日系无重力浮空套路，全篇动作设计深度植根于**中国传统武侠身法**与**东方傀儡戏律动**——主角讲究**“腰马合一、沉肩坠肘、虚实相生、步随身转”**，冲刺采用“双臂后掠、低身掠地”的踏雪无痕轻功姿态；敌对杂兵与精英则通过提线木偶般的机械顿挫、重器负重步态与丝线牵引感，外化“被执笔阁规矩异化”的悲剧压迫力。
>
> **【工程对齐基准 · SOP 4.0 唯一真值】**：Godot Engine 4.3+ · `Sprite3D`（`pixel_size = 0.01`，脚底中心点严格锁定 **`Bottom-Center` 零净空底边对齐**）· 匹配主相机 **`2.5D` 微俯视透视（`Pitch = -15^\circ$`，`FOV = 36^\circ$`）** · 视觉动画严格对齐 **`$60\ \text{FPS}$`（`$16.67\ \text{ms/帧}$`）** · 序列帧背景统一锁定中性浅灰（`#E0E0E0`），且**严禁在静态序列帧中画死周身悬浮的 `$5$` 朵朱砂血梅**（交由程序 `PlumBlossomOrbitRig` 独立弹簧节点渲染以防转身镜像跳变）。

---

# 第一部分：中国武侠动态法则与全角色单元格规范

## 1.1 武侠桩功重心与三段式延迟跟随（S-Curve & Follow-Through）

* **下盘稳健、上身灵动**：拒绝垂直木桩站姿。主角在任何武侠架势下的脊柱线必须呈现富有张力的 **“弓弦曲线”**——待机时“虚步沉肩”，疾奔时前倾 `$32^\circ$`，**掠地冲刺时重心压低前倾 `$38^\circ$`、双臂向后潇洒掠起**，急停时“坐胯后仰 `$18^\circ$`”。
* **三段式延迟物理（二级动态）**：全角色拆分出三个延迟响应层级——**腰胯与双足（第 `$0$` 帧发力蹬地）** $\to$ **躯干与兵刃（延迟 `$1 \sim 2$` 帧挥出）** $\to$ **衣摆大氅与散乱长发/丝带（延迟 `$3 \sim 4$` 帧飘荡收尾）**。角色落地静止后，发丝与衣角仍会随余风轻拂 `$4 \sim 6$` 帧，绝不出现“木偶骤停”。

## 1.2 《雾山五行》式狂草涂抹残影帧（Calligraphic Smear Frames）

* 在高速出刀（“破宣斩”判定帧）或高速掠地（“双臂后掠冲刺”与“钻缝无敌墨线滑行”）的爆发瞬间，不使用廉价的半透明重影拷贝，而是将肢体边缘与兵刃拖尾直接夸张形变为**苍劲的焦墨飞白笔触（Dry-Brush Feibai Arcs）与撕裂的桑皮纸纤维丝带**，下一帧再迅速收束回清晰的 `$0.25\ \text{mm}$` 白描人体轮廓。

## 1.3 全生态单帧画布尺寸与零净空底边铁律

为容纳武侠大氅飘带、狂草超长刀光以及敌方重器长兵，全游戏序列帧按角色体量分级锁定单格（Cell）尺寸，且**所有地面动作的支撑脚底均紧贴底边中点（`0 px` 底部净空）**：

| 角色分级 | 单帧画布像素尺寸 | 对应 3D 空间包络 | `Bottom-Center` 锚点像素 | 规范说明 |
| :--- | :--- | :--- | :--- | :--- |
| **主角【墨痕】** | **`$512 \times 320\ \text{px}$`** | `$5.12\ \text{m} \times 3.20\ \text{m}$` | `(256, 320)` | 完美容纳双臂后掠冲刺大氅与破宣斩狂草刀光；不画静态悬浮血梅。 |
| **四大章杂兵（Mobs）** | **`$320 \times 320\ \text{px}$`** | `$3.20\ \text{m} \times 3.20\ \text{m}$` | `(160, 320)` | 容纳戒尺、浚河长钩、残碑与刮霜铅拂挥扫半径。 |
| **四大章精英（Elites）** | **`$448 \times 384\ \text{px}$`** | `$4.48\ \text{m} \times 3.84\ \text{m}$` | `(224, 384)` | 容纳两丈魁梧体态、方圆重盾、折叠画屏与黄金天平。 |
| **四大关底主宰（Bosses）** | **`$512 \times 448\ \text{px}$`** | `$5.12\ \text{m} \times 4.48\ \text{m}$` | `(256, 448)` | 容纳老梅铁枝披风、丈八竹枪、四扇石碑翼与千手戒尺法环。 |

---

# 第二部分：主角【墨痕】武侠全动作帧序列详表（60 FPS 基准）

```text
[武侠身法移动]：虚步待机(8帧) ──► 踏墨疾奔(8帧) ──► 拧腰甩袖急停(4帧) ──► 纵云梯跳跃周期(13帧)
                                                                              │
[掠地撕纸身法]：钻缝无敌墨线滑行(6帧) ◄── 掠地疾行·双臂后掠冲刺(6帧) ◄─────────┘
      │
      ├──► [武侠剑招]：破宣斩三连（弓步平抹16帧 -> 虚步撩剑16帧 -> 腾空劈山22帧） + 千斤坠下劈(12帧)
      ├──► [画理武学]：云手折纸绞杀(14帧) / 凌空撕纸弹弓(12帧) / 错身抽纸处决(10帧)
      └──► [宗师终局]：金石格挡与拔刀撕甲(14帧) ──► Boss两段式终局（掀卷七笔8帧 -> 落卷近身贯心8帧）
```

## 2.1 基础武侠步法与跳跃序列

### 1. 虚步待机（Wuxia Idle · 8 帧循环 · `$133\ \text{ms/帧}$`）
* **武侠神韵**：古典剑客“沉肩坠肘、虚步藏锋”起手式。左足微前虚点地面，右膝微屈坐胯承重；左手立剑诀（食指中指并拢）护于胸前，右手反握【断铁錾 · 裁云】斜垂于身侧后方，如临风修竹。
* **逐帧细节**：
  * `Frame 1-4`（气沉丹田）：胸廓微扩，皮下原矿朱砂经络（`#C3272B`）随呼吸泛起暗红微光；左半身生宣衣袂与散乱黑发向后上方轻柔飘起。
  * `Frame 5-8`（呼气下沉）：重心微沉 `$4\ \text{px}$`，大氅下摆与发梢波浪式回落，腰间无字白玉方印轻晃归位。

### 2. 踏墨疾奔（Wuxia Run Cycle · 8 帧循环 · `$67\ \text{ms/帧}$` · `$12.5\ \text{m/s}$`）
* **武侠神韵**：低重心武侠疾行，步幅矫健轻灵。躯干前倾 `$32^\circ$`，右手反握断铁錾顺势向后平拖，左手自然前后摆动保持平衡，衣袂随步法猎猎飞扬。
* **逐帧细节**：
  * `Frame 1`（右足蹬地爆发）：右腿向后完全蹬直，脚底在台面擦出一缕干燥飞白纸灰，大氅下摆向后拉直。
  * `Frame 2-3`（腾空掠步）：双足短暂离地向前跨步，左手五指微张向后拖出淡墨气丝。
  * `Frame 4`（左足落地缓冲）：左足前跨弓步触地，膝盖微屈吸收冲击，长发与大氅因惯性向前微涌。
  * `Frame 5-8`（左足蹬地 $\to$ 腾空 $\to$ 右足落地）：镜像完成另一侧跨步循环，下盘稳健不晃。

### 3. 拧腰甩袖急停（Turn-Around / Brake · 4 帧过渡 · `$67\ \text{ms/帧}$`）
* **武侠神韵**：高速奔跑中反向输入时触发，展现武侠经典的“坐胯刹停、拧腰甩袖”身法。
* **逐帧细节**：`Frame 1` 前足猛蹬台面侧滑刹停，地面迸出纸屑；`Frame 2` 腰胯率先向反方向拧转 `$180^\circ$`，焦墨大氅与长发因惯性仍在原方向大幅扬起；`Frame 3-4` 断铁錾随腰部扭转划出一道低弧切风，大氅如风轮般甩过头顶完成转身衔接疾奔。

### 4. 纵云梯跳跃周期（Wuxia Jump · 总计 13 帧 · 满跳 `$3.0\ \text{m}$`）
* **起跳上升（Ascent · 4 帧）**：`Frame 1` 屈膝坐胯蓄势；`Frame 2` 脚尖点地如白鹤冲天向上拔起，脊柱呈“C 型”舒展，脚下绽开水墨涟漪；`Frame 3-4` 单膝微提收腹，左手剑诀上引，大氅向下拉成锥形。
* **波峰滞空（Apex Float · 3 帧 · `$V_y \approx 0$`）**：达到最高点瞬间的失重美感——双臂微展如大鹏展翅保持平衡，大氅下摆与长发向上蓬松浮起。
* **苍鹰搏兔下落（Descent · 3 帧 · `$g_{\text{down}} = -65.0\ \text{m/s}^2$`）**：身形收紧向下俯冲，双足微并准备点地，大氅与长发被气流垂直向上吹起，刀锋斜指下方。
* **弓步落地缓冲（Landing Squash · 3 帧 · 对齐 `$120\ \text{ms}$` 跳跃缓冲）**：`Frame 1-2` 触地瞬间深屈膝沉胯卸力（同步触发 `Camera3D` 落地 `$Y$` 轴锚点吸附）；`Frame 3` 弹性起身恢复虚步待机或无缝衔接疾奔。

## 2.2 掠地疾行（双臂后掠冲刺）与钻缝滑行序列

### 5. 掠地疾行 · 双臂后掠冲刺（Wuxia Ground-Skimming Dash · 6 帧 · `$180\ \text{ms}$` · `$20.0\ \text{m/s}$`）
* **武侠核心神韵**：**并非离地浮空飞行，而是中国经典武侠中的“踏雪无痕 · 掠地疾行”冲刺身法！** 角色下盘压低贴地疾驰，上身大幅前倾 **`$38^\circ$`** 破开风阻，**双臂潇洒地向正后方舒展掠起**（右手反握【断铁錾 · 裁云】向后平伸，剑尖低垂拖地犁开宣纸；左臂向后上方舒展如鹤翼保持高速平衡），双足紧贴地面高速交错掠步，衣袂与长发向正后方拉成笔直的墨色流线！
* **逐帧细节**：
  * `Frame 1`（压身起势 · `$20\ \text{ms}$`）：前膝深屈压低重心，上身瞬间前倾 `$38^\circ$`，双臂向身后猛然一甩掠起，后足蹬地激起一圈焦墨气浪。
  * `Frame 2-5`（双臂后掠极速疾驰 · `$120\ \text{ms}$` / 前 `$140\ \text{ms}$` 无敌帧）：双足紧贴 `$3.2\ \text{m}$` 台面高速交错掠行（脚底紧贴 `(256, 320)` 基线，零物理悬空），双臂稳稳向后掠展形成极具武侠宗师风范的流线剪影；低垂的断铁錾剑尖贴地高速拖行，在台面顶面实时“犁”出一道宽 **`$0.85\ \text{m}$`** 的白描裂隙 `Decal`（防御 `$-40\%$` + 减速 `$30\%$`），双足两侧向外排开对称的“八字形”焦墨尘浪与飞白气丝。
  * `Frame 6`（收势弓步 · `$40\ \text{ms}$`）：前足前踏弓步刹停，左臂顺势向前收拢护胸，右手持刀回拉蓄势，大氅余势向前翻卷，无缝衔接破宣斩三连、跳跃，或当轨迹撞入已有白描裂隙时顺势俯身潜入纸缝转入“钻缝无敌墨线滑行”。

### 6. 钻缝无敌墨线滑行（Rift Grind · 6 帧 · `$31.25\ \text{m/s}$` 极速穿刺）
* **武侠神韵**：人剑合一、化形入画——武者俯身潜入自己犁出的白描裂隙之中，化作一道游走于宣纸肌理间的狂草墨锋。
* **逐帧细节**：
  * `Frame 1`（俯身入缝）：双臂后掠俯冲潜向白描裂隙边缘，指尖触及发光的白色撕裂纸边，身躯轮廓开始向水墨线条消融。
  * `Frame 2`（半身化墨）：下半身已化作翻滚的浓黑水墨卷入纸缝，上半身白描线条向前极速拉伸。
  * `Frame 3-4`（狂草墨线穿刺）：**人形完全消失**，化作一道贴着白描裂隙中轴线高速飞驰的**怀素狂草飞白墨线**，两侧伴随漫天纯白纸蝶（全程无敌，穿过敌人触发背刺暴击并刷新冲刺冷却）。
  * `Frame 5`（破缝而出）：抵达裂隙末端，墨线前端炸开生宣纸灰，武者身影自墨迹中重新凝聚。
  * `Frame 6`（回身点剑收势）：弓步落地稳住重心，断铁錾反手向后平指，大氅在身后高高扬起，尽显侠客风流。

## 2.3 武侠剑招序列：【破宣斩】三连与千斤坠下劈

### 7. 破宣斩 · 一段弓步平抹（Slash 1 · 16 帧 · `$267\ \text{ms}$`）
* `Frame 1-4`（藏锋拧腰）：右足前跨成弓步（微前突 `$1.2\ \text{m}$`），腰胯向左后方拧转蓄力，左手剑诀前引，右手握断铁錾横置腰侧。
* `Frame 5-9`（弓步平抹 · 判定帧 + `$60\ \text{ms}$` 局部顿帧）：腰马合一爆发发力，由左向右水平横扫出一道宽阔的 `$140^\circ$` 纯白撕裂月弧！上下边缘翻卷桑皮纸白边，刀尾甩出 `$6$` 滴滞空浓墨滴。
* `Frame 10-16`（收势沉肩）：刀锋停于右侧后方，身体顺势微侧，大氅随刀风向右飘散。

### 8. 破宣斩 · 二段虚步撩剑（Slash 2 · 16 帧 · `$267\ \text{ms}$`）
* `Frame 1-3`（转腕沉剑）：承接一段收势，重心后移转虚步，手腕翻转将刀尖沉向地面。
* `Frame 4-8`（逆风斜撩 · 判定帧）：自右下方向左上方 `$45^\circ$` 疾撩而出！前脚掌微离地面形成轻盈的腾空感，刀锋拖曳出三道干涩苍劲的“渴笔飞白”平行裂隙，与一段横抹交叉形成“宣纸破洞”。
* `Frame 9-16`（白鹤亮翅悬停）：身形在半空舒展，单手高举断铁錾，为三段劈山蓄满高位势能。

### 9. 破宣斩 · 三段腾空劈山（Heavy Slash 3 · 22 帧 · `$367\ \text{ms}$`）
* `Frame 1-7`（凌空翻腾蓄力）：借二段撩剑之势在半空向前凌空翻身 `$360^\circ$`，双手握紧断铁錾高举过头顶。
* `Frame 8-13`（力劈华山 · 判定帧 + `$80\ \text{ms}$` 局部顿帧）：双手持錾垂直下砸！刀光化作贯穿天地的纯白垂直飞白光瀑，断铁錾狠狠劈入玄武岩台面，迸射暗金火星并烙下白色裂隙 `Decal`。
* `Frame 14-22`（单膝沉稳收刀）：单膝微蹲压住地面反震，左手剑诀点地稳住身形，随后缓缓直起腰身拔出刀锋，大氅四周铺开。

### 10. 踏墨穿石 · 千斤坠下劈（Aerial Pogo · 12 帧 · `$200\ \text{ms}$`）
* `Frame 1-2`（倒悬收腹）：空中双腿微曲上收，左手剑诀指向天顶，右手反握断铁錾垂直指向脚下。
* `Frame 3-8`（千斤坠直刺 · 判定帧）：全身化作一柄垂直下坠的墨色锥刺向下突刺；命中目标瞬间，刀尖下方的虚空中绽开一朵**由 `$0.25\ \text{mm}$` 纯黑单线勾勒的“五瓣生宣白莲印”**。
* `Frame 9-12`（蜻蜓点水腾空）：借白莲反冲力优雅翻身向上弹起（`$V_y = +18.0\ \text{m/s}$`），双臂自然张开如御风而行。

## 2.4 画理武学与两段式终局处决序列

### 11. 云手折纸·绞杀（Spatial Fold · 14 帧 · `$240\ \text{ms}$` 墙钟畸变）
* `Frame 1-4`（太极云手虚抓）：双足分开扎稳四平马步，双臂如太极云手般在身前画圆探出，十指张开虚抓空间中的交叉裂隙，周身浮现泥金折纸辅助线。
* `Frame 5-9`（合十坍缩 · 爆发帧）：双手猛然向丹田前合十收拢！动作极具武学内家发力张力，将空间画布死死捏皱折叠，四周敌人被强行扯向中心撞击碎甲。
* `Frame 10-14`（震袖散气）：双臂向两侧猛然振开，大氅向四周鼓荡翻飞。

### 12. 凌空撕纸·裂隙弹弓（Aerial Rift Slingshot · 12 帧）
* `Frame 1-3`（半空撕宣）：半空时间骤缓（`time_scale = 0.20`），左手插入虚空硬生生扯开一道半月形发光白描裂隙，撕裂处飞出桑皮纸纤维。
* `Frame 4-7`（弯弓满月蓄势）：身体向后仰拉，双手拽住裂隙边缘的白描纸边，将纸边像满月弓弦一样向外绷紧变形。
* `Frame 8-12`（离弦破空）：松手回弹，身体如一支裹挟着狂草墨锋的利箭向选定八向爆射而出，身后拉出三道飞白气浪。

### 13. 金石格挡与拔刀撕甲（Parry & Armor Peel · 14 帧）
* `Frame 1-2`（十字架刀 · `$160\ \text{ms}$` 有效窗）：弓步下沉，左手抵住刀背，断铁錾横挡于胸前格挡，眼神冷冽如霜。
* `Frame 3-6`（拓片负片定格 · `$260\ \text{ms}$` 全局冻结）：刀锋与敌刃相撞，爆出朱砂泥金火星与纯白规矩圆环；角色在黑底白线的金石拓片反相中保持稳如泰山的格挡剪影。
* `Frame 7-10`（居合拔刀撕甲）：定格结束首帧，主角顺着敌人重甲上的朱砂裁切虚线，打出极速居合横拉斩！手中如同扯下一张废稿般，将整片焦墨重甲带卷边向后撕飞。
* `Frame 11-14`（振刃归鞘）：反手一振刀身，甩落刀锋残墨，大氅优雅垂落。

### 14. 错身抽纸·处决（Rip-Out Finisher · 10 帧 · `$180\ \text{ms}$`）
* `Frame 1-3`（掠影错身）：化作半透明白描虚影与虚弱敌人高速错身而过。
* `Frame 4-7`（反手扯稿）：错身抵达敌人背后半步，弓步下沉，左手反手死死抓住敌人背部的表层焦墨轮廓猛力向后一拽！整张黑色墨皮如宣纸般被完整剥离。
* `Frame 8-10`（负手立定）：手中撕下的墨皮在半空化作漫天纯白纸蝶消散，主角左手背负于身后、右手垂刀优雅立定。

### 15. Boss 两段式终局处决（Two-Stage Finisher · 16 帧总览）
* **第 1 段 · 掀卷破阵与狂草成字（8 帧）**：
  * `Frame 1-2`（跪步插錾掀画）：单膝跪地将断铁錾狠狠插入画布底层，双手紧握錾柄发力向上猛掀，将整张表层浓墨世界从左向右卷成巨型纸筒。
  * `Frame 3-8`（踏空狂草连斩）：主角施展绝顶轻功踏空穿梭于纯白里层世界中，每一帧定格为一个极具书法挥毫与剑道韵味的腾挪出刀身姿（横、竖、撇、捺、折、钩），身形化作狂草墨迹劈砍右侧纸筒。
* **第 2 段 · 落卷近身按键处决（8 帧 · `FOV = 24^\circ$` 特写）**：
  * `Frame 1-3`（轻盈落卷）：最后一道笔画落成，主角如落叶般轻巧落地在瘫跪于舞台中央的白描 Boss 身前半步，收刀归鞘，神情悲悯而坚定。
  * `Frame 4-6`（双手贯心 · `$300 \sim 340\ \text{ms}$` 拓片反相）：弓步前倾，双手平举断铁錾稳健笔直地刺入 Boss 胸口命核；在黑底白线的金石拓片反相中保持庄严刺击定格。
  * `Frame 7-8`（题跋引爆）：背后全屏狂草巨字（折 / 直 / 藏 / 休）轰然炸裂，主角缓缓抽出断铁錾，衣袂在漫天纸蝶与五彩流光中静静飘荡。

---

# 第三部分：主角【墨痕】武侠序列帧（Sprite-Sheet）AI 生图 Prompt 库

> **【使用铁律】**：
> 1. 所有 Prompt 均已按 **`$512 \times 320\ \text{px}$` 宽幅单元格比例**配置充足动作留白，严格锁死 **`$15^\circ$` 微俯视角**、`Bottom-Center` 脚底紧贴地面基线（零悬空净空）与**中性浅灰（`#E0E0E0`）无阴影背景**。
> 2. 已移除静态绘制的“五朵悬浮血梅”（由程序端 `PlumBlossomOrbitRig` 独立渲染），确保左右镜像翻转（`flip_h`）零穿帮。

### 1. 武侠虚步待机循环（Wuxia Idle Cycle · 8 Keyframes）
```text
2D game character animation sprite sheet, 8 sequential horizontal keyframes from left to right showing a seamless Chinese wuxia swordmaster breathing idle loop, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt) matching a 2.5D stage, Wu Shan Wu Xing painterly ink-wash style and Southern Song Li Gonglin 0.25mm baimiao line-art. Male ink martial artist Mo Hen in a classic wuxia empty-stance (xubu) guard: front foot lightly touching the ground, back knee slightly bent, left hand raised in a two-finger sword mudra (jianjue) at chest height, right hand reverse-gripping a fractured bronze chisel blade angled downward behind his hip. Body crafted from warm aged ivory raw Xuan paper (#EFE9DA) with 0.25mm black outlines, visible mulberry fibers, and glowing cinnabar-red (#C3272B) meridians pulsing softly beneath the skin; right arm and shoulder corrupted by cracked pitch-black charred ink; wearing a tattered sleeveless charcoal wuxia overcoat with frayed dry-brush feibai edges. Subtle chest rise and fall, flowing long hair and coat hem rippling gently in mountain wind, foot baseline strictly anchored at bottom-center with zero bottom padding, isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, no floating orbs, 8k --ar 21:9 --v 6.1 --style raw
```

### 2. 武侠踏墨疾奔循环（Wuxia Run Cycle · 8 Keyframes）
```text
2D game character animation sprite sheet, 8 sequential horizontal keyframes from left to right showing a fluid Chinese wuxia sprinting cycle, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt) matching a 2.5D stage, Wu Shan Wu Xing painterly ink-wash brushwork. Male ink swordsman Mo Hen (half ivory baimiao Xuan paper body with 0.25mm black outlines and pulsing cinnabar meridians, half cracked charred-ink right arm) leaning 32 degrees forward in an agile low-center-of-gravity wuxia sprint, right hand reverse-gripping a fractured bronze chisel blade trailing behind his hip, left arm swinging naturally for martial balance. Fluid alternating strides with light footwork, tattered charcoal wuxia coat and long hair streaming backward in dynamic calligraphic ink ribbons. Consistent character scale, foot baseline strictly anchored at bottom-center, isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 3. 拧腰甩袖急停折返（Wuxia Turn-Around Brake · 4 Keyframes）
```text
2D game character animation sprite sheet, 4 sequential horizontal keyframes from left to right showing a dramatic Chinese wuxia momentum brake and 180-degree hip-twist turn-around, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing ink-wash style. Male ink swordsman Mo Hen (half ivory baimiao Xuan paper body, half charred-ink right arm). Frame 1: front foot digging into the ground in a low sliding horse-stance brake kicking up dry paper dust; Frame 2: torso and waist twisting 180 degrees backward while tattered charcoal cloak and long hair still billow forward from momentum; Frame 3: sweeping the fractured bronze chisel blade in a low circular arc as the cloak whips overhead; Frame 4: settling into an agile forward-facing wuxia dash stance. Foot baseline strictly anchored at bottom-center, isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 4. 纵云梯跳跃与弓步落地缓冲（Wuxia Jump Cycle · 8 Keyframes）
```text
2D game character animation sprite sheet, 8 sequential horizontal keyframes from left to right showing a complete Chinese wuxia acrobatic jump cycle, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt) matching a 2.5D stage, Wu Shan Wu Xing ink-wash style. Male ink swordsman Mo Hen wielding a fractured bronze chisel blade. Frame 1: deep coiled knee-bend crouch; Frame 2: explosive upward crane-leap launch with C-curve spine stretch, left hand raising sword mudra, and ink ripple underfoot; Frame 3-4: graceful rising ascent with one knee tucked; Frame 5: weightless mid-air apex float with arms spread like wings and coat billowing upward; Frame 6-7: streamlined downward eagle-dive with cloth streaming straight up; Frame 8: low wuxia bow-stance (gongbu) landing squash absorption. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 5. 掠地疾行 · 双臂后掠冲刺序列（Wuxia Arms-Back Ground-Skimming Dash · 6 Keyframes）
```text
2D game character animation sprite sheet, 6 sequential horizontal keyframes arranged left to right in a single row with wide horizontal margins, isolated on a flat solid neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, foot baseline strictly anchored at the bottom-center ground plane with zero hovering gap. Male Chinese wuxia ink swordsman Mo Hen (half ivory baimiao Xuan paper body with 0.25mm black outlines, half charred-ink right arm) performing a high-speed grounded wuxia light-footwork sprint (qinggong ground-skimming dash), inspired by Wu Shan Wu Xing dynamic brushwork. Frame 1: low crouching push-off with ink burst underfoot as torso leans sharply 38 degrees forward and both arms whip backward. Frames 2-5: ultra-fast grounded gliding sprint with feet skimming directly along the floor plane, upper body pitched 38 degrees forward in a sleek aerodynamic wuxia dash pose, BOTH ARMS SWEPT GRACEFULLY BACKWARD behind his torso—right hand reverse-gripping the fractured bronze chisel blade trailing behind with the blade tip dragging along the floor, left arm extended backward like a crane wing for balance—tattered charcoal wuxia coat and long hair streaming horizontally straight back into dry-brush feibai ink streaks, symmetrical V-shaped ink wind wakes kicking out from his feet. Frame 6: low wuxia bow-stance braking slide with left hand bringing sword mudra forward. Crisp ink edges, no cast shadows, no text --ar 21:9 --v 6.1 --style raw
```

### 6. 武侠破宣斩三连击（Wuxia 3-Hit Sword Combo · 8 Keyframes）
```text
2D game character animation sprite sheet, 8 sequential horizontal keyframes from left to right showing a fluid Chinese wuxia 3-hit sword combo, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing painterly brushwork. Male ink swordsman Mo Hen wielding a fractured bronze chisel blade. Frame 1: coiled hip-twist wind-up with left hand in sword mudra; Frame 2-3: forward bow-stance (gongbu) horizontal sweep leaving a jagged white paper-tear crescent smear with curled mulberry paper edges and black ink droplets; Frame 4-5: empty-stance upward 45-degree diagonal lift slash with triple dry-brush feibai streaks; Frame 6: mid-air somersault apex holding blade overhead with both hands; Frame 7: heavy vertical downward cleave slamming the ground; Frame 8: low one-knee grounded recovery with flowing wuxia coat. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 7. 千斤坠下劈与钻缝无敌墨线滑行（Aerial Pogo & Rift Grind · 7 Keyframes）
```text
2D game character animation sprite sheet, 7 sequential horizontal keyframes from left to right showing a wuxia aerial downward stab into a cursive ink rift dash, wide cell spacing, slight 15-degree high-angle top-down perspective, Wu Shan Wu Xing ink style. Male ink swordsman Mo Hen. Frame 1-2: mid-air vertical downward stab with fractured bronze chisel (left hand pointing sword mudra upward), blooming a 0.25mm black line-art white lotus seal beneath the blade tip; Frame 3: graceful dragonfly-skimming rebounding flip; Frame 4: diving headfirst with arms swept back into a glowing white paper rift tear; Frame 5: body completely dissolved into a razor-sharp horizontal Huaisu cursive ink stroke with white paper butterflies; Frame 6-7: reforming from ink into a low wuxia bow-stance backstab lunge pose. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 8. 云手折纸绞杀与凌空撕纸弹弓（Spatial Fold & Aerial Tear Slingshot · 6 Keyframes）
```text
2D game character animation sprite sheet, 6 sequential horizontal keyframes from left to right showing wuxia spatial folding and paper-tearing skills, wide cell spacing, slight 15-degree high-angle top-down perspective, Wu Shan Wu Xing ink-wash style. Male ink martial artist Mo Hen. Frame 1: wide horse stance executing Tai Chi cloud-hands gesture gripping glowing gold-and-white spatial crack lines; Frame 2-3: violent inward two-handed clasping gesture collapsing space toward his dantian with swirling ink vortex lines; Frame 4: mid-air tearing open a glowing crescent white paper slit; Frame 5: leaning back pulling the curled paper edge like a taut bowstring; Frame 6: launching forward like an ink arrow trailing three dry-brush feibai trails. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 9. 金石格挡、居合撕甲与错身抽纸处决（Parry, Armor Peel & Rip-Out Finisher · 7 Keyframes）
```text
2D game character animation sprite sheet, 7 sequential horizontal keyframes from left to right, wide cell spacing, slight 15-degree high-angle top-down perspective, Wu Shan Wu Xing style. Male ink swordsman Mo Hen. Frame 1: low bow-stance defensive cross-guard with left palm bracing the back of the fractured bronze chisel; Frame 2: impact parry with explosive cinnabar-gold sparks and concentric white calligraphy ring; Frame 3: high-contrast black-and-white stone rubbing negative freeze silhouette; Frame 4: explosive iaido draw-slash peeling off a sheet of black ink armor with curled paper edges; Frame 5-6: phantom wuxia step-through yanking a sheet of dark ink silhouette backward, shattering it into white paper butterflies; Frame 7: dignified one-handed behind-back wuxia standing pose. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 10. Boss 两段式终局处决全套（Page Curl, Cursive Slashes & Heart Pierce · 7 Keyframes）
```text
2D game character animation sprite sheet, 7 sequential horizontal keyframes from left to right showing a climactic two-stage boss finisher, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing ink-wash style. Male ink swordsman Mo Hen. Frame 1-2: kneeling and plunging fractured bronze chisel into the ground, heaving upward with both hands to curl a massive sheet of dark ink canvas into a scroll; Frame 3-4: weightless mid-air qinggong cursive calligraphy slash poses, body transforming into flying ink strokes; Frame 5: feather-light landing in a dignified, solemn wuxia stance; Frame 6: steady bow-stance two-handed forward thrust piercing an invisible core with high-contrast black-and-white stone rubbing negative flash; Frame 7: slow blade withdrawal amidst floating white paper butterflies. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

---

# 第四部分：敌对生态（杂兵、精英、四大主宰）移动动作设计与全序列 Prompt 库

在 `2.5D` 微俯视视角（`Pitch = -15^\circ$`）下，敌对势力的移动绝非僵硬的“纸片平移”，必须通过**步态重心起伏、兵器拖地物理反馈与衣摆延迟跟随**，外化“被执笔阁规矩异化的纸偶傀儡”或“武林宗师”的独特质感。

## 4.1 四大章杂兵（Mobs）移动动作设计（木偶顿挫与负重感）

杂兵核心特征为**“受丝线或重物束缚的提线木偶感”**，单格画布统一锁定 **`$320 \times 320\ \text{px}$`**（`Bottom-Center` 锚点 `(160, 320)`）：

| 敌方名称 | 待机循环（Idle · 4 帧 / `$800\ \text{ms}$`） | 巡逻移动（Patrol · 6 帧 / `$1.5\ \text{m/s}$`） | 警戒追击（Chase · 6 帧 / `$3.8\ \text{m/s}$`） |
| :--- | :--- | :--- | :--- |
| **序章 · 盲眼巡卒** | 头部僵硬地左右微偏（模拟听声辨位），肩部木质榫卯随呼吸上下顿挫 `$2\ \text{px}$`，生铁戒尺垂直杵地。 | **【拖尺木偶步】**：单膝僵直迈步，手持的生铁戒尺斜拖在身后，尺尖在 `$3.2\ \text{m}$` 台面顶面划出断续焦墨细痕。 | **【前倾急趋步】**：上身前倾 `$30^\circ$`，戒尺横抱于胸前，双腿高频小步碎跑，额前血麻布条向后水平飘飞。 |
| **第一章 · 巡水工偶** | 佝偻驼背，双手拄着丈二三棱浚河长钩微微喘息，肩头石绿矿痂渗出粘稠水滴。 | **【涉水拔泥步】**：每迈一步双脚都有明显的“拔出淤泥”停顿感，长钩随步幅一前一后点地支撑身体。 | **【扛钩冲锋步】**：右手单臂平端长钩夹于肋下，左臂大幅摆动，迈大步趟水狂奔，脚踝带起石青水花。 |
| **第二章 · 守碑阴傀** | 背负两块黑色残碑重心压低，双膝微曲半蹲，手中生铁短錾垂地轻晃。 | **【负碑重踏步】**：如背负千钧重石般左右摇晃前进，每一步落脚都伴随头肩下沉，短錾尖端刮起干燥飞白沙尘。 | **【暴走掠地步】**：四肢近乎贴地伏低，利用残碑惯性向前猛冲，风化焦墨碎屑从背甲缝隙向后喷洒。 |
| **终章 · 去色司祝** | 双手合十垂眸，僧袍被铅白矿浆凝固如硬纸钟罩，仅袍底边缘有极微弱的浮尘流动。 | **【僵直仪仗滑步】**：双足隐藏在硬质僧袍下几乎不抬起，整个人如木雕神像般匀速诡异滑行，刮霜铅拂横架胸前。 | **【凌空掠影疾飘】**：身躯微倾悬浮离地 `$0.10\ \text{m}$`，铅拂拖于身后，以无声鬼魅般的直线高速逼近主角。 |

## 4.2 四大章精英（Elites）移动动作设计（仪仗威压与武学架势）

精英怪强调**“不可撼动的重器压迫感与阵法走位”**，单格画布统一锁定 **`$448 \times 384\ \text{px}$`**（`Bottom-Center` 锚点 `(224, 384)`）：

* **序章 · 镇峰狱尉（玄武岩重盾步）**：
  * **待机（`4` 帧）**：双足分开略宽于肩，右手将两米方圆生铁大盾死死敦在身前地面，青铜狴犴盔下眼眶暗红地火明灭。
  * **移动（`6` 帧 / `$2.2\ \text{m/s}$`）**：**【侧身横推蟹步】**——始终保持大盾正面朝向主角，前脚踏出半步、后脚沉稳跟进拖步，每一步落定都伴随盾底与石板碰撞的沉闷金石震动，绝不轻易转身露出后背。
* **第一章 · 伏波画督（提线悬偶仪仗步）**：
  * **待机（`4` 帧）**：四扇紫檀泥金画屏在身前呈半扇形展开微幅呼吸开合，头顶隐约可见数根垂入虚空的发黑悬丝。
  * **移动（`6` 帧 / `$2.6\ \text{m/s}$`）**：**【提线顿挫官步】**——迈步时身体先被无形悬丝向上轻轻“提”起 `$0.08\ \text{m}$`，随后迈步落下，官袍下摆与四扇画屏同步呈波浪状律动，兼具官僚仪仗与提线木偶的诡异美感。
* **第二章 · 司弦刑官（踏弦螳螂掠步）**：
  * **待机（`4` 帧）**：身形瘦长微弓如蓄势螳螂，十指虚扣在怀中【断头瑟刃】的猩红琴弦上，周身缠绕的倒钩琴弦随风高频微颤。
  * **移动（`8` 帧 / `$4.8\ \text{m/s}$`）**：**【踏弦鬼魅折线步】**——脚尖轻点地面如踩无形琴弦，不走直线，而是以极快的弹性跳跃滑步忽前忽后拉扯距离，随时准备挑弦释放音波刃。
* **终章 · 平规衡司（神明悬空平移）**：
  * **待机（`4` 帧）**：汉白玉四面佛神像离地悬浮 `$0.20\ \text{m}$`，背后纯金戒尺法环缓缓逆时针自转，右手黄金天平左右托盘微幅上下平衡摆动。
  * **移动（`6` 帧 / `$3.0\ \text{m/s}$`）**：**【绝对水平御空平移】**——神像躯干保持绝对垂直、零上下颠簸的机械神性平移，唯有加速起步与急停刹车的瞬间，黄金天平两端托盘会因惯性产生剧烈的倾斜晃动。

## 4.3 四大关底主宰（Bosses）专属武侠移动身法

四大 Boss 均拥有独特的武学移动体态，且随阶段切换产生显著的视觉演变（单格画布锁定 **`$512 \times 448\ \text{px}$`**，`Bottom-Center` 锚点 `(256, 448)`）：

1. **序章 · 先锋镇将【墨梅】**：
   * **一阶段（冷峻剑客滑步 · `6` 帧）**：右手反持两丈生铁细软剑斜指地面，左手背负腰后，身躯微侧，采用**前脚滑行、后脚点地随行**的传统冷傲剑客步法逼近（周身六朵朱砂血梅由独立程序组件随步幅缓缓公转）。
   * **二阶段（焦墨梅枝疾掠 · `6` 帧）**：身披万劫焦墨老梅披风，移动变为**低空贴地掠行瞬步**——身形压低几乎融入黑墨浪潮中高速突进，披风化作无数狂草黑枝在身后翻涌，急停瞬间黑枝炸开成梅林姿态。
   * **三阶段（白描真身踉跄 · `4` 帧）**：重甲尽褪后仅剩单线白描剑仙真身，半跪单手撑剑喘息，不再主动攻击，仅在主角靠近时微抬首迎视。
2. **第一章 · 画院督监【墨竹】**：
   * **一阶段（破浪长枪弓步 · `6` 帧）**：右手单持丈八狼牙竹枪拖于身后，左手提巨型斗笔，迈大开大合的武侠弓箭步大步流星逼近，枪尖在石青水面拖出一道长长的白描裂浪。
   * **二阶段（踏浪乘风疾行 · `6` 帧）**：在 `$14.0\ \text{m/s}$` 极速跑打中，墨竹单足轻点浮木或白描应龙龙脊，衣袂翻飞如鹤，长枪平端指前随波浪起伏高速滑行。
3. **第二章 · 司碑宗师【墨骨】**：
   * **一阶段（负手拓碑沉步 · `6` 帧）**：高大枯骨身躯挺拔如碑，双手负于身后或单手拖曳破山铁錾，迈步沉稳缓慢，每一步都在地面留下焦墨碑文脚印。
   * **二阶段（四翼凌空滑翔 · `8` 帧）**：古坛崩碎进入纯空战后，背后四扇倒插墓碑风化石翼展开，墨骨在半空中呈**双臂微张的浮空御风姿态**滑翔变向，破烂袍袖随气流剧烈鼓荡。
4. **终章 · 大阁尊【顾狂墨】**：
   * **一阶段（神明垂拱悬浮 · `4` 帧）**：足踏汉白玉莲台离地悬浮，双手垂拱于腹前，神袍纹丝不动，由千手戒尺法环推动在神坛上空庄严平移。
   * **二阶段（狂草癫狂疾掠 · `6` 帧）**：神袍撕裂后如疯癫草书大家，俯身拖曳五丈万劫枯笔，在 `$95\%$` 死白风暴中以不规则的狂草折线高速疾掠冲刺。
   * **三阶段（枯槁老翁微颤 · `4` 帧）**：回归白描粗布老翁真容后，瘫坐于素宣地面，胸口五彩火种微弱跳动，仅以慈悲平静的目光注视走近的主角。

## 4.4 敌对生态序列帧（Sprite-Sheet）AI 生图 Prompt 库

为防止分次生图导致角色比例与墨色深浅不一致，移动类序列帧统一采用**“单行 `8` 帧一体化合并表（前 `4` 帧为待机呼吸循环，后 `4` 帧为标志性移动循环）”**标准，锁死 **`$15^\circ$` 微俯视角**与**中性浅灰底（`#E0E0E0`）**：

### 11. 序章杂兵：【盲眼巡卒】待机 + 拖尺木偶步（8 帧一体化表）
```text
2D game enemy sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. A corrupted Song Dynasty paper-puppet patrol guard wrapped in blood-stained hemp blindfolds with Chinese calligraphy, wearing thick axe-cut charred-ink iron shoulder armor and holding a heavy blunt iron ruler. Frames 1-4 (Idle loop): stiff marionette breathing, head tilting slightly side to side, iron ruler resting vertically on the ground. Frames 5-8 (Patrol walk loop): jerky wooden-joint marching steps with knees stiff, dragging the heavy iron ruler behind on the floor leaving faint ink scratches. Wu Shan Wu Xing painterly ink texture mixed with 0.25mm baimiao inner joints, clean silhouette, no cast shadows, no text, no UI --ar 21:9 --v 6.1 --style raw
```

### 12. 第一章杂兵：【巡水工偶】待机 + 涉水拔泥步（8 帧一体化表）
```text
2D game enemy sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. A hunched Song Dynasty river-dredging laborer puppet encrusted with malachite-green (#1F4E3F) and azurite-blue (#16355C) mineral crusts, wearing mud-gold anti-toxin goggles and holding a long three-edged cast-iron dredging hook. Frames 1-4 (Idle loop): hunched heavy breathing leaning on the vertical iron hook, dripping thick green mineral sludge. Frames 5-8 (Wading walk loop): labored heavy steps pulling feet out of thick river mud, using the iron hook as a walking staff with splashing blue-green droplets. Wu Shan Wu Xing painterly brushwork with 0.25mm baimiao skeleton underneath, clean silhouette, no cast shadows, no text --ar 21:9 --v 6.1 --style raw
```

### 13. 第二章杂兵：【守碑阴傀】待机 + 负碑重踏步（8 帧一体化表）
```text
2D game enemy sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. A heavily burdened tomb-guarding shade puppet carrying two cracked black stone tombstone slabs strapped to its back and chest with weathered charred-ink bark armor, holding a heavy iron stone-carving chisel. Frames 1-4 (Idle loop): low crouched stance swaying slightly under the immense weight of the stone tablets. Frames 5-8 (Heavy burdened walk loop): slow lumbering side-to-side stomping steps with shoulders dipping on each footfall, dragging the iron chisel across dry sand. Dry-brush feibai ink texture, clean silhouette, no cast shadows, no text --ar 21:9 --v 6.1 --style raw
```

### 14. 终章杂兵：【去色司祝】待机 + 僵直仪仗滑步（8 帧一体化表）
```text
2D game enemy sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. A sterile acolyte puppet wearing stiffened lead-white (#F8F8F8) mineral-coated monastic robes, an expressionless white jade mask, holding a white horsehair duster coated in lead powder. Frames 1-4 (Idle loop): motionless statue-like posture with hands clasped and subtle white frost dust drifting from robe hems. Frames 5-8 (Eerie ritual glide walk): gliding smoothly forward like a rigid wooden idol with feet hidden beneath stiff robes and duster held horizontally across the chest. Desaturated monochrome with subtle mud-gold trim, clean silhouette, no cast shadows, no text --ar 21:9 --v 6.1 --style raw
```

### 15. 序章精英：【镇峰狱尉】威压待机 + 重盾横推步（8 帧一体化表）
```text
2D game elite boss sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. Towering heavy-armored warden in a bronze beast helmet and basalt axe-cut ink plate armor, wielding a massive two-meter rectangular cast-iron shield decorated with mud-gold (#D4A017) and azurite mineral patterns. Frames 1-4 (Idle loop): planting the giant shield firmly into the ground, chest heaving heavily with dark ink vapor rising from armor cracks. Frames 5-8 (Shield advance walk loop): defensive side-facing crab-walk advance keeping the massive shield facing forward, heavy grounded steps kicking up small ink dust rings. Wu Shan Wu Xing bold brushwork, clean silhouette, no cast shadows, no text, no UI --ar 21:9 --v 6.1 --style raw
```

### 16. 序章精英：【镇峰狱尉】重甲受击、虚线撕甲与木偶崩解序列（6 帧战斗表）
```text
2D game elite enemy animation sprite sheet, 6 sequential horizontal keyframes from left to right, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing painterly ink style. Towering 9-foot Peak Warden in Li Tang axe-cut basalt armor carrying a massive hexagonal iron shield with mud-gold geometry. Frame 1: heavy shielded guard stance; Frame 2: glowing red-gold charging wind-up; Frame 3: high-speed bulldozing shield bash; Frame 4: shield and chest armor splitting cleanly along a glowing cinnabar dotted cut-line, peeling away like torn paper; Frame 5: vulnerable hunched 0.25mm baimiao line-art wooden mortise-and-tenon puppet skeleton kneeling with a pulsing red seal in its chest; Frame 6: dissolving into white paper butterflies. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 17. 序章主宰：【先锋镇将 · 墨梅】剑客待机 + 寒梅滑步（8 帧一体化表）
```text
2D game boss sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. Aristocratic Chinese wuxia swordsman boss Mo Mei in dark crimson and charred-ink Song Dynasty martial robes with gold-leaf trim, holding a long flexible cast-iron sword reverse-gripped. Frames 1-4 (Idle loop): cold composed wuxia stance, one hand behind his back, sword tip angled down toward the floor, robe hems swaying gently. Frames 5-8 (Wuxia gliding step loop): low-center-of-gravity martial arts gliding stride, leading foot sliding forward smoothly while trailing foot pushes off, ink-wash cloak billowing behind in dry-brush feibai streaks. Inspired by Wu Shan Wu Xing and Song Dynasty baimiao aesthetics, clean silhouette, no floating orbs, no cast shadows, no text, no UI --ar 21:9 --v 6.1 --style raw
```

### 18. 序章主宰：【先锋镇将 · 墨梅】三阶段完整武学与破甲序列（7 帧战斗表）
```text
2D game boss animation sprite sheet, 7 sequential horizontal keyframes from left to right, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing dynamic ink-wash style. Boss Mo Mei, graceful Song Dynasty swordsman in mud-gold robes with flexible iron rapier. Frame 1: poised Chinese fencer guard; Frame 2: lightning-fast horizontal lunge thrust with red warning glint; Frame 3: mid-air spinning tempest slash; Frame 4: Phase 2 transformation bursting with hundreds of wild charred-ink old plum branches forming a spiked thorn cloak; Frame 5: summoning thorny black brambles from the ground; Frame 6: outer charred-ink cloak tearing apart like peeled paper; Frame 7: Phase 3 kneeling pure Southern Song 0.25mm baimiao single line-art ethereal swordsman in simple white robes. Isolated on a flat solid neutral light grey (#E0E0E0) background, no floating orbs, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```

### 19. 第一章主宰：【画院督监 · 墨竹】破浪长枪弓步 + 踏浪乘风疾行（8 帧一体化表）
```text
2D game boss sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. Tall gaunt Song Dynasty scholar-general boss Mo Zhu wearing heavy bamboo plate armor crafted from deep malachite-green (#1F4E3F) and azurite-blue (#16355C) bamboo stalks with mud-gold trims, wielding a giant barbed iron bamboo lance in his right hand and a colossal calligraphy brush in his left. Frames 1-4 (Bow-stance march loop): sweeping wuxia bow-stance strides advancing steadily, trailing the bamboo lance tip behind. Frames 5-8 (Wave-surfing dash loop): agile one-footed wind-riding glide leaning forward with bamboo lance leveled ahead and ink-wash robes billowing like crane wings. Wu Shan Wu Xing painterly brushwork, clean silhouette, no cast shadows, no text --ar 21:9 --v 6.1 --style raw
```

### 20. 第二章主宰：【司碑宗师 · 墨骨】空战四翼悬浮滑翔（8 帧一体化表）
```text
2D game boss sprite sheet, 8 horizontal frames arranged left to right in a single row on a uniform neutral light-grey background (#E0E0E0), slight 15-degree high-angle top-down perspective, consistent character scale and bottom-center ground anchor. Tall gaunt skeletal ink-wash sorcerer boss Mo Gu wrapped in weathered black stone-rubbing robes with four massive wings made of cracked inverted tombstones spread behind him, wielding a heavy iron stone-carving chisel. Frames 1-4 (Aerial hover loop): floating mid-air with heavy stone wings beating slowly, tattered robes drifting downward. Frames 5-8 (Aerial glide dash loop): leaning forward horizontally in mid-air with four tombstone wings swept back, gliding rapidly through the air trailing dry-brush feibai ink wisps. Monochrome ink wash with subtle mud-gold accents, clean silhouette, no cast shadows, no text, no UI --ar 21:9 --v 6.1 --style raw
```

### 21. 终章大主宰：【大阁尊 · 顾狂墨】神明到殉道者全序列（7 帧全态表）
```text
2D game final boss animation sprite sheet, 7 sequential horizontal keyframes from left to right, wide cell spacing, slight high-angle top-down perspective (15-degree downward camera tilt), Wu Shan Wu Xing tragic ink style. Grand Master Gu Kuangmo. Frame 1: floating serene lead-white frost deity seated on a white jade lotus haloed by rotating golden compass rulers; Frame 2: majestic hand gesture launching golden ruler laser beams; Frame 3: Phase 2 frantic ink-madman with wild flying hair swinging a colossal dry brush in a blinding white blizzard; Frame 4: heavy downward brush slam; Frame 5: outer lead-white divine shell tearing open like cracked paper; Frame 6: Phase 3 frail weeping old calligrapher in 0.25mm baimiao robes kneeling on one knee, chest open revealing a glowing five-color mineral flame; Frame 7: peaceful smile dissolving into warm glowing paper feathers. Isolated on a flat solid neutral light grey (#E0E0E0) background, no cast shadows, 8k --ar 21:9 --v 6.1 --style raw
```