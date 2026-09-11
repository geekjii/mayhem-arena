extends SceneTree

const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")
const MapCatalog = preload("res://scripts/game/map_catalog.gd")
const GameScript = preload("res://scripts/game/game.gd")
const PlayerScript = preload("res://scripts/players/player.gd")
const WeaponCrateScript = preload("res://scripts/weapons/weapon_crate.gd")
const ProjectileScript = preload("res://scripts/weapons/projectile.gd")
const FontCatalog = preload("res://scripts/ui/font_catalog.gd")
const PlatformGraphScript = preload("res://scripts/ai/platform_graph.gd")
const TestWeaponOverlayScript = preload("res://scripts/ui/test_weapon_overlay.gd")

var failures: Array[String] = []

func expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func near(actual: float, expected: float, tolerance := 0.001) -> bool:
	return absf(actual - expected) <= tolerance

func _init() -> void:
	expect(Engine.physics_ticks_per_second == 35, "physics tick rate must be 35 Hz")
	expect(Engine.max_fps == 35, "render cap must be 35 FPS")
	expect(FontCatalog.supports_required_glyphs(), "project UI font must contain the required Chinese glyphs")
	expect(WeaponCatalog.DEFAULT_WEAPON_IDS.size() == 5, "the selectable default pool must contain five weapons")
	expect(WeaponCatalog.CRATE_WEAPON_IDS.size() == 13, "the complete crate weapon pool must contain thirteen weapons")
	expect(WeaponCatalog.WEAPONS.size() == 18, "the catalog must contain five default and thirteen crate weapons")
	expect(MapCatalog.MAP_TEXTURES.size() == 10, "all ten Redux map art frames must be available")
	for map_id in range(1, 11):
		expect(MapCatalog.scene_layer_for("scene1", map_id) != null, "map %d scene1 layer must be available" % map_id)
		expect(MapCatalog.scene_layer_for("scene2", map_id) != null, "map %d scene2 layer must be available" % map_id)
		expect(MapCatalog.scene_layer_for("scene3", map_id) != null, "map %d scene3 layer must be available" % map_id)
	expect(ResourceLoader.load("res://assets/original_reference/effects/muzzle/1.png") != null, "recursive muzzle flash export must be available")
	expect(ResourceLoader.load("res://assets/original_reference/effects/shell/1.png") != null, "recursive shell export must be available")
	expect(ResourceLoader.load("res://assets/original_reference/effects/shell2/1.png") != null, "recursive shell2 export must be available")
	expect(GameScript.MenuScreen.PLAYER_MODAL != GameScript.MenuScreen.MAIN, "menu screen enum must retain the player modal state")
	for map_id in range(1, 11):
		var map_texture := MapCatalog.texture_for(map_id)
		expect(map_texture.get_width() == 1000 and map_texture.get_height() == 560, "map %d must retain the original 1000 x 560 stage" % map_id)
		expect(not MapCatalog.platforms_for(map_id).is_empty(), "map %d must have playable platform tops" % map_id)
		expect(MapCatalog.spawns_for(map_id).size() == 4, "map %d must provide four local-player slot spawns" % map_id)
		var platform_graph := PlatformGraphScript.new()
		platform_graph.rebuild(MapCatalog.platforms_for(map_id))
		expect(platform_graph.platforms.size() == MapCatalog.platforms_for(map_id).size(), "map %d AI graph must include every playable platform" % map_id)
		var connection_count := 0
		for neighbors in platform_graph.edges.values():
			connection_count += neighbors.size()
		expect(connection_count > 0, "map %d AI graph must provide jump or drop connections" % map_id)
	expect(near(MapCatalog.platforms_for(2)[0].position.y, 110.0), "exported maps 2-10 must receive the scene3 vertical alignment correction")
	for map_id in range(1, 11):
		var reachable_platforms := MapCatalog.platforms_for(map_id)
		for candidate_index in reachable_platforms.size():
			var candidate: Rect2 = reachable_platforms[candidate_index]
			if candidate.size.x >= MapCatalog.SMALL_PLATFORM_WIDTH_LIMIT:
				continue
			var nearest_support_y := 100000.0
			for support_index in reachable_platforms.size():
				if support_index == candidate_index:
					continue
				var support: Rect2 = reachable_platforms[support_index]
				var vertical_gap := support.position.y - candidate.position.y
				var horizontal_gap := MapCatalog.platform_interval_gap(candidate.position.x, candidate.end.x, support.position.x, support.end.x)
				if vertical_gap > 0.0 and horizontal_gap <= MapCatalog.PLATFORM_ROUTE_GAP and absf(candidate.get_center().x - support.get_center().x) <= 300.0:
					nearest_support_y = minf(nearest_support_y, support.position.y)
			expect(nearest_support_y >= 99999.0 or nearest_support_y - candidate.position.y <= MapCatalog.SINGLE_JUMP_VERTICAL_REACH, "map %d small ledges must remain within one standard jump" % map_id)

	var expected_ammo := {1: 9, 2: 24, 3: 6, 4: 14, 5: -1}
	for weapon_id in range(1, 6):
		var weapon := WeaponCatalog.get_weapon(weapon_id)
		expect(int(weapon["ammo"]) == expected_ammo[weapon_id], "weapon %d ammo differs from Redux" % weapon_id)
		expect(weapon.has("primary") and weapon.has("secondary"), "weapon %d must provide both attacks" % weapon_id)

	var sand_hawk := WeaponCatalog.get_weapon(1)
	expect(near(float(sand_hawk["primary"]["firepower"]), 23.0), "Sand Hawk firepower must be 23")
	expect(near(float(sand_hawk["primary"]["firepower"]) * 0.4, 9.2), "Sand Hawk health damage must be 9.2")

	var angry_cow := WeaponCatalog.get_weapon(3)
	expect(near(float(angry_cow["secondary"]["speed"]), 47.0), "Angry Cow aimed shot speed must be 47")
	expect(near(float(angry_cow["secondary"]["firepower"]) * 0.4, 14.8), "Angry Cow aimed damage must be 14.8")
	expect(str(angry_cow["secondary"]["type"]) == "bullet", "Angry Cow secondary must remain a chargeable aimed shot")
	expect(int(angry_cow["secondary"]["charge_frames"]) == 14, "Angry Cow aimed shot must converge for fourteen frames")
	var scattergun := WeaponCatalog.get_weapon(6)
	var rapid_carbine := WeaponCatalog.get_weapon(7)
	expect(int(scattergun["primary"]["ammo_cost"]) == 1 and int(scattergun["secondary"]["ammo_cost"]) == 2, "Scattergun must use one shell normally and two shells for BOOM")
	expect(int(rapid_carbine["primary"].get("ammo_cost", 1)) == 1 and int(rapid_carbine["secondary"]["ammo_cost"]) == 4, "M4 special attack must consume four rounds")
	var expected_crate_names := ["SHOTGUN", "M4", "HOMING MISSILE", "AK-47", "BASEBALL BAT", "BOW", "SNIPER", "MP5K", "UZI", "MINI GUN", "UMBRELLA", "THROWING KNIFE", "BOMB"]
	for index in WeaponCatalog.CRATE_WEAPON_IDS.size():
		var crate_id: int = WeaponCatalog.CRATE_WEAPON_IDS[index]
		var crate_weapon := WeaponCatalog.get_weapon(crate_id)
		expect(str(crate_weapon["name"]) == expected_crate_names[index], "crate weapon %d must retain its original name" % crate_id)
		expect(bool(crate_weapon.get("crate_only", false)), "crate weapon %d must be marked crate-only" % crate_id)
		expect(crate_weapon.has("primary") and crate_weapon.has("secondary"), "crate weapon %d must provide both attacks" % crate_id)
	var sniper := WeaponCatalog.get_weapon(12)
	expect(str(sniper["secondary"]["type"]) == "sniper_stealth", "Sniper secondary must be a stealth action")
	expect(int(sniper["primary"]["cooldown"]) == 18, "Sniper must use the shortened eighteen-frame recovery between aim sequences")
	var knife := WeaponCatalog.get_weapon(17)
	expect(str(knife["primary"]["type"]) == "knife" and str(knife["secondary"]["type"]) == "melee", "Throwing Knife primary must throw and secondary must stab")
	var split_missile := WeaponCatalog.get_weapon(8)
	expect(str(split_missile["secondary"]["type"]) == "homing_split" and int(split_missile["secondary"]["cooldown"]) == 30 and int(split_missile["secondary"]["windup_frames"]) == 4 and int(split_missile["secondary"]["split_frame"]) == 18, "Homing Missile secondary must use a thirty-frame recovery while keeping its windup and split timers separate")
	expect(near(float(split_missile["primary"]["turning"]), 1.1) and int(split_missile["primary"]["homing_deploy_frames"]) == 10, "Homing Missile primary must use the original seek acceleration and ten-frame deployment")
	expect(near(float(split_missile["primary"]["speed"]), 12.0) and near(float(split_missile["primary"]["homing_speed_min"]), 10.0) and near(float(split_missile["primary"]["homing_speed_max"]), 14.0), "Homing Missile primary must use the original launch and randomized capped speeds")
	var bow := WeaponCatalog.get_weapon(11)
	expect(float(bow["primary"]["gravity"]) > 0.24 and near(float(bow["primary"]["gravity"]), float(bow["secondary"]["gravity"])), "both Bow attacks must use the more pronounced shared arc")
	var bomb_weapon := WeaponCatalog.get_weapon(18)
	expect(near(float(bomb_weapon["primary"]["angle"]), -45.0) and near(float(bomb_weapon["secondary"]["angle"]), -45.0), "both Bomb throws must launch forward-up at 45 degrees")
	expect(bool(bomb_weapon["primary"]["platform_collision"]) and not bool(bomb_weapon["secondary"]["platform_collision"]), "Bomb primary must collide with platforms while secondary passes through them")
	expect(not bool(bomb_weapon["secondary"]["detonate_on_expiry"]) and float(bomb_weapon["primary"]["bounce_horizontal_retention"]) >= 0.86, "Bomb secondary must only detonate on a player and primary must retain its doubled rolling reach")
	var mini_gun := WeaponCatalog.get_weapon(15)
	expect(str(mini_gun["secondary"]["type"]) == "minigun_spin" and int(mini_gun["primary"]["startup_frames"]) == 7 and int(mini_gun["primary"]["ramp_frames"]) == 18, "Mini Gun must use a seven-frame startup followed by an eighteen-frame ramp, with a non-firing secondary")

	var displayed_health := 100.0
	for frame in 8:
		displayed_health += (0.0 - displayed_health) / 3.0
	expect(displayed_health < 4.0 and displayed_health > 3.0, "Redux health easing should retain about 3.9% after eight frames")

	var player := PlayerScript.new()
	player.set_weapon(1)
	player.set_perk(1)
	expect(player.max_jump_count() == 3, "Triple Jump perk must increase the jump allowance to three")
	player.set_perk(3)
	player.equip_weapon(1, false)
	expect(player.ammo == 12, "Extra Ammo perk must round Sand Hawk capacity up by 33 percent")
	player.set_perk(2)
	player.equip_weapon(1, false)
	player.velocity.x = 0.0
	player.facing = 1
	player.apply_weapon_recoil(5.0)
	expect(near(player.velocity.x, 0.0), "No Recoil perk must suppress weapon self-recoil")
	player.set_perk(5)
	player.equip_weapon(1, false)
	player.set_perk(4)
	var random_spawn_weapon := player.spawn_weapon_id()
	expect(random_spawn_weapon in WeaponCatalog.CRATE_WEAPON_IDS, "Random Weapon perk must select from the crate weapon pool")
	player.set_perk(0)
	player.set_weapon(1)
	player.set_ai_controlled(true)
	player.set_ai_controls({"right": true, "jump": true, "jump_just": true, "primary": true})
	expect(player.control_pressed("right") and player.control_just_pressed("jump") and player.control_pressed("primary"), "AI must drive the same control interface as a human player")
	player.set_ai_controlled(false)
	expect(player.visual_frame_cache.is_empty(), "weapon selection must not synchronously decode complete animation controllers")
	player.start_weapon_visual("primary")
	expect(player.visual_action_active and player.visual_frame == 1 and player.visual_frame_end == 11, "Sand Hawk primary timeline must start at frame 1 and end at frame 11")
	expect(player.weapon_frame_texture() != null, "the first Sand Hawk action frame must load")
	expect(player.visual_frame_cache.size() == 1, "weapon animation frames must load lazily one frame at a time")
	player.process_visual_animation()
	expect(player.visual_frame == 2, "weapon animation must advance exactly one original frame per 35 Hz tick")
	player.start_reload()
	expect(player.reload_frames == 55, "Sand Hawk reload must retain the original 55-frame sequence")
	expect(player.visual_action_active and player.visual_action == "reload" and player.visual_frame == 58, "reload must switch to the original reload visual timeline")
	player.equip_weapon(6, false)
	expect(player.default_weapon_id == 1, "crate pickup must not replace the selected respawn weapon")
	expect(player.weapon_id == 6 and player.ammo == 6, "crate pickup must equip and refill the contained weapon")
	player.consume_ammo(2)
	expect(player.ammo == 4, "multi-projectile attacks must consume their original shell count")
	player.start_reload()
	expect(player.reload_frames == 12, "empty crate weapons must be discarded quickly instead of reloading")
	player.equip_weapon(9, false)
	player.start_weapon_visual("primary")
	expect(player.visual_frame == 1 and player.visual_frame_end == 32, "AK primary attack must use the extracted 32-frame timeline")
	expect(player.weapon_frame_texture() != null, "AK primary attack must load the extracted composite player frame")
	expect(player.portrait_texture() != null, "crate weapons must use their own composite static portrait instead of a default gun placeholder")
	var cleaned_composite := player.portrait_texture().get_image()
	var backing_pixels := 0
	for y in range(88, mini(167, cleaned_composite.get_height())):
		for x in range(78, mini(139, cleaned_composite.get_width())):
			var pixel := cleaned_composite.get_pixel(x, y)
			if pixel.a > 0.9 and pixel.b > 0.75 and pixel.g > 0.40 and pixel.r < 0.12:
				backing_pixels += 1
	expect(backing_pixels == 0, "crate composite frames must remove the solid player-colour backing block")
	player.process_visual_animation()
	expect(player.visual_frame == 2, "AK composite animation must advance one frame per 35 Hz tick")
	var crate_visual_ranges := {
		6: {"primary": Vector2i(1, 41), "secondary": Vector2i(70, 78)},
		7: {"primary": Vector2i(1, 32), "secondary": Vector2i(50, 79)},
		8: {"primary": Vector2i(1, 39), "secondary": Vector2i(60, 61)},
		9: {"primary": Vector2i(1, 32), "secondary": Vector2i(45, 68)},
		10: {"primary": Vector2i(1, 30), "secondary": Vector2i(42, 76)},
		11: {"primary": Vector2i(1, 21), "secondary": Vector2i(31, 51)},
		12: {"primary": Vector2i(1, 53), "secondary": Vector2i(74, 94)},
		13: {"primary": Vector2i(1, 32), "secondary": Vector2i(50, 65)},
		14: {"primary": Vector2i(1, 32), "secondary": Vector2i(50, 51)},
		15: {"primary": Vector2i(1, 24), "secondary": Vector2i(2, 75)},
		16: {"primary": Vector2i(1, 22), "secondary": Vector2i(35, 46)},
		17: {"primary": Vector2i(20, 42), "secondary": Vector2i(1, 15)},
		18: {"primary": Vector2i(1, 20), "secondary": Vector2i(25, 48)},
	}
	for crate_id in WeaponCatalog.CRATE_WEAPON_IDS:
		player.equip_weapon(crate_id, false)
		player.start_weapon_visual("primary")
		var primary_range: Vector2i = crate_visual_ranges[crate_id]["primary"]
		var primary_start := primary_range.x
		var primary_end := primary_range.y
		expect(player.visual_action_active and player.visual_frame == primary_start and player.visual_frame_end == primary_end, "crate weapon %d primary animation must use its full controller timeline" % crate_id)
		expect(player.weapon_frame_texture() != null, "crate weapon %d primary frame must load from the composite export" % crate_id)
		player.process_visual_animation()
		expect(player.visual_frame == primary_start + 1, "crate weapon %d primary animation must advance one frame per tick" % crate_id)
		player.start_weapon_visual("secondary")
		var secondary_range: Vector2i = crate_visual_ranges[crate_id]["secondary"]
		var secondary_start := secondary_range.x
		var secondary_end := secondary_range.y
		expect(player.visual_action_active and player.visual_frame == secondary_start and player.visual_frame_end == secondary_end, "crate weapon %d secondary animation must use its full controller timeline" % crate_id)
		expect(player.weapon_frame_texture() != null, "crate weapon %d secondary frame must load from the composite export" % crate_id)
	var recolored_crate_player := PlayerScript.new()
	recolored_crate_player.setup(null, 1, Vector2.ZERO, Color("ff355a"), 6)
	recolored_crate_player.start_weapon_visual("primary")
	var recolored_crate_image := recolored_crate_player.weapon_frame_texture().get_image()
	var red_body_pixels := 0
	for pixel_y in range(80, 166):
		for pixel_x in range(84, 136):
			var body_pixel := recolored_crate_image.get_pixel(pixel_x, pixel_y)
			if body_pixel.a > 0.5 and body_pixel.r > body_pixel.b * 1.3 and body_pixel.r > body_pixel.g * 1.3:
				red_body_pixels += 1
	expect(red_body_pixels > 20, "composite crate frames must recolour the player body for P2")
	recolored_crate_player.free()
	player.equip_weapon(1, false)
	var visual_player := PlayerScript.new()
	visual_player.setup(null, 0, Vector2.ZERO, Color("0099ff"), 1)
	var cleaned_preview := visual_player.texture_for_weapon(1).get_image()
	var opaque_palette_pixels := 0
	for pixel_y in cleaned_preview.get_height():
		for pixel_x in cleaned_preview.get_width():
			var pixel := cleaned_preview.get_pixel(pixel_x, pixel_y)
			if pixel.a > 0.9 and visual_player.color_distance(pixel, Color("0099ff")) < 0.14:
				opaque_palette_pixels += 1
	expect(opaque_palette_pixels < 20, "player preview must remove the large palette-color backing blocks")
	visual_player.free()
	player.lives = 2
	player.lose_life()
	expect(player.lives == 1 and near(player.position.y, -500.0), "surviving players must respawn from Redux's original off-screen height")
	expect(player.respawn_invulnerability_frames == 35, "respawning players must receive one second of protection")
	player.health = 100.0
	player.take_damage(20.0, 10.0, 0, null)
	expect(near(player.health, 100.0), "respawn protection must ignore incoming damage")
	player.free()
	var crate := WeaponCrateScript.new()
	expect(crate.weapon_id == 1, "weapon crate script must instantiate")
	crate.free()

	var behavior_game := GameScript.new()
	behavior_game.platforms = [Rect2(-100, 0, 200, 20)]
	var behavior_player := PlayerScript.new()
	behavior_player.setup(behavior_game, 0, Vector2.ZERO, Color("0099ff"), 16)
	behavior_player.set_ai_controlled(true)
	behavior_player.set_ai_controls({"secondary": true})
	behavior_player.process_weapons()
	expect(behavior_player.umbrella_open and behavior_player.umbrella_guard_pose, "Umbrella special must remain in its dedicated open pose while held")
	behavior_player.set_ai_controls({"secondary": false})
	behavior_player.process_weapons()
	expect(not behavior_player.umbrella_open and not behavior_player.umbrella_guard_pose, "Umbrella must close immediately when its input is released")
	behavior_player.equip_weapon(3, false)
	behavior_player.set_ai_controls({"secondary": true})
	behavior_player.process_weapons()
	expect(behavior_player.charged_attack_active and behavior_player.charged_attack_total_frames == 14 and not behavior_player.visual_action_active, "Angry Cow special must aim for fourteen frames without playing its firing animation")
	behavior_player.set_ai_controls({"secondary": false})
	for charge_frame in 14:
		behavior_player.process_weapons()
	expect(not behavior_player.charged_attack_active and behavior_game.get_child_count() > 0 and behavior_player.visual_action_active, "Angry Cow release must create one shot and begin its firing animation on the same tick")
	for child in behavior_game.get_children():
		child.free()
	behavior_player.visual_action_active = false
	behavior_player.secondary_cooldown = 0
	behavior_player.set_ai_controls({"secondary": true})
	behavior_player.process_weapons()
	for held_frame in 18:
		behavior_player.process_weapons()
	expect(behavior_player.charged_attack_active and behavior_game.get_child_count() == 0, "holding Angry Cow after convergence must keep aiming without firing early")
	behavior_player.set_ai_controls({"secondary": false})
	behavior_player.process_weapons()
	expect(not behavior_player.charged_attack_active and behavior_game.get_child_count() == 1, "a long Angry Cow hold must still create exactly one shot on release")
	behavior_player.set_ai_controls({"secondary": true})
	behavior_player.process_weapons()
	expect(not behavior_player.charged_attack_active and behavior_game.get_child_count() == 1, "Angry Cow rapid taps must be ignored until its previous firing animation finishes")
	for child in behavior_game.get_children():
		child.free()
	behavior_player.equip_weapon(12, false)
	behavior_player.set_ai_controls({"secondary": false})
	behavior_player.process_weapons()
	behavior_player.set_ai_controls({"secondary": true})
	behavior_player.process_weapons()
	expect(behavior_player.hidden_from_sniper, "Sniper special must hide the full player")
	behavior_player.take_damage(1.0, 0.0, 0, behavior_player)
	expect(not behavior_player.hidden_from_sniper, "Taking damage must reveal a cloaked Sniper")
	behavior_player.visual_action_active = false
	behavior_player.set_ai_controls({"primary": true})
	behavior_player.process_weapons()
	expect(behavior_player.charged_attack_active and behavior_player.sniper_aim_pose and not behavior_player.visual_action_active, "Sniper press must enter the aim pose without playing a shooting animation")
	for charge_frame in 11:
		behavior_player.process_weapons()
	expect(behavior_player.charged_attack_active and behavior_player.sniper_aim_pose, "Sniper must hold its dedicated aim pose after the eleven-frame windup")
	behavior_player.set_ai_controls({"primary": false})
	behavior_player.process_weapons()
	expect(not behavior_player.sniper_aim_pose and behavior_player.visual_action_active and behavior_game.get_child_count() == 1, "Sniper release must create exactly one bullet and begin its firing animation together")
	behavior_player.set_ai_controls({"primary": true})
	behavior_player.process_weapons()
	expect(not behavior_player.charged_attack_active and behavior_game.get_child_count() == 1, "Sniper rapid taps must be ignored until the previous firing workflow finishes")
	behavior_player.set_ai_controls({"primary": false})
	behavior_player.process_weapons()
	for recovery_frame in 18:
		behavior_player.primary_cooldown = maxi(0, behavior_player.primary_cooldown - 1)
		behavior_player.process_visual_animation()
	expect(behavior_player.visual_action_active, "Sniper's cosmetic firing animation should still be running when its shortened recovery ends")
	behavior_player.set_ai_controls({"primary": true})
	behavior_player.process_weapons()
	expect(behavior_player.charged_attack_active and behavior_player.sniper_aim_pose, "Sniper must accept the next aim after eighteen frames without waiting for the full firing animation")
	for child in behavior_game.get_children():
		child.free()
	var bow_player := PlayerScript.new()
	bow_player.setup(behavior_game, 0, Vector2.ZERO, Color("0099ff"), 11)
	bow_player.set_ai_controlled(true)
	bow_player.set_ai_controls({"primary": true})
	bow_player.process_weapons()
	var bow_start_ammo := bow_player.ammo
	expect(bow_player.bow_primary_armed and behavior_game.get_child_count() == 0 and bow_player.ammo == bow_start_ammo, "Bow primary press and hold must prepare without firing or consuming ammo")
	bow_player.process_weapons()
	expect(behavior_game.get_child_count() == 0 and bow_player.ammo == bow_start_ammo, "holding Bow primary must not create repeated arrows")
	bow_player.set_ai_controls({"primary": false})
	bow_player.process_weapons()
	expect(behavior_game.get_child_count() == 1 and bow_player.ammo == bow_start_ammo - 1, "Bow primary release must create exactly one arrow and consume ammo once")
	for child in behavior_game.get_children():
		child.free()
	bow_player.visual_action_active = false
	bow_player.primary_cooldown = 0
	bow_player.set_ai_controls({"secondary": true})
	bow_player.process_weapons()
	var bow_secondary_ammo := bow_player.ammo
	expect(bow_player.bow_secondary_armed and behavior_game.get_child_count() == 0, "Bow secondary press must prepare without spawning its triple shot")
	bow_player.set_ai_controls({"secondary": false})
	bow_player.process_weapons()
	expect(behavior_game.get_child_count() == 3 and bow_player.ammo == bow_secondary_ammo - 3, "Bow secondary release must create one three-arrow volley and consume three ammo")
	for child in behavior_game.get_children():
		child.free()

	var minigun_player := PlayerScript.new()
	minigun_player.setup(behavior_game, 0, Vector2.ZERO, Color("0099ff"), 15)
	minigun_player.set_ai_controlled(true)
	minigun_player.set_ai_controls({"primary": true})
	for startup_frame in 7:
		minigun_player.process_weapons()
	expect(minigun_player.minigun_startup_active and minigun_player.minigun_startup_frames == 7 and minigun_player.ammo == 150, "Mini Gun must complete seven startup frames without consuming ammo")
	for ramp_frame in 18:
		minigun_player.primary_cooldown = 0
		minigun_player.process_weapons()
	expect(minigun_player.minigun_ramp_frames == 18 and minigun_player.minigun_last_shot_cooldown == 2 and near(minigun_player.minigun_last_shot_recoil, 1.6), "Mini Gun must reach maximum fire rate and stronger recoil only after the following eighteen-frame ramp")
	minigun_player.set_ai_controls({"primary": false})
	minigun_player.process_weapons()
	expect(not minigun_player.minigun_startup_active and minigun_player.minigun_startup_frames == 0 and minigun_player.minigun_ramp_frames == 0, "Mini Gun release must reset both startup and ramp progress")
	var minigun_ammo_after_primary := minigun_player.ammo
	var minigun_children_after_primary := behavior_game.get_child_count()
	minigun_player.set_ai_controls({"secondary": true})
	minigun_player.process_weapons()
	expect(minigun_player.ammo == minigun_ammo_after_primary and behavior_game.get_child_count() == minigun_children_after_primary, "Mini Gun secondary must not create a projectile or consume ammo")
	for child in behavior_game.get_children():
		child.free()

	var homing_player := PlayerScript.new()
	homing_player.setup(behavior_game, 1, Vector2.ZERO, Color("ff355a"), 8)
	homing_player.set_ai_controlled(true)
	homing_player.set_ai_controls({"secondary": true})
	homing_player.process_weapons()
	expect(homing_player.homing_secondary_windup_frames == 4 and behavior_game.get_child_count() == 0, "Homing Missile secondary must begin its short launch windup without spawning early")
	homing_player.set_ai_controls({"secondary": false})
	for windup_frame in 4:
		homing_player.process_weapons()
	expect(behavior_game.get_child_count() == 1 and behavior_game.get_child(0).projectile_kind == "homing_split" and behavior_game.get_child(0).age == 0 and homing_player.secondary_cooldown == 30, "Homing Missile split timer must start after the windup with its shortened recovery applied")
	for child in behavior_game.get_children():
		child.free()

	var bomb := ProjectileScript.new()
	bomb.setup(behavior_game, minigun_player, Vector2(0, -1), 1, 40.0, 0.0, 0.0, 32.0, 0, false, {"kind": "bomb", "bounce": false, "gravity": 1.26, "blast_radius": 50.0, "platform_collision": true})
	bomb._physics_process(0.0)
	bomb._physics_process(0.0)
	expect(bomb.bomb_detonation_frames == 4 and not bomb.is_queued_for_deletion(), "Bomb platform contact must start a four-frame fuse instead of detonating immediately")
	bomb.free()
	var bouncy_bomb := ProjectileScript.new()
	bouncy_bomb.setup(behavior_game, minigun_player, Vector2(0, -1), 1, 40.0, 0.0, 0.0, 32.0, 0, false, {"kind": "bomb", "bounce": true, "gravity": 1.26, "blast_radius": 50.0, "platform_collision": true, "bounce_horizontal_retention": 0.86, "roll_horizontal_retention": 0.75})
	bouncy_bomb._physics_process(0.0)
	bouncy_bomb._physics_process(0.0)
	expect(bouncy_bomb.bomb_detonation_frames < 0 and bouncy_bomb.velocity.y < 0.0, "Normal bomb must bounce on its first platform contact instead of exploding or arming")
	for bounce_frame in 40:
		if bouncy_bomb.bomb_detonation_frames >= 0:
			break
		bouncy_bomb._physics_process(0.0)
	expect(bouncy_bomb.bomb_detonation_frames >= 0, "Normal bomb must eventually settle before starting its four-frame fuse")
	bouncy_bomb.free()
	var passthrough_bomb := ProjectileScript.new()
	passthrough_bomb.setup(behavior_game, minigun_player, Vector2(0, -1), 1, 40.0, 10.0, 0.0, 32.0, 0, false, {"kind": "bomb", "gravity": 1.26, "blast_radius": 50.0, "angle_offset": -45.0, "platform_collision": false, "detonate_on_expiry": false})
	expect(near(rad_to_deg(passthrough_bomb.velocity.angle()), -45.0), "right-facing Bomb throw must launch forward-up at 45 degrees")
	for passthrough_frame in 14:
		passthrough_bomb._physics_process(0.0)
	expect(passthrough_bomb.bomb_detonation_frames < 0 and passthrough_bomb.position.y > 0.0, "Bomb secondary must cross a platform without bouncing, stopping, or arming a fuse")
	passthrough_bomb.free()
	var left_bomb := ProjectileScript.new()
	left_bomb.setup(behavior_game, minigun_player, Vector2.ZERO, -1, 40.0, 10.0, 0.0, 32.0, 0, false, {"kind": "bomb", "angle_offset": -45.0, "platform_collision": false, "detonate_on_expiry": false})
	expect(near(rad_to_deg(left_bomb.velocity.angle()), -135.0), "left-facing Bomb throw must mirror the forward-up 45-degree launch")
	left_bomb.free()
	var bomb_target := PlayerScript.new()
	bomb_target.setup(behavior_game, 1, Vector2.ZERO, Color("ff355a"), 1)
	behavior_game.players = [minigun_player, bomb_target]
	var player_hit_bomb := ProjectileScript.new()
	player_hit_bomb.setup(behavior_game, minigun_player, Vector2(0, -1), 1, 40.0, 10.0, 0.0, 32.0, 0, false, {"kind": "bomb", "angle_offset": -45.0, "platform_collision": false, "detonate_on_expiry": false, "blast_radius": 50.0})
	var blast_count_before_hit := behavior_game.effects.size()
	player_hit_bomb._physics_process(0.0)
	expect(player_hit_bomb.is_queued_for_deletion() and behavior_game.effects.size() > blast_count_before_hit, "Bomb secondary must still detonate immediately when it touches a player")
	player_hit_bomb.free()
	behavior_game.players = []
	var expired_bomb := ProjectileScript.new()
	expired_bomb.setup(behavior_game, minigun_player, Vector2.ZERO, 1, 40.0, 0.0, 0.0, 32.0, 0, false, {"kind": "bomb", "life": 0, "platform_collision": false, "detonate_on_expiry": false, "blast_radius": 50.0})
	var blast_count_before_expiry := behavior_game.effects.size()
	expired_bomb._physics_process(0.0)
	expect(expired_bomb.is_queued_for_deletion() and behavior_game.effects.size() == blast_count_before_expiry, "Bomb secondary must disappear without exploding when its flight lifetime expires")
	expired_bomb.free()
	bomb_target.free()

	var split_parent := ProjectileScript.new()
	split_parent.setup(behavior_game, minigun_player, Vector2.ZERO, 1, 32.0, 10.0, 0.0, 32.0, 0, false, {"kind": "homing_split", "life": 70, "blast_radius": 50.0, "split_frame": 18})
	split_parent.age = 17
	split_parent._physics_process(0.0)
	expect(behavior_game.get_child_count() == 3, "Homing Missile special must create three straight split missiles")
	for child in behavior_game.get_children():
		child.free()
	split_parent.free()
	var arrow := ProjectileScript.new()
	arrow.setup(behavior_game, minigun_player, Vector2(300, 300), 1, 34.0, 30.0, 0.0, 20.0, 0, false, {"kind": "arrow", "gravity": 0.34})
	var arrow_vertical_speed := arrow.velocity.y
	arrow._physics_process(0.0)
	expect(near(arrow.velocity.y - arrow_vertical_speed, 0.34), "arrow flight must apply the increased gravity step per frame")
	arrow.free()
	var homing_target := PlayerScript.new()
	homing_target.position = Vector2(-1000, 24)
	behavior_game.players = [minigun_player, homing_target]
	var guided_missile := ProjectileScript.new()
	guided_missile.setup(behavior_game, minigun_player, Vector2.ZERO, 1, 32.0, 12.0, 0.0, 32.0, 0, false, {"kind": "homing", "life": 100, "turning": 1.1, "homing_deploy_frames": 10, "homing_speed_min": 10.0, "homing_speed_max": 10.0, "blast_radius": 50.0})
	for deploy_frame in 10:
		guided_missile.age = deploy_frame + 1
		guided_missile.steer_to_closest_target()
	expect(near(guided_missile.velocity.x, 12.0) and near(guided_missile.homing_velocity.x, 10.0), "Homing Missile must fly straight while building and capping its inertial velocity for ten frames")
	guided_missile.age = 11
	guided_missile.steer_to_closest_target()
	expect(near(guided_missile.velocity.x, 10.0) and near(guided_missile.homing_velocity.x, 8.9), "Homing Missile must switch to its accumulated velocity before applying target-seeking acceleration")
	for pursuit_frame in 12:
		guided_missile.age += 1
		guided_missile.steer_to_closest_target()
	expect(guided_missile.velocity.x < 0.0 and guided_missile.velocity.length() <= 10.001, "Homing Missile must reverse through inertial seek acceleration without exceeding its randomized speed cap")
	guided_missile.free()
	homing_target.free()
	behavior_player.free()
	minigun_player.free()
	homing_player.free()
	bow_player.free()
	behavior_game.free()

	var game := GameScript.new()
	expect(game.HitSounds.size() == 2 and game.FallDeathSounds.size() == 4 and game.ExplosionSounds.size() == 4, "original hit, fall-death, and explosion sound pools must be complete")
	expect(game.LandingSounds.size() == 3, "all three original landing sounds must be available")
	expect(game.SmallWaveTextures.size() == 15 and game.LandingDustTextures.size() == 10, "small-wave animation and all map-specific landing dust textures must be complete")
	game.spawn_explosion(Vector2(300, 200), Color("0099ff"), 4.0)
	expect(game.effects.size() == 17, "Redux death burst must contain flash, wave, ten particles, four body parts, and text")
	expect(game.screen_shake_frames == 15, "Redux death burst must start 15 frames of screen shake")
	game.update_effect(0)
	expect(near(float(game.effects[0]["scale"]), 4.0), "death flash must grow by 300 percent per original frame")
	game.effects.clear()
	game.spawn_stun_effect(Vector2(300, 160), 4.0)
	expect(game.effects.size() == 1 and game.effects[0]["type"] == "stun", "Redux stun marker must spawn as a status particle")
	expect(float(game.effects[0]["target_scale"]) >= 2.0 and float(game.effects[0]["target_scale"]) <= 3.0, "stun marker must target the original 200-300 percent scale")
	game.update_effect(0)
	expect(float(game.effects[0]["scale"]) > 1.0, "stun marker must expand before shrinking")
	game.effects.clear()
	game.spawn_small_wave(Vector2(300, 160))
	game.update_effect(0)
	expect(game.effects.size() == 1 and near(float(game.effects[0]["scale"]), 2.05), "small impact wave must follow the original half-distance scale easing")
	game.effects.clear()
	game.spawn_hit_effect(Vector2(300, 160), Color("0099ff"), "SNIPED", 26.0, 65.0)
	expect(game.effects.size() == 7 and game.effects[0]["label"] == "SNIPED" and bool(game.effects[0]["big"]), "Sniper hit feedback must use the large original label and shrapnel burst")
	expect(Color(game.effects[0]["color"]) == Color("a91224") and Color(game.effects[2]["color"]) == Color("ff8a2b"), "high-power hit feedback must use the dark-red treatment instead of player colour")
	game.update_effect(2)
	expect(game.effects[2]["type"] == "shrapnel" and float(game.effects[2]["scale"]) < 1.25, "shrapnel feedback must advance and fade")
	game.effects.clear()
	game.spawn_hit_effect(Vector2(300, 160), Color.WHITE, "HIT", 9.2, 23.0)
	expect(not bool(game.effects[0]["big"]) and Color(game.effects[0]["color"]) == Color("ff4b2b"), "ordinary player hits must use readable red-orange text even for a white player")
	game.effects.clear()
	game.spawn_combat_text(Vector2(300, 160), "BOOM!", Color("ffd166"), true)
	expect(game.effects.size() == 1 and game.effects[0]["type"] == "combat_text" and game.effects[0]["life_max"] == 20, "combat text must retain the original expanding lifetime")
	game.update_effect(0)
	expect(float(game.effects[0]["scale"]) > 1.0, "combat text must expand before fading")
	game.effects.clear()
	game.spawn_crate_open_effect(Vector2(300, 160))
	expect(game.effects.size() == 6, "crate pickup must create four large and two small original fragments")
	game.effects.clear()
	game.spawn_landing_dust(Vector2(300, 160))
	expect(game.effects.size() == 1 and game.effects[0]["type"] == "landing_dust", "hard landings must create map-matched original dust")
	game.free()
	var shell_game := GameScript.new()
	shell_game.spawn_shell_eject(null, Vector2(300, 160), 1, 1)
	expect(shell_game.effects.size() == 1 and shell_game.effects[0]["type"] == "shell", "fire actions must eject a shell effect")
	var shell_start := Vector2(shell_game.effects[0]["position"])
	shell_game.update_effect(0)
	expect(Vector2(shell_game.effects[0]["position"]).y < shell_start.y, "ejected shells must initially travel upward")
	shell_game.free()

	var projectile_game := GameScript.new()
	var projectile_owner := PlayerScript.new()
	var weak_bullet := ProjectileScript.new()
	weak_bullet.setup(projectile_game, projectile_owner, Vector2.ZERO, 1, 13.0, 25.0, 0.0)
	expect(near(weak_bullet.visual_scale_x, 70.0), "low-firepower BULLET must start at the original 70 percent horizontal scale")
	weak_bullet._physics_process(0.0)
	expect(weak_bullet.age == 1, "BULLET must remain hidden for its first logic frame")
	var sniper_bullet := ProjectileScript.new()
	sniper_bullet.setup(projectile_game, projectile_owner, Vector2.ZERO, 1, 65.0, 25.0, 0.0)
	sniper_bullet._physics_process(0.0)
	expect(sniper_bullet.visual_scale_x > 100.0, "high-firepower BULLET must expand toward the original 500 percent scale")
	var shotgun_pellet := ProjectileScript.new()
	shotgun_pellet.setup(projectile_game, projectile_owner, Vector2.ZERO, 1, 10.0, 25.0, 0.0, -1.0, 0, false, {"kind": "bullet_shell"})
	shotgun_pellet._physics_process(0.0)
	expect(shotgun_pellet.projectile_kind == "bullet_shell" and near(shotgun_pellet.visual_scale_x, 84.0), "BULLET_shell must shorten by 16 percent per original frame")
	weak_bullet.free()
	sniper_bullet.free()
	shotgun_pellet.free()
	projectile_owner.free()
	projectile_game.free()
	expect(WeaponCrateScript.WARNING_START_FRAME == 250 and WeaponCrateScript.WARNING_FRAME_COUNT == 8, "crate must remain steady for 250 frames and only then play its eight-frame warning")

	var menu := GameScript.new()
	expect(menu.menu_screen == GameScript.MenuScreen.MAIN, "a new game must open on the main menu")
	expect(menu.player_slot_types == [GameScript.SlotType.HUMAN, GameScript.SlotType.EMPTY, GameScript.SlotType.EMPTY, GameScript.SlotType.AI], "player setup must start with one human, two empty slots, and one AI")
	expect(menu.can_start_round(), "one non-empty human or AI slot must be enough to start")
	for slot in 4:
		menu.set_slot_type(slot, GameScript.SlotType.EMPTY)
	expect(not menu.can_start_round(), "four empty slots must be the only setup that cannot start")
	menu.set_slot_type(2, GameScript.SlotType.HUMAN)
	expect(menu.can_start_round() and menu.player_slot_types[2] == GameScript.SlotType.HUMAN, "any slot must be independently addable as a human")
	menu.set_slot_type(2, GameScript.SlotType.AI)
	expect(menu.can_start_round() and menu.player_slot_types[2] == GameScript.SlotType.AI and menu.players_ready[2], "any AI slot must be independently replaceable and automatically ready")
	menu.player_slot_types = [GameScript.SlotType.HUMAN, GameScript.SlotType.EMPTY, GameScript.SlotType.EMPTY, GameScript.SlotType.AI]
	menu.process_menu_click(Vector2(750, 320))
	expect(menu.menu_screen == GameScript.MenuScreen.CUSTOM_MODE, "main menu custom game click must open mode selection")
	menu.process_menu_click(Vector2(100, 160))
	expect(menu.menu_screen == GameScript.MenuScreen.MAP_SELECTION, "free for all click must open map selection")
	menu.process_menu_click(Vector2(500, 515))
	expect(menu.menu_screen == GameScript.MenuScreen.PLAYER_SETUP, "map continue click must open player setup")
	menu.process_menu_click(Vector2(120, 400))
	expect(menu.menu_screen == GameScript.MenuScreen.PLAYER_MODAL and menu.player_modal_kind == 1, "player setup gun click must open the weapon modal")
	menu.process_menu_click(Vector2(740, 470))
	expect(menu.menu_screen == GameScript.MenuScreen.PLAYER_SETUP, "weapon modal back click must return to player setup")
	menu.process_menu_click(Vector2(190, 400))
	expect(menu.menu_screen == GameScript.MenuScreen.PLAYER_MODAL and menu.player_modal_kind == 2, "player setup perk click must open the perk modal")
	menu.process_menu_click(Vector2(10, 10))
	expect(menu.menu_screen == GameScript.MenuScreen.PLAYER_SETUP, "blank modal click must safely close the modal")
	menu.free()

	var live_game := GameScript.new()
	live_game.create_players()
	expect(live_game.players.size() == 4 and live_game.huds.size() == 4, "the four custom-game slots must each have an isolated runtime player and HUD container")
	for slot in 4:
		live_game.open_player_modal(slot, 1)
		live_game.player_modal_cursor = 2
		live_game.select_player_modal_item()
		expect(live_game.selected_weapons[slot] == 3 and live_game.players[slot].visual_frame_cache.is_empty(), "Angry Cow must switch instantly in every player slot without eagerly loading its full controller")
	live_game.enter_player_setup_screen()
	live_game.process_menu_click(Vector2(50, 125))
	expect(live_game.player_slot_types[0] == GameScript.SlotType.EMPTY, "the first slot must be clearable like every other slot")
	live_game.process_menu_click(Vector2(380, 281))
	expect(live_game.player_slot_types[1] == GameScript.SlotType.HUMAN, "an empty slot must create a human in its original card position")
	live_game.process_menu_click(Vector2(790, 125))
	expect(live_game.player_slot_types[3] == GameScript.SlotType.EMPTY, "the fourth slot must be independently clearable")
	expect(live_game.can_start_round(), "one remaining human slot must permit starting")
	live_game.process_menu_click(Vector2(500, 515))
	expect(live_game.round_started and live_game.match_participant_count == 1, "a single configured slot must create a valid one-participant round")
	expect(not live_game.players[1].eliminated and live_game.players[1].visible, "the configured slot must be the only active runtime character")
	expect(live_game.players[0].eliminated and live_game.players[2].eliminated and live_game.players[3].eliminated, "empty slots must not participate in combat")
	var player2_default_weapon: int = live_game.players[1].default_weapon_id
	expect(live_game.assign_test_weapon_to_player2(15), "in-game test picker must assign a crate weapon to active Player 2")
	expect(live_game.players[1].weapon_id == 15 and live_game.players[1].default_weapon_id == player2_default_weapon and live_game.players[1].ammo == 150, "test weapon assignment must preserve Player 2's configured default and initialize crate ammo")
	expect(not live_game.assign_test_weapon_to_player2(1), "in-game test picker must reject non-special weapons")
	var test_overlay := TestWeaponOverlayScript.new()
	test_overlay.setup(live_game)
	live_game.selected_map = 7
	expect(test_overlay.map_badge_text() == "MAP 07", "gameplay overlay must show the selected map number in the lower-left badge")
	var unique_weapon_cells: Array[Rect2] = []
	for weapon_index in WeaponCatalog.CRATE_WEAPON_IDS.size():
		var weapon_cell: Rect2 = test_overlay.weapon_cell_rect(weapon_index)
		expect(not unique_weapon_cells.any(func(existing: Rect2) -> bool: return existing.intersects(weapon_cell)), "all thirteen test weapon choices must have distinct click targets")
		unique_weapon_cells.append(weapon_cell)
	test_overlay.free()
	live_game.screen_shake_frames = 8
	live_game.position = Vector2(4, -3)
	live_game.exit_round_to_map_selection()
	expect(not live_game.round_started and live_game.menu_screen == GameScript.MenuScreen.MAP_SELECTION and live_game.map_menu_cursor == live_game.selected_map, "Esc from a live round must return directly to the current map selection")
	expect(live_game.players.all(func(candidate: Node) -> bool: return not candidate.visible) and live_game.huds.all(func(hud: Node) -> bool: return not hud.visible), "leaving a round for map selection must hide all gameplay players and HUDs")
	expect(live_game.screen_shake_frames == 0 and live_game.position == Vector2.ZERO, "leaving a round must clear residual screen shake")
	live_game.free()

	var ai_game := GameScript.new()
	ai_game.ai_platform_graph.rebuild([Rect2(100, 300, 200, 20)])
	var ai_actor := PlayerScript.new()
	ai_actor.player_index = 0
	ai_actor.position = Vector2(292, 300)
	ai_actor.velocity = Vector2(4, 0)
	ai_actor.jumps_remaining = 2
	var same_platform_target := PlayerScript.new()
	same_platform_target.position = Vector2(500, 300)
	var edge_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(not edge_controls["right"] and edge_controls["left"] and not edge_controls["jump_just"], "AI-3 must brake inward instead of walking off an unplanned platform edge or jump-looping")
	ai_game.ai_jump_cooldowns.clear()
	ai_actor.position = Vector2(10, 520)
	ai_actor.velocity = Vector2(-6, 8)
	var recovery_controls := ai_game.build_ai_controls(ai_actor, null)
	expect(recovery_controls["right"] and recovery_controls["jump_just"], "AI-3 must prioritize steering and jumping back toward the arena when launched out")
	ai_game.ai_jump_cooldowns.clear()
	ai_game.ai_platform_graph.rebuild([Rect2(100, 300, 200, 20), Rect2(380, 220, 200, 20)])
	ai_actor.position = Vector2(240, 300)
	ai_actor.velocity = Vector2.ZERO
	same_platform_target.position = Vector2(470, 220)
	var route_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(route_controls["right"] and route_controls["jump_just"], "AI-3 must jump toward the next platform selected by the route graph")
	ai_game.ai_jump_cooldowns.clear()
	ai_game.ai_platform_graph.rebuild([Rect2(7, 501, 960, 18)])
	ai_actor.position = Vector2(500, 501)
	ai_actor.velocity = Vector2.ZERO
	ai_actor.jumps_remaining = 2
	same_platform_target.position = Vector2(650, 501)
	var low_floor_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(not low_floor_controls["jump_just"], "AI must not mistake map 6's low floor for an out-of-bounds recovery state")
	ai_game.ai_jump_cooldowns.clear()
	ai_game.ai_platform_graph.rebuild([Rect2(100, 300, 200, 20), Rect2(380, 180, 200, 20)])
	ai_actor.set_perk(1)
	ai_actor.position = Vector2(280, 260)
	ai_actor.velocity = Vector2(6, -6)
	ai_actor.jumps_remaining = 2
	same_platform_target.position = Vector2(470, 180)
	var early_air_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(not early_air_controls["jump_just"], "Triple Jump AI must preserve extra jumps while the current ascent still has useful lift")
	ai_game.ai_jump_cooldowns.clear()
	ai_actor.velocity = Vector2(6, 1)
	var second_jump_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(second_jump_controls["jump_just"], "Triple Jump AI must use a second jump when the projected route landing is short")
	ai_game.ai_jump_cooldowns.clear()
	ai_actor.position = Vector2(330, 245)
	ai_actor.velocity = Vector2(2, 3)
	ai_actor.jumps_remaining = 1
	var rescue_jump_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(rescue_jump_controls["jump_just"], "Triple Jump AI must spend its final jump when falling short of a required higher route")

	# AI-4: every weapon policy must emit ordinary player controls, including
	# held/release weapons instead of bypassing their weapon state machines.
	ai_game.ai_platform_graph.rebuild([Rect2(0, 300, 1000, 20)])
	ai_actor.set_ai_controlled(true)
	ai_actor.position = Vector2(300, 300)
	ai_actor.velocity = Vector2.ZERO
	ai_actor.facing = 1
	same_platform_target.player_index = 1
	same_platform_target.position = Vector2(470, 300)
	same_platform_target.eliminated = false
	for weapon_id in range(1, 19):
		ai_game.ai_states.erase(ai_actor.player_index)
		ai_actor.equip_weapon(weapon_id, false)
		same_platform_target.position.x = 360.0 if weapon_id in [5, 10, 16] else (560.0 if weapon_id == 12 else 470.0)
		var emitted_attack := false
		for decision_frame in 80:
			var weapon_controls := ai_game.empty_ai_controls()
			ai_game.apply_ai_weapon_controls(ai_actor, same_platform_target, weapon_controls, ai_game.ai_state_for(ai_actor), {"danger": false})
			emitted_attack = emitted_attack or weapon_controls["primary"] or weapon_controls["secondary"]
		expect(emitted_attack, "AI-4 must produce a legal attack control for weapon %d" % weapon_id)

	# The 60% crate choice has a fixed boundary and is stored once per crate.
	expect(ai_game.ai_crate_roll_succeeds(0.5999) and not ai_game.ai_crate_roll_succeeds(0.6), "AI crate priority must use an exact sixty-percent boundary")
	var crate_state := ai_game.ai_state_for(ai_actor)
	crate_state["crate_serial"] = 4
	crate_state["seek_crate"] = true
	var test_crate := WeaponCrateScript.new()
	test_crate.position = Vector2(700, 300)
	ai_game.active_weapon_crate = test_crate
	var crate_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(crate_controls["right"] and int(crate_state["crate_serial"]) == 4 and bool(crate_state["seek_crate"]), "AI-5 must keep one crate decision and route toward that crate instead of rerolling every frame")
	ai_game.active_weapon_crate = null
	test_crate.free()

	# Overlap separation and projectile avoidance are also normal movement
	# controls and must choose the platform-safe direction.
	ai_game.players = [ai_actor, same_platform_target]
	ai_game.ai_states.erase(ai_actor.player_index)
	ai_actor.position = Vector2(500, 300)
	same_platform_target.position = Vector2(500, 300)
	var separation_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(separation_controls["left"] and not separation_controls["right"], "AI-5 overlapping actors must separate by ordinary movement controls")
	same_platform_target.position = Vector2(700, 300)
	var threat_projectile := ProjectileScript.new()
	ai_game.add_child(threat_projectile)
	threat_projectile.shooter = same_platform_target
	threat_projectile.position = Vector2(300, 276)
	threat_projectile.velocity = Vector2(20, 0)
	threat_projectile.projectile_kind = "bullet"
	var threat_controls := ai_game.build_ai_controls(ai_actor, same_platform_target)
	expect(threat_controls["right"] and not threat_controls["left"], "AI-5 must step away from an incoming projectile on a safe platform side")
	threat_projectile.free()

	# Target locks expire, invalid targets switch immediately, and cloaked
	# Snipers are ignored unless already at defensive contact range.
	var alternate_target := PlayerScript.new()
	alternate_target.player_index = 2
	alternate_target.position = Vector2(760, 300)
	ai_game.players = [ai_actor, same_platform_target, alternate_target]
	var target_state := ai_game.ai_state_for(ai_actor)
	target_state["target"] = same_platform_target
	target_state["target_lock"] = 10
	same_platform_target.eliminated = true
	expect(ai_game.update_ai_target(ai_actor, target_state) == alternate_target, "AI-6 must immediately replace an eliminated target")
	same_platform_target.eliminated = false
	same_platform_target.hidden_from_sniper = true
	same_platform_target.position = Vector2(620, 300)
	target_state["target_lock"] = 0
	expect(ai_game.update_ai_target(ai_actor, target_state) == alternate_target, "AI-6 must respect Sniper stealth during target acquisition")
	alternate_target.free()
	ai_actor.free()
	same_platform_target.free()
	ai_game.free()

	if failures.is_empty():
		print("SMOKE TEST PASSED: 35 Hz, AI-4 to AI-6 controls/tactics, four free player slots, ten maps, eighteen weapons, test tools, projectiles, combat effects, health easing, and pickup verified")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
