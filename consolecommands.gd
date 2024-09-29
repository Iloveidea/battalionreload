extends Node

var unitinaction:bool= false
signal test

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("test",Callable($".","testfunc"))
	#emit_signal("test")
	pass # Replace with function body.

func testfunc():
	
	test1()
	test2()
	print("all ok")
	pass

func test1():
	var tween = create_tween()
	var unit = Gamemap.unit.get(Vector2i(4,3))
	tween.tween_callback(unit.playani.bind("firing_s"))
	tween.tween_callback(unit.playani.bind("move_s")).set_delay(5)
	tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(unit.pauseani.bind())
	await tween.finished
	print("test1ok")
	#test2(tween)
	

func test2():
	var tween = create_tween()
	var unit = Gamemap.unit.get(Vector2i(4,3))
	tween.tween_callback(unit.playani.bind("firing_n"))
	tween.tween_callback(unit.playani.bind("move_n")).set_delay(5)
	tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(unit.pauseani.bind())
	await tween.finished
	print("test1ok")
	





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_unit_hp(unitcoord:Vector2i):
	var unit = Gamemap.unit.get(unitcoord)
	print(unit)
	if unit == null:
		print("找不到单位")
		return
	unit.hp = 0

func unit_sleep(unitcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	#print(unit)
	unit.actioned = true
	tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(unit.pauseani.bind())
	tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative()


func um(a:int,b:int,c:int,d:int):
	if unitinaction == true:
		print("单位在行动")
		return
	unitinaction = true
	var tween = create_tween()
	unit_move(Vector2i(a,b),Vector2i(c,d),tween)
	await tween.finished
	var tween2 = create_tween()
	unit_sleep(Vector2i(c,d),tween2)
	await tween2.finished
	unitinaction = false
	pass


func unit_move(unitcoord:Vector2i,goalcoord:Vector2i,tween):
	if unitcoord == goalcoord:
		print("起始地不能与目标相同")
		return
	var unit = Gamemap.unit.get(unitcoord)
	if unit == null:
		print("找不到单位")
		return
	if unit.get("player") != Gamemap.currentplayer:
		print("单位不属于当前玩家")
		return
	if unit.get("actioned") == true:
		print("单位已行动")
		return
	var unitdata = unit.get("unitdata")
	
	var path_matrix:Dictionary = Gamemap.path_matrix.get(unitdata.get("movement")).duplicate(true)
	path_matrix.keys().all(func(tile):
		if Gamemap.unit.get(tile,{}).get("player") != Gamemap.currentplayer and Gamemap.unit.get(tile,{}).get("player") != null:
			path_matrix.erase(tile)
		return 1
		)
	
	var movetiles = dijkstar_tiles(path_matrix,unitcoord,unitdata.get("speed"))
	if !movetiles.has(goalcoord):
		print("无法抵达目标")
		return
	
	var goalunit = Gamemap.unit.get(goalcoord)
	if goalunit != null:
		print("目标地点有一个单位")
		return
	
	var path = dijkstar_path(path_matrix,unitcoord,goalcoord)
	if path == []:
		print("异常：路径为空数组")
		return
	Gamemap.unit[goalcoord] = Gamemap.unit[unitcoord]
	Gamemap.unit.erase(unitcoord)
	
	#var tween = create_tween()
	
	var tflag = []
	for i in range(path.size()-1):
		tflag.append(path[i+1] - path[i])
	for i in tflag:
		if i == Vector2i(-1,0):
			tween.tween_callback(unit.playani.bind("move_w"))
		elif i == Vector2i(0,-1):
			tween.tween_callback(unit.playani.bind("move_n"))
		elif i == Vector2i(1,0):
			tween.tween_callback(unit.playani.bind("move_e"))
		elif i == Vector2i(0,1):
			tween.tween_callback(unit.playani.bind("move_s"))
		tween.tween_property(unit, "position", Vector2(i*56), 0.3).as_relative()
	tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative()
	
	#$sprite.material.set_shader_parameter("sleep",0.5)


func ua(a:int,b:int,c:int,d:int):
	unit_attack(Vector2i(a,b),Vector2i(c,d))
	pass


func unit_attack(unitcoord:Vector2i,goalcoord:Vector2i):
	if unitcoord == goalcoord:
		print("起始地不能与目标相同")
		return
	var unit = Gamemap.unit.get(unitcoord)
	var goalunit = Gamemap.unit.get(goalcoord)
	if unit == null:
		print("找不到单位")
		return
	if goalunit == null:
		print("找不到敌方单位")
		return
	if unit.get("player") != Gamemap.currentplayer:
		print("单位不属于当前玩家")
		return
	if goalunit.get("player") == Gamemap.currentplayer:
		print("目标单位属于当前玩家")
		return
	if unit.get("actioned") == true:
		print("单位已行动")
		return
	var unitdata = unit.get("unitdata")
	var goalunitdata = goalunit.get("unitdata")
	if unitdata.get("rangemin") <= 0 or unitdata.get("rangemax") <= 0:
		print("单位无法攻击")
		return
	if unitdata.get("weapon") == GAMEDATA.UNIT_WEAPON.NONE:
		print("单位无法攻击")
		return
	
	var tween = create_tween()
	attack(unitcoord,goalcoord,tween)
	await tween.finished
	
	
	
	
	
	return
	
	if unitdata.get("rangemin") == 1 and unitdata.get("rangemax") == 1:
		if ![unitcoord+Vector2i(1,0),unitcoord+Vector2i(0,1),unitcoord+Vector2i(-1,0),unitcoord+Vector2i(0,-1),].has(goalcoord):
			print("无法攻击目标")
			return
		
		var unitterraindefense = 0.0
		if unitdata.get("type") == GAMEDATA.UNIT_TYPE.GROUND:
			unitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(unitcoord,{}).get("sourceid"),0).get("grounddefense")
		elif unitdata.get("type") == GAMEDATA.UNIT_TYPE.WINGS:
			unitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(unitcoord,{}).get("sourceid"),0).get("airdefense")
		elif unitdata.get("type") == GAMEDATA.UNIT_TYPE.SEA:
			unitterraindefense = GAMEDATA.TERRAIN_DATA.get(Gamemap.terrain.get(unitcoord,{}).get("sourceid"),0).get("seadefense")
		
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
		
		if goalunithp <= 0:
			#var tween = create_tween()
			var unitattacktime:float = unit.get_node("sprite").sprite_frames.get_frame_count("firing_w")*10.0
			match unitcoord - goalcoord:
				Vector2i(1,0):
					tween.tween_callback(unit.playani.bind("firing_w")).set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("move_w"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
				Vector2i(0,1):
					tween.tween_callback(unit.playani.bind("firing_s")).set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("move_s"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
				Vector2i(-1,0):
					tween.tween_callback(unit.playani.bind("firing_e")).set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("move_e"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
				Vector2i(0,-1):
					tween.tween_callback(unit.playani.bind("firing_n")).set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("move_n"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
			tween.tween_callback(goalunit.sethp.bind(goalunithp))
		else:
			var goalunitattack = float(goalunitdata.get("attack")) * (float(goalunithp)/float(goalunitdata.get("hp"))) * (1-unitterraindefense)
			match [goalunitdata.get("weapon"),unitdata.get("armor")]:
				[GAMEDATA.UNIT_WEAPON.LIGHT,GAMEDATA.UNIT_ARMOR.LIGHT]:
					goalunitattack = goalunitattack*1.5
				[GAMEDATA.UNIT_WEAPON.LIGHT,GAMEDATA.UNIT_ARMOR.HEAVY]:
					goalunitattack = goalunitattack*0.5
				[GAMEDATA.UNIT_WEAPON.HEAVY,GAMEDATA.UNIT_ARMOR.LIGHT]:
					goalunitattack = goalunitattack*0.5
				[GAMEDATA.UNIT_WEAPON.HEAVY,GAMEDATA.UNIT_ARMOR.HEAVY]:
					goalunitattack = goalunitattack*1.5
			
			if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.FLAK) and goalunitdata.get("armor") == GAMEDATA.UNIT_ARMOR.LIGHT:
				goalunitattack = goalunitattack*2
			if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.MAMMOTH):
				goalunitattack = goalunitattack*0.85
			
			var unithp = int(unit.get("hp")-goalunitattack)
			
			#var tween = create_tween()
			var unitattacktime:float = unit.get_node("sprite").sprite_frames.get_frame_count("firing_w")*(1.0/10.0)
			var goalunitattacktime:float = goalunit.get_node("sprite").sprite_frames.get_frame_count("firing_w")*(1.0/10.0)
			match unitcoord - goalcoord:
				Vector2i(1,0):
					tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("firing_e"))
					tween.tween_callback(unit.playani.bind("move_e"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
					tween.tween_callback(goalunit.sethp.bind(goalunithp))
					tween.tween_callback(goalunit.playani.bind("firing_w")).set_delay(goalunitattacktime)
					tween.tween_callback(goalunit.playani.bind("move_w"))
					tween.tween_callback(goalunit.pauseani.bind())
					
				Vector2i(0,1):
					tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("firing_n"))
					tween.tween_callback(unit.playani.bind("move_n"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
					tween.tween_callback(goalunit.sethp.bind(goalunithp))
					tween.tween_callback(goalunit.playani.bind("firing_s")).set_delay(goalunitattacktime)
					tween.tween_callback(goalunit.playani.bind("move_s"))
					tween.tween_callback(goalunit.pauseani.bind())
				Vector2i(-1,0):
					tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("firing_w"))
					tween.tween_callback(unit.playani.bind("move_w"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
					tween.tween_callback(goalunit.sethp.bind(goalunithp))
					tween.tween_callback(goalunit.playani.bind("firing_e")).set_delay(goalunitattacktime)
					tween.tween_callback(goalunit.playani.bind("move_e"))
					tween.tween_callback(goalunit.pauseani.bind())
				Vector2i(0,-1):
					tween.tween_callback(unit.playani.bind("firing_s"))
					tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
					tween.tween_callback(unit.playani.bind("move_s"))
					tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
					tween.tween_callback(unit.pauseani.bind())
					tween.tween_callback(goalunit.sethp.bind(goalunithp))
					tween.tween_callback(goalunit.playani.bind("firing_n"))
					tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(goalunitattacktime)
					tween.tween_callback(goalunit.playani.bind("move_n"))
					tween.tween_callback(goalunit.pauseani.bind())
					
			tween.tween_callback(unit.sethp.bind(unithp))
			print(unithp)
			print(goalunithp)
		pass
		

func ua2(a:int,b:int,c:int,d:int):
	var unitcoord = Vector2i(a,b)
	var goalcoord = Vector2i(c,d)
	var tween1 = create_tween()
	ua22(unitcoord,goalcoord,tween1)
	await tween1.finished
	print("all ok")
	pass

func ua22(unitcoord:Vector2i,goalcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	var goalunit = Gamemap.unit.get(goalcoord)
	tween.tween_callback(unit.playani.bind("firing_s"))
	tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(5)
	tween.tween_callback(unit.playani.bind("move_s"))
	tween.tween_method(unit.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(unit.pauseani.bind())
	tween.tween_callback(goalunit.sethp.bind(50))
	pass

func attack(unitcoord:Vector2i,goalcoord:Vector2i,tween):
	var unit = Gamemap.unit.get(unitcoord)
	var goalunit = Gamemap.unit.get(goalcoord)
	var unitdata = unit.get("unitdata")
	var goalunitdata = goalunit.get("unitdata")
	if unitdata.get("rangemin") <= 0 or unitdata.get("rangemax") <= 0:
		print("单位无法攻击")
		return
	if unitdata.get("weapon") == GAMEDATA.UNIT_WEAPON.NONE:
		print("单位无法攻击")
		return
	var distance = abs((unitcoord - goalcoord).x) + abs((unitcoord - goalcoord).y)
	if !(unitdata.get("rangemin") <= distance and unitdata.get("rangemax") >= distance):
		print("目标不在射程内")
		return
	
	
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
	
	match _direction(unitcoord - goalcoord):
		"w":
			tween.tween_callback(unit.playani.bind("firing_w"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_w"))
			tween.tween_callback(unit.pauseani.bind())
			tween.tween_callback(goalunit.sethp.bind(goalunithp))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative()
		"e":
			tween.tween_callback(unit.playani.bind("firing_e"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_e"))
			tween.tween_callback(unit.pauseani.bind())
			tween.tween_callback(goalunit.sethp.bind(goalunithp))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative()
		"n":
			tween.tween_callback(unit.playani.bind("firing_n"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_n"))
			tween.tween_callback(unit.pauseani.bind())
			tween.tween_callback(goalunit.sethp.bind(goalunithp))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative()
		"s":
			tween.tween_callback(unit.playani.bind("firing_s"))
			tween.tween_property(unit, "position", Vector2(0,0), 0.1).as_relative().set_delay(unitattacktime)
			tween.tween_callback(unit.playani.bind("move_s"))
			tween.tween_callback(unit.pauseani.bind())
			tween.tween_callback(goalunit.sethp.bind(goalunithp))
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


func _direction(v)->String:
	if v.x > v.x : return "w"
	if v.x < v.x : return "e"
	if v.y > v.y : return "n"
	return "s"
