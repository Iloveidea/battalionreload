extends Node2D

#var map = "res://map/mapeditorinit"
var map = "res://map/testmap/asd.bmap"
var path_matrix :Dictionary= {}

var playernum = 3
var playername = ["player1","player2","player3",]
var playercolor = [
	GAMEDATA.COLOR_COIN_GRAY,
	GAMEDATA.COLOR_COIN_GOLD,
	GAMEDATA.COLOR_TEAL,
]

var playresource = [0,0,0]

var turn = 0
var currentplayer = 0

var mapx = 10
var mapy = 10

var terrain:Dictionary = {}
var building:Dictionary = {}
var unit:Dictionary = {}

var lockcontrol = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$building/building.queue_free()
	$unit/unit.queue_free()
	var file = FileAccess.open(map,1)
	var mapdata = file.get_var()
	load_map(mapdata)
	
	pass # Replace with function body.

func load_map(data):
	playernum = data["playernum"]
	playername = data["playername"]
	$Camera/turnui.init(playernum,playername)
	playercolor = data["playercolor"]
	Gamemap.playercolor= data["playercolor"]
	mapx = data["mapx"]
	mapy = data["mapy"]
	$line.clear_points()
	$line.add_point(Vector2(0,0))
	$line.add_point(Vector2(Gamemap.mapx*56.0,0))
	$line.add_point(Vector2(Gamemap.mapx*56.0,Gamemap.mapy*56.0))
	$line.add_point(Vector2(0,Gamemap.mapy*56.0))
	terrain = data["terrain"]
	load_terrain(data["terrain"])
	#building = data["building"]
	load_building(data["building"])
	path_matrix_init(data["terrain"],data["building"])
	#unit = data["unit"]
	load_unit(data["unit"])
	
	#print(dijkstar_tiles(path_matrix[1],Vector2i(3,3),5))
	
	
	pass

func load_terrain(data):
	for key in data.keys():
		$terrainmap/TileMap.set_cell(0,key,data[key].sourceid,data[key].atlascoords,0)


func load_building(data):
	for key in data.keys():
		var b = load("res://building.tscn").instantiate()
		b.player = data[key]["player"]
		b.building = data[key]["building"]
		b.position = (key * 56) + Vector2i(28,28)
		building[key] = b
		$building.add_child(b)
	pass

func load_unit(data):
	for key in data.keys():
		var u = load("res://unit.tscn").instantiate()
		u.player = data[key]["player"]
		u.unit = data[key]["unit"]
		u.position = (key * 56) + Vector2i(28,28)
		unit[key] = u
		$unit.add_child(u)
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func path_matrix_init(terraindata,buildingdata):
	for movement in GAMEDATA.UNIT_MOVEMENT:
		var m = GAMEDATA.UNIT_MOVEMENT[movement]
		path_matrix[m] = {}
		for i in terraindata.keys():
			path_matrix[m][i] = {}
			[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(tile):
				var t = tile + i
				path_matrix[m][i][t] = get_tile_movement(terraindata.get(t,{}).get("sourceid",-1),buildingdata.get(t,{}).get("building",-1),m)
				
				)



func get_tile_movement(source,b,movement)->float:
	if b < 0:
		if source < 0 : return INF
		var m = GAMEDATA.TERRAIN_DATA.get(source,{}).get(movement)
		if m == null : return INF
		if m != NAN :
			return m
		return INF
	else:
		var m = GAMEDATA.BUILDING_DATA.get(b,{}).get(movement,INF)
		return m

func dijkstar_tiles(path:Dictionary,start:Vector2i,speed:float)->Array:
	if speed <= 0.1: return []
	if path.has(0):
		print("寻路表导入错误")
		return []
	var tiles = []
	var pathlist = {}
	#var visited = [start]
	var unvisited = path.keys()
	unvisited.erase(start)
	for key in path:
		pathlist[key] = {}
		pathlist[key]["distance"] = path.get(start,{}).get(key,INF)
	pathlist[start]["distance"] = 0
	while 1:
		var next_node = null
		var min_distance = INF
		
		if unvisited == []:
			return tiles
		
		for i in unvisited:
			if pathlist[i]["distance"] < min_distance:
				next_node = i
				min_distance = pathlist[i]["distance"]
		
		if min_distance > speed :
			return tiles
		
		for i in unvisited:
			#if path[next_node][i] == INF : continue
			var d = pathlist[next_node]["distance"] + path.get(next_node,{}).get(i,INF)
			if d < pathlist[i]["distance"]:
				pathlist[i]["distance"] = d
		unvisited.erase(next_node)
		#visited.append(next_node)
		tiles.append(next_node)
	
	return []
	


func dijkstar_path(path:Dictionary,start:Vector2i,goal:Vector2i)->Array:
	if path.has(0):
		print("寻路表导入错误")
		return []
	if start == goal : return []
	if !path.has(start) : return[]
	if !path.has(goal) : return[]
	var tiles = []
	tiles.append(goal)
	var pathlist = {}
	#var visited = [start]
	var unvisited = path.keys()
	unvisited.erase(start)
	for key in path:
		pathlist[key] = {}
		pathlist[key]["last"] = start
		pathlist[key]["distance"] = path[start][key]
	pathlist[start]["distance"] = 0
	
	while 1:
		var next_node = null
		var min_distance = INF
		
		for i in unvisited:
			if pathlist[i]["distance"] < min_distance:
				next_node = i
				min_distance = pathlist[i]["distance"]
		
		if min_distance == INF :
			return []
		
		for i in unvisited:
			#if path[next_node][i] == INF : continue
			var d = pathlist[next_node]["distance"] + path[next_node][i]
			if d < pathlist[i]["distance"]:
				pathlist[i]["last"] = next_node
				pathlist[i]["distance"] = d
		unvisited.erase(next_node)
		#visited.append(next_node)
		
		if next_node == goal :
			while 1:
				var t = pathlist[tiles[-1]]["last"]
				tiles.append(t)
				if t == start : break
			tiles.reverse()
			return tiles
	
	
	return []
