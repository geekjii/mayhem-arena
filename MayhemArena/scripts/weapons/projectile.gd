extends Node2D

var arena: Node
var shooter: Node
var velocity := Vector2.ZERO
var facing := 1
var firepower := 10.0
var explicit_damage := -1.0
var stun_frames := 0
var thrown_gun := false
var projectile_kind := "bullet"
var blast_radius := 0.0
var gravity := 0.0
var age := 0
var max_age := 240
var homing_turn := 0.0
var homing_speed := 0.0
var bounce := false
var visual_scale_x := 100.0

func setup(
		game: Node,
		owner_player: Node,
		start_position: Vector2,
		direction: int,
		power: float,
		speed: float,
		spread_degrees: float,
		damage_override: float = -1.0,
		stun: int = 0,
		is_thrown_gun: bool = false,
		options: Dictionary = {}
) -> void:
	arena = game
	shooter = owner_player
	position = start_position
	facing = direction
	firepower = power
	explicit_damage = damage_override
	stun_frames = stun
	thrown_gun = is_thrown_gun
	projectile_kind = str(options.get("kind", "bullet"))
	blast_radius = float(options.get("blast_radius", 0.0))
	gravity = float(options.get("gravity", 0.0))
	max_age = int(options.get("life", 240))
	homing_turn = float(options.get("turning", 0.0))
	homing_speed = float(options.get("homing_speed", speed))
	bounce = bool(options.get("bounce", false))
	if projectile_kind == "bullet" and firepower <= 15.0:
		visual_scale_x = 70.0
	var angle_offset := float(options.get("angle_offset", 0.0)) * facing
	var angle := deg_to_rad(-90.0 + 90.0 * facing + angle_offset + randf_range(-spread_degrees * 0.5, spread_degrees * 0.5))
	velocity = Vector2(cos(angle), sin(angle)) * speed
	z_index = 20
	queue_redraw()

func _physics_process(_delta: float) -> void:
	age += 1
	if projectile_kind == "bullet" and firepower > 40.0:
		visual_scale_x += (500.0 - visual_scale_x) / 6.0
	elif projectile_kind == "bullet_shell":
		if firepower >= 30.0:
			visual_scale_x += (350.0 - visual_scale_x) / 8.0
		visual_scale_x -= 16.0
		if visual_scale_x <= 1.0:
			queue_free()
			return
	if age > max_age:
		if projectile_kind in ["bomb", "homing", "homing_jokes"]:
			detonate(position)
		else:
			queue_free()
		return

	# Redux used a handful of point tests per 35 Hz frame instead of swept
	# collision. Keep that coarse behavior, including the possibility of misses.
	var samples := [
		position,
		position + Vector2(velocity.x * 0.333, 0.0),
		position + Vector2(velocity.x * 0.667, velocity.y * 0.8),
	]
	for target in arena.players:
		if target == shooter or target.eliminated:
			continue
		for sample in samples:
			if target.hit_test_point(sample):
				if projectile_kind in ["rocket", "bomb", "homing", "homing_jokes"]:
					detonate(sample)
					return
				var damage := explicit_damage if explicit_damage >= 0.0 else firepower * 0.4
				if target.umbrella_open and target.facing != facing:
					if projectile_kind != "knife":
						target.drain_ammo(firepower * 0.8)
					target.velocity.x += firepower * facing * 0.25
				else:
					target.take_damage(damage, firepower * facing, stun_frames, shooter)
				var hit_label := ""
				if projectile_kind in ["arrow", "baseball"]:
					hit_label = "POW"
				elif projectile_kind == "knife":
					hit_label = "SHANKED"
				elif shooter.weapon_id == 12:
					hit_label = "SNIPED"
				arena.spawn_hit_effect(sample, shooter.player_color, hit_label)
				queue_free()
				return

	if projectile_kind in ["homing", "homing_jokes"]:
		steer_to_closest_target()
	position += velocity
	velocity.y += gravity
	if thrown_gun:
		velocity = velocity.rotated(deg_to_rad(1.5 * facing))
		rotation += deg_to_rad(9.0 * facing)
	elif projectile_kind == "rocket":
		rotation = velocity.angle()
		arena.spawn_rocket_trail(position - velocity.normalized() * 13.0)
		if arena.point_hits_platform(position):
			detonate(position)
			return
	elif projectile_kind == "bomb":
		rotation += 0.26 * facing
		if arena.point_hits_platform(position):
			if bounce:
				velocity.y = maxf(-9.0, -velocity.y * 0.5)
				velocity.x *= 0.8
				if absf(velocity.x) <= 3.0:
					detonate(position)
					return
			else:
				detonate(position)
				return
	elif projectile_kind in ["arrow", "knife", "baseball"]:
		rotation = velocity.angle()
		if projectile_kind == "arrow":
			velocity.y += 0.12
		arena.spawn_projectile_trail(position, shooter.player_color)

	if position.x < -400.0 or position.x > 1400.0 or position.y < -250.0 or position.y > 850.0:
		queue_free()
	queue_redraw()

func detonate(at_position: Vector2) -> void:
	var detonation_label := "KABOOM!"
	if projectile_kind == "bomb":
		detonation_label = "BOOM!"
	elif projectile_kind in ["homing", "homing_jokes"]:
		detonation_label = "KABOOM!"
	arena.radial_attack(at_position, shooter, explicit_damage, firepower, blast_radius, detonation_label)
	queue_free()

func steer_to_closest_target() -> void:
	if age < 18:
		return
	var closest: Node = null
	var closest_distance := INF
	for target in arena.players:
		if target == shooter or target.eliminated:
			continue
		var distance := position.distance_to(target.position + Vector2(0, -24))
		if distance < closest_distance:
			closest_distance = distance
			closest = target
	if closest == null:
		return
	var desired := position.direction_to(closest.position + Vector2(0, -24)) * homing_speed
	velocity = velocity.lerp(desired, clampf(homing_turn / 10.0, 0.03, 0.22))

func _draw() -> void:
	if projectile_kind in ["bullet", "bullet_shell"]:
		# Original BULLET/BULLET_shell instances are invisible on creation and
		# appear as a thin line from their second 35 Hz frame onward.
		if age < 2:
			return
		var direction := velocity.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2(float(facing), 0.0)
		var line_length := 20.0 * visual_scale_x / 100.0
		var tail := -direction * line_length
		var tip := direction * 2.0
		draw_line(tail, tip, Color("35110b"), 4.0 if projectile_kind == "bullet_shell" else 3.0)
		draw_line(tail * 0.82, tip, Color("ffb12b"), 2.0 if projectile_kind == "bullet_shell" else 1.4)
		return
	if thrown_gun:
		draw_colored_polygon(PackedVector2Array([Vector2(-13, -4), Vector2(9, -4), Vector2(13, 1), Vector2(-2, 4), Vector2(-8, 9)]), Color("4b4f55"))
		draw_polyline(PackedVector2Array([Vector2(-13, -4), Vector2(9, -4), Vector2(13, 1), Vector2(-2, 4), Vector2(-8, 9), Vector2(-13, -4)]), Color("171717"), 2.0)
	elif projectile_kind == "arrow":
		draw_line(Vector2(-16, 0), Vector2(9, 0), Color("222222"), 4.0)
		draw_line(Vector2(-15, 0), Vector2(8, 0), Color("d8b06a"), 2.0)
		draw_colored_polygon(PackedVector2Array([Vector2(13, 0), Vector2(5, -5), Vector2(5, 5)]), Color("d9e1e8"))
		draw_polyline(PackedVector2Array([Vector2(13, 0), Vector2(5, -5), Vector2(5, 5), Vector2(13, 0)]), Color("222222"), 1.5)
	elif projectile_kind == "knife":
		draw_colored_polygon(PackedVector2Array([Vector2(-2, -3), Vector2(14, 0), Vector2(-2, 3)]), Color("d9e1e8"))
		draw_polyline(PackedVector2Array([Vector2(-2, -3), Vector2(14, 0), Vector2(-2, 3)]), Color("202020"), 1.5)
		draw_line(Vector2(-11, 0), Vector2(-2, 0), Color("8b5a3c"), 5.0)
	elif projectile_kind == "baseball":
		draw_circle(Vector2.ZERO, 7.0, Color("202020"))
		draw_circle(Vector2.ZERO, 5.5, Color("f3f0e8"))
		draw_arc(Vector2.ZERO, 3.2, -1.1, 1.1, 6, Color("d94b3d"), 1.2)
	elif projectile_kind in ["homing", "homing_jokes"]:
		draw_set_transform(Vector2.ZERO, velocity.angle(), Vector2.ONE)
		var missile_color := Color("8bd14b") if projectile_kind == "homing_jokes" else Color("d7d9dc")
		draw_colored_polygon(PackedVector2Array([Vector2(-12, -5), Vector2(8, -5), Vector2(14, 0), Vector2(8, 5), Vector2(-12, 5)]), missile_color)
		draw_polyline(PackedVector2Array([Vector2(-12, -5), Vector2(8, -5), Vector2(14, 0), Vector2(8, 5), Vector2(-12, 5), Vector2(-12, -5)]), Color("202020"), 2.0)
		draw_circle(Vector2(-13, 0), 4.0, Color("ff7a24"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	elif projectile_kind == "bomb":
		draw_circle(Vector2.ZERO, 9.0, Color("171717"))
		draw_circle(Vector2.ZERO, 6.5, Color("343434"))
		draw_line(Vector2(4, -7), Vector2(8, -12), Color("8b5a3c"), 2.0)
		draw_circle(Vector2(9, -13), 2.5, Color("ff8a24"))
	elif projectile_kind == "rocket":
		draw_set_transform(Vector2.ZERO, velocity.angle(), Vector2.ONE)
		draw_colored_polygon(PackedVector2Array([Vector2(-13, -5), Vector2(8, -5), Vector2(14, 0), Vector2(8, 5), Vector2(-13, 5)]), Color("d5d7d8"))
		draw_polyline(PackedVector2Array([Vector2(-13, -5), Vector2(8, -5), Vector2(14, 0), Vector2(8, 5), Vector2(-13, 5), Vector2(-13, -5)]), Color("202020"), 2.0)
		draw_circle(Vector2(-14, 0), 5.0, Color(1.0, 0.45, 0.12, 0.9))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_circle(Vector2.ZERO, 3.0, Color("ffb12b"))
