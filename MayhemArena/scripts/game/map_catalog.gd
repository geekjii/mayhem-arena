class_name MapCatalog
extends RefCounted

# Exact 1000 x 560 scene3 frames from the local Redux reference SWF.
const MAP_TEXTURES := {
	1: preload("res://assets/original_reference/maps/redux_map_01.png"),
	2: preload("res://assets/original_reference/maps/redux_map_02.png"),
	3: preload("res://assets/original_reference/maps/redux_map_03.png"),
	4: preload("res://assets/original_reference/maps/redux_map_04.png"),
	5: preload("res://assets/original_reference/maps/redux_map_05.png"),
	6: preload("res://assets/original_reference/maps/redux_map_06.png"),
	7: preload("res://assets/original_reference/maps/redux_map_07.png"),
	8: preload("res://assets/original_reference/maps/redux_map_08.png"),
	9: preload("res://assets/original_reference/maps/redux_map_09.png"),
	10: preload("res://assets/original_reference/maps/redux_map_10.png"),
}

# The painted stage is a three-layer movie clip in the original SWF. Its ten
# timeline frames are map ids 1..10 (selected by gotoAndStop(mapnumber)), not
# animation frames for a single map. The existing redux_map_## images remain
# the stable opaque base, while gameplay composites the matching source layers.
const SCENE_LAYER_PATHS := {
	"scene1": "res://assets/original_reference/map_layers/scene1/%d.png",
	"scene2": "res://assets/original_reference/map_layers/scene2/%d.png",
	"scene3": "res://assets/original_reference/map_layers/scene3/%d.png",
}
const SCENE_LAYER_ORIGINS := {
	"scene1": Vector2(173, 57),
	"scene2": Vector2(381, 157),
	"scene3": Vector2(485, 160),
}

# The first map was hand-aligned to its painted ledges. Maps 2-10 are traced
# from the black platform shapes in symbol 1163. Their exported collision layer
# sits 12 pixels above scene3, so platforms_for() applies that visual correction.
# The rectangles deliberately retain the broad, forgiving Flash collision.
const PLATFORM_SETS := {
	1: [
		Rect2(85, 83, 510, 18), Rect2(452, 157, 505, 18),
		Rect2(390, 239, 204, 16), Rect2(40, 291, 510, 18),
		Rect2(305, 375, 407, 18), Rect2(87, 445, 304, 18),
		Rect2(551, 445, 408, 18),
	],
	2: [
		Rect2(107, 98, 809, 18), Rect2(141, 238, 731, 18),
		Rect2(384, 448, 262, 18), Rect2(68, 308, 253, 18),
		Rect2(188, 378, 251, 18), Rect2(27, 448, 246, 18),
		Rect2(701, 308, 245, 18), Rect2(582, 378, 228, 18),
		Rect2(756, 448, 221, 18), Rect2(691, 168, 126, 18),
		Rect2(233, 168, 126, 18),
	],
	3: [
		Rect2(17, 335, 463, 18), Rect2(568, 335, 421, 18),
		Rect2(587, 196, 335, 18), Rect2(142, 198, 323, 18),
		Rect2(373, 406, 290, 18), Rect2(71, 265, 166, 18),
		Rect2(447, 128, 154, 18), Rect2(812, 265, 141, 18),
		Rect2(621, 265, 107, 18), Rect2(314, 265, 107, 18),
	],
	4: [
		Rect2(495, 268, 411, 18), Rect2(118, 341, 388, 18),
		Rect2(491, 128, 334, 18), Rect2(197, 201, 308, 18),
		Rect2(741, 341, 247, 18), Rect2(9, 128, 237, 18),
		Rect2(765, 56, 223, 18), Rect2(16, 412, 211, 18),
	],
	5: [
		Rect2(439, 431, 549, 18), Rect2(8, 361, 483, 18),
		Rect2(34, 221, 470, 18), Rect2(478, 151, 466, 18),
		Rect2(478, 289, 466, 18), Rect2(57, 81, 464, 18),
	],
	6: [
		Rect2(7, 489, 960, 18), Rect2(660, 344, 307, 18),
		Rect2(46, 274, 302, 18), Rect2(19, 204, 299, 18),
		Rect2(696, 274, 289, 18), Rect2(666, 204, 301, 18),
		Rect2(688, 134, 302, 18), Rect2(19, 346, 299, 18),
		Rect2(46, 416, 298, 18), Rect2(46, 134, 297, 18),
		Rect2(696, 416, 285, 18), Rect2(426, 272, 205, 18),
	],
	7: [
		Rect2(103, 341, 328, 18), Rect2(125, 198, 309, 18),
		Rect2(666, 271, 322, 18), Rect2(548, 201, 308, 18),
		Rect2(-1, 271, 309, 18), Rect2(552, 341, 304, 18),
		Rect2(365, 271, 252, 18),
	],
	8: [
		Rect2(27, 201, 943, 18), Rect2(113, 341, 808, 18),
		Rect2(249, 131, 249, 18), Rect2(575, 131, 243, 18),
		Rect2(722, 269, 177, 18), Rect2(155, 271, 175, 18),
	],
	9: [
		Rect2(45, 481, 927, 18), Rect2(373, 61, 267, 18),
		Rect2(471, 201, 169, 18), Rect2(411, 411, 167, 18),
		Rect2(425, 131, 160, 18), Rect2(391, 271, 160, 18),
		Rect2(455, 341, 159, 18),
	],
	10: [
		Rect2(297, 201, 478, 18), Rect2(576, 481, 397, 18),
		Rect2(88, 481, 372, 18), Rect2(95, 340, 308, 18),
		Rect2(643, 341, 297, 18), Rect2(414, 411, 200, 18),
		Rect2(472, 131, 149, 18), Rect2(141, 268, 140, 18),
		Rect2(784, 270, 124, 18),
	],
}

const SPAWN_SETS := {
	1: [Vector2(292, 250), Vector2(741, 110)],
	2: [Vector2(291, 130), Vector2(749, 130)],
	3: [Vector2(149, 225), Vector2(877, 225)],
	4: [Vector2(125, 80), Vector2(875, 18)],
	5: [Vector2(235, 40), Vector2(710, 110)],
	6: [Vector2(190, 90), Vector2(840, 90)],
	7: [Vector2(280, 155), Vector2(700, 158)],
	8: [Vector2(370, 88), Vector2(695, 88)],
	9: [Vector2(500, 18), Vector2(525, 158)],
	10: [Vector2(545, 88), Vector2(210, 225)],
}

static func texture_for(map_id: int) -> Texture2D:
	return MAP_TEXTURES.get(map_id, MAP_TEXTURES[1])

static func scene_layer_for(layer_name: String, map_id: int) -> Texture2D:
	var path_template: String = SCENE_LAYER_PATHS.get(layer_name, "")
	if path_template.is_empty():
		return null
	var normalized_map_id := clampi(map_id, 1, 10)
	return ResourceLoader.load(path_template % normalized_map_id) as Texture2D

static func scene_layer_origin(layer_name: String) -> Vector2:
	return SCENE_LAYER_ORIGINS.get(layer_name, Vector2.ZERO)

static func platforms_for(map_id: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var visual_offset := Vector2(0, 12) if map_id > 1 else Vector2.ZERO
	for platform in PLATFORM_SETS.get(map_id, PLATFORM_SETS[1]):
		result.append(Rect2(platform.position + visual_offset, platform.size))
	return result

static func spawns_for(map_id: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for spawn in SPAWN_SETS.get(map_id, SPAWN_SETS[1]):
		result.append(spawn)
	# Slots three and four enter from above and settle onto the same broad Flash
	# platform collision used by the original two verified spawn points.
	result.append(Vector2(400, -80))
	result.append(Vector2(600, -150))
	return result
