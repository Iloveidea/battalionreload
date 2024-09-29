extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	#print(Vector2i(-3,4).abs().length())
	#print(Vector2i(-3,4).abs().length_squared())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func um(a:int,b:int,c:int,d:int):
	var movetween = create_tween()
	unit_move(Vector2i(a,b),Vector2i(c,d),movetween)
	await movetween.finished
	var sleeptween = create_tween()
	unit_sleep(Vector2i(c,d),sleeptween)
	await sleeptween.finished

func ua(a:int,b:int,c:int,d:int):
	var unit = Gamemap.unit.get(Vector2i(a,b))
	var unitdata = unit.get("unitdata")
	var goalunit = Gamemap.unit.get(Vector2i(c,d))
	var goalunitdata = goalunit.get("unitdata")
	
	unit.z_index = 1
	var attacktween = create_tween()
	unit_attack(Vector2i(a,b),Vector2i(c,d),attacktween)
	await attacktween.finished
	unit.z_index = 0
	
	
	if goalunit != null and _attackable(Vector2i(c,d),Vector2i(a,b)):
		goalunit.z_index = 1
		var counterattacktween = create_tween()
		unit_attack(Vector2i(c,d),Vector2i(a,b),counterattacktween)
		await counterattacktween.finished
		goalunit.z_index = 0
	
	if unit != null:
		var sleeptween = create_tween()
		unit_sleep(Vector2i(a,b),sleeptween)
		await sleeptween.finished

func uma(a:int,b:int,c:int,d:int,e:int,f:int):
	var movetween = create_tween()
	unit_move(Vector2i(a,b),Vector2i(c,d),movetween)
	await movetween.finished
	
	var unit = Gamemap.unit.get(Vector2i(c,d))
	var unitdata = unit.get("unitdata")
	var goalunit = Gamemap.unit.get(Vector2i(e,f))
	var goalunitdata = goalunit.get("unitdata")
	
	unit.z_index = 1
	var attacktween = create_tween()
	unit_attack(Vector2i(c,d),Vector2i(e,f),attacktween)
	await attacktween.finished
	unit.z_index = 0
	
	
	if goalunit != null and _attackable(Vector2i(e,f),Vector2i(c,d)):
		goalunit.z_index = 1
		var counterattacktween = create_tween()
		unit_attack(Vector2i(e,f),Vector2i(c,d),counterattacktween)
		await counterattacktween.finished
		goalunit.z_index = 0
	
	if unit != null:
		var sleeptween = create_tween()
		unit_sleep(Vector2i(c,d),sleeptween)
		await sleeptween.finished



func unit_move(unitcoord:Vector2i,goalcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	var unitdata = unit.get("unitdata")
	var path_matrix:Dictionary = Gamemap.path_matrix.get(unitdata.get("movement")).duplicate(true)
	path_matrix.keys().all(func(tile):
		if Gamemap.unit.get(tile,{}).get("player") != unit.get("player") and Gamemap.unit.get(tile,{}).get("player") != null:
			path_matrix.erase(tile)
		return 1
		)
	var path = dijkstar_path(path_matrix,unitcoord,goalcoord)
	if path == []:
		path = [unitcoord,goalcoord]
	
	for i in range(len(path)-1):
		match _direction(path[i],path[i+1]):
			"w":
				tween.tween_callback(unit.playani.bind("move_w"))
				tween.tween_property(unit, "position", Vector2(-56,0), 0.3).as_relative()
			"s":
				tween.tween_callback(unit.playani.bind("move_s"))
				tween.tween_property(unit, "position", Vector2(0,56), 0.3).as_relative()
			"e":
				tween.tween_callback(unit.playani.bind("move_e"))
				tween.tween_property(unit, "position", Vector2(56,0), 0.3).as_relative()
			"n":
				tween.tween_callback(unit.playani.bind("move_n"))
				tween.tween_property(unit, "position", Vector2(0,-56), 0.3).as_relative()
	tween.tween_property(unit, "position", Vector2(goalcoord*56)+Vector2(28,28), 0.1)
	Gamemap.unit[goalcoord] = unit
	Gamemap.unit.erase(unitcoord)
	pass

func unit_attack(unitcoord:Vector2i,goalcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	var unitdata = unit.get("unitdata")
	var goalunit = Gamemap.unit.get(goalcoord)
	var goalunitdata = goalunit.get("unitdata")
	
	var goalunitterraindefense = 0.0
	if goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.GROUND:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(goalcoord,{}).get("sourceid"),0).get("grounddefense")
	elif goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.WINGS:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(goalcoord,{}).get("sourceid"),0).get("airdefense")
	elif goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.SEA:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(goalcoord,{}).get("sourceid"),0).get("seadefense")
	
	
	var unitattack = float(unitdata.get("attack")) * (float(unit.get("hp"))/float(unitdata.get("hp"))) * (1.0-goalunitterraindefense)
	match [unitdata.get("weapon"),goalunitdata.get("armor")]:
		[GAMEDATA.UNIT_WEAPON.LIGHT,GAMEDATA.UNIT_ARMOR.LIGHT]:
			unitattack = unitattack*1.5
		[GAMEDATA.UNIT_WEAPON.LIGHT,GAMEDATA.UNIT_ARMOR.HEAVY]:
			unitattack = unitattack*0.5
		[GAMEDATA.UNIT_WEAPON.HEAVY,GAMEDATA.UNIT_ARMOR.LIGHT]:
			unitattack = unitattack*0.5
		[GAMEDATA.UNIT_WEAPON.HEAVY,GAMEDATA.UNIT_ARMOR.HEAVY]:
			unitattack = unitattack*1.5
	
	if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.FLAK) and goalunitdata.get("armor") == GAMEDATA.UNIT_ARMOR.LIGHT:
		unitattack = unitattack*2
	if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.BLITZ):
		unitattack = unitattack*1.2
	
	var goalunithp = int(goalunit.get("hp")-unitattack)
	
	var unitattacktime:float = unit.get_node("sprite").sprite_frames.get_frame_count("firing_w")*(1.0/10.0)	
	
	match _direction(unitcoord,goalcoord):
		"w":
			tween.tween_callback(unit.playani.bind("firing_w"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_w"))
		"s":
			tween.tween_callback(unit.playani.bind("firing_s"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_s"))
		"e":
			tween.tween_callback(unit.playani.bind("firing_e"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_e"))
		"n":
			tween.tween_callback(unit.playani.bind("firing_n"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_n"))
	tween.tween_callback(unit.pauseani.bind())
	tween.tween_callback(goalunit.sethp.bind(goalunithp))
	tween.tween_property(unit, "position", Vector2(unitcoord*56)+Vector2(28,28), 0.1)
	

func unit_counter_attack(unitcoord:Vector2i,goalcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	var unitdata = unit.get("unitdata")
	var goalunit = Gamemap.unit.get(goalcoord)
	var goalunitdata = goalunit.get("unitdata")
	
	var goalunitterraindefense = 0.0
	if goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.GROUND:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(goalcoord,{}).get("sourceid"),0).get("grounddefense")
	elif goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.WINGS:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(goalcoord,{}).get("sourceid"),0).get("airdefense")
	elif goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.SEA:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(goalcoord,{}).get("sourceid"),0).get("seadefense")
	
	
	var unitattack = float(unitdata.get("attack")) * (float(unit.get("hp"))/float(unitdata.get("hp"))) * (1.0-goalunitterraindefense)
	match [unitdata.get("weapon"),goalunitdata.get("armor")]:
		[GAMEDATA.UNIT_WEAPON.LIGHT,GAMEDATA.UNIT_ARMOR.LIGHT]:
			unitattack = unitattack*1.5
		[GAMEDATA.UNIT_WEAPON.LIGHT,GAMEDATA.UNIT_ARMOR.HEAVY]:
			unitattack = unitattack*0.5
		[GAMEDATA.UNIT_WEAPON.HEAVY,GAMEDATA.UNIT_ARMOR.LIGHT]:
			unitattack = unitattack*0.5
		[GAMEDATA.UNIT_WEAPON.HEAVY,GAMEDATA.UNIT_ARMOR.HEAVY]:
			unitattack = unitattack*1.5
	
	if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.MAMMOTH) and goalunitdata.get("armor") == GAMEDATA.UNIT_ARMOR.LIGHT:
		unitattack = unitattack*0.85
	
	var goalunithp = int(goalunit.get("hp")-unitattack)
	
	var unitattacktime:float = unit.get_node("sprite").sprite_frames.get_frame_count("firing_w")*(1.0/10.0)	
	
	match _direction(unitcoord,goalcoord):
		"w":
			tween.tween_callback(unit.playani.bind("firing_w"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_w"))
		"s":
			tween.tween_callback(unit.playani.bind("firing_s"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_s"))
		"e":
			tween.tween_callback(unit.playani.bind("firing_e"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_e"))
		"n":
			tween.tween_callback(unit.playani.bind("firing_n"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_n"))
	tween.tween_callback(unit.pauseani.bind())
	tween.tween_callback(goalunit.sethp.bind(goalunithp))
	tween.tween_property(unit, "position", Vector2(unitcoord*56)+Vector2(28,28), 0.1)
	

func unit_sleep(unitcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	#print(unit)
	unit.actioned = true
	tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(unit.pauseani.bind())
	tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative()


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

func _direction(form,to)->String:
	var angle = Vector2(1,1).angle_to(Vector2(to-form))
	if angle > PI/2:
		return "w"
	elif angle > 0:
		return "s"
	elif angle > -PI/2:
		return "e"
	else:
		return "n"
	return "s"

func _attackable(unitcoord:Vector2i,goalcoord:Vector2i)->bool:
	var unit = Gamemap.unit.get(unitcoord)
	var unitdata = unit.get("unitdata")
	var goalunit = Gamemap.unit.get(goalcoord)
	var goalunitdata = goalunit.get("unitdata")
	if unitdata.get("weapon") == GAMEDATA.UNIT_WEAPON.NONE:
		return false
	if !unitdata.get("traits").has(GAMEDATA.UNIT_TRAIT.ANTISUB) and goalunitdata.get("traits").has(GAMEDATA.UNIT_TRAIT.SUBMERGED):
		return false
	if !unitdata.get("traits").has(GAMEDATA.UNIT_TRAIT.SKYSWEEPER) and goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.WINGS:
		return false
	var distance = (unitcoord - goalcoord).abs().x + (unitcoord - goalcoord).abs().y
	if unitdata.get("rangemin") > distance or unitdata.get("rangemax") < distance:
		return false
	return true
	
