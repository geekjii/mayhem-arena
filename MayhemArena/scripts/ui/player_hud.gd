extends Node2D

const FontCatalog = preload("res://scripts/ui/font_catalog.gd")

var target: Node
var panel_position := Vector2.ZERO
var panel_color := Color.WHITE
var shown_health := 100.0
var shake_time := 0.0

func setup(player: Node, at_position: Vector2) -> void:
	target = player
	panel_position = at_position
	panel_color = player.player_color
	position = panel_position
	z_index = 100
	queue_redraw()

func add_shake(amount: float) -> void:
	shake_time += abs(amount)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		return

	# Exact Redux health display easing: close one third of the gap per frame.
	var target_health: float = maxf(target.health, 0.0)
	shown_health += (target_health - shown_health) / 3.0

	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - 2.0)
		position = panel_position + Vector2(
			randf_range(-shake_time * 0.3, shake_time * 0.3),
			randf_range(-shake_time * 0.3, shake_time * 0.3)
		)
	else:
		position = panel_position
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(target):
		return
	var font := FontCatalog.ui_font()
	var panel := Rect2(0, 0, 300, 50)
	draw_rect(panel, Color("f4f4ef"), true)
	draw_rect(panel, Color("171a1c"), false, 3.0)
	draw_rect(Rect2(4, 4, 36, 42), Color("d9d9d3"), true)
	draw_rect(Rect2(4, 4, 36, 42), Color("171a1c"), false, 2.0)
	var portrait: Texture2D = target.texture_for_weapon(target.weapon_id)
	var portrait_scale := minf(34.0 / portrait.get_width(), 38.0 / portrait.get_height())
	var portrait_size := Vector2(portrait.get_width(), portrait.get_height()) * portrait_scale
	draw_texture_rect(portrait, Rect2(Vector2(22, 45) - portrait_size * Vector2(0.5, 1.0), portrait_size), false)
	draw_string(font, Vector2(46, 18), target.display_name, HORIZONTAL_ALIGNMENT_LEFT, 155, 15, Color("25292b"))
	draw_string(font, Vector2(224, 18), "%d♥" % target.lives, HORIZONTAL_ALIGNMENT_RIGHT, 68, 18, Color("e8192f"))
	var ammo_text := "∞" if target.ammo < 0 else str(target.ammo)
	draw_string(font, Vector2(46, 32), "%s  %s" % [target.weapon_name(), ammo_text], HORIZONTAL_ALIGNMENT_LEFT, 246, 10, Color("555b5e"))

	var bar_rect := Rect2(45, 35, 247, 11)
	draw_rect(bar_rect, Color("233024"), true)
	var ratio: float = clampf(shown_health / 100.0, 0.0, 1.0)
	var health_color := Color("ef2938") if target.health <= 25.0 else Color("19d521")
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)), health_color, true)
	if target.health <= 25.0 and int(Time.get_ticks_msec() / 140.0) % 2 == 0:
		draw_rect(bar_rect, Color(1.0, 0.1, 0.08, 0.18), true)
	draw_rect(bar_rect, Color.WHITE, false, 1.0)
