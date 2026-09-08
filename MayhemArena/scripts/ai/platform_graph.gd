class_name PlatformGraph
extends RefCounted

var platforms: Array[Rect2] = []
var edges: Dictionary = {}

func rebuild(source_platforms: Array[Rect2]) -> void:
	platforms = source_platforms.duplicate()
	edges.clear()
	for from_index in platforms.size():
		edges[from_index] = []
		var from_rect := platforms[from_index]
		var from_center := from_rect.get_center()
		for to_index in platforms.size():
			if from_index == to_index:
				continue
			var to_rect := platforms[to_index]
			var to_center := to_rect.get_center()
			var horizontal_gap := interval_gap(from_rect.position.x, from_rect.end.x, to_rect.position.x, to_rect.end.x)
			var vertical_delta := to_rect.position.y - from_rect.position.y
			var reachable_jump := vertical_delta >= -190.0 and vertical_delta <= 90.0 and horizontal_gap <= 185.0 and absf(to_center.x - from_center.x) <= 300.0
			var reachable_drop := vertical_delta > 0.0 and vertical_delta <= 285.0 and horizontal_gap <= 120.0
			if reachable_jump or reachable_drop:
				edges[from_index].append(to_index)

func interval_gap(first_min: float, first_max: float, second_min: float, second_max: float) -> float:
	if first_max < second_min:
		return second_min - first_max
	if second_max < first_min:
		return first_min - second_max
	return 0.0

func nearest_platform(point: Vector2) -> int:
	var best_index := -1
	var best_score := INF
	for index in platforms.size():
		var platform := platforms[index]
		var clamped_x := clampf(point.x, platform.position.x, platform.end.x)
		var score := absf(point.x - clamped_x) + absf(point.y - platform.position.y) * 1.5
		if score < best_score:
			best_score = score
			best_index = index
	return best_index

func next_platform_toward(from_index: int, target_index: int) -> int:
	if from_index < 0 or target_index < 0 or from_index == target_index:
		return target_index
	var frontier: Array[int] = [from_index]
	var came_from := {from_index: -1}
	while not frontier.is_empty():
		var current: int = frontier.pop_front()
		for neighbor_value in edges.get(current, []):
			var neighbor: int = int(neighbor_value)
			if came_from.has(neighbor):
				continue
			came_from[neighbor] = current
			if neighbor == target_index:
				var step: int = target_index
				while int(came_from[step]) != from_index and int(came_from[step]) >= 0:
					step = int(came_from[step])
				return step
			frontier.append(neighbor)
	return target_index

func platform_center(index: int) -> Vector2:
	if index < 0 or index >= platforms.size():
		return Vector2.ZERO
	var platform := platforms[index]
	return Vector2(platform.get_center().x, platform.position.y)
