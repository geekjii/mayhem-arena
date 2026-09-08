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
	var angle := deg_to_rad(-90.0 + 90.0 * facing + randf_range(-spread_degrees * 0.5, spread_degrees * 0.5))
	velocity = Vector2(cos(angle), sin(angle)) * speed
	z_index = 20
	queue_redraw()

func _physics_process(_delta: float) -> void:
	age += 1

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
				if projectile_kind == "rocket":
					detonate(sample)
					return
				var damage := explicit_damage if explicit_damage >= 0.0 else firepower * 0.4
				target.take_damage(damage, firepower * facing, stun_frames, shooter)
				arena.spawn_hit_effect(sample, shooter.player_color)
				queue_free()
				return

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

	if position.x < -400.0 or position.x > 1400.0 or position.y < -250.0 or position.y > 850.0:
		queue_free()

func detonate(at_position: Vector2) -> void:
	arena.radial_attack(at_position, shooter, explicit_damage, firepower, blast_radius)
	queue_free()

func _draw() -> void:
	if thrown_gun:
		draw_rect(Rect2(-10, -3, 20, 6), Color(0.86, 0.82, 0.58), true)
	elif projectile_kind == "rocket":
		draw_rect(Rect2(-12, -4, 22, 8), Color("ff7a3d"), true)
		draw_circle(Vector2(-13, 0), 5.0, Color(1.0, 0.83, 0.25, 0.75))
	else:
		draw_circle(Vector2.ZERO, 3.0 if firepower < 60.0 else 5.0, Color(1.0, 0.87, 0.3))
		draw_line(Vector2(-12.0 * facing, 0), Vector2.ZERO, Color(1.0, 0.45, 0.12, 0.55), 2.0)
