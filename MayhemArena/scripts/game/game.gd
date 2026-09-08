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
var selected_weapons := [1, 3, 1, 1]
var players_ready := [false, false]
var player_slot_perks := [0, 1, 2, 3]
var player_slot_colors := [Color("0099ff"), Color("ff355a"), Color("35c759"), Color("ff72c7")]
var player_slot_names := ["Player 1", "Player 2", "Player 3", "Player 4"]
var map_menu_cursor := 1
var selected_player_slot := 0
var player_modal_kind := 0
var player_modal_cursor := 0
var active_weapon_crate: Node
var crate_spawn_frames := 0
var screen_shake_frames := 0
enum MenuScreen { MAIN, CUSTOM_MODE, MAP_SELECTION, PLAYER_SETUP, PLAYER_MODAL, SETTINGS, RESERVED }
var menu_screen := MenuScreen.MAIN
var main_menu_cursor := 1
var custom_mode_cursor := 0
var reserved_menu_title := ""
var use_chinese := false
var settings_cursor := 0
var menu_mouse_position := Vector2(-1000.0, -1000.0)
var menu_hover_pulse := 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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

func _input(event: InputEvent) -> void:
	if round_started or input_lock_frames > 0:
		return
	if event is InputEventMouseMotion:
		menu_mouse_position = event.position
		menu_hover_pulse = float(Time.get_ticks_msec()) / 220.0
		queue_redraw()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		process_menu_click(event.position)

func _physics_process(_delta: float) -> void:
	process_screen_shake()
	if input_lock_frames > 0:
		input_lock_frames -= 1

	if not round_started:
		menu_hover_pulse = float(Time.get_ticks_msec()) / 220.0
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
		"shell":
			effect["position"] = Vector2(effect["position"]) + Vector2(effect["velocity"])
			var shell_velocity: Vector2 = effect["velocity"]
			shell_velocity.x *= 0.96
			shell_velocity.y = minf(shell_velocity.y + 0.55, 14.0)
			effect["velocity"] = shell_velocity
			effect["rotation"] = float(effect["rotation"]) + float(effect["rotation_speed"])
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
	if menu_screen == MenuScreen.MAIN:
		process_main_menu_input()
	elif menu_screen == MenuScreen.CUSTOM_MODE:
		process_custom_mode_input()
	elif menu_screen == MenuScreen.MAP_SELECTION:
		process_map_selection_input()
	elif menu_screen == MenuScreen.PLAYER_SETUP:
		process_player_setup_input()
	elif menu_screen == MenuScreen.PLAYER_MODAL:
		process_player_modal_input()
	elif menu_screen == MenuScreen.SETTINGS:
		process_settings_input()
	elif menu_screen == MenuScreen.RESERVED:
		if Input.is_action_just_pressed("p1_secondary") or Input.is_action_just_pressed("back_to_menu"):
			enter_selection_screen()
			play_ui_sound()
	return

func process_main_menu_input() -> void:
	var interacted := false
	if Input.is_action_just_pressed("p1_jump"):
		main_menu_cursor = wrapi(main_menu_cursor - 1, 0, 5)
		interacted = true
	if Input.is_action_just_pressed("p1_down"):
		main_menu_cursor = wrapi(main_menu_cursor + 1, 0, 5)
		interacted = true
	if Input.is_action_just_pressed("p1_primary"):
		interacted = true
		match main_menu_cursor:
			1:
				enter_custom_mode_screen()
			0:
				enter_reserved_screen("SINGLE PLAYER")
			2:
				enter_settings_screen()
			3:
				enter_reserved_screen("MORE GAMES")
			4:
				enter_reserved_screen("CREDITS")
	if interacted:
		play_ui_sound()

func process_settings_input() -> void:
	var interacted := false
	if Input.is_action_just_pressed("p1_jump") or Input.is_action_just_pressed("p1_down"):
		settings_cursor = 1 - settings_cursor
		interacted = true
	if Input.is_action_just_pressed("p1_left") or Input.is_action_just_pressed("p1_right") or Input.is_action_just_pressed("p1_primary"):
		if settings_cursor == 0:
			use_chinese = not use_chinese
		interacted = true
	if Input.is_action_just_pressed("p1_secondary") or Input.is_action_just_pressed("back_to_menu"):
		enter_selection_screen()
		interacted = true
	if interacted:
		play_ui_sound()

func process_custom_mode_input() -> void:
	var interacted := false
	if Input.is_action_just_pressed("p1_jump"):
		custom_mode_cursor = wrapi(custom_mode_cursor - 1, 0, 3)
		interacted = true
	if Input.is_action_just_pressed("p1_down"):
		custom_mode_cursor = wrapi(custom_mode_cursor + 1, 0, 3)
		interacted = true
	if Input.is_action_just_pressed("p1_primary"):
		interacted = true
		if custom_mode_cursor == 0:
			enter_map_selection_screen()
		else:
			enter_reserved_screen(["TEAM DEATHMATCH", "DOMINATION"][custom_mode_cursor - 1])
	if Input.is_action_just_pressed("p1_secondary") or Input.is_action_just_pressed("back_to_menu"):
		enter_selection_screen()
		interacted = true
	if interacted:
		play_ui_sound()

func process_map_selection_input() -> void:
	var interacted := false
	if Input.is_action_just_pressed("p1_jump"):
		map_menu_cursor = wrapi(map_menu_cursor - 1, 0, 11)
		if map_menu_cursor > 0:
			selected_map = map_menu_cursor
			map_texture = MapCatalog.texture_for(selected_map)
			platforms = MapCatalog.platforms_for(selected_map)
		interacted = true
	if Input.is_action_just_pressed("p1_down"):
		map_menu_cursor = wrapi(map_menu_cursor + 1, 0, 11)
		if map_menu_cursor > 0:
			selected_map = map_menu_cursor
			map_texture = MapCatalog.texture_for(selected_map)
			platforms = MapCatalog.platforms_for(selected_map)
		interacted = true
	if Input.is_action_just_pressed("p1_primary"):
		enter_player_setup_screen()
		interacted = true
	if Input.is_action_just_pressed("p1_secondary") or Input.is_action_just_pressed("back_to_menu"):
		enter_custom_mode_screen()
		interacted = true
	if interacted:
		play_ui_sound()

func process_player_setup_input() -> void:
	if Input.is_action_just_pressed("back_to_menu"):
		enter_map_selection_screen()
		play_ui_sound()
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

func process_player_modal_input() -> void:
	var interacted := false
	if Input.is_action_just_pressed("p1_jump"):
		player_modal_cursor = maxi(0, player_modal_cursor - 1)
		interacted = true
	if Input.is_action_just_pressed("p1_down"):
		var item_count := 5 if player_modal_kind == 1 else 6
		player_modal_cursor = mini(item_count - 1, player_modal_cursor + 1)
		interacted = true
	if Input.is_action_just_pressed("p1_primary"):
		select_player_modal_item()
		interacted = true
	if Input.is_action_just_pressed("p1_secondary") or Input.is_action_just_pressed("back_to_menu"):
		close_player_modal()
		interacted = true
	if interacted:
		play_ui_sound()

func process_menu_click(click_position: Vector2) -> void:
	var interacted := false
	match menu_screen:
		MenuScreen.MAIN:
			for index in 5:
				var item_rect := Rect2(700, 270 + index * 42, 270, 42)
				if item_rect.has_point(click_position):
					main_menu_cursor = index
					if index == 1:
						enter_custom_mode_screen()
					elif index == 2:
						enter_settings_screen()
					else:
						enter_reserved_screen(["SINGLE PLAYER", "", "", "MORE GAMES", "CREDITS"][index])
					interacted = true
		MenuScreen.CUSTOM_MODE:
			for index in 3:
				if Rect2(38, 150 + index * 62, 470, 50).has_point(click_position):
					custom_mode_cursor = index
					if index == 0:
						enter_map_selection_screen()
					else:
						enter_reserved_screen(["TEAM DEATHMATCH", "DOMINATION"][index - 1])
					interacted = true
			if Rect2(24, 480, 185, 54).has_point(click_position):
				enter_selection_screen()
				interacted = true
			elif Rect2(230, 480, 746, 54).has_point(click_position) and custom_mode_cursor == 0:
				enter_map_selection_screen()
				interacted = true
		MenuScreen.MAP_SELECTION:
			for index in 11:
				if Rect2(22, 128 + index * 34, 316, 29).has_point(click_position):
					map_menu_cursor = index
					if index > 0:
						selected_map = index
						map_texture = MapCatalog.texture_for(selected_map)
						platforms = MapCatalog.platforms_for(selected_map)
					interacted = true
			if Rect2(22, 493, 185, 44).has_point(click_position):
				enter_custom_mode_screen()
				interacted = true
			elif Rect2(222, 493, 756, 44).has_point(click_position):
				enter_player_setup_screen()
				interacted = true
		MenuScreen.PLAYER_SETUP:
			for slot in 4:
				var card := player_card_rect(slot)
				if not card.has_point(click_position):
					continue
				selected_player_slot = slot
				var gun_rect := Rect2(card.position + Vector2(94, 294), Vector2(65, 62))
				var perk_rect := Rect2(card.position + Vector2(169, 294), Vector2(43, 62))
				if gun_rect.has_point(click_position):
					open_player_modal(slot, 1)
					interacted = true
				elif perk_rect.has_point(click_position):
					open_player_modal(slot, 2)
					interacted = true
			if Rect2(22, 493, 185, 44).has_point(click_position):
				enter_map_selection_screen()
				interacted = true
			elif Rect2(222, 493, 756, 44).has_point(click_position):
				players_ready = [true, true]
				start_round()
				interacted = true
		MenuScreen.PLAYER_MODAL:
			if Rect2(735, 458, 190, 52).has_point(click_position):
				close_player_modal()
				interacted = true
			else:
				var item_count := 5 if player_modal_kind == 1 else 6
				var item_width := 108.0 if player_modal_kind == 1 else 94.0
				var row_start := 174.0 if player_modal_kind == 1 else 146.0
				for index in item_count:
					if Rect2(row_start + index * item_width, 154, item_width - 8, 112).has_point(click_position):
						player_modal_cursor = index
						select_player_modal_item()
						interacted = true
			if Rect2(0, 0, 1000, 560).has_point(click_position) and not interacted:
				close_player_modal()
				interacted = true
		MenuScreen.SETTINGS:
			if Rect2(240, 180, 520, 66).has_point(click_position):
				settings_cursor = 0
				use_chinese = not use_chinese
				interacted = true
			elif Rect2(240, 350, 520, 66).has_point(click_position):
				settings_cursor = 1
				enter_selection_screen()
				interacted = true
	if not interacted:
		# Blank menu space is a safe mouse back target, matching the low-risk
		# navigation behavior of the original Flash menus.
		match menu_screen:
			MenuScreen.CUSTOM_MODE:
				enter_selection_screen()
				interacted = true
			MenuScreen.MAP_SELECTION:
				enter_custom_mode_screen()
				interacted = true
			MenuScreen.PLAYER_SETUP:
				enter_map_selection_screen()
				interacted = true
			MenuScreen.SETTINGS:
				enter_selection_screen()
				interacted = true
			MenuScreen.RESERVED:
				enter_selection_screen()
				interacted = true
	if interacted:
		play_ui_sound()

func select_map(direction: int) -> void:
	selected_map = wrapi(selected_map + direction, 1, 11)
	map_menu_cursor = selected_map
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
	menu_screen = MenuScreen.MAIN
	players_ready = [false, false]
	input_lock_frames = 2
	effects.clear()
	clear_weapon_crate()
	for player in players:
		player.visible = false
	for hud in huds:
		hud.visible = false
	queue_redraw()

func enter_custom_mode_screen() -> void:
	menu_screen = MenuScreen.CUSTOM_MODE
	custom_mode_cursor = 0
	players_ready = [false, false]
	input_lock_frames = 2
	queue_redraw()

func enter_map_selection_screen() -> void:
	menu_screen = MenuScreen.MAP_SELECTION
	map_menu_cursor = selected_map
	input_lock_frames = 2
	queue_redraw()

func enter_player_setup_screen() -> void:
	menu_screen = MenuScreen.PLAYER_SETUP
	players_ready = [false, false]
	selected_player_slot = 0
	player_modal_kind = 0
	input_lock_frames = 2
	queue_redraw()

func open_player_modal(slot: int, modal_kind: int) -> void:
	selected_player_slot = slot
	player_modal_kind = modal_kind
	if modal_kind == 1:
		player_modal_cursor = clampi(selected_weapons[mini(slot, selected_weapons.size() - 1)] - 1, 0, 4)
	else:
		player_modal_cursor = clampi(player_slot_perks[slot], 0, 5)
	menu_screen = MenuScreen.PLAYER_MODAL
	input_lock_frames = 2
	queue_redraw()

func close_player_modal() -> void:
	player_modal_kind = 0
	menu_screen = MenuScreen.PLAYER_SETUP
	input_lock_frames = 2
	queue_redraw()

func select_player_modal_item() -> void:
	if player_modal_kind == 1:
		var weapon_id := player_modal_cursor + 1
		if selected_player_slot < selected_weapons.size():
			selected_weapons[selected_player_slot] = weapon_id
		if selected_player_slot < players.size():
			players[selected_player_slot].set_weapon(weapon_id)
	else:
		player_slot_perks[selected_player_slot] = player_modal_cursor
	close_player_modal()

func player_card_rect(slot: int) -> Rect2:
	return Rect2(18 + slot * 245, 98, 232, 382)

func enter_reserved_screen(title: String) -> void:
	menu_screen = MenuScreen.RESERVED
	reserved_menu_title = title
	input_lock_frames = 2
	queue_redraw()

func enter_settings_screen() -> void:
	menu_screen = MenuScreen.SETTINGS
	settings_cursor = 0
	input_lock_frames = 2
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
		players[index].set_perk(player_slot_perks[index])
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

func spawn_arrow(shooter: Node, start: Vector2, direction: int, attack: Dictionary, angle_degrees: float = 0.0) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["firepower"]), float(attack["speed"]), float(attack.get("spread", 0.0)),
		float(attack["damage"]), 0, false,
		{"kind": "arrow", "life": 120, "angle_offset": angle_degrees}
	)

func spawn_knife(shooter: Node, start: Vector2, direction: int, attack: Dictionary) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["firepower"]), float(attack["speed"]), float(attack.get("spread", 0.0)),
		float(attack["damage"]), 0, false,
		{"kind": "knife", "life": 80, "angle_offset": float(attack.get("angle", 0.0))}
	)

func spawn_baseball(shooter: Node, start: Vector2, direction: int, attack: Dictionary) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["knockback"]), float(attack["speed"]), 3.0,
		float(attack["damage"]), 30, false,
		{"kind": "baseball", "life": 90}
	)

func spawn_homing(shooter: Node, start: Vector2, direction: int, attack: Dictionary, joke_variant: bool = false) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["firepower"]), float(attack["speed"]), float(attack.get("spread", 0.0)),
		float(attack["damage"]), 0, false,
		{
			"kind": "homing_jokes" if joke_variant else "homing",
			"life": int(attack["life"]), "turning": float(attack["turning"]),
			"homing_speed": float(attack["speed"]), "blast_radius": 50.0,
		}
	)

func spawn_bomb(shooter: Node, start: Vector2, direction: int, attack: Dictionary) -> void:
	var projectile := ProjectileScript.new()
	add_child(projectile)
	projectile.setup(
		self, shooter, start, direction,
		float(attack["firepower"]), float(attack["speed"]), 0.0,
		float(attack["damage"]), 0, false,
		{
			"kind": "bomb", "life": 120, "blast_radius": float(attack["blast_radius"]),
			"gravity": float(attack["gravity"]), "bounce": bool(attack["bounce"]),
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
		freeze: int,
		respect_umbrella: bool = false,
		block_ammo_damage: float = 0.0,
		melee_stun: int = 0
) -> int:
	var hit_count := 0
	for target in players:
		if target == attacker or target.eliminated:
			continue
		var difference: Vector2 = target.position - attacker.position
		var in_front := difference.x > -10.0 and difference.x < range_x if attacker.facing == 1 else difference.x < 10.0 and difference.x > -range_x
		if in_front and difference.y > min_y and difference.y < max_y:
			if respect_umbrella and target.umbrella_open and target.facing != attacker.facing:
				if block_ammo_damage > 0.0:
					target.drain_ammo(block_ammo_damage)
				spawn_small_wave(target.position + Vector2(0, -24))
			else:
				target.receive_melee(damage, power, vertical, freeze, attacker, melee_stun)
				spawn_hit_effect(target.position + Vector2(0, -24), attacker.player_color)
				hit_count += 1
	return hit_count

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

func spawn_projectile_trail(at_position: Vector2, color: Color) -> void:
	effects.append({"type": "projectile_trail", "position": at_position, "color": color, "life": 10})

func spawn_shell_eject(_shooter: Node, at_position: Vector2, direction: int, weapon_id: int) -> void:
	# Procedural local feedback until the original shell sprites are integrated.
	var shell_color := Color("e4bd68") if weapon_id != 2 else Color("d8d8c8")
	effects.append({
		"type": "shell",
		"position": at_position + Vector2(0, 4),
		"velocity": Vector2(-direction * randf_range(2.5, 4.5), randf_range(-5.0, -2.5)),
		"rotation": randf_range(-0.4, 0.4),
		"rotation_speed": randf_range(-0.22, 0.22),
		"color": shell_color,
		"life": 24,
	})

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
		players[index].set_perk(player_slot_perks[index])
		players[index].set_weapon(selected_weapons[index])
		players[index].reset_for_match()
		huds[index].shown_health = 100.0
		huds[index].visible = true

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color.BLACK, true)
	draw_texture(map_texture, Vector2.ZERO)

	var font := ThemeDB.fallback_font
	if not round_started:
		if menu_screen == MenuScreen.MAIN:
			draw_main_menu(font)
		elif menu_screen == MenuScreen.CUSTOM_MODE:
			draw_custom_mode_menu(font)
		elif menu_screen == MenuScreen.MAP_SELECTION:
			draw_map_selection(font)
		elif menu_screen == MenuScreen.PLAYER_SETUP:
			draw_player_setup(font)
		elif menu_screen == MenuScreen.PLAYER_MODAL:
			draw_player_setup(font)
			draw_player_modal(font)
		elif menu_screen == MenuScreen.SETTINGS:
			draw_settings_menu(font)
		elif menu_screen == MenuScreen.RESERVED:
			draw_reserved_menu(font)
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
			"projectile_trail":
				draw_circle(effect_position, 1.5 + life * 0.18, Color(effect_color, life / 16.0))
			"shell":
				draw_set_transform(effect_position, float(effect["rotation"]), Vector2.ONE)
				draw_rect(Rect2(-3, -1.5, 6, 3), Color(effect_color, minf(1.0, life / 8.0)), true)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
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

func menu_text(english: String, chinese: String) -> String:
	return chinese if use_chinese else english

func weapon_menu_name(weapon_id: int) -> String:
	var chinese_names := {
		1: "沙鹰", 2: "双持冷酷手枪", 3: "愤怒之牛", 4: "闪耀手枪", 5: "武士刀",
		6: "散弹枪", 7: "M4", 8: "追踪导弹", 9: "AK-47", 10: "棒球棍",
		11: "弓", 12: "狙击枪", 13: "MP5K", 14: "UZI", 15: "迷你机枪",
		16: "雨伞", 17: "飞刀", 18: "炸弹",
	}
	return str(chinese_names.get(weapon_id, WeaponCatalog.weapon_name_for(weapon_id))) if use_chinese else WeaponCatalog.weapon_name_for(weapon_id)

func perk_menu_name(perk_id: int) -> String:
	var english_names := ["NO PERK", "3X JUMP", "RECOIL", "AMMO", "RANDOM", "INFINITE"]
	var chinese_names := ["无技能", "三段跳", "无后坐", "额外弹药", "随机武器", "无限弹药"]
	return (chinese_names if use_chinese else english_names)[clampi(perk_id, 0, 5)]

func menu_hovered(rect: Rect2) -> bool:
	return rect.has_point(menu_mouse_position)

func draw_hover_feedback(rect: Rect2, accent: Color = Color("ffd166")) -> void:
	if not menu_hovered(rect):
		return
	var pulse := 0.22 + 0.10 * (0.5 + 0.5 * sin(menu_hover_pulse * TAU))
	draw_rect(rect.grow(3.0), Color(accent, pulse), false, 3.0)
	draw_line(rect.position + Vector2(4, rect.size.y - 3), rect.position + Vector2(rect.size.x - 4, rect.size.y - 3), Color(accent, 0.9), 2.0)

func draw_settings_menu(font: Font) -> void:
	draw_striped_menu_background()
	draw_menu_header(font, menu_text("CONTROLS & SETTINGS", "控制与设置"))
	draw_string(font, Vector2(40, 132), menu_text("LANGUAGE", "语言"), HORIZONTAL_ALIGNMENT_LEFT, 260, 28, Color.WHITE)
	var language_rect := Rect2(240, 180, 520, 66)
	draw_rect(language_rect, Color("ff7a00") if settings_cursor == 0 else Color("f2f2f2"), true)
	draw_rect(language_rect, Color("121212"), false, 3.0)
	draw_string(font, language_rect.position + Vector2(22, 42), menu_text("English", "中文"), HORIZONTAL_ALIGNMENT_LEFT, 280, 25, Color("161616"))
	draw_string(font, language_rect.position + Vector2(350, 42), menu_text("中文", "English"), HORIZONTAL_ALIGNMENT_LEFT, 130, 20, Color("303030"))
	draw_hover_feedback(language_rect, Color("43a6ff"))

	var back_rect := Rect2(240, 350, 520, 66)
	draw_rect(back_rect, Color("ad0000") if settings_cursor == 1 else Color("7a1212"), true)
	draw_rect(back_rect, Color("111111"), false, 3.0)
	draw_string(font, back_rect.position + Vector2(22, 42), menu_text("Back to Main Menu", "返回主菜单"), HORIZONTAL_ALIGNMENT_LEFT, 360, 24, Color.WHITE)
	draw_hover_feedback(back_rect, Color("ff7a7a"))
	draw_string(font, Vector2(40, 510), menu_text("↑ ↓ SELECT    Z / ← → TOGGLE    X / ESC BACK", "↑ ↓ 选择    Z / ← → 切换    X / ESC 返回"), HORIZONTAL_ALIGNMENT_LEFT, 700, 15, Color("e6e6e6"))

func draw_main_menu(font: Font) -> void:
	var blue := Color("43a6ff")
	var gold := Color("ffd166")
	var menu_items := [
		menu_text("Single Player", "单人游戏"),
		menu_text("Custom Game", "自定义游戏"),
		menu_text("Controls & Settings", "控制与设置"),
		menu_text("More Games", "更多游戏"),
		menu_text("Credits", "制作人员"),
	]
	var pulse := 0.75 + 0.25 * sin(float(Time.get_ticks_msec()) / 260.0)

	# Static replacement for the original two-AI battle reel.
	draw_rect(Rect2(0, 0, 1000, 560), Color(0.02, 0.04, 0.035, 0.28), true)
	draw_rect(Rect2(24, 22, 952, 516), Color(0.02, 0.025, 0.035, 0.18), false, 2.0)
	draw_string(font, Vector2(42, 83), menu_text("GUN MAYHEM", "混乱大枪战"), HORIZONTAL_ALIGNMENT_LEFT, 600, 58, Color.WHITE)
	draw_string(font, Vector2(602, 83), "REDUX", HORIZONTAL_ALIGNMENT_LEFT, 330, 58, Color(0.05, 0.07, 0.06, 0.92))
	draw_line(Vector2(44, 104), Vector2(565, 104), Color.WHITE, 7.0)
	draw_string(font, Vector2(48, 132), menu_text("MAYHEM ARENA  //  STATIC BATTLE PREVIEW", "混乱竞技场  //  静态战斗预览"), HORIZONTAL_ALIGNMENT_LEFT, 520, 13, Color(0.95, 0.9, 0.7, pulse))

	for index in menu_items.size():
		var item_y := 300.0 + index * 42.0
		var selected := main_menu_cursor == index
		if selected:
			draw_rect(Rect2(705, item_y - 29, 250, 35), Color(0.02, 0.03, 0.04, 0.72), true)
			draw_rect(Rect2(705, item_y - 29, 6, 35), blue if index == 1 else gold, true)
		draw_hover_feedback(Rect2(705, item_y - 29, 250, 35), blue if index == 1 else gold)
		draw_string(font, Vector2(723, item_y), str(menu_items[index]), HORIZONTAL_ALIGNMENT_LEFT, 225, 23, Color.WHITE if selected else Color(0.92, 0.95, 0.93, 0.86))

	draw_rect(Rect2(30, 475, 195, 54), Color(0.02, 0.03, 0.04, 0.72), true)
	draw_string(font, Vector2(48, 508), menu_text("↑ ↓  SELECT", "↑ ↓ 选择"), HORIZONTAL_ALIGNMENT_LEFT, 175, 15, Color.WHITE)
	draw_string(font, Vector2(710, 523), menu_text("Z  ENTER    X / ESC  BACK", "Z  确认    X / ESC  返回"), HORIZONTAL_ALIGNMENT_LEFT, 250, 13, Color(0.9, 0.93, 0.98))
	draw_string(font, Vector2(40, 550), menu_text("STATIC PREVIEW PLACEHOLDER · AI BATTLE REEL RESERVED", "静态预览占位 · AI 对战动态回放待接入"), HORIZONTAL_ALIGNMENT_LEFT, 850, 11, Color(1, 1, 1, 0.72))

func draw_custom_mode_menu(font: Font) -> void:
	var orange := Color("ff6b0a")
	var green := Color("00b80b")
	var dark := Color(0.12, 0.13, 0.15, 0.97)
	var modes := [menu_text("Free For All", "自由混战"), menu_text("Team Deathmatch", "团队死斗"), menu_text("Domination", "据点争夺")]
	draw_rect(Rect2(0, 0, 1000, 560), dark, true)
	draw_rect(Rect2(18, 16, 964, 64), Color("646464"), true)
	draw_rect(Rect2(18, 16, 964, 64), Color("141414"), false, 3.0)
	draw_string(font, Vector2(36, 61), menu_text("CUSTOM GAME", "自定义游戏"), HORIZONTAL_ALIGNMENT_LEFT, 500, 34, Color.WHITE)
	draw_string(font, Vector2(36, 125), menu_text("SELECT GAME MODE", "选择游戏模式"), HORIZONTAL_ALIGNMENT_LEFT, 500, 27, Color.WHITE)

	for index in modes.size():
		var row := Rect2(38, 150 + index * 62, 470, 50)
		var selected := custom_mode_cursor == index
		draw_rect(row, orange if selected else Color("f2f2f2"), true)
		draw_rect(row, Color("111111"), false, 3.0)
		draw_hover_feedback(row, orange)
		draw_string(font, row.position + Vector2(12, 34), modes[index], HORIZONTAL_ALIGNMENT_LEFT, 380, 23, Color("111111"))
		if selected:
			draw_string(font, row.position + Vector2(410, 35), "✓", HORIZONTAL_ALIGNMENT_LEFT, 40, 28, green)

	draw_rect(Rect2(550, 150, 410, 210), Color("f2f2f2"), true)
	draw_rect(Rect2(550, 150, 410, 210), Color("111111"), false, 3.0)
	draw_string(font, Vector2(574, 195), modes[custom_mode_cursor], HORIZONTAL_ALIGNMENT_LEFT, 350, 28, Color("111111"))
	if custom_mode_cursor == 0:
		draw_string(font, Vector2(574, 235), menu_text("Last player standing wins.", "最后存活者获胜。"), HORIZONTAL_ALIGNMENT_LEFT, 350, 16, Color("111111"))
		draw_string(font, Vector2(574, 274), menu_text("100 points per elimination", "每次淘汰 100 分"), HORIZONTAL_ALIGNMENT_LEFT, 350, 15, Color("222222"))
		draw_string(font, Vector2(574, 300), menu_text("10 points per weapon crate", "每个武器箱 10 分"), HORIZONTAL_ALIGNMENT_LEFT, 350, 15, Color("222222"))
	else:
		draw_string(font, Vector2(574, 235), menu_text("Reserved interface", "界面预留"), HORIZONTAL_ALIGNMENT_LEFT, 350, 17, Color("555555"))
		draw_string(font, Vector2(574, 274), menu_text("This mode is not implemented yet.", "该模式暂未实现。"), HORIZONTAL_ALIGNMENT_LEFT, 350, 15, Color("555555"))

	var options_rect := Rect2(550, 382, 410, 52)
	draw_rect(options_rect, Color("646464"), true)
	draw_hover_feedback(options_rect, Color("ffd166"))
	draw_string(font, Vector2(585, 417), menu_text("⚙  CUSTOM OPTIONS  ·  RESERVED", "⚙  自定义选项 · 预留接口"), HORIZONTAL_ALIGNMENT_LEFT, 350, 19, Color.WHITE)
	var back_rect := Rect2(24, 480, 185, 54)
	draw_rect(back_rect, Color("a40000"), true)
	draw_hover_feedback(back_rect, Color("ff7a7a"))
	draw_string(font, Vector2(45, 516), menu_text("X  BACK", "X  返回"), HORIZONTAL_ALIGNMENT_LEFT, 140, 24, Color.WHITE)
	var continue_rect := Rect2(230, 480, 746, 54)
	draw_rect(continue_rect, green if custom_mode_cursor == 0 else Color("4a4a4a"), true)
	draw_hover_feedback(continue_rect, Color("7dff7d"))
	draw_string(font, Vector2(260, 516), menu_text("Z  CONTINUE", "Z  继续"), HORIZONTAL_ALIGNMENT_LEFT, 680, 25, Color.WHITE)

func draw_reserved_menu(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color(0.07, 0.08, 0.1, 1.0), true)
	draw_rect(Rect2(24, 20, 952, 62), Color("5a5a5a"), true)
	draw_string(font, Vector2(48, 61), reserved_menu_title, HORIZONTAL_ALIGNMENT_LEFT, 650, 34, Color.WHITE)
	draw_string(font, Vector2(0, 245), menu_text("INTERFACE RESERVED", "界面功能预留"), HORIZONTAL_ALIGNMENT_CENTER, 1000, 34, Color("ffd166"))
	draw_string(font, Vector2(0, 290), menu_text("This feature is intentionally not implemented in the current phase.", "该功能暂未在当前阶段实现。"), HORIZONTAL_ALIGNMENT_CENTER, 1000, 16, Color("d0d4db"))
	draw_string(font, Vector2(0, 510), menu_text("X / ESC  BACK TO MAIN MENU", "X / ESC  返回主菜单"), HORIZONTAL_ALIGNMENT_CENTER, 1000, 18, Color.WHITE)

func draw_striped_menu_background() -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color("252525"), true)
	for index in range(-8, 32):
		var x := float(index * 42)
		draw_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + 18, 0), Vector2(x - 180, 560), Vector2(x - 198, 560)]), PackedColorArray([Color(0.18, 0.18, 0.18, 0.22)]))

func draw_menu_header(font: Font, title: String) -> void:
	draw_rect(Rect2(18, 12, 964, 68), Color("656565"), true)
	draw_rect(Rect2(18, 12, 964, 68), Color("161616"), false, 3.0)
	draw_string(font, Vector2(30, 60), title, HORIZONTAL_ALIGNMENT_LEFT, 700, 36, Color.WHITE)
	draw_shield_icon(Vector2(935, 45), 0.8)

func draw_shield_icon(center: Vector2, scale_value: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(-27, -30) * scale_value,
		center + Vector2(27, -30) * scale_value,
		center + Vector2(22, 14) * scale_value,
		center + Vector2(0, 35) * scale_value,
		center + Vector2(-22, 14) * scale_value,
	])
	draw_colored_polygon(points, Color("d7d7d7"))
	draw_polyline(points + PackedVector2Array([points[0]]), Color("141414"), 4.0 * scale_value)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-17, -17) * scale_value,
		center + Vector2(17, -17) * scale_value,
		center + Vector2(14, 10) * scale_value,
		center + Vector2(0, 25) * scale_value,
		center + Vector2(-14, 10) * scale_value,
	]), Color("236ca7"))

func draw_map_selection(font: Font) -> void:
	draw_striped_menu_background()
	draw_menu_header(font, menu_text("CUSTOM GAME", "自定义游戏"))
	draw_string(font, Vector2(28, 118), menu_text("MAP SELECTION", "地图选择"), HORIZONTAL_ALIGNMENT_LEFT, 360, 25, Color.WHITE)
	var map_names := [menu_text("RANDOM", "随机"), menu_text("Forest Fight", "森林战场"), menu_text("Beanstalk Brawl", "豆茎混战"), menu_text("Swamp Struggle", "沼泽争斗"), menu_text("Cloudy Conflict", "云端冲突"), menu_text("Cake Combat", "蛋糕战场"), menu_text("Bookshelf Battle", "书架战斗"), menu_text("Mushroom Melee", "蘑菇混战"), menu_text("Frozen Feud", "冰原对决"), menu_text("Waterfall Warfare", "瀑布战役"), menu_text("Floating Platforms", "浮空平台")]
	for index in map_names.size():
		var row := Rect2(22, 128 + index * 34, 316, 29)
		var selected := map_menu_cursor == index
		draw_rect(row, Color("ff6b0a") if selected else Color("f4f4f4"), true)
		draw_rect(row, Color("141414"), false, 2.0)
		draw_hover_feedback(row, Color("ff9f43"))
		draw_string(font, row.position + Vector2(9, 21), map_names[index], HORIZONTAL_ALIGNMENT_LEFT, 292, 16, Color("151515"))

	var preview := Rect2(362, 105, 600, 360)
	draw_rect(preview, Color("f0f0f0"), true)
	draw_rect(preview, Color("101010"), false, 3.0)
	draw_texture_rect(map_texture, Rect2(preview.position + Vector2(20, 20), Vector2(560, 302)), false, Color.WHITE)
	draw_rect(Rect2(preview.position + Vector2(20, 20), Vector2(560, 302)), Color("161616"), false, 2.0)
	draw_string(font, preview.position + Vector2(20, 345), menu_text("MIRRORED", "镜像地图"), HORIZONTAL_ALIGNMENT_LEFT, 240, 19, Color("202020"))
	draw_string(font, Vector2(670, 450), menu_text("%d PLAYABLE LEDGES" % platforms.size(), "%d 个可玩平台" % platforms.size()), HORIZONTAL_ALIGNMENT_RIGHT, 250, 13, Color("202020"))

	draw_rect(Rect2(22, 493, 185, 44), Color("ad0000"), true)
	draw_hover_feedback(Rect2(22, 493, 185, 44), Color("ff7a7a"))
	draw_string(font, Vector2(39, 523), menu_text("BACK", "返回"), HORIZONTAL_ALIGNMENT_LEFT, 150, 22, Color.WHITE)
	var continue_rect := Rect2(222, 493, 756, 44)
	draw_rect(continue_rect, Color("00a900"), true)
	draw_hover_feedback(continue_rect, Color("7dff7d"))
	draw_string(font, Vector2(252, 523), menu_text("CONTINUE", "继续"), HORIZONTAL_ALIGNMENT_LEFT, 680, 22, Color.WHITE)
	draw_string(font, Vector2(30, 550), menu_text("↑ ↓ SELECT MAP    Z CONTINUE    X / ESC BACK", "↑ ↓ 选择地图    Z 继续    X / ESC 返回"), HORIZONTAL_ALIGNMENT_LEFT, 760, 12, Color("e6e6e6"))

func draw_player_setup(font: Font) -> void:
	draw_striped_menu_background()
	draw_menu_header(font, menu_text("CUSTOM GAME", "自定义游戏"))
	draw_string(font, Vector2(30, 94), menu_text("PLAYER SETUP", "玩家设置"), HORIZONTAL_ALIGNMENT_LEFT, 300, 23, Color.WHITE)
	draw_string(font, Vector2(650, 94), menu_text("MAP %02d  ·  FREE FOR ALL" % selected_map, "地图 %02d  ·  自由混战" % selected_map), HORIZONTAL_ALIGNMENT_RIGHT, 320, 13, Color("ffd166"))
	for slot in 4:
		draw_player_slot_card(font, slot, player_card_rect(slot))

	draw_rect(Rect2(22, 493, 185, 44), Color("ad0000"), true)
	draw_hover_feedback(Rect2(22, 493, 185, 44), Color("ff7a7a"))
	draw_string(font, Vector2(39, 523), menu_text("BACK", "返回"), HORIZONTAL_ALIGNMENT_LEFT, 150, 22, Color.WHITE)
	var start_rect := Rect2(222, 493, 756, 44)
	draw_rect(start_rect, Color("00a900"), true)
	draw_hover_feedback(start_rect, Color("7dff7d"))
	draw_string(font, Vector2(252, 523), menu_text("START!", "开始！"), HORIZONTAL_ALIGNMENT_LEFT, 680, 22, Color.WHITE)
	draw_string(font, Vector2(30, 550), menu_text("CLICK GUN / PERK TO CUSTOMIZE    P1 Z READY    P2 T READY", "点击武器 / 技能自定义    P1 Z 准备    P2 T 准备"), HORIZONTAL_ALIGNMENT_LEFT, 860, 12, Color("e6e6e6"))

func draw_player_slot_card(font: Font, slot: int, card: Rect2) -> void:
	var color: Color = player_slot_colors[slot]
	var weapon_id: int = selected_weapons[slot] if slot < selected_weapons.size() else 1
	var weapon := WeaponCatalog.get_weapon(weapon_id)
	var is_active := slot < players.size()
	draw_rect(card, Color("f5f5f5"), true)
	draw_rect(card, Color("111111"), false, 3.0)
	draw_rect(Rect2(card.position + Vector2(20, 16), Vector2(card.size.x - 40, 30)), Color("d69a9d"), true)
	draw_string(font, card.position + Vector2(30, 38), menu_text("CLEAR SLOT", "清空槽位"), HORIZONTAL_ALIGNMENT_LEFT, 145, 16, Color("4b2730"))
	draw_string(font, card.position + Vector2(190, 38), "×", HORIZONTAL_ALIGNMENT_LEFT, 24, 25, Color("e60000"))
	draw_string(font, card.position + Vector2(26, 70), menu_text("name:", "名称："), HORIZONTAL_ALIGNMENT_LEFT, 100, 12, Color("585858"))
	draw_rect(Rect2(card.position + Vector2(20, 76), Vector2(card.size.x - 40, 27)), Color("bfe4f8"), true)
	draw_string(font, card.position + Vector2(28, 96), player_slot_names[slot], HORIZONTAL_ALIGNMENT_LEFT, 175, 15, Color("1d2e3c"))
	if slot > 0:
		draw_string(font, card.position + Vector2(0, 122), menu_text("AI PLAYER", "AI 玩家"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 18, Color("e32323"))

	var preview_player := mini(slot, players.size() - 1)
	var avatar_rect := Rect2(card.position + Vector2(22, 112), Vector2(104, 112))
	if weapon_id <= 5:
		var avatar_texture: Texture2D = players[preview_player].texture_for_weapon(weapon_id)
		draw_texture_rect(avatar_texture, avatar_rect, false, Color(1, 1, 1, 0.96))
	else:
		var base_texture: Texture2D = players[preview_player].base_texture_for_display()
		draw_texture_rect(base_texture, Rect2(avatar_rect.position + Vector2(25, 10), Vector2(54, 82)), false, Color(1, 1, 1, 0.96))
		draw_card_weapon_shape(avatar_rect.position + Vector2(66, 62), weapon_id, 1.0)
	for index in 3:
		var label: String = [menu_text("HAT", "帽子"), menu_text("SHIRT", "上衣"), menu_text("FACE", "脸部")][index]
		var edit_rect := Rect2(card.position + Vector2(126, 112 + index * 35), Vector2(80, 29))
		draw_rect(edit_rect, Color("d5d5d5"), true)
		draw_rect(edit_rect, Color("292929"), false, 2.0)
		draw_string(font, edit_rect.position + Vector2(0, 21), label, HORIZONTAL_ALIGNMENT_CENTER, edit_rect.size.x, 14, Color("333333"))

	var color_rect := Rect2(card.position + Vector2(20, 294), Vector2(60, 62))
	draw_rect(color_rect, color, true)
	draw_rect(color_rect, Color("161616"), false, 2.0)
	draw_string(font, card.position + Vector2(18, 376), menu_text("COLOR", "颜色"), HORIZONTAL_ALIGNMENT_LEFT, 70, 13, Color("303030"))
	var gun_rect := Rect2(card.position + Vector2(94, 294), Vector2(65, 62))
	draw_rect(gun_rect, Color("e4e4e4"), true)
	draw_rect(gun_rect, Color("161616"), false, 2.0)
	draw_hover_feedback(gun_rect, Color("ff9f43"))
	if is_active:
		if weapon_id <= 5:
			var gun_texture: Texture2D = players[preview_player].texture_for_weapon(weapon_id)
			draw_texture_rect(gun_texture, Rect2(gun_rect.position + Vector2(5, 3), Vector2(55, 48)), false, Color(1, 1, 1, 0.72))
		else:
			draw_card_weapon_shape(gun_rect.get_center() + Vector2(0, -5), weapon_id, 0.75)
	draw_string(font, gun_rect.position + Vector2(0, 59), menu_text("GUN", "武器"), HORIZONTAL_ALIGNMENT_CENTER, gun_rect.size.x, 13, Color("303030"))
	var perk_rect := Rect2(card.position + Vector2(169, 294), Vector2(43, 62))
	draw_rect(perk_rect, Color("f1f1f1"), true)
	draw_rect(perk_rect, Color("161616"), false, 2.0)
	draw_hover_feedback(perk_rect, Color("71d24c"))
	draw_perk_icon(perk_rect.position + Vector2(21, 26), player_slot_perks[slot], 0.72)
	draw_string(font, perk_rect.position + Vector2(-3, 59), menu_text("PERK", "技能"), HORIZONTAL_ALIGNMENT_CENTER, 50, 11, Color("303030"))
	var status_text := menu_text("READY", "已准备") if slot < 2 and players_ready[slot] else (menu_text("ACTIVE", "玩家") if is_active else menu_text("RESERVED", "预留"))
	draw_string(font, card.position + Vector2(20, 416), status_text, HORIZONTAL_ALIGNMENT_LEFT, 150, 12, Color("159447") if is_active else Color("777777"))

func draw_card_weapon_shape(center: Vector2, weapon_id: int, scale_value: float) -> void:
	var length := 30.0 * scale_value
	var color := Color("d9dce3")
	match weapon_id:
		6:
			draw_line(center + Vector2(-length, 5), center + Vector2(length, 5), Color("e6a15b"), 6.0 * scale_value)
			draw_line(center + Vector2(4, 0), center + Vector2(length, 0), color, 3.0 * scale_value)
		7, 9, 13, 14:
			draw_line(center + Vector2(-length, 3), center + Vector2(length + 8, 3), Color("586775"), 5.0 * scale_value)
			draw_line(center + Vector2(3, -2), center + Vector2(length + 5, -2), color, 2.0 * scale_value)
		8:
			draw_line(center + Vector2(-length, 3), center + Vector2(length + 8, 3), Color("ff7a3d"), 7.0 * scale_value)
			draw_circle(center + Vector2(length + 8, 3), 4.0 * scale_value, Color("522a25"))
		10:
			draw_line(center + Vector2(-length, 3), center + Vector2(length, 3), Color("8b542f"), 6.0 * scale_value)
			draw_line(center + Vector2(length - 2, -5), center + Vector2(length + 8, 6), Color("d6a36a"), 5.0 * scale_value)
		11:
			draw_arc(center + Vector2(-2, 5), 13.0 * scale_value, -1.2, 1.2, 12, Color("8dcf85"), 2.0 * scale_value)
			draw_line(center + Vector2(0, 5), center + Vector2(length + 8, -2), color, 2.0 * scale_value)
		12:
			draw_line(center + Vector2(-length, 2), center + Vector2(length + 12, 2), color, 4.0 * scale_value)
		15:
			draw_line(center + Vector2(-length, 3), center + Vector2(length + 10, 3), Color("bf9b45"), 8.0 * scale_value)
			draw_circle(center + Vector2(length + 8, 3), 4.0 * scale_value, Color("4a4e55"))
		16:
			draw_line(center + Vector2(-length, 3), center + Vector2(length, 3), Color("79563f"), 3.0 * scale_value)
			draw_arc(center + Vector2(length - 1, -9), 13.0 * scale_value, PI, TAU, 12, Color("78a8d8"), 5.0 * scale_value)
		17:
			draw_line(center + Vector2(-length, 2), center + Vector2(length + 8, 2), color, 3.0 * scale_value)
			draw_line(center + Vector2(-3, -3), center + Vector2(-3, 7), Color("8b5a3c"), 3.0 * scale_value)
		18:
			draw_circle(center + Vector2(5, 3), 7.0 * scale_value, Color("282b31"))
			draw_circle(center + Vector2(8, 0), 2.0 * scale_value, Color("ffb000"))

func draw_player_modal(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color(0, 0, 0, 0.72), true)
	var panel := Rect2(108, 70, 784, 420)
	draw_rect(panel, Color("3e3e3e"), true)
	draw_rect(panel, Color("111111"), false, 3.0)
	draw_rect(Rect2(panel.position + Vector2(22, 22), Vector2(panel.size.x - 44, 62)), Color("686868"), true)
	draw_rect(Rect2(panel.position + Vector2(22, 22), Vector2(panel.size.x - 44, 62)), Color("171717"), false, 3.0)
	var title := menu_text("PRIMARY WEAPON", "主武器") if player_modal_kind == 1 else menu_text("PERKS", "额外技能")
	draw_string(font, panel.position + Vector2(40, 68), title, HORIZONTAL_ALIGNMENT_LEFT, 560, 32, Color.WHITE)
	draw_string(font, panel.position + Vector2(585, 64), "PLAYER %d" % (selected_player_slot + 1), HORIZONTAL_ALIGNMENT_RIGHT, 120, 14, player_slot_colors[selected_player_slot])

	if player_modal_kind == 1:
		var item_width := 108.0
		for index in 5:
			var weapon_id: int = index + 1
			var icon_rect := Rect2(174 + index * item_width, 154, item_width - 8, 112)
			var selected := player_modal_cursor == index
			draw_rect(icon_rect, Color("ff7a00") if selected else Color("4f4f4f"), true)
			draw_rect(icon_rect, Color("121212"), false, 2.0)
			draw_hover_feedback(icon_rect, Color("ffd166"))
			var preview_player := mini(selected_player_slot, players.size() - 1)
			var icon_texture: Texture2D = players[preview_player].texture_for_weapon(weapon_id)
			draw_texture_rect(icon_texture, Rect2(icon_rect.position + Vector2(15, 5), Vector2(76, 74)), false, Color.WHITE)
			draw_string(font, icon_rect.position + Vector2(4, 101), weapon_menu_name(weapon_id), HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x - 8, 10, Color.WHITE)
		var weapon := WeaponCatalog.get_weapon(player_modal_cursor + 1)
		draw_modal_weapon_details(font, panel, weapon)
	else:
		var perk_names := [perk_menu_name(0), perk_menu_name(1), perk_menu_name(2), perk_menu_name(3), perk_menu_name(4), perk_menu_name(5)]
		for index in perk_names.size():
			var item_width := 94.0
			var icon_rect := Rect2(146 + index * item_width, 154, item_width - 8, 112)
			var selected := player_modal_cursor == index
			draw_rect(icon_rect, Color("ff7a00") if selected else Color("4f4f4f"), true)
			draw_rect(icon_rect, Color("121212"), false, 2.0)
			draw_hover_feedback(icon_rect, Color("ffd166"))
			draw_perk_icon(icon_rect.position + Vector2(icon_rect.size.x * 0.5, 42), index, 1.0)
			draw_string(font, icon_rect.position + Vector2(3, 101), perk_names[index], HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x - 6, 10, Color.WHITE)
		var perk_descriptions := [
			menu_text("You are too skilled to use perks. Choose a perk to change your strategy.", "你的技术足够好了。选择技能来改变策略。"),
			menu_text("Large increase in vertical movement. Greatly increases survivability.", "大幅提升垂直移动能力，提高生存率。"),
			menu_text("Increased mobility. You will no longer be pushed back by your weapon fire.", "提升机动性，开火时不再被自己的武器击退。"),
			menu_text("All weapons start with an additional 33% ammo.", "所有武器初始弹药增加 33%。"),
			menu_text("Start each life with a random weapon from the crate weapon pool.", "每条命开始时从武器箱池随机获得武器。"),
			menu_text("Your primary weapon never needs to reload.", "主武器永远不需要换弹。"),
		]
		var perk_description: String = perk_descriptions[player_modal_cursor]
		draw_modal_text_details(font, panel, perk_names[player_modal_cursor], perk_description)

	var back_rect := Rect2(735, 458, 190, 52)
	draw_rect(back_rect, Color("ad0000"), true)
	draw_hover_feedback(back_rect, Color("ff7a7a"))
	draw_string(font, Vector2(755, 493), menu_text("BACK", "返回"), HORIZONTAL_ALIGNMENT_LEFT, 150, 22, Color.WHITE)

func draw_modal_weapon_details(font: Font, panel: Rect2, weapon: Dictionary) -> void:
	draw_rect(Rect2(panel.position + Vector2(32, 285), Vector2(520, 126)), Color("686868"), true)
	draw_rect(Rect2(panel.position + Vector2(32, 285), Vector2(520, 126)), Color("151515"), false, 2.0)
	draw_string(font, panel.position + Vector2(50, 319), weapon_menu_name(int(weapon.get("id", player_modal_cursor + 1))), HORIZONTAL_ALIGNMENT_LEFT, 250, 23, Color.WHITE)
	draw_string(font, panel.position + Vector2(50, 344), menu_text(str(weapon["tagline"]), weapon_menu_name(int(weapon.get("id", player_modal_cursor + 1))) + " · 原版参数"), HORIZONTAL_ALIGNMENT_LEFT, 280, 13, Color("202020"))
	var labels := [menu_text("damage", "伤害"), menu_text("knockback", "击退"), menu_text("rate of fire", "射速"), menu_text("ammo capacity", "弹药容量"), menu_text("reload time", "换弹时间")]
	for index in labels.size():
		var y := 363.0 + index * 13.0
		draw_string(font, panel.position + Vector2(55, y), labels[index], HORIZONTAL_ALIGNMENT_RIGHT, 105, 10, Color("f1f1f1"))
		draw_rect(Rect2(panel.position + Vector2(170, y - 8), Vector2(92, 7)), Color("303030"), true)
		draw_rect(Rect2(panel.position + Vector2(170, y - 8), Vector2(35 + index * 10, 7)), Color("eeeeee"), true)
	draw_string(font, panel.position + Vector2(318, 330), menu_text("Primary fire:  %s" % weapon["primary_label"], "普通攻击：%s" % weapon["primary_label"]), HORIZONTAL_ALIGNMENT_LEFT, 220, 13, Color.WHITE)
	draw_string(font, panel.position + Vector2(318, 355), menu_text("Secondary fire:  %s" % weapon["secondary_label"], "特殊攻击：%s" % weapon["secondary_label"]), HORIZONTAL_ALIGNMENT_LEFT, 250, 13, Color.WHITE)
	draw_string(font, panel.position + Vector2(318, 380), menu_text("Notes:  Redux reference weapon", "说明：Redux 原版参考武器"), HORIZONTAL_ALIGNMENT_LEFT, 250, 12, Color.WHITE)

func draw_modal_text_details(font: Font, panel: Rect2, title: String, description: String) -> void:
	draw_rect(Rect2(panel.position + Vector2(32, 285), Vector2(620, 126)), Color("686868"), true)
	draw_rect(Rect2(panel.position + Vector2(32, 285), Vector2(620, 126)), Color("151515"), false, 2.0)
	draw_string(font, panel.position + Vector2(50, 322), title, HORIZONTAL_ALIGNMENT_LEFT, 400, 23, Color.WHITE)
	draw_string(font, panel.position + Vector2(50, 360), description, HORIZONTAL_ALIGNMENT_LEFT, 560, 16, Color("f1f1f1"))
	draw_string(font, panel.position + Vector2(50, 389), menu_text("Z applies selection · X / ESC returns", "Z 确认选择 · X / ESC 返回"), HORIZONTAL_ALIGNMENT_LEFT, 560, 12, Color("222222"))

func draw_perk_icon(center: Vector2, perk_id: int, scale_value: float) -> void:
	var colors := [Color("dadada"), Color("2474df"), Color("f4c542"), Color("f28c28"), Color("71d24c"), Color("7fb2de")]
	var points := PackedVector2Array([
		center + Vector2(0, -27) * scale_value,
		center + Vector2(27, 0) * scale_value,
		center + Vector2(0, 27) * scale_value,
		center + Vector2(-27, 0) * scale_value,
	])
	draw_colored_polygon(points, colors[clampi(perk_id, 0, colors.size() - 1)])
	draw_polyline(points + PackedVector2Array([points[0]]), Color("101010"), 3.0 * scale_value)
	var labels := ["NO", "3X", "R", "AM", "?", "∞"]
	draw_string(ThemeDB.fallback_font, center + Vector2(-21, 6) * scale_value, labels[clampi(perk_id, 0, labels.size() - 1)], HORIZONTAL_ALIGNMENT_CENTER, 42 * scale_value, 16 * scale_value, Color("111111"))
