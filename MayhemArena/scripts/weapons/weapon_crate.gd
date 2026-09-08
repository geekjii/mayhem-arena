extends Node2D

const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")
const CrateTexture = preload("res://assets/original_reference/props/crate.png")
const CrateTimeline := [
	preload("res://assets/original_reference/props/crate_timeline/1.png"),
	preload("res://assets/original_reference/props/crate_timeline/2.png"),
	preload("res://assets/original_reference/props/crate_timeline/3.png"),
	preload("res://assets/original_reference/props/crate_timeline/4.png"),
	preload("res://assets/original_reference/props/crate_timeline/5.png"),
	preload("res://assets/original_reference/props/crate_timeline/6.png"),
	preload("res://assets/original_reference/props/crate_timeline/7.png"),
	preload("res://assets/original_reference/props/crate_timeline/8.png"),
]

var arena: Node
var weapon_id := 1
var velocity := Vector2.ZERO
var landed := false
var pickup_lock_frames := 14
var age_frames := 0
var animation_frame := 0

# The original CRATE controller remains steady for 250 logic frames, then
# plays its eight-frame warning/disappearance timeline once.
const WARNING_START_FRAME := 250
const WARNING_FRAME_COUNT := 8

func setup(game: Node, at_position: Vector2, contained_weapon_id: int) -> void:
	arena = game
	position = at_position
	weapon_id = contained_weapon_id if WeaponCatalog.is_valid_weapon(contained_weapon_id) else WeaponCatalog.CRATE_WEAPON_IDS[0]
	z_index = 6
	arena.spawn_small_wave(position + Vector2(0, -15))
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if not arena.round_started or arena.match_over:
		return
	age_frames += 1
	if age_frames >= WARNING_START_FRAME:
		animation_frame = age_frames - WARNING_START_FRAME
		if animation_frame >= WARNING_FRAME_COUNT:
			arena.on_weapon_crate_lost(self)
			queue_free()
			return
	pickup_lock_frames = maxi(0, pickup_lock_frames - 1)

	if not landed:
		velocity.y = minf(velocity.y + 0.75, 18.0)
		var previous := position
		position += velocity
		var landing_y: float = arena.find_landing_y(previous, position)
		if not is_nan(landing_y):
			position.y = landing_y
			velocity = Vector2.ZERO
			landed = true
			arena.spawn_crate_landing_effect(position)
		if position.y > 650.0:
			arena.on_weapon_crate_lost(self)
			queue_free()
			return

	if pickup_lock_frames == 0:
		for player in arena.players:
			if player.eliminated:
				continue
			if absf(player.position.x - position.x) <= 29.0 and absf(player.position.y - position.y) <= 48.0:
				player.equip_weapon(weapon_id, false)
				arena.on_weapon_crate_picked(self, player, weapon_id)
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	var bob := sin(age_frames * 0.22) * 1.5 if landed else 0.0
	var target_size := Vector2(51, 42)
	var warning_active := age_frames >= WARNING_START_FRAME
	var texture: Texture2D = CrateTimeline[clampi(animation_frame, 0, CrateTimeline.size() - 1)] if warning_active and not CrateTimeline.is_empty() else CrateTexture
	draw_texture_rect(texture, Rect2(-target_size.x * 0.5, -target_size.y + bob, target_size.x, target_size.y), false)
