# 《Godot 4.x 仿〈艾希〉（ICEY）2.5D 立体舞台镜头与动态光雾系统工程落地全典》

> **【设计总则与技术愿景】**：
> 《艾希》（ICEY）令人惊艳的“横版动作精准判定 + 深邃立体戏剧舞台”，其工程本质在于**将所有物理碰撞死锁在绝对平面的 `$Z = 0$` 交互层，同时在 Godot 4 真 3D 空间（`Node3D` + `Sprite3D`）中，通过“长焦窄视场角（`FOV = $26^\circ \sim 28^\circ$`）微俯视 `Camera3D` + 纵深分布的 7 轨景片 + 逐材质动态光雾（`SpatialShader`） + 前景虚化剪影框定”**，构建出兼具硬核操作精度与舞台空间压迫感的 2.5D 视听体系。
> 本指南针对 **Godot 4.x（推荐 Godot 4.3+，Forward+ 管线）**，提供可直接投入《留白》全章开发的工业级镜头控制器与 3D `SpatialShader` 全套代码。

---

## 一、 核心光学原理与《ICEY》2.5D 舞台解构

```text
【Z轴深度】   Z = -180m       Z = -85m~-140m    Z = -22m~-45m     Z = 0.0m (锁定)     Z = +4.5m~+7.5m
【舞台层级】 [宣纸天幕] ---> [极远景天顶气象] -> [中远景巨构山峦] -> [主战斗与纵深地板] -> [极近景虚化框景]
【光学表现】  固定底板        高雾化/低对比      35%~60%空气透视    绝对锐利/泥金靶心     焦外模糊/纯暗剪影
```

### 1.1 《ICEY》式 2.5D 立体舞台的四大工程法则

1. **长焦窄视角 + 微俯角地面纵深（Narrow FOV & Visible Floor Depth）**：
   * 弃用纯 2D 正交纸片平视，启用 `Camera3D`（`Projection = Perspective`），将视场角锁死在 **`FOV = $26^\circ \sim 28^\circ$`**。窄视场角能大幅压缩屏幕边缘的透视畸变，保证角色跳跃落点与 `$Z = 0$` 碰撞体 `$1:1$` 精准对齐。
   * 摄像机沿 `$+Z$` 轴拉远至 **`Cam Z = $+22.0\ \text{m}$`**（配合全局 `Sprite3D.pixel_size = 0.01`，在 `$Z = 0$` 处垂直视野高度为 `$2 \times 22 \times \tan(14^\circ) \approx 10.97\ \text{m}$`，与 `$1080\text{p}$` 屏幕实现像素级 `$1:1$` 对应），同时机位抬高 `Offset Y = $+2.2\ \text{m}$` 并向下微俯 **`Pitch = $-6.5^\circ$`**。此时横跨 `XZ` 平面铺设的地板贴图（进深 `$3.5\ \text{m} \sim 5.0\ \text{m}$`）会自然呈现出《ICEY》标志性的“立体走廊地面纵深”。
2. **落地 `$Y$` 轴舞台基准线吸附（Grounded Y-Snapping）**：
   * 在微俯视视角下，若镜头随角色每次小跳或空中下劈（Pogo）上下晃动，会导致地面的透视倾角频繁抖动。
   * **工程铁律**：设定空中高度容差阈值 `$2.5\ \text{m}$`；角色起跳高度在阈值内时，镜头 `$Y$` 轴锚定起跳前的地面基准线，落地瞬间用 `$0.25\ \text{s}$` 平滑吸附。
3. **三大核心立体渲染与“刮白”动态光雾联动（`SpatialShader`）**：
   * **空气透视色彩衰减**：中远景图层通过逐材质 `SpatialShader` 向章节主色调混合 `$30\% \sim 60\%$` 雾色；当角色挥刀“刮白”撕开表层浓墨时，撕裂遮罩内雾效在 `$0.15\ \text{s}$` 内瞬降为 `$< 5\%$` 的温润古宣漫射天光。
   * **动态前景暗影框定**：在 `$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$` 布置虚化暗部剪影，冲刺时 `Cam Z` 瞬退 `$+1.8\ \text{m}$` 放大掠屏速度感；“刮白”撕裂窗口内前景剪影同步水墨消融解除遮挡。
   * **跨层体积光束**：在 `$Z = -1.5\ \text{m} \sim -2.5\ \text{m}$` 穿插 `Blend Mode = Add` 的丁达尔光束，“刮白”时直接从画布裂缝迸射打亮里层安全机关。
4. **`$Z = 0$` 机制碰撞中心线校准**：
   * 所有悬浮机关（悬空墨桶、下沉浮桩、猩红琴弦、黄金戒尺）的立体纵深统一向 `$Z < 0$` 延伸，并在 `$Z = 0$` 前沿碰撞锋线上绘制高对比度引导线（泥金包边、猩红高光或冷白刃口），彻底消除微俯角下的落脚视差误判。

---

## 二、 7 轨 `$Z$` 轴空间分层矩阵表（Godot 4 `Node3D` + `Sprite3D`）

| 舞台轨道 | 节点容器命名 | `$Z$` 轴深度坐标 | `Alpha Cut` / 混合模式 | `Render Priority` | 视觉材质与着色规范 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Layer -2（极近景框景）** | `Foreground_Frame` | `$+4.5\ \text{m} \sim +7.5\ \text{m}$` | `Disabled` / `Mix` | `+10` | 5-Tap 轻量焦外模糊 + 逆光纯暗剪影（铁链/垂柳/断碑/流苏），遮挡四角 `$12\% \sim 20\%$`；刮白区内水墨消融。 |
| **Layer -1（近景微粒）** | `Foreground_Particles` | `$+1.5\ \text{m} \sim +3.0\ \text{m}$` | `Disabled` / `Mix` 或 `Add` | `+6` | `GPUParticles3D` 动态拉丝（朱砂雨丝、石青水沫、飞白炭屑、铅白毒粉）。 |
| **Layer 0（主战斗舞台）** | `Gameplay_Plane` | **`$0.0\ \text{m}$`（绝对锁定）** | **`Discard`（写入深度）** | `0` | 角色、敌人、`$Z = 0$` 碰撞体、横剖面台基，以及沿 `XZ` 平面平铺（`Rotation X = $-90^\circ$`）的立体纵深地板。 |
| **Layer +1（次近景布景）** | `NearBackground` | `$-4.0\ \text{m} \sim -9.0\ \text{m}$` | **`Discard`（写入深度）** | `-2` | 剧场左右大幕（生铁重闸/泥金屏风/华表）、刑架、界桩；穿插 `$Z = -2.0\ \text{m}$` `Add` 体积光束（`Priority = +2`）。 |
| **Layer +2（中远景长卷）** | `MidBackground` | `$-22.0\ \text{m} \sim -45.0\ \text{m}$` | **`Discard`（写入深度）** | `-5` | 大斧劈皴绝壁、青绿峰峦、倒插碑林、千手戒尺法环；逐材质 Shader 混合 `$35\% \sim 50\%$` 章节暗雾。 |
| **Layer +3（极远景天象）** | `FarBackground` | `$-85.0\ \text{m} \sim -140.0\ \text{m}$` | `Disabled` / `Mix` | `-8` | 残阳墨云、暴雨长瀑、死霜虚空；逐材质 Shader 混合 `$50\% \sim 60\%$` 空气透视雾色。 |
| **Layer +4（宣纸胎体天幕）** | `XuanPaper_Backdrop` | `$-180.0\ \text{m}$` | `Opaque`（不透明底板） | `-12` | 4K 巨幅古宣纸帘纹底板（桑皮生宣/温州蠲纸/硬黄纸/澄心堂宣），随摄像机 `$X$` 轴 `$1:1$` 缓慢微动。 |

---

## 三、 3D 场景节点树搭建结构规范（`StageRoot.tscn`）

在主关卡场景中，采用**双 `SubViewport` 同矩阵透视合成**架构，实现表层实景与里层白描底稿在任意微俯视角下的 `$1:1$` 空间咬合：

```text
StageRoot (Node3D)
├── DualViewport_Compositor (CanvasLayer, layer = -1) # 合成 TopInk 与 Baimiao 两张 SubViewport 纹理
│   ├── TopInk_Viewport (SubViewport)                 # 渲染表层浓墨实景 3D 节点
│   │   └── SyncCamera_Top (Camera3D)                 # 每帧同步主 StageCamera3D 的变换矩阵与 FOV
│   └── Baimiao_Viewport (SubViewport)                # 渲染里层白描底稿 3D 节点
│       └── SyncCamera_Draft (Camera3D)               # 每帧同步主 StageCamera3D 的变换矩阵与 FOV
│
├── StageCamera (Camera3D)                            # 挂载 stage_camera_3d.gd (FOV=28, Far=300m)
├── StageSpotlight (SpotLight3D)                      # 精英/BOSS 剧场决斗中央追光灯
│
├── Foreground_Frame (Node3D)                         # Z = +4.5m ~ +7.5m (挂载 foreground_dof_3d.gdshader)
├── Gameplay_Plane (Node3D)                           # Z = 0.0m 物理交互主平面
│   ├── LevelGeometry (Node3D)
│   │   ├── GroundCollider (StaticBody3D + BoxShape3D)
│   │   ├── FloorDepthSprite (Sprite3D, Rotation X = -90, pixel_size = 0.01) # 2.5D 立体地面纵深
│   │   └── CutawayBaseSprite (Sprite3D, Z = 0.0m, pixel_size = 0.01)        # 地面下方横剖面台基
│   ├── Player (CharacterBody3D)                      # Axis Lock: Linear Z, Angular X/Y/Z
│   └── Enemies (Node3D)
│
├── NearBackground (Node3D)                           # Z = -4.0m ~ -9.0m
├── VolumetricGodRays (Node3D)                        # Z = -2.0m (Blend Mode = Add, Render Priority = +2)
├── MidBackground (Node3D)                            # Z = -22m ~ -45m (挂载 stage_sprite_3d.gdshader)
├── FarBackground (Node3D)                            # Z = -85m ~ -140m (挂载 stage_sprite_3d.gdshader)
├── XuanPaper_Backdrop (Sprite3D)                     # Z = -180m 4K 古宣纸天幕
│
└── ScreenEffectsLayer (CanvasLayer, layer = 100)     # 全屏后处理：留白率暗角 / 拓片负片反相 / 2.39:1 电影黑边
```

---

## 四、 核心代码实现：《ICEY》式 2.5D 舞台摄像机（`StageCamera3D.gd`）

在 `StageCamera` 节点上挂载以下生产级脚本。该脚本完整实现了：
1. **朝向前瞻预判（Look-Ahead）与冲刺 `$Z$` 轴拉远张力（Dash Z-Pullback）**；
2. **落地 `$Y$` 轴舞台基准线吸附（Grounded Y-Snapping）**，防止小跳或空中下劈时地面微俯角晃动；
3. **下探视野与俯角联动（Downward Pitch Bias）**，长按向下键时自动加大俯角暴露深渊落点；
4. **基于创伤平方律（Trauma Squared）的 Simplex Noise 无漂移震屏**，以及处决电影瞬切接口。

```gdscript
class_name StageCamera3D
extends Camera3D

## 《留白》×《ICEY》真 3D 空间 2.5D 舞台摄像机控制器

@export_group("Stage Optical Baseline")
@export var target: Node3D
@export var base_fov: float = 28.0
@export var base_offset: Vector3 = Vector3(0.0, 2.2, 22.0) # Z=22m 配合 FOV=28° 实现 1080p 1:1 像素对齐
@export var base_pitch_deg: float = -6.5                   # 微俯角，展现 XZ 平面地板纵深

@export_group("Tracking & Grounded Y-Snapping")
@export var follow_damping: Vector2 = Vector2(8.0, 6.0)
@export var look_ahead_x: float = 2.4
@export var look_ahead_smooth: float = 4.5
@export var grounded_y_tolerance: float = 2.5              # 空中高度变化小于 2.5m 时锁死地面基准线

@export_group("Action Dynamics & Pitch Bias")
@export var dash_z_pullback: float = 1.8                   # 冲刺时沿 +Z 后退距离，放大前景剪影掠屏张力
@export var down_look_offset_y: float = -1.8               # 长按向下键时的视野下探偏移
@export var down_look_pitch_delta: float = -2.0            # 长按向下键时额外下压 2° 俯角看清深渊

@export_group("Trauma Screen Shake")
@export var max_shake_offset: Vector2 = Vector2(0.24, 0.18)
@export var max_shake_roll_deg: float = 1.8
@export var trauma_decay: float = 2.8

var _current_look_ahead: float = 0.0
var _anchor_ground_y: float = 0.0
var _down_hold_time: float = 0.0
var _trauma: float = 0.0
var _is_override_locked: bool = false
var _shake_noise: FastNoiseLite

func _ready() -> void:
	projection = PROJECTION_PERSPECTIVE
	fov = base_fov
	far = 300.0 # 确保 Z = -180m 的宣纸天幕不被远裁剪面裁切
	
	_shake_noise = FastNoiseLite.new()
	_shake_noise.seed = randi()
	_shake_noise.frequency = 0.08
	_shake_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	
	if is_instance_valid(target):
		_anchor_ground_y = target.global_position.y
		global_position = target.global_position + base_offset
	rotation_degrees.x = base_pitch_deg

func _physics_process(delta: float) -> void:
	if _is_override_locked or not is_instance_valid(target):
		_apply_trauma_shake(delta)
		return

	_update_camera_framing(delta)
	_apply_trauma_shake(delta)

func _update_camera_framing(delta: float) -> void:
	# 1. 朝向前瞻计算
	var facing: float = target.get("facing_dir") if target.get("facing_dir") != null else 1.0
	_current_look_ahead = lerpf(_current_look_ahead, facing * look_ahead_x, look_ahead_smooth * delta)

	# 2. 落地 Y 轴舞台基准线吸附（防高频小跳/下劈眩晕）
	var on_floor: bool = target is CharacterBody3D and target.is_on_floor()
	var height_diff: float = target.global_position.y - _anchor_ground_y
	if on_floor or absf(height_diff) > grounded_y_tolerance:
		_anchor_ground_y = lerpf(_anchor_ground_y, target.global_position.y, 10.0 * delta)

	# 3. 长按向下键触发下探视野与俯角联动
	if Input.is_action_pressed("move_down") and on_floor:
		_down_hold_time += delta
	else:
		_down_hold_time = 0.0
	var is_looking_down: bool = _down_hold_time >= 0.30
	var extra_y: float = down_look_offset_y if is_looking_down else 0.0
	var target_pitch: float = base_pitch_deg + (down_look_pitch_delta if is_looking_down else 0.0)

	# 4. 冲刺状态动态 Z 轴后退（增强前景掠屏速度感）
	var is_dashing: bool = target.get("is_dashing") == true
	var target_z: float = base_offset.z + (dash_z_pullback if is_dashing else 0.0)

	# 5. 平滑追踪目标位置与俯角
	var desired_x: float = target.global_position.x + base_offset.x + _current_look_ahead
	var desired_y: float = _anchor_ground_y + base_offset.y + extra_y

	global_position.x = lerpf(global_position.x, desired_x, follow_damping.x * delta)
	global_position.y = lerpf(global_position.y, desired_y, follow_damping.y * delta)
	global_position.z = lerpf(global_position.z, target_z, 6.0 * delta)
	rotation_degrees.x = lerpf(rotation_degrees.x, target_pitch, 6.0 * delta)
	fov = lerpf(fov, base_fov, 8.0 * delta)

## 创伤平方律震屏（通过局部 h_offset/v_offset 施加，绝不污染世界坐标）
func _apply_trauma_shake(delta: float) -> void:
	if _trauma <= 0.001:
		h_offset = 0.0
		v_offset = 0.0
		rotation_degrees.z = 0.0
		return

	var shake_power: float = _trauma * _trauma
	var ticks: float = float(Time.get_ticks_msec())

	h_offset = _shake_noise.get_noise_2d(ticks, 10.0) * max_shake_offset.x * shake_power
	v_offset = _shake_noise.get_noise_2d(ticks, 20.0) * max_shake_offset.y * shake_power
	rotation_degrees.z = _shake_noise.get_noise_2d(ticks, 30.0) * max_shake_roll_deg * shake_power

	_trauma = maxf(0.0, _trauma - trauma_decay * delta)

## 外部接口：增加震屏创伤度 [0.0, 1.0]
func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)

## 外部接口：四大主宰题跋处决无插值电影瞬切（P4 最高优先级）
func trigger_execution_cut(focus_world_pos: Vector3, cut_z: float = 12.2, cut_fov: float = 24.0) -> void:
	_is_override_locked = true
	fov = cut_fov
	rotation_degrees.x = -3.0
	global_position = Vector3(focus_world_pos.x, focus_world_pos.y + 0.8, cut_z)

func release_override() -> void:
	_is_override_locked = false
```

---

## 五、 3D 舞台动态光雾与景深 `SpatialShader` 全套实现

### 5.1 逐材质空气透视与“刮白”局部消雾 Shader（`stage_sprite_3d.gdshader`）
* **应用对象**：`Layer 0` 至 `Layer +3` 的所有场景 `Sprite3D`。
* **技术特性**：支持 Godot 4 `instance uniform`（所有景片共用同一份材质实现合批，互不打断 Draw Call），在表层状态下按 `$Z$` 轴深度混合 `$30\% \sim 60\%$` 章节暗雾；一旦进入“刮白/破宣斩”撕裂遮罩内，雾效浓度瞬间降至 `$< 5\%$` 的温润古宣天光。

```glsl
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D tear_mask_tex : hint_default_black, filter_linear; // 屏幕空间“刮白”撕裂遮罩
uniform vec4 chapter_fog_color : source_color = vec4(0.14, 0.08, 0.08, 1.0); // 章节主雾色
uniform vec4 xuan_light_tint : source_color = vec4(1.0, 0.98, 0.94, 1.0);   // 里层古宣漫射光色

// 使用 instance uniform 保证全场景 Sprite3D 共享材质并合批
instance uniform float fog_weight : hint_range(0.0, 1.0) = 0.45;
instance uniform float desaturation : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec4 tex = texture(albedo_tex, UV);
	if (tex.a < 0.05) {
		discard; // 强制写入深度缓冲，彻底杜绝微俯视下 Sprite3D 透明穿帮
	}

	// 1. 基础空气透视去饱和与雾色混合
	float luma = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 desat = mix(tex.rgb, vec3(luma), desaturation);
	vec3 top_ink_col = mix(desat, chapter_fog_color.rgb, fog_weight);

	// 2. 采样屏幕空间“刮白”撕裂遮罩：裂缝内部雾效瞬降为 < 5% 温润古宣天光
	float tear_factor = texture(tear_mask_tex, SCREEN_UV).r;
	vec3 draft_col = mix(tex.rgb * xuan_light_tint.rgb, chapter_fog_color.rgb, fog_weight * 0.08);

	ALBEDO = mix(top_ink_col, draft_col, tear_factor);
	ALPHA = tex.a;
}
```

### 5.2 前景焦外模糊与“破幕水墨消融” Shader（`foreground_dof_3d.gdshader`）
* **应用对象**：`Layer -2`（`$Z = +4.5\ \text{m} \sim +7.5\ \text{m}$`）的极近景框景 `Sprite3D`（铁链、垂柳、断碑、流苏）。
* **技术特性**：5-Tap 轻量焦外模糊 + 逆光纯暗剪影；在“刮白”撕裂区域内自动执行水墨消融，解除前景遮挡对里层机关跳跃的视觉干扰。

```glsl
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D tear_mask_tex : hint_default_black, filter_linear;
uniform float blur_amount : hint_range(0.0, 4.0) = 2.2;
uniform vec4 silhouette_color : source_color = vec4(0.04, 0.035, 0.035, 1.0);
uniform float silhouette_mix : hint_range(0.0, 1.0) = 0.88;

void fragment() {
	vec2 ps = (1.0 / vec2(textureSize(albedo_tex, 0))) * blur_amount;

	// 5-Tap 轻量十字采样模拟大光圈焦外 Bokeh
	vec4 col = texture(albedo_tex, UV) * 0.4;
	col += texture(albedo_tex, UV + vec2(ps.x, 0.0)) * 0.15;
	col += texture(albedo_tex, UV - vec2(ps.x, 0.0)) * 0.15;
	col += texture(albedo_tex, UV + vec2(0.0, ps.y)) * 0.15;
	col += texture(albedo_tex, UV - vec2(0.0, ps.y)) * 0.15;

	vec3 final_rgb = mix(col.rgb, silhouette_color.rgb, silhouette_mix);

	// 刮白撕裂窗口内水墨消融，解除前景框景遮挡
	float tear_factor = texture(tear_mask_tex, SCREEN_UV).r;
	float dissolved_alpha = col.a * (1.0 - tear_factor * 0.85);

	ALBEDO = final_rgb;
	ALPHA = dissolved_alpha;
}
```

### 5.3 《ICEY》冲刺径向速度线 Shader（`dash_speed_lines.gdshader`）
* **应用对象**：顶层 `ScreenEffectsLayer`（`CanvasLayer`）下的满屏 `ColorRect`。

```glsl
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float dash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform int samples = 6;
uniform float falloff_radius : hint_range(0.1, 1.0) = 0.35;

void fragment() {
	if (dash_intensity <= 0.001) {
		COLOR = texture(screen_texture, SCREEN_UV);
		return;
	}

	vec2 center = vec2(0.5, 0.5);
	vec2 uv_offset = SCREEN_UV - center;
	float dist = length(uv_offset);
	float factor = smoothstep(falloff_radius, 1.0, dist) * dash_intensity * 0.045;

	vec4 accum = vec4(0.0);
	for (int i = 0; i < samples; i++) {
		float scale = 1.0 - factor * (float(i) / float(samples));
		accum += texture(screen_texture, center + uv_offset * scale);
	}
	COLOR = accum / float(samples);
}
```

---

## 六、 3D 舞台避坑与核显 `$60\ \text{FPS}$` 性能压测自检清单（DoD 检查项）

1. **彻底杜绝微俯视下 `Sprite3D` 透明层级闪烁与穿帮**：
   * **成因**：多张带半透明边缘的 `Sprite3D` 在微俯角下前后叠加时，引擎默认的透明物体质心排序容易在镜头移动时发生前后翻转；
   * **解决方案**：所有硬边缘景片（角色、地面、建筑立面）必须使用 `depth_prepass_alpha`（或检查器 `Alpha Cut = Discard`）强制写入深度缓冲；半透明光效（`Additive` 丁达尔光束）与前景框景严格按 `$Z$` 轴从远到近递增设置 `Render Priority`。
2. **消除 `InfiniteScroll3D` 长卷切片拼接黑线与远景闪烁**：
   * 在 Godot `Import` 面板中，手绘厚涂与水墨长卷贴图必须保留默认的 **`Linear Mipmap`**（禁用 `Nearest`，防止远景 `Sprite3D` 横移时产生锯齿闪烁），并将边缘采样设为 **`Clamp`**，同时贴图左右边缘保留 `$2\ \text{px}$` 同色延伸缓冲区。
3. **校准 `$Z = 0$` 机制碰撞中心线（防微俯视踩空）**：
   * 水平铺设于 `XZ` 平面（`Rotation X = $-90^\circ$`）的 2.5D 地板贴图，其 `$Z = 0$` 前沿承重石锋线必须与 `StaticBody3D` 碰撞盒顶面保持 `$1:1$` 像素重合；所有空中悬停跳板（墨桶、浮桩、琴弦、戒尺）必须在 `$Z = 0$` 轴线绘制高对比度靶心高光。
4. **核显 `$60\ \text{FPS}$` 性能保障（Draw Call 优化）**：
   * 全场景所有背景 `Sprite3D` 必须共用同一份 `ShaderMaterial` 资源，通过 `GeometryInstance3D` 的 **`Instance Shader Parameters`（`instance uniform`）** 独立调节每层的 `fog_weight` 与 `desaturation`，确保引擎自动合批，将 3D Draw Calls 稳定控制在 **`$\le 50$` 次**以内。