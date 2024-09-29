@tool
extends TileSet
# "tool" makes this also apply when placing tiles by hand in the tilemap editor too.


var binds = {
	2: [2,10],
#	8: [9],
	9: [10],
	10: [2,10],

	
}



func _is_tile_bound(id, neighbour_id):
	#return false
	#return true
	if id in binds:
		return neighbour_id in binds[id]
	return false
