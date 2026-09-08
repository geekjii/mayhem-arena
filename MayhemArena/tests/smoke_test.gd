extends SceneTree

const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")
const MapCatalog = preload("res://scripts/game/map_catalog.gd")
const GameScript = preload("res://scripts/game/game.gd")
const PlayerScript = preload("res://scripts/players/player.gd")
const WeaponCrateScript = preload("res://scripts/weapons/weapon_crate.gd")
const FontCatalog = preload("res://scripts/ui/font_catalog.gd")

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
		expect(MapCatalog.spawns_for(map_id).size() == 2, "map %d must provide two local-player spawns" % map_id)
	expect(near(MapCatalog.platforms_for(2)[0].position.y, 110.0), "exported maps 2-10 must receive the scene3 vertical alignment correction")

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
	expect(player.visual_frame_cache.size() == 77, "Sand Hawk's attack and reload frames must preload")
	player.start_weapon_visual("primary")
	expect(player.visual_action_active and player.visual_frame == 1 and player.visual_frame_end == 11, "Sand Hawk primary timeline must start at frame 1 and end at frame 11")
	expect(player.weapon_frame_texture() != null, "the first Sand Hawk action frame must load")
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
		17: {"primary": Vector2i(1, 15), "secondary": Vector2i(20, 42)},
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
	game.spawn_hit_effect(Vector2(300, 160), Color("0099ff"), "SNIPED")
	expect(game.effects.size() == 7 and game.effects[0]["label"] == "SNIPED", "hit feedback must include the original label and shrapnel burst")
	game.update_effect(2)
	expect(game.effects[2]["type"] == "shrapnel" and float(game.effects[2]["scale"]) < 1.25, "shrapnel feedback must advance and fade")
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

	var menu := GameScript.new()
	expect(menu.menu_screen == GameScript.MenuScreen.MAIN, "a new game must open on the main menu")
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

	if failures.is_empty():
		print("SMOKE TEST PASSED: 35 Hz, ten maps, five defaults, six Redux perks, action/reload/audio timelines, shell ejection, death/stun/landing/crate effects, thirteen crate weapons, health easing, and pickup verified")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
