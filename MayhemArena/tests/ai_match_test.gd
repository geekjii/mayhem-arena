extends SceneTree

const GameScript = preload("res://scripts/game/game.gd")
const ProjectileScript = preload("res://scripts/weapons/projectile.gd")
const WeaponCrateScript = preload("res://scripts/weapons/weapon_crate.gd")

var failures: Array[String] = []

func expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _init() -> void:
	run.call_deferred()

func run() -> void:
	seed(240910)
	await run_match_case("four AI", [GameScript.SlotType.AI, GameScript.SlotType.AI, GameScript.SlotType.AI, GameScript.SlotType.AI], [10, 12, 15, 18])
	await run_match_case("one human and three AI", [GameScript.SlotType.HUMAN, GameScript.SlotType.AI, GameScript.SlotType.AI, GameScript.SlotType.AI], [1, 8, 15, 18])
	if failures.is_empty():
		print("AI MATCH TEST PASSED: four-AI and one-human/three-AI Free For All matches completed at 35 Hz without input crossover or persistent overlap")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func run_match_case(label: String, slot_types: Array, test_weapons: Array) -> void:
	var game := GameScript.new()
	root.add_child(game)
	# The test advances the real 35 Hz methods deterministically without waiting
	# for wall-clock time. Processing is disabled only to prevent a second copy
	# of the same tick from being delivered by SceneTree.
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.player_slot_types = slot_types.duplicate()
	game.selected_weapons = [1, 2, 3, 4]
	game.start_round()
	game.input_lock_frames = 0
	for index in game.players.size():
		var player: Node = game.players[index]
		player.lives = 1
		player.health = 34.0
		player.equip_weapon(int(test_weapons[index]), false)

	var maximum_frames := 35 * 150
	var overlap_streaks := {}
	var longest_overlap := 0
	var saw_combat_progress := false
	for frame in maximum_frames:
		if game.match_over:
			break
		var health_before := 0.0
		for player in game.players:
			if not player.eliminated:
				health_before += player.health

		game._physics_process(1.0 / 35.0)
		for player in game.players:
			player._physics_process(1.0 / 35.0)
		for child in game.get_children().duplicate():
			if child.is_queued_for_deletion():
				continue
			if child.get_script() == ProjectileScript or child.get_script() == WeaponCrateScript:
				child._physics_process(1.0 / 35.0)

		var health_after := 0.0
		for player in game.players:
			if not player.eliminated:
				health_after += player.health
			if player.is_ai_controlled:
				expect(not (player.control_pressed("left") and player.control_pressed("right")), "%s AI %d emitted conflicting movement on frame %d" % [label, player.player_index + 1, frame])
		saw_combat_progress = saw_combat_progress or health_after < health_before

		for first_index in game.players.size():
			for second_index in range(first_index + 1, game.players.size()):
				var first: Node = game.players[first_index]
				var second: Node = game.players[second_index]
				var key := "%d:%d" % [first_index, second_index]
				var overlapping: bool = not first.eliminated and not second.eliminated and absf(first.position.x - second.position.x) <= 28.0 and absf(first.position.y - second.position.y) <= 46.0
				overlap_streaks[key] = int(overlap_streaks.get(key, 0)) + 1 if overlapping else 0
				longest_overlap = maxi(longest_overlap, int(overlap_streaks[key]))

		# Give SceneTree occasional opportunities to retire queue_free projectiles.
		if frame % 70 == 69:
			await process_frame

	var survivors := game.players.filter(func(player: Node) -> bool: return not player.eliminated)
	expect(game.match_over and survivors.size() <= 1, "%s match did not reach a winner within 150 simulated seconds" % label)
	expect(saw_combat_progress, "%s match produced no player-vs-player damage" % label)
	expect(longest_overlap < 105, "%s match kept two characters overlapped for three seconds" % label)
	if slot_types[0] == GameScript.SlotType.HUMAN:
		expect(not game.players[0].is_ai_controlled, "%s leaked AI controls into the human slot" % label)
	game.queue_free()
	await process_frame
	await process_frame
