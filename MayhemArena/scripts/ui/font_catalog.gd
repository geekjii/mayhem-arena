class_name FontCatalog
extends RefCounted

const UI_FONT: Font = preload("res://assets/fonts/SourceHanSansCN-Heavy.ttf")
const REQUIRED_CJK_TEXT := "中文混乱大枪战控制设置返回继续开始技能武器地图"

static func ui_font() -> Font:
	return UI_FONT

static func supports_required_glyphs() -> bool:
	for character in REQUIRED_CJK_TEXT:
		if not UI_FONT.has_char(character.unicode_at(0)):
			return false
	return true
