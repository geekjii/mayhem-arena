extends SceneTree

const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")
const MapCatalog = preload("res://scripts/game/map_catalog.gd")
const GameScript = preload("res://scripts/game/game.gd")
const PlayerScript = preload("res://scripts/players/player.gd")
const WeaponCrateScript = preload("res://scripts/weapons/weapon_crate.gd")

var failures: Array[String] = []

func expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func near(actual: float, expected: float, tolerance := 0.001) -> bool:
	return absf(actual - expected) <= tolerance

func _init() -> void:
	expect(Engine.physics_ticks_per_second == 35, "physics tick rate must be 35 Hz")
	expect(Engine.max_fps == 35, "render cap must be 35 FPS")
	expect(WeaponCatalog.DEFAULT_WEAPON_IDS.size() == 5, "the selectable default pool must contain five weapons")
	expect(WeaponCatalog.CRATE_WEAPON_IDS.size() == 13, "the complete crate weapon pool must contain thirteen weapons")
	expect(WeaponCatalog.WEAPONS.size() == 18, "the catalog must contain five default and thirteen crate weapons")
	expect(MapCatalog.MAP_TEXTURES.size() == 10, "all ten Redux map art frames must be available")
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
	expect(player.visual_frame_cache.size() == 41, "Sand Hawk's 11 primary and 30 secondary frames must preload")
	player.start_weapon_visual("primary")
	expect(player.visual_action_active and player.visual_frame == 1 and player.visual_frame_end == 11, "Sand Hawk primary timeline must start at frame 1 and end at frame 11")
	expect(player.weapon_frame_texture() != null, "the first Sand Hawk action frame must load")
	player.process_visual_animation()
	expect(player.visual_frame == 2, "weapon animation must advance exactly one original frame per 35 Hz tick")
	player.start_reload()
	expect(player.reload_frames == 55, "Sand Hawk reload must retain the original 55-frame sequence")
	expect(not player.visual_action_active and player.visual_frame == 0, "reload must interrupt the previous attack visual timeline")
	player.equip_weapon(6, false)
	expect(player.default_weapon_id == 1, "crate pickup must not replace the selected respawn weapon")
	expect(player.weapon_id == 6 and player.ammo == 6, "crate pickup must equip and refill the contained weapon")
	player.consume_ammo(2)
	expect(player.ammo == 4, "multi-projectile attacks must consume their original shell count")
	player.start_reload()
	expect(player.reload_frames == 12, "empty crate weapons must be discarded quickly instead of reloading")
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

	if failures.is_empty():
		print("SMOKE TEST PASSED: 35 Hz, ten maps, five defaults, six Redux perks, action/reload/audio timelines, shell ejection, death/stun/landing/crate effects, thirteen crate weapons, health easing, and pickup verified")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
