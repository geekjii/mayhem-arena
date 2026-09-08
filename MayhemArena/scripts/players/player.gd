extends Node2D

const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")

const P1_WEAPON_TEXTURES := {
	1: preload("res://assets/original_reference/players/p1_deagle.png"),
	2: preload("res://assets/original_reference/players/p1_dual.png"),
	3: preload("res://assets/original_reference/players/p1_revolver.png"),
	4: preload("res://assets/original_reference/players/p1_bling.png"),
	5: preload("res://assets/original_reference/players/p1_katana.png"),
}
const P2_WEAPON_TEXTURES := {
	1: preload("res://assets/original_reference/players/p2_deagle.png"),
	2: preload("res://assets/original_reference/players/p2_dual.png"),
	3: preload("res://assets/original_reference/players/p2_revolver.png"),
	4: preload("res://assets/original_reference/players/p2_bling.png"),
	5: preload("res://assets/original_reference/players/p2_katana.png"),
}
const P1_BASE_TEXTURE = preload("res://assets/original_reference/player_layers/base/p1.png")
const P2_BASE_TEXTURE = preload("res://assets/original_reference/player_layers/base/p2.png")

const WEAPON_VISUAL_NAMES := {
	1: "deagle",
	2: "dual",
	3: "revolver",
	4: "bling",
	5: "katana",
}
const WEAPON_VISUAL_RANGES := {
	1: {"primary": Vector2i(1, 11), "secondary": Vector2i(97, 126)},
	2: {"primary": Vector2i(1, 5), "secondary": Vector2i(60, 63)},
	3: {"primary": Vector2i(1, 16), "secondary": Vector2i(116, 141)},
	4: {"primary": Vector2i(1, 9), "secondary": Vector2i(97, 127)},
	5: {"primary": Vector2i(1, 25), "secondary": Vector2i(30, 49)},
}
const WEAPON_CANVAS_ORIGINS := {
	1: Vector2(-33.0, -49.0),
	2: Vector2(-23.0, -42.0),
	3: Vector2(-16.5, -45.5),
	4: Vector2(-16.0, -46.0),
	5: Vector2(-35.5, -77.5),
}
const DEFAULT_RELOAD_FRAMES := {1: 55, 2: 56, 3: 60, 4: 55}

var arena: Node
var player_index := 0
var display_name := "PLAYER"
var player_color := Color.WHITE
var spawn_position := Vector2.ZERO

var velocity := Vector2.ZERO
var facing := 1
var health := 100.0
var lives := 5
var eliminated := false
var jumps_remaining := 2
var drop_frames := 0
var stun_frames := 0
var hitstop_frames := 0

var default_weapon_id := 1
var weapon_id := 1
var ammo := 0
var primary_cooldown := 0
var secondary_cooldown := 0
var reload_frames := 0
var reload_total_frames := 45
var primary_was_pressed := false
var secondary_was_pressed := false
var katana_events: Array[Dictionary] = []
var hud: Node
var muzzle_flash_frames := 0
var weapon_kick_frames := 0
var visual_action := ""
var visual_frame := 0
var visual_frame_end := 0
var visual_action_active := false
var visual_frame_cache: Dictionary = {}
var walk_phase := 0.0
var body_visual_y := 0.0
var hand_visual_y := 0.0

const MOVE_ACCEL := 0.65
const FRICTION := 0.91
const GRAVITY := 0.9
const JUMP_POWER := 12.0
const MAX_FALL_SPEED := 20.0

func setup(game: Node, index: int, at_position: Vector2, color: Color, starting_weapon: int) -> void:
	arena = game
	player_index = index
	display_name = "PLAYER %d" % (index + 1)
	player_color = color
	spawn_position = at_position
	position = at_position
	default_weapon_id = starting_weapon
	set_weapon(starting_weapon)
	z_index = 10
	queue_redraw()

func action_name(suffix: String) -> String:
	return "p%d_%s" % [player_index + 1, suffix]

func weapon_name() -> String:
	return WeaponCatalog.weapon_name_for(weapon_id)

func set_weapon(new_weapon_id: int) -> void:
	equip_weapon(new_weapon_id, true)

func equip_weapon(new_weapon_id: int, make_default: bool = false) -> void:
	weapon_id = new_weapon_id if WeaponCatalog.is_valid_weapon(new_weapon_id) else 1
	if make_default:
		default_weapon_id = weapon_id
	var weapon := WeaponCatalog.get_weapon(weapon_id)
	ammo = int(weapon["ammo"])
	primary_cooldown = 0
	secondary_cooldown = 0
	reload_frames = 0
	katana_events.clear()
	visual_action_active = false
	precache_weapon_visuals(weapon_id)
	queue_redraw()

func attach_hud(new_hud: Node) -> void:
	hud = new_hud

func _physics_process(_delta: float) -> void:
	if eliminated or arena.match_over or not arena.round_started or arena.input_lock_frames > 0:
		return
	if hitstop_frames > 0:
		hitstop_frames -= 1
		return
	muzzle_flash_frames = maxi(0, muzzle_flash_frames - 1)
	weapon_kick_frames = maxi(0, weapon_kick_frames - 1)

	primary_cooldown = maxi(0, primary_cooldown - 1)
	secondary_cooldown = maxi(0, secondary_cooldown - 1)
	if drop_frames > 0:
		drop_frames -= 1
	if stun_frames > 0:
		stun_frames -= 1
		if stun_frames % 7 == 0:
			arena.spawn_stun_effect(position + Vector2(0, -40), velocity.x)

	if reload_frames > 0:
		reload_frames -= 1
		if weapon_id == default_weapon_id:
			arena.play_reload_frame_sound(weapon_id, reload_total_frames - reload_frames)
		if reload_frames == 0:
			if weapon_id != default_weapon_id:
				var empty_weapon_id := weapon_id
				equip_weapon(default_weapon_id, false)
				arena.on_pickup_weapon_empty(self, empty_weapon_id)
			else:
				ammo = int(WeaponCatalog.get_weapon(weapon_id)["ammo"])

	process_katana_events()
	process_visual_animation()
	process_weapons()
	process_movement()
	process_visual_motion()
	queue_redraw()

func process_visual_motion() -> void:
	var target_bob := 0.0
	if is_standing_on_platform():
		if absf(velocity.x) > 0.3:
			walk_phase += maxf(absf(velocity.x), 1.0) * 0.18
			target_bob = -absf(sin(walk_phase)) * 2.0
	else:
		target_bob = clampf(-velocity.y * 0.12, -2.2, 2.2)
	body_visual_y += (target_bob - body_visual_y) / 3.0
	hand_visual_y += (body_visual_y - hand_visual_y) / 8.0

func process_visual_animation() -> void:
	if not visual_action_active:
		return
	visual_frame += 1
	notify_weapon_visual_frame()
	if visual_frame > visual_frame_end:
		visual_action_active = false

func process_movement() -> void:
	var move_multiplier := 0.2 if stun_frames > 0 else 1.0
	var jump_multiplier := 0.4 if stun_frames > 0 else 1.0
	var left := Input.is_action_pressed(action_name("left"))
	var right := Input.is_action_pressed(action_name("right"))
	if right and not left:
		velocity.x += MOVE_ACCEL * move_multiplier
		facing = 1
	elif left and not right:
		velocity.x -= MOVE_ACCEL * move_multiplier
		facing = -1

	if Input.is_action_just_pressed(action_name("jump")) and jumps_remaining > 0:
		jumps_remaining -= 1
		velocity.y = -JUMP_POWER * (1.0 if jumps_remaining == 1 else 0.8) * jump_multiplier
		position.y -= 1.0

	if Input.is_action_just_pressed(action_name("down")) and is_standing_on_platform():
		drop_frames = 5
		velocity.y += 1.0
		position.y += 2.0
		jumps_remaining = 1

	velocity.x *= FRICTION
	if absf(velocity.x) < 0.3:
		velocity.x = 0.0
	velocity.y = minf(velocity.y + GRAVITY, MAX_FALL_SPEED)

	var previous := position
	position.x += velocity.x
	position.y += velocity.y
	if drop_frames <= 0 and velocity.y > 0.0:
		var landing_y: float = arena.find_landing_y(previous, position)
		if not is_nan(landing_y):
			var landing_speed := velocity.y
			position.y = landing_y
			velocity.y = 0.0
			jumps_remaining = 2
			if landing_speed > 2.0:
				arena.play_landing_sound()
				for particle in 5:
					arena.spawn_landing_dust(position + Vector2(0, 20))

	if position.y > 720.0:
		arena.play_fall_death_sound()
		lose_life()

func is_standing_on_platform() -> bool:
	for platform in arena.platforms:
		if position.x >= platform.position.x and position.x <= platform.end.x:
			if absf(position.y - platform.position.y) <= 2.5:
				return true
	return false

func process_weapons() -> void:
	var primary_pressed := Input.is_action_pressed(action_name("primary"))
	var secondary_pressed := Input.is_action_pressed(action_name("secondary"))
	var weapon := WeaponCatalog.get_weapon(weapon_id)
	var primary: Dictionary = weapon["primary"]
	var secondary: Dictionary = weapon["secondary"]

	var primary_trigger := primary_pressed
	if primary.get("semi_auto", false):
		primary_trigger = primary_pressed and not primary_was_pressed
	var secondary_trigger := secondary_pressed
	if secondary.get("semi_auto", false):
		secondary_trigger = secondary_pressed and not secondary_was_pressed

	if reload_frames == 0:
		if primary_trigger and primary_cooldown == 0:
			fire_attack(primary, false)
		if secondary_trigger and secondary_cooldown == 0:
			fire_attack(secondary, true)

	primary_was_pressed = primary_pressed
	secondary_was_pressed = secondary_pressed

func fire_attack(attack: Dictionary, secondary: bool) -> void:
	var attack_type := str(attack["type"])
	if attack_type != "katana_combo" and attack_type != "katana_uppercut" and attack_type != "make_it_rain":
		if ammo == 0:
			start_reload()
			return

	if secondary:
		secondary_cooldown = int(attack["cooldown"])
	else:
		primary_cooldown = int(attack["cooldown"])
	start_weapon_visual("secondary" if secondary else "primary")
	if attack_type in ["bullet", "pellet_burst", "rocket", "throw_gun"]:
		muzzle_flash_frames = 3
		weapon_kick_frames = 4

	match attack_type:
		"bullet":
			velocity.x -= float(attack["recoil"]) * facing
			arena.spawn_bullet(self, muzzle_position(), facing, attack)
			consume_ammo()
		"pellet_burst":
			velocity.x -= float(attack["recoil"]) * facing
			for pellet in int(attack["pellets"]):
				arena.spawn_bullet(self, muzzle_position(), facing, attack)
			consume_ammo()
		"rocket":
			velocity.x -= float(attack["recoil"]) * facing
			arena.spawn_rocket(self, muzzle_position(), facing, attack)
			consume_ammo()
		"throw_gun":
			arena.spawn_thrown_gun(self, muzzle_position(), facing, attack)
		"make_it_rain":
			take_damage(float(attack["self_damage"]), 0.0, 0, self)
			arena.spawn_money_effect(muzzle_position(), player_color)
		"katana_combo":
			katana_events = [{"frames": 0, "power": 12.0}, {"frames": 11, "power": 13.0}]
		"katana_uppercut":
			velocity.y = -9.0
			arena.melee_attack(self, 75.0, -80.0, 30.0, 20.0, 25.0, -10.0, 2)

func process_katana_events() -> void:
	for index in range(katana_events.size() - 1, -1, -1):
		katana_events[index]["frames"] = int(katana_events[index]["frames"]) - 1
		if int(katana_events[index]["frames"]) <= 0:
			var power := float(katana_events[index]["power"])
			arena.melee_attack(self, 65.0 if power == 12.0 else 75.0, -40.0, 30.0, 20.0, power, 0.0, 2)
			if power == 13.0:
				velocity.x += 6.0 * facing
			katana_events.remove_at(index)

func muzzle_position() -> Vector2:
	return position + Vector2(35.0 * facing, -20.0)

func consume_ammo() -> void:
	if ammo < 0:
		return
	ammo -= 1
	if ammo <= 0:
		start_reload()

func start_reload() -> void:
	if ammo < 0 or reload_frames > 0:
		return
	reload_total_frames = 12 if weapon_id != default_weapon_id else int(DEFAULT_RELOAD_FRAMES.get(weapon_id, 45))
	reload_frames = reload_total_frames

func take_damage(damage: float, horizontal_impulse: float, stun: int, attacker: Node) -> void:
	if eliminated:
		return
	health -= damage
	velocity.x += horizontal_impulse
	stun_frames = maxi(stun_frames, stun)
	if damage > 5.0:
		arena.play_hit_sound()
	if is_instance_valid(hud):
		hud.add_shake(damage)
	if health <= 0.0:
		arena.spawn_explosion(position, player_color, velocity.x)
		lose_life()

func receive_melee(damage: float, power: float, vertical: float, freeze: int, attacker: Node) -> void:
	var random_knockback := maxf(0.0, power - randf() * 10.0)
	take_damage(damage, random_knockback * attacker.facing + attacker.velocity.x, 0, attacker)
	velocity.y += vertical
	hitstop_frames = freeze
	attacker.hitstop_frames = freeze

func lose_life() -> void:
	lives -= 1
	if lives <= 0:
		lives = 0
		eliminated = true
		visible = false
		arena.on_player_eliminated(self)
		return

	health = 100.0
	velocity = Vector2.ZERO
	position = Vector2(randf_range(250.0, 750.0), -500.0)
	jumps_remaining = 2
	drop_frames = 0
	stun_frames = 0
	hitstop_frames = 0
	set_weapon(default_weapon_id)

func reset_for_match() -> void:
	lives = 5
	health = 100.0
	velocity = Vector2.ZERO
	position = spawn_position
	eliminated = false
	visible = true
	jumps_remaining = 2
	muzzle_flash_frames = 0
	weapon_kick_frames = 0
	set_weapon(default_weapon_id)
	if is_instance_valid(hud):
		hud.shown_health = 100.0

func hit_test_point(point: Vector2) -> bool:
	return Rect2(position + Vector2(-14, -48), Vector2(28, 48)).has_point(point)

func texture_for_weapon(requested_weapon_id: int) -> Texture2D:
	var palette: Dictionary = P1_WEAPON_TEXTURES if player_index == 0 else P2_WEAPON_TEXTURES
	return palette.get(requested_weapon_id, palette[1])

func start_weapon_visual(action: String) -> void:
	if not WEAPON_VISUAL_RANGES.has(weapon_id):
		return
	var frame_range: Vector2i = WEAPON_VISUAL_RANGES[weapon_id][action]
	visual_action = action
	visual_frame = frame_range.x
	visual_frame_end = frame_range.y
	visual_action_active = true
	notify_weapon_visual_frame()
	queue_redraw()

func notify_weapon_visual_frame() -> void:
	if is_instance_valid(arena):
		arena.play_weapon_frame_sound(weapon_id, visual_action, visual_frame)

func precache_weapon_visuals(requested_weapon_id: int) -> void:
	if not WEAPON_VISUAL_RANGES.has(requested_weapon_id):
		return
	var weapon_name: String = WEAPON_VISUAL_NAMES[requested_weapon_id]
	for action in ["primary", "secondary"]:
		var frame_range: Vector2i = WEAPON_VISUAL_RANGES[requested_weapon_id][action]
		for frame in range(frame_range.x, frame_range.y + 1):
			var cache_key := "%d:%s:%d" % [requested_weapon_id, action, frame]
			if visual_frame_cache.has(cache_key):
				continue
			var path := "res://assets/original_reference/player_layers/weapons/%s/%s/%d.png" % [weapon_name, action, frame]
			var texture := ResourceLoader.load(path) as Texture2D
			if texture != null:
				visual_frame_cache[cache_key] = texture

func weapon_frame_texture() -> Texture2D:
	if not visual_action_active or not WEAPON_VISUAL_NAMES.has(weapon_id):
		return null
	var cache_key := "%d:%s:%d" % [weapon_id, visual_action, visual_frame]
	if visual_frame_cache.has(cache_key):
		return visual_frame_cache[cache_key]
	var weapon_name: String = WEAPON_VISUAL_NAMES[weapon_id]
	var path := "res://assets/original_reference/player_layers/weapons/%s/%s/%d.png" % [weapon_name, visual_action, visual_frame]
	var texture := ResourceLoader.load(path) as Texture2D
	if texture != null:
		visual_frame_cache[cache_key] = texture
	return texture

func _draw() -> void:
	if eliminated:
		return
	draw_ellipse_shadow()
	var animated_weapon := weapon_frame_texture()
	if animated_weapon != null:
		draw_layered_player(animated_weapon)
	else:
		draw_idle_player()
	if weapon_id >= 6:
		draw_pickup_weapon()
	elif muzzle_flash_frames > 0 and weapon_id != 5:
		var muzzle := muzzle_position() - position - Vector2(5 * facing, 0)
		var flash_size := 5.0 + muzzle_flash_frames * 2.0
		draw_circle(muzzle, flash_size, Color(1.0, 0.82, 0.25, muzzle_flash_frames / 3.0))
	if reload_frames > 0:
		draw_arc(Vector2(0, -57), 8, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - float(reload_frames) / reload_total_frames), 12, Color.WHITE, 2.0)

func draw_idle_player() -> void:
	var texture := texture_for_weapon(weapon_id)
	var kick := float(weapon_kick_frames) * 0.65
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture(texture, Vector2(-texture.get_width() * 0.5 - kick, -texture.get_height() + body_visual_y))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_layered_player(animated_weapon: Texture2D) -> void:
	var base_texture: Texture2D = P1_BASE_TEXTURE if player_index == 0 else P2_BASE_TEXTURE
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture(base_texture, Vector2(-base_texture.get_width() * 0.5, -base_texture.get_height() + body_visual_y))
	var weapon_size := Vector2(animated_weapon.get_width(), animated_weapon.get_height()) * 0.5
	var weapon_position: Vector2 = WEAPON_CANVAS_ORIGINS[weapon_id] + Vector2(-float(weapon_kick_frames) * 0.45, hand_visual_y)
	draw_texture_rect(animated_weapon, Rect2(weapon_position, weapon_size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_pickup_weapon() -> void:
	var kick := float(weapon_kick_frames) * 1.3
	var start := Vector2((7.0 - kick) * facing, -25)
	var end := Vector2((25.0 - kick) * facing, -25)
	match weapon_id:
		6:
			draw_line(start, end + Vector2(8 * facing, 0), Color("e6a15b"), 8.0)
			draw_line(end + Vector2(2 * facing, 0), end + Vector2(10 * facing, 0), Color("f0d7ae"), 4.0)
		7:
			draw_line(start, end + Vector2(13 * facing, 0), Color("90d3a8"), 6.0)
			draw_rect(Rect2(Vector2(-2 if facing == 1 else -8, -24), Vector2(10, 8)), Color("426a52"), true)
		8:
			draw_line(start, end + Vector2(13 * facing, 0), Color("ff7a3d"), 10.0)
			draw_circle(end + Vector2(14 * facing, 0), 6.0, Color("522a25"))
	if muzzle_flash_frames > 0:
		var muzzle := muzzle_position() - position - Vector2(5 * facing, 0)
		var flash_size := 5.0 + muzzle_flash_frames * 2.0
		draw_circle(muzzle, flash_size, Color(1.0, 0.82, 0.25, muzzle_flash_frames / 3.0))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 2), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 15.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
