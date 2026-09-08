extends Node2D

const PlayerScript = preload("res://scripts/players/player.gd")
const ProjectileScript = preload("res://scripts/weapons/projectile.gd")
const WeaponCrateScript = preload("res://scripts/weapons/weapon_crate.gd")
const HudScript = preload("res://scripts/ui/player_hud.gd")
const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")
const MapCatalog = preload("res://scripts/game/map_catalog.gd")
const StunTexture = preload("res://assets/original_reference/effects/status/stun.png")
const CrateOpen1Texture = preload("res://assets/original_reference/effects/crate/open1/1.png")
const CrateOpen2Texture = preload("res://assets/original_reference/effects/crate/open2/1.png")
const SmallWaveTextures := [
	preload("res://assets/original_reference/effects/small_wave/1.png"),
	preload("res://assets/original_reference/effects/small_wave/2.png"),
	preload("res://assets/original_reference/effects/small_wave/3.png"),
	preload("res://assets/original_reference/effects/small_wave/4.png"),
	preload("res://assets/original_reference/effects/small_wave/5.png"),
	preload("res://assets/original_reference/effects/small_wave/6.png"),
	preload("res://assets/original_reference/effects/small_wave/7.png"),
	preload("res://assets/original_reference/effects/small_wave/8.png"),
	preload("res://assets/original_reference/effects/small_wave/9.png"),
	preload("res://assets/original_reference/effects/small_wave/10.png"),
	preload("res://assets/original_reference/effects/small_wave/11.png"),
	preload("res://assets/original_reference/effects/small_wave/12.png"),
	preload("res://assets/original_reference/effects/small_wave/13.png"),
	preload("res://assets/original_reference/effects/small_wave/14.png"),
	preload("res://assets/original_reference/effects/small_wave/15.png"),
]
const LandingDustTextures := [
	preload("res://assets/original_reference/effects/landing/1.png"),
	preload("res://assets/original_reference/effects/landing/2.png"),
	preload("res://assets/original_reference/effects/landing/3.png"),
	preload("res://assets/original_reference/effects/landing/4.png"),
	preload("res://assets/original_reference/effects/landing/5.png"),
	preload("res://assets/original_reference/effects/landing/6.png"),
	preload("res://assets/original_reference/effects/landing/7.png"),
	preload("res://assets/original_reference/effects/landing/8.png"),
	preload("res://assets/original_reference/effects/landing/9.png"),
	preload("res://assets/original_reference/effects/landing/10.png"),
]
const HitSounds := [
	preload("res://assets/original_reference/audio/hit1.mp3"),
	preload("res://assets/original_reference/audio/hit2.mp3"),
]
const FallDeathSounds := [
	preload("res://assets/original_reference/audio/die1.mp3"),
	preload("res://assets/original_reference/audio/die2.mp3"),
	preload("res://assets/original_reference/audio/die3.mp3"),
	preload("res://assets/original_reference/audio/die4.mp3"),
]
const ExplosionSounds := [
	preload("res://assets/original_reference/audio/explosion1.mp3"),
	preload("res://assets/original_reference/audio/explosion2.mp3"),
	preload("res://assets/original_reference/audio/explosion3.mp3"),
	preload("res://assets/original_reference/audio/explosion4.mp3"),
]
const LandingSounds := [
	preload("res://assets/original_reference/audio/drop1.mp3"),
	preload("res://assets/original_reference/audio/drop2.mp3"),
	preload("res://assets/original_reference/audio/drop3.mp3"),
]
const Pistol0Sound = preload("res://assets/original_reference/audio/pistol0.mp3")
const Pistol3Sound = preload("res://assets/original_reference/audio/pistol3.mp3")
const Smg2Sound = preload("res://assets/original_reference/audio/smg2.mp3")
const WhooshSound = preload("res://assets/original_reference/audio/whoosh.mp3")
const PistolMagSound = preload("res://assets/original_reference/audio/pistol_mag.mp3")
const PistolSlideSound = preload("res://assets/original_reference/audio/pistol_slide.mp3")
const Bolt1Sound = preload("res://assets/original_reference/audio/bolt1.mp3")
const PickupSound = preload("res://assets/original_reference/audio/pump2.mp3")
const ButtonSound = preload("res://assets/original_reference/audio/btn.mp3")
const DeathFlashTexture = preload("res://assets/original_reference/effects/death/flash.png")
const DeathPart1Texture = preload("res://assets/original_reference/effects/death/part1.png")
const DeathPart2Texture = preload("res://assets/original_reference/effects/death/part2.png")
const DeathBodyTextures := [
	preload("res://assets/original_reference/effects/death/body/1.png"),
	preload("res://assets/original_reference/effects/death/body/2.png"),
	preload("res://assets/original_reference/effects/death/body/3.png"),
]
const DeathWaveTextures := [
	preload("res://assets/original_reference/effects/death/wave/1.png"),
	preload("res://assets/original_reference/effects/death/wave/2.png"),
	preload("res://assets/original_reference/effects/death/wave/3.png"),
	preload("res://assets/original_reference/effects/death/wave/4.png"),
	preload("res://assets/original_reference/effects/death/wave/5.png"),
	preload("res://assets/original_reference/effects/death/wave/6.png"),
	preload("res://assets/original_reference/effects/death/wave/7.png"),
	preload("res://assets/original_reference/effects/death/wave/8.png"),
	preload("res://assets/original_reference/effects/death/wave/9.png"),
	preload("res://assets/original_reference/effects/death/wave/10.png"),
	preload("res://assets/original_reference/effects/death/wave/11.png"),
	preload("res://assets/original_reference/effects/death/wave/12.png"),
	preload("res://assets/original_reference/effects/death/wave/13.png"),
	preload("res://assets/original_reference/effects/death/wave/14.png"),
	preload("res://assets/original_reference/effects/death/wave/15.png"),
]

var selected_map := 1
var map_texture: Texture2D = MapCatalog.texture_for(1)
var platforms: Array[Rect2] = MapCatalog.platforms_for(1)
var players: Array[Node] = []
var huds: Array[Node] = []
var match_over := false
var round_started := false
var input_lock_frames := 0
var winner_text := ""
var effects: Array[Dictionary] = []
var selected_weapons := [1, 3]
var players_ready := [false, false]
var active_weapon_crate: Node
var crate_spawn_frames := 0
var screen_shake_frames := 0

func _ready() -> void:
	configure_input()
	create_players()
	enter_selection_screen()
	queue_redraw()

func create_players() -> void:
	var definitions := [
		{"spawn": Vector2(292, 250), "color": Color("0099ff"), "weapon": 1},
		{"spawn": Vector2(741, 110), "color": Color("ff355a"), "weapon": 3},
	]
	for index in definitions.size():
		var definition: Dictionary = definitions[index]
		var player := PlayerScript.new()
		add_child(player)
		player.setup(self, index, definition["spawn"], definition["color"], definition["weapon"])
		players.append(player)

		var hud := HudScript.new()
		add_child(hud)
		var hud_position := Vector2(70 if index == 0 else 630, 498)
		hud.setup(player, hud_position)
		player.attach_hud(hud)
		huds.append(hud)

func configure_input() -> void:
	var bindings := {
		"p1_left": KEY_LEFT, "p1_right": KEY_RIGHT, "p1_jump": KEY_UP,
		"p1_down": KEY_DOWN, "p1_primary": KEY_Z, "p1_secondary": KEY_X,
		"p2_left": KEY_A, "p2_right": KEY_D, "p2_jump": KEY_W,
		"p2_down": KEY_S, "p2_primary": KEY_T, "p2_secondary": KEY_Y,
		"map_previous": KEY_Q, "map_next": KEY_E,
		"restart": KEY_R, "back_to_menu": KEY_ESCAPE,
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)

func _physics_process(_delta: float) -> void:
	process_screen_shake()
	if input_lock_frames > 0:
		input_lock_frames -= 1

	if not round_started:
		process_selection_input()
		queue_redraw()
		return

	if Input.is_action_just_pressed("back_to_menu"):
		enter_selection_screen()
		return
	if match_over and Input.is_action_just_pressed("restart"):
		reset_match()
	if not match_over:
		process_weapon_crate_spawning()

	for index in range(effects.size() - 1, -1, -1):
		update_effect(index)
		effects[index]["life"] = int(effects[index]["life"]) - 1
		if int(effects[index]["life"]) <= 0:
			effects.remove_at(index)
	queue_redraw()

func process_screen_shake() -> void:
	if screen_shake_frames <= 0:
		position = Vector2.ZERO
		return
	var strength := 7.0 * float(screen_shake_frames) / 15.0
	position = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	screen_shake_frames -= 1

func update_effect(index: int) -> void:
	var effect: Dictionary = effects[index]
	match effect["type"]:
		"death_flash":
			effect["scale"] = float(effect["scale"]) + 3.0
		"death_wave":
			effect["scale"] += (7.0 - float(effect["scale"])) / 2.5
		"small_wave":
			effect["scale"] += (4.0 - float(effect["scale"])) / 2.0
		"death_part1", "death_body":
			effect["position"] = Vector2(effect["position"]) + Vector2(effect["velocity"])
			var part_velocity: Vector2 = effect["velocity"]
			part_velocity.x *= 0.95
			part_velocity.y = minf(part_velocity.y + float(effect["gravity"]), 20.0)
			effect["velocity"] = part_velocity
			effect["rotation"] = float(effect["rotation"]) + float(effect["rotation_speed"])
		"death_part2":
			effect["position"] = Vector2(effect["position"]) + Vector2(effect["velocity"])
			var smoke_velocity: Vector2 = effect["velocity"]
			smoke_velocity.x *= 0.9
			effect["velocity"] = smoke_velocity
			if int(effect["phase"]) == 1:
				effect["scale"] += (float(effect["target_scale"]) - float(effect["scale"])) / 1.5
				if float(effect["scale"]) > float(effect["target_scale"]) - 0.1:
					effect["phase"] = 2
			else:
				effect["scale"] = float(effect["scale"]) - 0.25
				if float(effect["scale"]) <= 0.05:
					effect["life"] = 1
		"death_text":
			effect["position"] = Vector2(effect["position"]) + Vector2(0, -0.7)
		"crate_piece":
			effect["position"] = Vector2(effect["position"]) + Vector2(effect["velocity"])
			var crate_velocity: Vector2 = effect["velocity"]
			crate_velocity.y += 1.08
			effect["velocity"] = crate_velocity
			effect["rotation"] = float(effect["rotation"]) + float(effect["rotation_speed"])
			if Vector2(effect["position"]).y >= 700.0:
				effect["life"] = 1
		"landing_dust":
			effect["position"] = Vector2(effect["position"]) + Vector2(effect["velocity"])
			var dust_velocity: Vector2 = effect["velocity"]
			dust_velocity *= 0.9
			effect["velocity"] = dust_velocity
			effect["scale"] = float(effect["scale"]) - float(effect["shrink"])
			if float(effect["scale"]) <= 0.05:
				effect["life"] = 1
		"stun":
			effect["position"] = Vector2(effect["position"]) + Vector2(effect["velocity"])
			var stun_velocity: Vector2 = effect["velocity"]
			stun_velocity.x *= 0.9
			effect["velocity"] = stun_velocity
			if int(effect["phase"]) == 1:
				effect["scale"] += (float(effect["target_scale"]) - float(effect["scale"])) / 1.5
				if float(effect["scale"]) > float(effect["target_scale"]) - 0.1:
					effect["phase"] = 2
			else:
				effect["scale"] = float(effect["scale"]) - 0.1
				if float(effect["scale"]) <= 0.05:
					effect["life"] = 1
	effects[index] = effect

func process_selection_input() -> void:
	if input_lock_frames > 0:
		return
	var interacted := false
	if not players_ready[0] and not players_ready[1]:
		if Input.is_action_just_pressed("map_previous"):
			select_map(-1)
			interacted = true
		if Input.is_action_just_pressed("map_next"):
			select_map(1)
			interacted = true
	if not players_ready[0]:
		if Input.is_action_just_pressed("p1_left"):
			selected_weapons[0] = wrapi(selected_weapons[0] - 1, 1, 6)
			interacted = true
		if Input.is_action_just_pressed("p1_right"):
			selected_weapons[0] = wrapi(selected_weapons[0] + 1, 1, 6)
			interacted = true
	if not players_ready[1]:
		if Input.is_action_just_pressed("p2_left"):
			selected_weapons[1] = wrapi(selected_weapons[1] - 1, 1, 6)
			interacted = true
		if Input.is_action_just_pressed("p2_right"):
			selected_weapons[1] = wrapi(selected_weapons[1] + 1, 1, 6)
			interacted = true

	if Input.is_action_just_pressed("p1_primary"):
		players_ready[0] = true
		interacted = true
	if Input.is_action_just_pressed("p2_primary"):
		players_ready[1] = true
		interacted = true
	if Input.is_action_just_pressed("p1_secondary"):
		players_ready[0] = false
		interacted = true
	if Input.is_action_just_pressed("p2_secondary"):
		players_ready[1] = false
		interacted = true
	if interacted:
		play_ui_sound()

	if players_ready[0] and players_ready[1]:
		start_round()

func select_map(direction: int) -> void:
	selected_map = wrapi(selected_map + direction, 1, 11)
	map_texture = MapCatalog.texture_for(selected_map)
	platforms = MapCatalog.platforms_for(selected_map)
	var spawns := MapCatalog.spawns_for(selected_map)
	for index in players.size():
		players[index].spawn_position = spawns[index]
	queue_redraw()

func enter_selection_screen() -> void:
	round_started = false
	match_over = false
	winner_text = ""
	players_ready = [false, false]
	input_lock_frames = 2
	effects.clear()
	clear_weapon_crate()
	for player in players:
		player.visible = false
	for hud in huds:
		hud.visible = false
	queue_redraw()

func start_round() -> void:
	match_over = false
	winner_text = ""
	round_started = true
	input_lock_frames = 2
	effects.clear()
	clear_weapon_crate()
	crate_spawn_frames = 105
	for index in players.size():
		players[index].set_weapon(selected_weapons[index])
		players[index].reset_for_match()
		players[index].visible = true
		huds[index].visible = true
	queue_redraw()

func find_landing_y(previous: Vector2, current: Vector2) -> float:
	for platform in platforms:
		var top := platform.position.y
		if current.x >= platform.position.x and current.x <= platform.end.x:
			if previous.y <= top and current.y >= top:
				return top
	return NAN

func spawn_bullet(shooter: Node, start: Vector2, direction: int, attack: Dictionary) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["firepower"]), float(attack["speed"]), float(attack["spread"])
	)

func spawn_thrown_gun(shooter: Node, start: Vector2, direction: int, attack: Dictionary) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["knockback"]), float(attack["speed"]), 0.0,
		float(attack["damage"]), int(attack["stun"]), true
	)

func spawn_rocket(shooter: Node, start: Vector2, direction: int, attack: Dictionary) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["firepower"]), float(attack["speed"]), float(attack["spread"]),
		float(attack["damage"]), 0, false,
		{
			"kind": "rocket",
			"blast_radius": float(attack["blast_radius"]),
			"gravity": float(attack["gravity"]),
		}
	)

func point_hits_platform(point: Vector2) -> bool:
	for platform in platforms:
		if platform.has_point(point):
			return true
	return false

func radial_attack(at_position: Vector2, shooter: Node, damage: float, power: float, radius: float) -> void:
	for target in players:
		if target.eliminated:
			continue
		var target_center: Vector2 = target.position + Vector2(0, -24)
		var distance := target_center.distance_to(at_position)
		if distance > radius:
			continue
		var strength := clampf(1.0 - distance / (radius * 1.65), 0.35, 1.0)
		var direction := signf(target_center.x - at_position.x)
		if direction == 0.0:
			direction = float(shooter.facing)
		target.take_damage(damage * strength, power * strength * direction, 0, shooter)
		target.velocity.y -= power * 0.32 * strength
	spawn_weapon_blast(at_position, shooter.player_color, radius)

func melee_attack(
		attacker: Node,
		range_x: float,
		min_y: float,
		max_y: float,
		damage: float,
		power: float,
		vertical: float,
		freeze: int
) -> void:
	for target in players:
		if target == attacker or target.eliminated:
			continue
		var difference: Vector2 = target.position - attacker.position
		var in_front := difference.x > -10.0 and difference.x < range_x if attacker.facing == 1 else difference.x < 10.0 and difference.x > -range_x
		if in_front and difference.y > min_y and difference.y < max_y:
			target.receive_melee(damage, power, vertical, freeze, attacker)
			spawn_hit_effect(target.position + Vector2(0, -24), attacker.player_color)

func spawn_hit_effect(at_position: Vector2, color: Color) -> void:
	effects.append({"type": "hit", "position": at_position, "color": color, "life": 7})

func play_random_sound(sound_pool: Array, volume_db: float = 0.0) -> void:
	if sound_pool.is_empty() or not is_inside_tree():
		return
	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = sound_pool.pick_random()
	audio_player.volume_db = volume_db
	add_child(audio_player)
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()

func play_hit_sound() -> void:
	play_random_sound(HitSounds)

func play_fall_death_sound() -> void:
	play_random_sound(FallDeathSounds)

func play_explosion_sound() -> void:
	play_random_sound(ExplosionSounds)

func play_landing_sound() -> void:
	play_random_sound(LandingSounds)

func play_pickup_sound() -> void:
	play_random_sound([PickupSound])

func play_ui_sound() -> void:
	play_random_sound([ButtonSound])

func play_reload_frame_sound(weapon_id: int, elapsed_frames: int) -> void:
	var stream: AudioStream
	if weapon_id in [1, 4]:
		if elapsed_frames == 29:
			stream = PistolSlideSound
		elif elapsed_frames == 45:
			stream = PistolMagSound
	elif weapon_id == 2:
		if elapsed_frames in [25, 29]:
			stream = PistolSlideSound
		elif elapsed_frames in [46, 50]:
			stream = PistolMagSound
	elif weapon_id == 3:
		if elapsed_frames in [17, 40]:
			stream = Bolt1Sound
		elif elapsed_frames == 53:
			stream = PistolMagSound
	if stream != null:
		play_random_sound([stream])

func play_weapon_frame_sound(weapon_id: int, action: String, frame: int) -> void:
	var stream: AudioStream
	if weapon_id == 1 and action == "primary" and frame == 2:
		stream = Smg2Sound
	elif weapon_id == 2 and ((action == "primary" and frame == 2) or (action == "secondary" and frame == 60)):
		stream = Pistol3Sound
	elif weapon_id == 3 and ((action == "primary" and frame == 2) or (action == "secondary" and frame == 136)):
		stream = Pistol0Sound
	elif weapon_id == 4 and action == "primary" and frame == 2:
		stream = Pistol3Sound
	elif weapon_id == 5 and ((action == "primary" and frame in [5, 16]) or (action == "secondary" and frame == 34)):
		stream = WhooshSound
	if stream != null:
		play_random_sound([stream], -6.0)

func spawn_stun_effect(at_position: Vector2, source_velocity_x: float) -> void:
	effects.append({
		"type": "stun",
		"position": at_position + Vector2(randf_range(-10.0, 10.0), randf_range(-5.0, 0.0)),
		"velocity": Vector2(randf_range(-2.0, 2.0) + source_velocity_x, randf_range(-3.0, -1.0)),
		"scale": 1.0,
		"target_scale": randf_range(2.0, 3.0),
		"phase": 1,
		"life": 40,
	})

func spawn_small_wave(at_position: Vector2) -> void:
	effects.append({"type": "small_wave", "position": at_position, "scale": 0.1, "life": 15})

func spawn_crate_open_effect(at_position: Vector2) -> void:
	for index in 6:
		var rotation_speed := deg_to_rad(randf_range(5.0, 35.0))
		if randi() % 2 == 0:
			rotation_speed *= -1.0
		effects.append({
			"type": "crate_piece", "variant": 0 if index < 4 else 1,
			"position": at_position + Vector2(randf_range(-10.0, 10.0), randf_range(-20.0, 0.0)),
			"velocity": Vector2(randf_range(-8.0, 8.0), randf_range(-15.0, -5.0)),
			"rotation": 0.0, "rotation_speed": rotation_speed, "life": 90,
		})

func spawn_landing_dust(at_position: Vector2) -> void:
	var horizontal_speed := randf_range(1.0, 5.0)
	if randi() % 2 == 0:
		horizontal_speed *= -1.0
	effects.append({
		"type": "landing_dust", "position": at_position + Vector2(0, -20),
		"velocity": Vector2(horizontal_speed, randf_range(-0.5, 0.5)),
		"scale": randf_range(1.0, 1.55), "shrink": randf_range(0.03, 0.09), "life": 50,
	})

func spawn_rocket_trail(at_position: Vector2) -> void:
	effects.append({"type": "smoke", "position": at_position, "color": Color("c8cad1"), "life": 9})

func spawn_money_effect(at_position: Vector2, color: Color) -> void:
	for offset in [-12.0, 0.0, 12.0]:
		effects.append({"type": "money", "position": at_position + Vector2(offset, 0), "color": color, "life": 18})

func spawn_explosion(at_position: Vector2, color: Color, source_velocity_x: float = 0.0) -> void:
	var center := at_position + Vector2(0, -20)
	play_explosion_sound()
	screen_shake_frames = 15
	effects.append({"type": "death_flash", "position": center, "color": color, "life": 4, "scale": 1.0})
	effects.append({"type": "death_wave", "position": center, "color": color, "life": 15, "scale": 0.1})
	for particle in 5:
		var angle := deg_to_rad(randf_range(-135.0, -45.0))
		var speed := randf_range(10.0, 25.0)
		effects.append({
			"type": "death_part1", "position": center,
			"velocity": Vector2(cos(angle) * speed + source_velocity_x, sin(angle) * speed),
			"rotation": angle, "rotation_speed": deg_to_rad(randf_range(25.0, 35.0) * (-1.0 if randi() % 2 == 0 else 1.0)),
			"gravity": 1.6, "life": 55,
		})
		effects.append({
			"type": "death_part2", "position": center,
			"velocity": Vector2(randf_range(-10.0, 10.0) + source_velocity_x, randf_range(-7.0, -1.0)),
			"scale": 1.0, "target_scale": randf_range(3.0, 7.0), "phase": 1, "life": 32,
		})
	for body_frame in [0, 1, 2, 2]:
		var body_angle := deg_to_rad(randf_range(-135.0, -45.0))
		var body_speed := randf_range(10.0, 15.0)
		effects.append({
			"type": "death_body", "position": center, "frame": body_frame,
			"velocity": Vector2((cos(body_angle) * body_speed + source_velocity_x) * 0.8, sin(body_angle) * body_speed),
			"rotation": body_angle, "rotation_speed": deg_to_rad(randf_range(10.0, 18.0) * (-1.0 if randi() % 2 == 0 else 1.0)),
			"gravity": 1.2, "life": 70,
		})
	effects.append({"type": "death_text", "position": center + Vector2(-70, -30), "color": color, "life": 25})

func spawn_weapon_blast(at_position: Vector2, color: Color, radius: float) -> void:
	effects.append({"type": "weapon_blast", "position": at_position, "color": color, "radius": radius, "life": 16})

func process_weapon_crate_spawning() -> void:
	if is_instance_valid(active_weapon_crate):
		return
	crate_spawn_frames -= 1
	if crate_spawn_frames > 0:
		return
	var spawn_points := [150.0, 280.0, 370.0, 500.0, 630.0, 720.0, 850.0]
	var crate := WeaponCrateScript.new()
	add_child(crate)
	crate.setup(self, Vector2(spawn_points.pick_random(), -35.0), WeaponCatalog.CRATE_WEAPON_IDS.pick_random())
	active_weapon_crate = crate

func on_weapon_crate_picked(crate: Node, player: Node, weapon_id: int) -> void:
	if active_weapon_crate == crate:
		active_weapon_crate = null
	crate_spawn_frames = randi_range(210, 315)
	play_pickup_sound()
	spawn_crate_open_effect(crate.position)
	effects.append({
		"type": "pickup",
		"position": player.position + Vector2(0, -62),
		"color": player.player_color,
		"label": WeaponCatalog.weapon_name_for(weapon_id),
		"life": 35,
	})

func on_pickup_weapon_empty(player: Node, weapon_id: int) -> void:
	effects.append({
		"type": "weapon_empty",
		"position": player.position + Vector2(0, -58),
		"color": player.player_color,
		"label": WeaponCatalog.weapon_name_for(weapon_id),
		"life": 30,
	})

func on_weapon_crate_lost(crate: Node) -> void:
	if active_weapon_crate == crate:
		active_weapon_crate = null
	crate_spawn_frames = 70

func spawn_crate_landing_effect(at_position: Vector2) -> void:
	effects.append({"type": "crate_land", "position": at_position, "color": Color("ffd166"), "life": 8})

func clear_weapon_crate() -> void:
	if is_instance_valid(active_weapon_crate):
		active_weapon_crate.queue_free()
	active_weapon_crate = null

func on_player_eliminated(_player: Node) -> void:
	var survivors := players.filter(func(candidate: Node) -> bool: return not candidate.eliminated)
	if survivors.size() == 1:
		match_over = true
		winner_text = "%s WINS!" % survivors[0].display_name

func reset_match() -> void:
	match_over = false
	winner_text = ""
	input_lock_frames = 2
	effects.clear()
	clear_weapon_crate()
	crate_spawn_frames = 105
	for index in players.size():
		players[index].set_weapon(selected_weapons[index])
		players[index].reset_for_match()
		huds[index].shown_health = 100.0
		huds[index].visible = true

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color.BLACK, true)
	draw_texture(map_texture, Vector2.ZERO)

	var font := ThemeDB.fallback_font
	if not round_started:
		draw_selection_screen(font)
		return
	draw_string(font, Vector2(24, 28), "MAYHEM ARENA · REDUX REFERENCE BUILD · 35 FPS", HORIZONTAL_ALIGNMENT_LEFT, 560, 17, Color("d9e4f5"))
	draw_string(font, Vector2(24, 49), "P1: ARROWS / Z / X", HORIZONTAL_ALIGNMENT_LEFT, 430, 13, Color("82c4ff"))
	draw_string(font, Vector2(550, 49), "P2: WASD / T / Y", HORIZONTAL_ALIGNMENT_LEFT, 420, 13, Color("ff899b"))
	if not is_instance_valid(active_weapon_crate) and not match_over:
		var crate_seconds := maxf(crate_spawn_frames, 0) / 35.0
		draw_string(font, Vector2(770, 70), "SUPPLY %.1fs" % crate_seconds, HORIZONTAL_ALIGNMENT_RIGHT, 205, 13, Color("ffd166"))

	for effect in effects:
		var life := int(effect["life"])
		var effect_position: Vector2 = effect["position"]
		var effect_color: Color = effect.get("color", Color.WHITE)
		match effect["type"]:
			"hit":
				draw_circle(effect_position, 4.0 + life * 1.5, Color(effect_color, life / 7.0), false, 3.0)
				draw_string(font, effect_position + Vector2(-12, -18), "HIT", HORIZONTAL_ALIGNMENT_LEFT, 45, 16, Color.WHITE)
			"money":
				draw_string(font, effect_position + Vector2(0, -18 + life * -0.6), "$", HORIZONTAL_ALIGNMENT_LEFT, 20, 18, Color("ffdd55"))
			"death_flash":
				draw_centered_texture(DeathFlashTexture, effect_position, float(effect["scale"]), 0.0, Color(1, 1, 1, life / 4.0))
			"death_wave":
				var wave_frame := clampi(15 - life, 0, DeathWaveTextures.size() - 1)
				draw_centered_texture(DeathWaveTextures[wave_frame], effect_position, float(effect["scale"]), 0.0, Color.WHITE)
			"small_wave":
				var small_wave_frame := clampi(15 - life, 0, SmallWaveTextures.size() - 1)
				draw_centered_texture(SmallWaveTextures[small_wave_frame], effect_position, float(effect["scale"]), 0.0, Color.WHITE)
			"death_part1":
				draw_centered_texture(DeathPart1Texture, effect_position, 1.0, float(effect["rotation"]), Color.WHITE)
			"death_part2":
				draw_centered_texture(DeathPart2Texture, effect_position, float(effect["scale"]), 0.0, Color.WHITE)
			"death_body":
				draw_centered_texture(DeathBodyTextures[int(effect["frame"])], effect_position, 1.0, float(effect["rotation"]), Color.WHITE)
			"death_text":
				draw_string(font, effect_position, "KABOOM!", HORIZONTAL_ALIGNMENT_CENTER, 140, 25, Color(1, 1, 1, life / 25.0))
			"stun":
				draw_centered_texture(StunTexture, effect_position, float(effect["scale"]), 0.0, Color.WHITE)
			"crate_piece":
				var crate_piece_texture: Texture2D = CrateOpen1Texture if int(effect["variant"]) == 0 else CrateOpen2Texture
				draw_centered_texture(crate_piece_texture, effect_position, 1.0, float(effect["rotation"]), Color.WHITE)
			"landing_dust":
				draw_centered_texture(LandingDustTextures[selected_map - 1], effect_position, float(effect["scale"]), 0.0, Color.WHITE)
			"crate_land":
				draw_circle(effect_position, 9.0 + (8 - life) * 3.0, Color(effect_color, life / 8.0), false, 3.0)
			"pickup":
				draw_string(font, effect_position + Vector2(-100, -0.7 * (35 - life)), "PICKED UP %s" % effect["label"], HORIZONTAL_ALIGNMENT_CENTER, 200, 16, Color(effect_color, life / 35.0))
			"weapon_blast":
				var blast_radius := float(effect["radius"])
				var progress := 1.0 - life / 16.0
				draw_circle(effect_position, lerpf(8.0, blast_radius, progress), Color(effect_color, life / 22.0), false, 5.0)
				draw_circle(effect_position, lerpf(4.0, blast_radius * 0.62, progress), Color(1.0, 0.72, 0.2, life / 20.0), false, 7.0)
			"smoke":
				draw_circle(effect_position, 2.0 + (9 - life) * 0.8, Color(effect_color, life / 18.0))
			"weapon_empty":
				draw_string(font, effect_position + Vector2(-120, -0.6 * (30 - life)), "%s EMPTY · DEFAULT RESTORED" % effect["label"], HORIZONTAL_ALIGNMENT_CENTER, 240, 13, Color(effect_color, life / 30.0))

	if match_over:
		draw_rect(Rect2(245, 175, 510, 150), Color(0.02, 0.025, 0.04, 0.9), true)
		draw_rect(Rect2(245, 175, 510, 150), Color.WHITE, false, 3.0)
		draw_string(font, Vector2(300, 245), winner_text, HORIZONTAL_ALIGNMENT_CENTER, 400, 34, Color.WHITE)
		draw_string(font, Vector2(300, 282), "PRESS R TO RESTART", HORIZONTAL_ALIGNMENT_CENTER, 400, 17, Color(0.75, 0.8, 0.9))

func draw_centered_texture(texture: Texture2D, at_position: Vector2, scale_value: float, rotation_value: float, modulate: Color) -> void:
	draw_set_transform(at_position, rotation_value, Vector2.ONE * scale_value)
	draw_texture(texture, -Vector2(texture.get_size()) * 0.5, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_selection_screen(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color(0.025, 0.032, 0.052, 0.88), true)
	draw_string(font, Vector2(0, 72), "MAYHEM ARENA", HORIZONTAL_ALIGNMENT_CENTER, 1000, 40, Color.WHITE)
	draw_string(font, Vector2(0, 101), "CHOOSE A DEFAULT WEAPON  ·  Q / E  MAP %02d" % selected_map, HORIZONTAL_ALIGNMENT_CENTER, 1000, 16, Color(0.65, 0.7, 0.79))

	draw_weapon_card(font, 0, Rect2(65, 135, 410, 315), Color("43a6ff"))
	draw_weapon_card(font, 1, Rect2(525, 135, 410, 315), Color("ff536b"))
	draw_string(font, Vector2(0, 493), "P1  ← → choose   Z ready   X cancel", HORIZONTAL_ALIGNMENT_CENTER, 500, 16, Color("82c4ff"))
	draw_string(font, Vector2(500, 493), "P2  A D choose   T ready   Y cancel", HORIZONTAL_ALIGNMENT_CENTER, 500, 16, Color("ff899b"))
	draw_string(font, Vector2(0, 530), "THE FIGHT STARTS WHEN BOTH PLAYERS ARE READY", HORIZONTAL_ALIGNMENT_CENTER, 1000, 14, Color(0.65, 0.7, 0.79))

func draw_weapon_card(font: Font, player_index: int, card: Rect2, color: Color) -> void:
	var weapon := WeaponCatalog.get_weapon(selected_weapons[player_index])
	draw_rect(card, Color(0.045, 0.06, 0.09, 0.98), true)
	draw_rect(card, color if players_ready[player_index] else Color(color, 0.65), false, 3.0)
	draw_string(font, card.position + Vector2(22, 34), "PLAYER %d" % (player_index + 1), HORIZONTAL_ALIGNMENT_LEFT, 170, 20, color)
	var ready_text := "READY!" if players_ready[player_index] else "CHOOSING"
	draw_string(font, card.position + Vector2(210, 34), ready_text, HORIZONTAL_ALIGNMENT_RIGHT, 176, 17, Color("8ff0a4") if players_ready[player_index] else Color(0.6, 0.65, 0.73))

	draw_string(font, card.position + Vector2(0, 92), "‹", HORIZONTAL_ALIGNMENT_CENTER, 55, 38, color)
	draw_string(font, card.position + Vector2(355, 92), "›", HORIZONTAL_ALIGNMENT_CENTER, 55, 38, color)
	draw_string(font, card.position + Vector2(55, 87), str(weapon["name"]), HORIZONTAL_ALIGNMENT_CENTER, 300, 25, Color.WHITE)
	draw_string(font, card.position + Vector2(55, 116), str(weapon["tagline"]), HORIZONTAL_ALIGNMENT_CENTER, 300, 14, Color(0.68, 0.72, 0.8))

	var ammo_text := "INFINITE" if int(weapon["ammo"]) < 0 else str(weapon["ammo"])
	draw_string(font, card.position + Vector2(22, 165), "AMMO", HORIZONTAL_ALIGNMENT_LEFT, 120, 14, Color(0.55, 0.6, 0.7))
	draw_string(font, card.position + Vector2(150, 165), ammo_text, HORIZONTAL_ALIGNMENT_LEFT, 220, 17, Color.WHITE)
	draw_string(font, card.position + Vector2(22, 207), "PRIMARY", HORIZONTAL_ALIGNMENT_LEFT, 120, 14, Color(0.55, 0.6, 0.7))
	draw_string(font, card.position + Vector2(150, 207), str(weapon["primary_label"]), HORIZONTAL_ALIGNMENT_LEFT, 220, 17, Color.WHITE)
	draw_string(font, card.position + Vector2(22, 249), "SECONDARY", HORIZONTAL_ALIGNMENT_LEFT, 120, 14, Color(0.55, 0.6, 0.7))
	draw_string(font, card.position + Vector2(150, 249), str(weapon["secondary_label"]), HORIZONTAL_ALIGNMENT_LEFT, 235, 17, Color.WHITE)
	draw_string(font, card.position + Vector2(0, 293), "LOCKED IN" if players_ready[player_index] else "PRESS READY", HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 16, color)
