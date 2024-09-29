extends TileMap

var testjson = {}
var isselected = false
var selectedtile = Vector2i(-1,-1)
var goaltile = Vector2i(-1,-1)
var tween


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$line.set_point_position(0,Vector2(0,0))
	$line.set_point_position(1,Vector2(56*Gamemap.gamemap.mapx,0))
	$line.set_point_position(2,Vector2(56*Gamemap.gamemap.mapx,56*Gamemap.gamemap.mapy))
	$line.set_point_position(3,Vector2(0,56*Gamemap.gamemap.mapy))
	#$".".visible = VISIBILITY_MODE_FORCE_HIDE
	#$".".erase_cell(0,Vector2i(6,1))
	#$".".update_internals()
	#get_surrounding_cells
	#set_cells_terrain_path 
	#print($".".get_cell_alternative_tile(0,Vector2i(0,0)))
	#print($".".get_cell_atlas_coords(0,Vector2i(0,0)))
	#print($".".get_cell_source_id(0,Vector2i(0,0)))
	#$".".set_cell(0,Vector2i(0,0),0,Vector2i(0,0),0)
	#$".".set_cells_terrain_connect(0,[Vector2i(0,0)],0,9,false)
	#$".".set_cells_terrain_path(0,[Vector2i(0,0),Vector2i(1,0)],0,9,true)
	#var tmapdata = []
	#for j in range(11+2):
	#	var tmapxdata = []
	#	for i in range(20+2):
	#		tmapxdata.append($".".get_cell_source_id(0,Vector2i(i-1,j-1)))
	#	tmapdata.append(tmapxdata)
	#print(tmapdata)
	#for j in range(Gamemap.gamemap.mapy+2):
		#for i in range(Gamemap.gamemap.mapx+2):
			#$".".set_cells_terrain_connect(0,[Vector2i(i-1,j-1)],0,Gamemap.gamemap.terrain[j][i],true)
	#var unit = load("res://unit.tscn").instantiate()
	#unit.unitsprite = GAMEDATA.UNIT_FRAME.AnnihilatorTank
	#unit.position = Vector2(0,0)
	#$"..".add_child.call_deferred(unit)
	#$"../Camera/RichTextLabel".add_image(load("res://sprites/512_info_icons_info_icons.png"))
	#var unitdata = load("res://unit.json").data
	#var unitdatajson = JSON.stringify(unitdata)
	#print(unitdata.Intrepid.name)
	#for y in Gamemap.gamemap.mapy :
		#var tempdata = []
		#for x in Gamemap.gamemap.mapx :
			#print("源:" + str($".".get_cell_source_id(0,Vector2i(x,y))) + "图集:" + str($".".get_cell_atlas_coords(0,Vector2i(x,y))))
			#tempdata.append([$".".get_cell_source_id(0,Vector2i(x,y)),$".".get_cell_atlas_coords(0,Vector2i(x,y))])
		#print(tempdata)
	#print(GAMEDATA.UNIT_DATA.AnnihilatorTank[GAMEDATA.UNIT_TRAIT.MAMMOTH])
	
	#for i in range(1111):
		#for j in range(1111):
			#testjson[Vector2i(i,j)] = Vector2i(i,j)
			#pass
	#print(JSON.print(unitdata, "\t"))
	for y in Gamemap.gamemap.mapy :
		for x in Gamemap.gamemap.mapx :
			var coord = Vector2i(x,y)
			if Gamemap.gamemap.unit.has(coord):
				var unit = load("res://unit.tscn").instantiate()
				Gamemap.gamemap.unit[coord]["unitobj"] = unit
				unit.position = Vector2(56*x+28,56*y+28)
				unit.player = Gamemap.gamemap.unit.get(coord).player
				unit.unitid = Gamemap.gamemap.unit.get(coord).unitid
				unit.unit = Gamemap.gamemap.unit.get(coord).unit
				unit.unitname = Gamemap.gamemap.unit.get(coord).unitname
				unit.color = Gamemap.playercolor[Gamemap.gamemap.unit.get(coord).player]
				print(Gamemap.playercolor[Gamemap.gamemap.unit.get(coord).player])
				unit.direction = Gamemap.gamemap.unit.get(coord).direction
				unit.unit = Gamemap.gamemap.unit.get(coord).unit
				unit.unitflag = Gamemap.gamemap.unit.get(coord).unitflag
				unit.resource = Gamemap.gamemap.unit.get(coord).resource
				var unitdata = GAMEDATA.UNIT_DATA.get(Gamemap.gamemap.unit.get(coord).unit)
				unit.unitsprite = unitdata.get("unitsprite")
				unit.unitaudio = unitdata.get("unitaudio")
				unit.type = unitdata.get("type")
				unit.hp = Gamemap.gamemap.unit.get(coord).hp
				unit.movement = unitdata.get("movement")
				unit.speed = unitdata.get("speed")
				unit.attack = unitdata.get("attack")
				unit.armor = unitdata.get("armor")
				unit.weapon = unitdata.get("weapon")
				unit.rangemin = unitdata.get("rangemin")
				unit.rangemax = unitdata.get("rangemax")
				unit.traits = unitdata.get("traits")
				unit.cost = unitdata.get("cost")
				unit.actioned = unitdata.get("actioned")
				unit.isinvisible = unitdata.get("isinvisible")
				Gamemap.unit[coord] = unit
				$"../units".add_child.call_deferred(unit)
			
			if Gamemap.terrain.has(coord):
				var terrain = Gamemap.terrain.get(coord)
				$".".set_cell(0,coord,terrain.sourceid,terrain.atlascoords,0)
			
			if Gamemap.building.has(coord):
				var builging = load("res://building.tscn").instantiate()
				var builgingdata = Gamemap.building.get(coord)
				builging.player = builgingdata.get("player")
				builging.building = builgingdata.get("building")
				builging.buildingflag = builgingdata.get("buildingflag")
				builging.position = Vector2(56*x+28,56*y+28)
				$"../buildings".add_child.call_deferred(builging)
				Gamemap.building[coord] = builging
	
	
	var allcellarray = []
	var allneighborcellarray = {}
	for y in Gamemap.gamemap.mapy :
		for x in Gamemap.gamemap.mapx :
			var cell = Vector2i(x,y)
			allcellarray.append(cell)
	
	for y in Gamemap.gamemap.mapy :
		for x in Gamemap.gamemap.mapx :
			var neighborcellarray = [Vector2i(x,y-1),Vector2i(x,y+1),Vector2i(x-1,y),Vector2i(x+1,y)]
			neighborcellarray = neighborcellarray.filter(func(cell): return allcellarray.has(cell))
			allneighborcellarray.merge({Vector2i(x,y):neighborcellarray})
	
	#print(allcellarray)
	#print(allneighborcellarray)
	
	
	for movement in GAMEDATA.UNIT_MOVEMENT:
		var m = GAMEDATA.UNIT_MOVEMENT[movement]
		Gamemap.path_matrix[m] = {}
		for i in allcellarray:
			Gamemap.path_matrix[m][i] = {}
			for j in allcellarray:
				Gamemap.path_matrix[m][i][j] = INF
				
			allneighborcellarray[i].all(
				func(tile):
					#var aaaa = get_tile_movement(Gamemap.terrain["source"],m)
					#print(Gamemap.terrain[tile]["sourceid"])
					Gamemap.path_matrix[m][i][tile] = get_tile_movement(Gamemap.terrain[tile]["sourceid"],m)
					return true
			)
	
	
	Gamemap.turn = 1
	Gamemap.currentplayer = 0
	
	
	#Gamemap.path_matrix.make_read_only()
	#print(dijkstar_tiles(Gamemap.path_matrix[1].duplicate(),Vector2i(1,1),3))
	#print(dijkstar_path(Gamemap.path_matrix[1].duplicate(),Vector2i(1,1),Vector2i(3,3)))
	#print(Gamemap.path_matrix[1])
	
	
	
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _unhandled_input(event):
	
	if event is InputEventKey and event.pressed:
			if event.keycode == KEY_UP:
				$"../Camera".position += Vector2(0,-30)
			if event.keycode == KEY_DOWN:
				$"../Camera".position += Vector2(0,30)
			if event.keycode == KEY_LEFT:
				$"../Camera".position += Vector2(-30,0)
			if event.keycode == KEY_RIGHT:
				$"../Camera".position += Vector2(30,0)
			
	pass
	
	#return
	#$"../Camera/Label".text = str(event.position+Camera2D.position)
	$"../Camera/Label".text = str(get_global_mouse_position())
	var mapxy = local_to_map(get_global_mouse_position())
	var x = mapxy.x
	var y = mapxy.y
	#if Gamemap.gamemap.mapx < x : return
	#if Gamemap.gamemap.mapy < y : return
	#print($".".get_cell_alternative_tile(0,Vector2i(0,0)))
	#print($".".get_cell_atlas_coords(0,Vector2i(0,0)))
	#print($".".get_cell_source_id(0,Vector2i(0,0)))
	
	var terrain = Gamemap.terrain.get(mapxy)
	var sourceid = -1
	var atlascoords = Vector2i(-1,-1)
	if terrain != null:
		sourceid = terrain.get("sourceid")
		atlascoords = terrain.get("atlascoords")
	
	$"../Camera/Label2".text = str(mapxy)
	$"../Camera/Label3".text = "tilemap  " + "sourceid:" + str($".".get_cell_source_id(0,Vector2i(x,y))) + "  atlascoords:" + str($".".get_cell_atlas_coords(0,Vector2i(x,y)))
	$"../Camera/Label4".text = "gamemap " + "sourceid:" + str(sourceid) + "  atlascoords:" + str(atlascoords)
	$"../Camera/Label5".text = "terrain:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid))
	$"../Camera/Label6".text = "unit:" + str(Gamemap.gamemap.unit.get(Vector2i(x,y)))
	$"../Camera/Label7".text = "building:" + str(Gamemap.building.get(Vector2i(x,y)))
	$"../Camera/Label8".text = "turn" + str(Gamemap.turn) + "  player" + str(Gamemap.currentplayer)
	#print(event.position)
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print(get_global_mouse_position())
			print(mapxy)
			
			$"../Camera/terrainui/Label".text = str(null)
			$"../Camera/terrainui/Label2".text = str(null)
			$"../Camera/terrainui/TileMap".erase_cell(0,Vector2i(0,0))
			if terrain != null :
				var terraindata = GAMEDATA.TERRAIN_DATA.get(sourceid)
				$"../Camera/terrainui/Label".text = str(terraindata.name)
				$"../Camera/terrainui/Label2".text = str(terraindata.description)
				$"../Camera/terrainui/TileMap".set_cell(0,Vector2i(0,0),sourceid,atlascoords,0)
			
			#if Gamemap.gamemap.unit.has(mapxy):
				#if Gamemap.gamemap.unit.get(mapxy).player == Gamemap.currentplayer:
					#if !Gamemap.gamemap.unit.get(mapxy).isaction:
						#$"../selecticon".visible = 1
						#$"../selecticon".position = Vector2(56*mapxy.x+28,56*mapxy.y+28)
						#selectedtile = mapxy
						#var path = Gamemap.path_matrix[GAMEDATA.UNIT_DATA[Gamemap.gamemap.unit.get(mapxy)["unit"]].get("movement")]
						#var start = mapxy
						#var speed = GAMEDATA.UNIT_DATA[Gamemap.gamemap.unit.get(mapxy)["unit"]]["speed"]
						#$"../movetile".tiles = dijkstar_tiles(path.duplicate(),start,speed)
						#$"../movetile".visible = 1
				#else:
					#$"../selecticon".visible = 0
					#$"../movetile".visible = 0
			#else:
				#$"../selecticon".visible = 0
				#$"../movetile".visible = 0
			
	
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$"../selectui/selecttilemap".clear()
			var unit = Gamemap.unit.get(mapxy,{})
			if unit.get("player") != null and unit.get("actioned") == false:
				var path:Dictionary = Gamemap.path_matrix.get(unit.unitdata.movement).duplicate(true)
				path.keys().all(func(tile):
					if Gamemap.unit.get(tile,{}).get("player") != Gamemap.unit.get(mapxy,{}).get("player") and Gamemap.unit.get(tile,{}).get("player") != null:
						path.erase(tile)
					return 1
					)
				var movetiles = dijkstar_tiles(path,mapxy,unit.unitdata.speed)
				movetiles.append(mapxy)
				movetiles.all(func(tile):
					$"../selectui/selecttilemap".set_cell(0,tile,0,Vector2i(0,0),0)
					return 1
					)
				
				var attacktiles = {}
				if unit.get("unitdata").get("rangemin") <= 0 and unit.get("unitdata").get("rangemax") <= 0:
					pass
				elif unit.get("unitdata").get("rangemin") <= 1 and unit.get("unitdata").get("rangemax") <= 1:
					#attacktiles.append_array(movetiles)
					movetiles.all(func(tile):
						attacktiles[tile+Vector2i(0,1)] = 0
						attacktiles[tile+Vector2i(1,0)] = 0
						attacktiles[tile+Vector2i(0,-1)] = 0
						attacktiles[tile+Vector2i(-1,0)] = 0
						return 1
						)
					attacktiles.keys().filter(func(tile):
						return Gamemap.path_matrix[0].has(tile) and !movetiles.has(tile)
						).all(func(tile):
							$"../selectui/selecttilemap".set_cell(0,tile,1,Vector2i(0,0),0)
							return 1
							)
				else:
					attacktiles[mapxy] = 0
					for i in range(unit.get("unitdata").get("rangemax")):
						attacktiles.keys().all(func(tile):
							attacktiles[tile+Vector2i(0,1)] = 0
							attacktiles[tile+Vector2i(1,0)] = 0
							attacktiles[tile+Vector2i(0,-1)] = 0
							attacktiles[tile+Vector2i(-1,0)] = 0
							return 1
							)
					var t = {}
					t[mapxy] = 0
					for i in range(unit.get("unitdata").get("rangemin")-1):
						t.keys().all(func(tile):
							t[tile+Vector2i(0,1)] = 0
							t[tile+Vector2i(1,0)] = 0
							t[tile+Vector2i(0,-1)] = 0
							t[tile+Vector2i(-1,0)] = 0
							return 1
							)
					t.keys().all(func(tile):
						attacktiles.erase(tile)
						return 1
						)
					attacktiles.keys().all(func(tile):
						$"../selectui/selecttilemap".set_cell(0,tile,1,Vector2i(0,0),0)
						if movetiles.has(tile):
							$"../selectui/selecttilemap".set_cell(0,tile,2,Vector2i(0,0),0)
						return 1
						)


func getmapterrain(x,y)->int:
	if (x < 0 or x > Gamemap.gamemap.mapx-1 or y < 0 or y > Gamemap.gamemap.mapy-1):
		return -1
	return Gamemap.gamemap.terrain[y+1][x+1]

func _input(event):
	pass
	

func getneighbortile()->Array:
	
	return []

func get_tile_movement(source,movement)->float:
	if source < 0 : return INF
	var m = GAMEDATA.TERRAIN_DATA.get(source).get(movement)
	if m == null : return INF
	if m != NAN :
		return m
	return INF

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
		pathlist[key]["distance"] = path[start][key]
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
			var d = pathlist[next_node]["distance"] + path[next_node][i]
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


func _on_pathfindbtn_button_down():
	var start = Vector2i(int($"../Camera/movetextui/start/SpinBox".value),int($"../Camera/movetextui/start/SpinBox2".value))
	var goal = Vector2i(int($"../Camera/movetextui/goal/SpinBox".value),int($"../Camera/movetextui/goal/SpinBox2".value))
	if !Gamemap.path_matrix[0].has(start) : return
	if !Gamemap.path_matrix[0].has(goal) : return
	if start == goal : return
	var path = dijkstar_path(Gamemap.path_matrix[1].duplicate(),start,goal)
	if path == [] : return
	print(path)
	$"../moveline".linedata = path
	pass # Replace with function body.


func _on_movetilebtn_button_down():
	var start = Vector2i(int($"../movetileui/SpinBox".value),int($"../movetileui/SpinBox2".value))
	var speed = $"../movetileui/SpinBox3".value
	if !Gamemap.path_matrix[0].has(start) : return
	if speed <= 0 : return
	var tiles = dijkstar_tiles(Gamemap.path_matrix[1].duplicate(),start,speed)
	print(tiles)
	$"../movetile".tiles = tiles
	pass # Replace with function body.


func _on_endturnbtn_button_down():
	#Consolecommands.emit_signal("test")
	#return
	AllSIGNAL.emit_signal("playerturnstart",Gamemap.currentplayer)
	if Gamemap.currentplayer >= Gamemap.playernum-1:
		Gamemap.turn = Gamemap.turn+1
		Gamemap.currentplayer = 0
	else:
		Gamemap.currentplayer = Gamemap.currentplayer+1
	AllSIGNAL.emit_signal("playerturnend",Gamemap.currentplayer)
	pass # Replace with function body.
