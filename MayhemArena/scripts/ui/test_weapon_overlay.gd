extends Node2D

const WeaponCatalog = preload("res://scripts/weapons/weapon_catalog.gd")
const FontCatalog = preload("res://scripts/ui/font_catalog.gd")

const BUTTON_RECT := Rect2(804, 78, 176, 38)
const PANEL_RECT := Rect2(108, 64, 784, 432)
const CLOSE_RECT := Rect2(732, 448, 128, 32)
const GRID_ORIGIN := Vector2(142, 126)
const CELL_SIZE := Vector2(174, 76)
const CELL_GAP := Vector2(10, 9)
const COLUMN_COUNT := 4

var arena: Node
var picker_open := false
var mouse_position := Vector2(-1000, -1000)
var feedback_text := ""
var feedback_frames := 0

func setup(game: Node) -> void:
	arena = game
	z_index = 200
	queue_redraw()

func reset() -> void:
	picker_open = false
	feedback_text = ""
	feedback_frames = 0
	mouse_position = Vector2(-1000, -1000)
	queue_redraw()

func tick() -> void:
	if feedback_frames > 0:
		feedback_frames -= 1
		if feedback_frames == 0:
			feedback_text = ""
	queue_redraw()

func set_mouse_position(next_position: Vector2) -> void:
	mouse_position = next_position
	queue_redraw()

func weapon_cell_rect(index: int) -> Rect2:
	var column: int = index % COLUMN_COUNT
	var row: int = index / COLUMN_COUNT
	return Rect2(GRID_ORIGIN + Vector2(column * (CELL_SIZE.x + CELL_GAP.x), row * (CELL_SIZE.y + CELL_GAP.y)), CELL_SIZE)

func handle_click(click_position: Vector2) -> bool:
	if not picker_open:
		if BUTTON_RECT.has_point(click_position):
			picker_open = true
			queue_redraw()
			return true
		return false

	for index in WeaponCatalog.CRATE_WEAPON_IDS.size():
		if weapon_cell_rect(index).has_point(click_position):
			var weapon_id: int = WeaponCatalog.CRATE_WEAPON_IDS[index]
			if arena.assign_test_weapon_to_player2(weapon_id):
				feedback_text = arena.menu_text("P2 TEST WEAPON: %s" % WeaponCatalog.weapon_name_for(weapon_id), "角色 2 测试武器：%s" % arena.weapon_menu_name(weapon_id))
			else:
				feedback_text = arena.menu_text("ENABLE PLAYER 2 BEFORE TESTING", "请先启用角色 2")
			feedback_frames = 105
			picker_open = false
			queue_redraw()
			return true
	if CLOSE_RECT.has_point(click_position) or not PANEL_RECT.has_point(click_position):
		picker_open = false
		queue_redraw()
		return true
	return true

func map_badge_text() -> String:
	return "MAP %02d" % int(arena.selected_map) if is_instance_valid(arena) else "MAP --"

func _draw() -> void:
	if not is_instance_valid(arena) or not arena.round_started:
		return
	var font: Font = FontCatalog.ui_font()
	draw_map_badge(font)
	draw_test_button(font)
	if not feedback_text.is_empty():
		var feedback_rect := Rect2(300, 510, 400, 34)
		draw_rect(feedback_rect, Color(0.02, 0.03, 0.04, 0.88), true)
		draw_rect(feedback_rect, Color("ffd166"), false, 2.0)
		draw_string(font, feedback_rect.position + Vector2(10, 23), feedback_text, HORIZONTAL_ALIGNMENT_CENTER, feedback_rect.size.x - 20, 14, Color.WHITE)
	if picker_open:
		draw_weapon_picker(font)

func draw_map_badge(font: Font) -> void:
	var badge := Rect2(14, 458, 104, 34)
	draw_rect(badge, Color(0.02, 0.03, 0.04, 0.84), true)
	draw_rect(badge, Color("ffd166"), false, 2.0)
	draw_string(font, badge.position + Vector2(0, 24), map_badge_text(), HORIZONTAL_ALIGNMENT_CENTER, badge.size.x, 17, Color("ffd166"))

func draw_test_button(font: Font) -> void:
	var active: bool = int(arena.player_slot_types[1]) != 0
	var hovered: bool = BUTTON_RECT.has_point(mouse_position)
	var fill: Color = Color("e66b00") if active else Color("555962")
	if hovered:
		fill = fill.lightened(0.16)
	draw_rect(BUTTON_RECT, fill, true)
	draw_rect(BUTTON_RECT, Color("151515"), false, 2.0)
	var label: String = arena.menu_text("P2 TEST WEAPON", "角色 2 测试武器")
	draw_string(font, BUTTON_RECT.position + Vector2(0, 25), label, HORIZONTAL_ALIGNMENT_CENTER, BUTTON_RECT.size.x, 14, Color.WHITE)

func draw_weapon_picker(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1000, 560), Color(0.0, 0.0, 0.0, 0.70), true)
	draw_rect(PANEL_RECT, Color("34383f"), true)
	draw_rect(PANEL_RECT, Color("111318"), false, 4.0)
	draw_rect(Rect2(PANEL_RECT.position + Vector2(18, 16), Vector2(PANEL_RECT.size.x - 36, 42)), Color("5b6068"), true)
	draw_string(font, PANEL_RECT.position + Vector2(32, 47), arena.menu_text("SELECT A SPECIAL WEAPON FOR PLAYER 2", "为角色 2 选择特殊武器"), HORIZONTAL_ALIGNMENT_LEFT, 620, 23, Color.WHITE)
	if int(arena.player_slot_types[1]) == 0:
		draw_string(font, PANEL_RECT.position + Vector2(565, 45), arena.menu_text("P2 INACTIVE", "角色 2 未启用"), HORIZONTAL_ALIGNMENT_RIGHT, 170, 13, Color("ff9b9b"))

	for index in WeaponCatalog.CRATE_WEAPON_IDS.size():
		var weapon_id: int = WeaponCatalog.CRATE_WEAPON_IDS[index]
		var cell: Rect2 = weapon_cell_rect(index)
		var hovered: bool = cell.has_point(mouse_position)
		draw_rect(cell, Color("ff7a00") if hovered else Color("50555e"), true)
		draw_rect(cell, Color("15171b"), false, 2.0)
		draw_string(font, cell.position + Vector2(10, 26), "%02d" % weapon_id, HORIZONTAL_ALIGNMENT_LEFT, 38, 16, Color("ffd166"))
		draw_string(font, cell.position + Vector2(42, 27), arena.weapon_menu_name(weapon_id), HORIZONTAL_ALIGNMENT_LEFT, cell.size.x - 48, 13, Color.WHITE)
		var weapon: Dictionary = WeaponCatalog.get_weapon(weapon_id)
		draw_string(font, cell.position + Vector2(10, 56), arena.menu_text("AMMO %s" % str(weapon["ammo"]), "弹药 %s" % str(weapon["ammo"])), HORIZONTAL_ALIGNMENT_LEFT, cell.size.x - 20, 11, Color("d7dce5"))

	var close_hovered: bool = CLOSE_RECT.has_point(mouse_position)
	draw_rect(CLOSE_RECT, Color("bd2424").lightened(0.14) if close_hovered else Color("9e1f1f"), true)
	draw_rect(CLOSE_RECT, Color("151515"), false, 2.0)
	draw_string(font, CLOSE_RECT.position + Vector2(0, 23), arena.menu_text("CLOSE", "关闭"), HORIZONTAL_ALIGNMENT_CENTER, CLOSE_RECT.size.x, 14, Color.WHITE)
