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
# Original default-weapon reload sections inside each controller timeline.
const WEAPON_RELOAD_RANGES := {
	1: Vector2i(58, 93),
	2: Vector2i(79, 120),
	3: Vector2i(63, 105),
	4: Vector2i(58, 93),
}
const WEAPON_RAW_NAMES := {
	1: "deagle",
	2: "dual",
	3: "revolver",
	4: "bling",
	5: "katana",
}
const CRATE_ANIMATION_LENGTHS := {
	6: 41, 7: 50, 8: 60, 9: 68, 10: 30, 11: 38, 12: 22,
	13: 50, 14: 50, 15: 46, 16: 42, 17: 30, 18: 32,
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
## Perk ids mirror the original SWF menu: 0 none, 1 triple jump,
## 2 no recoil, 3 extra ammo, 4 random weapon at spawn, 5 infinite ammo.
var perk_id := 0
var umbrella_open := false

var velocity := Vector2.ZERO
var facing := 1
var health := 100.0
var lives := 5
var eliminated := false
var jumps_remaining := 2
var drop_frames := 0
var stun_frames := 0
var hitstop_frames := 0
var respawn_invulnerability_frames := 0
var hit_flash_frames := 0

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
var transparent_texture_cache: Dictionary = {}
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
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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

func set_perk(new_perk_id: int) -> void:
	perk_id = clampi(new_perk_id, 0, 5)

func has_perk(requested_perk_id: int) -> bool:
	return perk_id == requested_perk_id

func max_jump_count() -> int:
	return 3 if has_perk(1) else 2

func spawn_weapon_id() -> int:
	if has_perk(4) and not WeaponCatalog.CRATE_WEAPON_IDS.is_empty():
		return int(WeaponCatalog.CRATE_WEAPON_IDS.pick_random())
	return default_weapon_id

func equip_weapon(new_weapon_id: int, make_default: bool = false) -> void:
	weapon_id = new_weapon_id if WeaponCatalog.is_valid_weapon(new_weapon_id) else 1
	if make_default:
		default_weapon_id = weapon_id
	var weapon := WeaponCatalog.get_weapon(weapon_id)
	ammo = int(weapon["ammo"])
	if ammo > 0 and has_perk(3):
		ammo = maxi(1, roundi(float(ammo) * 1.33))
	primary_cooldown = 0
	secondary_cooldown = 0
	reload_frames = 0
	umbrella_open = false
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
	respawn_invulnerability_frames = maxi(0, respawn_invulnerability_frames - 1)
	hit_flash_frames = maxi(0, hit_flash_frames - 1)

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
		velocity.y = -JUMP_POWER * (1.0 if jumps_remaining == max_jump_count() - 1 else 0.8) * jump_multiplier
		position.y -= 1.0

	if Input.is_action_just_pressed(action_name("down")) and is_standing_on_platform():
		drop_frames = 5
		velocity.y += 1.0
		position.y += 2.0
		jumps_remaining = max_jump_count() - 1

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
			jumps_remaining = max_jump_count()
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
	if str(secondary["type"]) == "umbrella_open":
		umbrella_open = secondary_pressed and reload_frames == 0
	else:
		umbrella_open = false

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
	if attack_type not in ["katana_combo", "katana_uppercut", "make_it_rain", "melee", "bat_throw", "umbrella_open"]:
		if ammo == 0 and not has_perk(5):
			start_reload()
			return

	if secondary:
		secondary_cooldown = int(attack["cooldown"])
	else:
		primary_cooldown = int(attack["cooldown"])
	start_weapon_visual("secondary" if secondary else "primary")
	if attack_type in ["bullet", "bullet_burst", "pellet_burst", "rocket", "homing", "homing_jokes", "arrow", "arrow_burst", "knife", "bomb", "throw_gun"]:
		muzzle_flash_frames = 3
		weapon_kick_frames = 4
	if attack_type in ["bullet", "bullet_burst", "pellet_burst"]:
		arena.spawn_shell_eject(self, muzzle_position(), facing, weapon_id)

	match attack_type:
		"bullet":
			apply_weapon_recoil(float(attack["recoil"]))
			arena.spawn_bullet(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"pellet_burst":
			apply_weapon_recoil(float(attack["recoil"]))
			for pellet in int(attack["pellets"]):
				arena.spawn_bullet(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"bullet_burst":
			apply_weapon_recoil(float(attack["recoil"]))
			for shot in int(attack["shots"]):
				arena.spawn_bullet(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"rocket":
			apply_weapon_recoil(float(attack["recoil"]))
			arena.spawn_rocket(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"throw_gun":
			arena.spawn_thrown_gun(self, muzzle_position(), facing, attack)
		"arrow":
			arena.spawn_arrow(self, muzzle_position(), facing, attack, float(attack.get("angle", 0.0)))
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"arrow_burst":
			for angle in attack["angles"]:
				arena.spawn_arrow(self, muzzle_position(), facing, attack, float(angle))
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"homing", "homing_jokes":
			arena.spawn_homing(self, muzzle_position(), facing, attack, attack_type == "homing_jokes")
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"knife":
			arena.spawn_knife(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"bomb":
			arena.spawn_bomb(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"melee":
			var melee_hits: int = arena.melee_attack(self, float(attack["range"]), float(attack["min_y"]), float(attack["max_y"]), float(attack["damage"]), float(attack["knockback"]), float(attack["vertical"]), int(attack["hitstop"]), bool(attack.get("respect_umbrella", false)), float(attack.get("block_ammo_damage", 0.0)), int(attack.get("stun", 0)))
			if bool(attack.get("ammo_on_hit", false)) and melee_hits > 0:
				consume_ammo(int(attack.get("ammo_cost", 1)))
		"bat_throw":
			var hit_count: int = arena.melee_attack(self, float(attack["range"]), float(attack["min_y"]), float(attack["max_y"]), float(attack["damage"]), float(attack["knockback"]), float(attack["vertical"]), int(attack["hitstop"]))
			if hit_count == 0:
				arena.spawn_baseball(self, muzzle_position(), facing, attack)
			consume_ammo(int(attack.get("ammo_cost", 1)))
		"umbrella_open":
			umbrella_open = true
		"make_it_rain":
			take_damage(float(attack["self_damage"]), 0.0, 0, self)
			arena.spawn_money_effect(muzzle_position(), player_color)
		"katana_combo":
			katana_events = [{"frames": 0, "power": 12.0}, {"frames": 11, "power": 13.0}]
		"katana_uppercut":
			velocity.y = -9.0
			arena.melee_attack(self, 75.0, -80.0, 30.0, 20.0, 25.0, -10.0, 2, true, 20.0, 0)

func process_katana_events() -> void:
	for index in range(katana_events.size() - 1, -1, -1):
		katana_events[index]["frames"] = int(katana_events[index]["frames"]) - 1
		if int(katana_events[index]["frames"]) <= 0:
			var power := float(katana_events[index]["power"])
			arena.melee_attack(self, 65.0 if power == 12.0 else 75.0, -40.0, 30.0, 20.0, power, 0.0, 2, true, power * 0.8, 0)
			if power == 13.0:
				velocity.x += 6.0 * facing
			katana_events.remove_at(index)

func apply_weapon_recoil(recoil: float) -> void:
	if not has_perk(2):
		velocity.x -= recoil * facing

func muzzle_position() -> Vector2:
	return position + Vector2(35.0 * facing, -20.0)

func consume_ammo(cost: int = 1) -> void:
	if ammo < 0 or has_perk(5):
		return
	ammo = maxi(0, ammo - maxi(1, cost))
	if ammo <= 0:
		start_reload()

func drain_ammo(amount: float) -> void:
	if ammo < 0 or has_perk(5):
		return
	ammo = maxi(0, roundi(float(ammo) - amount))
	if ammo <= 0:
		start_reload()

func start_reload() -> void:
	if ammo < 0 or reload_frames > 0:
		return
	reload_total_frames = 12 if weapon_id != default_weapon_id else int(DEFAULT_RELOAD_FRAMES.get(weapon_id, 45))
	reload_frames = reload_total_frames
	if WEAPON_RELOAD_RANGES.has(weapon_id):
		var frame_range: Vector2i = WEAPON_RELOAD_RANGES[weapon_id]
		visual_action = "reload"
		visual_frame = frame_range.x
		visual_frame_end = frame_range.y
		visual_action_active = true
		notify_weapon_visual_frame()
	else:
		visual_action_active = false
		visual_action = ""
		visual_frame = 0
		visual_frame_end = 0
	queue_redraw()

func take_damage(damage: float, horizontal_impulse: float, stun: int, attacker: Node) -> void:
	if eliminated or respawn_invulnerability_frames > 0:
		return
	health -= damage
	velocity.x += horizontal_impulse
	stun_frames = maxi(stun_frames, stun)
	hit_flash_frames = 4
	if damage > 5.0:
		arena.play_hit_sound()
	if is_instance_valid(hud):
		hud.add_shake(damage)
	if health <= 0.0:
		arena.spawn_explosion(position, player_color, velocity.x)
		lose_life()

func receive_melee(damage: float, power: float, vertical: float, freeze: int, attacker: Node, melee_stun: int = 0) -> void:
	var random_knockback := maxf(0.0, power - randf() * 10.0)
	take_damage(damage, random_knockback * attacker.facing + attacker.velocity.x, 0, attacker)
	velocity.y += vertical
	stun_frames = maxi(stun_frames, melee_stun)
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
	jumps_remaining = max_jump_count()
	drop_frames = 0
	stun_frames = 0
	hitstop_frames = 0
	respawn_invulnerability_frames = 35
	hit_flash_frames = 0
	equip_weapon(spawn_weapon_id(), false)

func reset_for_match() -> void:
	lives = 5
	health = 100.0
	velocity = Vector2.ZERO
	position = spawn_position
	eliminated = false
	visible = true
	jumps_remaining = max_jump_count()
	muzzle_flash_frames = 0
	weapon_kick_frames = 0
	respawn_invulnerability_frames = 0
	hit_flash_frames = 0
	equip_weapon(spawn_weapon_id(), false)
	if is_instance_valid(hud):
		hud.shown_health = 100.0

func hit_test_point(point: Vector2) -> bool:
	return Rect2(position + Vector2(-14, -48), Vector2(28, 48)).has_point(point)

func texture_for_weapon(requested_weapon_id: int) -> Texture2D:
	var palette: Dictionary = P1_WEAPON_TEXTURES if player_index == 0 else P2_WEAPON_TEXTURES
	return transparent_texture(palette.get(requested_weapon_id, palette[1]))

func transparent_texture(texture: Texture2D) -> Texture2D:
	if texture == null:
		return texture
	var cache_key := texture.get_instance_id()
	if transparent_texture_cache.has(cache_key):
		return transparent_texture_cache[cache_key]
	var image := texture.get_image()
	if image == null:
		return texture
	# The SWF exporter can leave both a faint matte and a solid, edge-connected
	# background on a few symbols. Remove the matte first, then flood-fill only
	# a border-connected color that matches the image corners. This preserves
	# interior black outlines while removing the rectangular color block.
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.5:
				pixel.a = 0.0
				image.set_pixel(x, y, pixel)
	remove_edge_matte(image)
	var cleaned := ImageTexture.create_from_image(image)
	transparent_texture_cache[cache_key] = cleaned
	return cleaned

func remove_edge_matte(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	if width < 3 or height < 3:
		return
	var corner_colors := [
		image.get_pixel(0, 0), image.get_pixel(width - 1, 0),
		image.get_pixel(0, height - 1), image.get_pixel(width - 1, height - 1),
	]
	var reference: Color = corner_colors[0]
	var matching_corners := 0
	for corner in corner_colors:
		if corner.a > 0.95 and color_distance(reference, corner) < 0.12:
			matching_corners += 1
	if matching_corners < 3:
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var queue: Array[Vector2i] = []
	for x in width:
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, height - 1))
	for y in range(1, height - 1):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(width - 1, y))
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		var offset := cell.y * width + cell.x
		if visited[offset] != 0:
			continue
		visited[offset] = 1
		var pixel := image.get_pixelv(cell)
		if pixel.a <= 0.0 or color_distance(pixel, reference) > 0.18:
			continue
		pixel.a = 0.0
		image.set_pixelv(cell, pixel)
		for neighbor in [Vector2i(cell.x - 1, cell.y), Vector2i(cell.x + 1, cell.y), Vector2i(cell.x, cell.y - 1), Vector2i(cell.x, cell.y + 1)]:
			if neighbor.x >= 0 and neighbor.x < width and neighbor.y >= 0 and neighbor.y < height:
				queue.append(neighbor)

func color_distance(first: Color, second: Color) -> float:
	return absf(first.r - second.r) + absf(first.g - second.g) + absf(first.b - second.b) + absf(first.a - second.a)

func base_texture_for_display() -> Texture2D:
	return transparent_texture(P1_BASE_TEXTURE if player_index == 0 else P2_BASE_TEXTURE)

func start_weapon_visual(action: String) -> void:
	if not WEAPON_VISUAL_RANGES.has(weapon_id):
		visual_action = action
		visual_frame = 1
		visual_frame_end = int(CRATE_ANIMATION_LENGTHS.get(weapon_id, 12))
		visual_action_active = true
		notify_weapon_visual_frame()
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
	for action in ["primary", "secondary"]:
		var frame_range: Vector2i = WEAPON_VISUAL_RANGES[requested_weapon_id][action]
		for frame in range(frame_range.x, frame_range.y + 1):
			load_and_cache_weapon_frame(requested_weapon_id, action, frame)
	if WEAPON_RELOAD_RANGES.has(requested_weapon_id):
		var reload_range: Vector2i = WEAPON_RELOAD_RANGES[requested_weapon_id]
		for frame in range(reload_range.x, reload_range.y + 1):
			load_and_cache_weapon_frame(requested_weapon_id, "reload", frame)

func load_and_cache_weapon_frame(requested_weapon_id: int, action: String, frame: int) -> Texture2D:
	var cache_key := "%d:%s:%d" % [requested_weapon_id, action, frame]
	if visual_frame_cache.has(cache_key):
		return visual_frame_cache[cache_key]
	var weapon_name: String = WEAPON_RAW_NAMES[requested_weapon_id]
	var path: String
	if action == "reload":
		path = "res://assets/original_reference/player_layers/raw/%s/%d.png" % [weapon_name, frame]
	else:
		path = "res://assets/original_reference/player_layers/weapons/%s/%s/%d.png" % [weapon_name, action, frame]
	var texture := ResourceLoader.load(path) as Texture2D
	if texture != null:
		visual_frame_cache[cache_key] = transparent_texture(texture)
	return texture

func weapon_frame_texture() -> Texture2D:
	if not visual_action_active or not WEAPON_VISUAL_NAMES.has(weapon_id):
		return null
	var cache_key := "%d:%s:%d" % [weapon_id, visual_action, visual_frame]
	if visual_frame_cache.has(cache_key):
		return visual_frame_cache[cache_key]
	return load_and_cache_weapon_frame(weapon_id, visual_action, visual_frame)

func _draw() -> void:
	if eliminated:
		return
	draw_ellipse_shadow()
	var animated_weapon := weapon_frame_texture()
	if weapon_id >= 6:
		draw_pickup_player()
	elif animated_weapon != null:
		draw_layered_player(animated_weapon)
	else:
		draw_idle_player()
	if weapon_id >= 6:
		draw_pickup_weapon()
	elif muzzle_flash_frames > 0 and weapon_id != 5:
		draw_muzzle_flash()
	if reload_frames > 0:
		draw_arc(Vector2(0, -57), 8, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - float(reload_frames) / reload_total_frames), 12, Color.WHITE, 2.0)
	if hit_flash_frames > 0:
		draw_rect(Rect2(-20, -64, 40, 62), Color(1.0, 0.2, 0.2, 0.18), false, 3.0)

func draw_idle_player() -> void:
	var texture := texture_for_weapon(weapon_id)
	var kick := float(weapon_kick_frames) * 0.65
	var modulate := visual_modulate()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture(texture, Vector2(-texture.get_width() * 0.5 - kick, -texture.get_height() + body_visual_y), modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_pickup_player() -> void:
	var base_texture: Texture2D = P1_BASE_TEXTURE if player_index == 0 else P2_BASE_TEXTURE
	var modulate := visual_modulate()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	base_texture = transparent_texture(base_texture)
	draw_texture(base_texture, Vector2(-base_texture.get_width() * 0.5, -base_texture.get_height() + body_visual_y), modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_layered_player(animated_weapon: Texture2D) -> void:
	var base_texture: Texture2D = P1_BASE_TEXTURE if player_index == 0 else P2_BASE_TEXTURE
	base_texture = transparent_texture(base_texture)
	animated_weapon = transparent_texture(animated_weapon)
	var modulate := visual_modulate()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_texture(base_texture, Vector2(-base_texture.get_width() * 0.5, -base_texture.get_height() + body_visual_y), modulate)
	var weapon_size := Vector2(animated_weapon.get_width(), animated_weapon.get_height()) * 0.5
	var weapon_position: Vector2 = WEAPON_CANVAS_ORIGINS[weapon_id] + Vector2(-float(weapon_kick_frames) * 0.45, hand_visual_y)
	draw_texture_rect(animated_weapon, Rect2(weapon_position, weapon_size), false, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func visual_modulate() -> Color:
	var modulate := Color.WHITE
	if hit_flash_frames > 0:
		modulate = Color(1.0, 0.45, 0.45, 1.0)
	elif respawn_invulnerability_frames > 0 and respawn_invulnerability_frames % 4 < 2:
		modulate = Color(1.0, 1.0, 1.0, 0.45)
	return modulate

func draw_pickup_weapon() -> void:
	var kick := float(weapon_kick_frames) * 1.3
	var action_progress := clampf(float(visual_frame) / 12.0, 0.0, 1.0) if visual_action_active else 0.0
	var attack_lift := -sin(action_progress * PI) * 7.0
	var start := Vector2((7.0 - kick) * facing, -25 + attack_lift)
	var end := Vector2((25.0 - kick) * facing, -25 + attack_lift)
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
		9:
			draw_line(start, end + Vector2(16 * facing, 0), Color("3a3e45"), 7.0)
			draw_line(end + Vector2(2 * facing, 0), end + Vector2(12 * facing, 0), Color("a4a9b0"), 4.0)
		10:
			draw_line(start, end + Vector2(13 * facing, -2), Color("8b542f"), 8.0)
			draw_line(end + Vector2(7 * facing, -8), end + Vector2(15 * facing, 1), Color("d6a36a"), 7.0)
		11:
			draw_arc(start + Vector2(8 * facing, 3), 15.0, deg_to_rad(-72 if facing == 1 else -108), deg_to_rad(72 if facing == 1 else 108), 12, Color("8dcf85"), 3.0)
			draw_line(start + Vector2(7 * facing, 3), end + Vector2(15 * facing, -4), Color("d9d9d9"), 3.0)
		12:
			draw_line(start, end + Vector2(20 * facing, 0), Color("d8dce4"), 6.0)
			draw_line(end + Vector2(8 * facing, 0), end + Vector2(21 * facing, 0), Color("515762"), 4.0)
		13:
			draw_line(start, end + Vector2(12 * facing, 0), Color("56616d"), 8.0)
			draw_rect(Rect2(Vector2(-2 if facing == 1 else -9, -28), Vector2(8, 12)), Color("22262d"), true)
		14:
			draw_line(start, end + Vector2(11 * facing, 0), Color("6f8794"), 6.0)
			draw_line(end + Vector2(4 * facing, 0), end + Vector2(14 * facing, 0), Color("d4b56c"), 3.0)
		15:
			draw_line(start, end + Vector2(18 * facing, 0), Color("bf9b45"), 10.0)
			draw_circle(end + Vector2(16 * facing, 0), 5.0, Color("4a4e55"))
		16:
			draw_line(start, end + Vector2(10 * facing, 0), Color("79563f"), 4.0)
			if umbrella_open:
				var umbrella_center := end + Vector2(9 * facing, -17)
				draw_arc(umbrella_center, 20.0, PI if facing == 1 else 0.0, TAU if facing == 1 else PI, 16, Color("78a8d8"), 8.0)
				draw_line(umbrella_center, end + Vector2(9 * facing, 2), Color("d8dce4"), 2.0)
		17:
			draw_line(start, end + Vector2(16 * facing, -1), Color("dce4ee"), 4.0)
			draw_line(end + Vector2(2 * facing, -5), end + Vector2(2 * facing, 5), Color("8b5a3c"), 4.0)
		18:
			draw_circle(end + Vector2(6 * facing, 0), 8.0, Color("282b31"))
			draw_circle(end + Vector2(9 * facing, -3), 2.0, Color("ffb000"))
	if muzzle_flash_frames > 0:
		draw_muzzle_flash()

func draw_muzzle_flash() -> void:
	var muzzle := muzzle_position() - position
	var alpha := float(muzzle_flash_frames) / 3.0
	var length := 10.0 + float(muzzle_flash_frames) * 3.0
	var tip := muzzle + Vector2(length * facing, 0)
	var upper := muzzle + Vector2(2.0 * facing, -5.0 - muzzle_flash_frames)
	var lower := muzzle + Vector2(2.0 * facing, 5.0 + muzzle_flash_frames)
	draw_colored_polygon(PackedVector2Array([muzzle, upper, tip, lower]), Color(1.0, 0.72, 0.12, alpha))
	draw_circle(muzzle, 3.0 + muzzle_flash_frames, Color(1.0, 0.95, 0.62, alpha))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 2), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 15.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
