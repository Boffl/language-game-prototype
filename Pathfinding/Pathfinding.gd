extends Node2D
class_name Pathfinding


var astar = AStar2D.new()	# initialize A*
var tilemap					# tilemap with coordinates
var half_cell_size = Vector2(8, 8)
var used_rect: Rect2


func create_navigation_map(tilemap):
	self.tilemap = tilemap
	used_rect = tilemap.get_used_rect()
	
	# stores all the tiles placed in the floor tilemap
	var tiles = tilemap.get_used_cells()
	
	add_traversable_tiles(tiles)
	connect_traversable_tiles(tiles)


func add_traversable_tiles(tiles: Array):
	""" Builds A* Grid """
	for tile in tiles:
		var id = get_id_for_point(tile)
		astar.add_point(id, tile)
	

func connect_traversable_tiles(tiles: Array):
	for tile in tiles:
		var id = get_id_for_point(tile)
		
		# 0, 1, 2 -1, 0, 1
		for x in range(3):
			for y in range(3):
				var target = tile + Vector2(x - 1, y- 1)
				var target_id = get_id_for_point(target)
				
				if tile == target or not astar.has_point(target_id):
					continue
				
				astar.connect_points(id, target_id, true)
		


func get_id_for_point(point: Vector2):
	""" Gives each tile a unique ID """
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y
	
	return x + y * used_rect.size.x
	


func get_new_path(start, end):
	var start_tile = tilemap.world_to_map(start)
	var end_tile = tilemap.world_to_map(end)
	
	var start_id = get_id_for_point(start_tile)
	var end_id = get_id_for_point(end_tile)
	
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return []
		
	var path_map = astar.get_point_path(start_id, end_id)
	var path_world = []
	for point in path_map:
		var point_world = tilemap.map_to_world(point + half_cell_size)
		path_world.append(point_world)
		
	return path_world
	
