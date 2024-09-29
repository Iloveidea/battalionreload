extends Node2D

var selectedunit = null
var selectedunittile = Vector2i(0,0)
var selectedunitmovetile = []
var selectedunitattacktile = []
enum SELECT_MODE{NONE,MOVE}
var selectmode = SELECT_MODE.NONE:
	set(value):
		selectmode = value
		if value == SELECT_MODE.NONE:
			selectedunitmovetile = []
			selectedunitattacktile = []
			#pathlinetile = []
			$pathline.clear_points()
			$pathline.visible = 0
		if value == SELECT_MODE.MOVE:
			pathlinetile = []
			$pathline.visible = 1
var cursortile = Vector2i(0,0):
	set(value):
		cursortile = value
		$cursor.position = value * Vector2i(56,56) + Vector2i(28,28)

var pathlinetile = []:
	set(value):
		pathlinetile = value
		#print("patnlinetile:"+str(pathlinetile))
		#print("attacktile:"+str(attacktile))
		if pathlinetile == []:
			$pathline.visible = 0
			return
		$pathline.visible = 1
		$pathline.clear_points()
		pathlinetile.map(func(t):
			$pathline.add_point(t*Vector2i(56,56)+Vector2i(28,28))
			return 0
		)
var attacktile = []
	#set(value):
		#attacktile = value
		#print("patnlinetile:"+str(pathlinetile))
		#print("attacktile:"+str(attacktile))

#var lockcontrol = false
	#set(value):
		#lockcontrol = value
		#if value == true:
			#print("true")
		#else:
			#print("false")


var isnearby = false


var selected_unit_for_unit_action_ui = null:
	set(u):
		selected_unit_for_unit_action_ui = u
		if u == null:
			$"../Camera/unitactionui/VBox/extractbtn".disabled = true
			$"../Camera/unitactionui/VBox/buildbtn".disabled = true
			$"../Camera/unitactionui/VBox/albatrossbtn".disabled = true
			$"../Camera/unitactionui/VBox/leviathanbtn".disabled = true
			$"../Camera/unitactionui/VBox/unloadbtn".disabled = true
			$"../Camera/unitactionui/VBox/repairbtn".disabled = true
			return
		elif u.issleep() == true or u.player != $"..".currentplayer:
			$"../Camera/unitactionui/VBox/extractbtn".disabled = true
			$"../Camera/unitactionui/VBox/buildbtn".disabled = true
			$"../Camera/unitactionui/VBox/albatrossbtn".disabled = true
			$"../Camera/unitactionui/VBox/leviathanbtn".disabled = true
			$"../Camera/unitactionui/VBox/unloadbtn".disabled = true
			$"../Camera/unitactionui/VBox/repairbtn".disabled = true
			return
		else:
			$"../Camera/unitactionui/VBox/extractbtn".disabled = true
			$"../Camera/unitactionui/VBox/buildbtn".disabled = true
			$"../Camera/unitactionui/VBox/albatrossbtn".disabled = true
			$"../Camera/unitactionui/VBox/leviathanbtn".disabled = true
			$"../Camera/unitactionui/VBox/unloadbtn".disabled = true
			$"../Camera/unitactionui/VBox/repairbtn".disabled = true
			
			var unitcoord = $"..".unit.find_key(u)
			var unitdata = GAMEDATA.UNIT_DATA.get(u.unit,0)
			var maxhp = unitdata.get("hp")
			var hp = u.hp
			#var unittype = unitdata.get("type")
			var unittraits = unitdata.get("traits")
			#var unitattack = unitdata.get("attack")
			#var unitarmor = unitdata.get("armor")
			#var unitweapon = unitdata.get("weapon")
			#var unitrangemin = unitdata.get("rangemin")
			#var unitrangemax = unitdata.get("rangemax")
			
			var tile = $"../terrainmap/TileMap".get_cell_source_id(0,unitcoord,)
			var tilemovementwings = GAMEDATA.TERRAIN_DATA.get(tile).get(GAMEDATA.UNIT_MOVEMENT.WINGS,INF)
			var tilemovementSHALLOWWATER = GAMEDATA.TERRAIN_DATA.get(tile).get(GAMEDATA.UNIT_MOVEMENT.SHALLOWWATER,INF)
			
			
			if unittraits.has(GAMEDATA.UNIT_TRAIT.EXTRACTOR) and [7,8].has(tile):
				$"../Camera/unitactionui/VBox/extractbtn".disabled = false
			
			if unittraits.has(GAMEDATA.UNIT_TRAIT.CONSTRUCTOR):
				$"../Camera/unitactionui/VBox/buildbtn".disabled = false
			
			if GAMEDATA.ALBATROSSTRANSPORT_LIST.has(u.unit):
				if tilemovementwings < INF:
					$"../Camera/unitactionui/VBox/albatrossbtn".disabled = false
			
			if GAMEDATA.LEVIATHANBARGE_LIST.has(u.unit):
				if tilemovementSHALLOWWATER < INF:
					$"../Camera/unitactionui/VBox/leviathanbtn".disabled = false
			
			if [GAMEDATA.UNIT.ALBATROSSTRANSPORT,GAMEDATA.UNIT.LEVIATHANBARGE].has(u.unit):
				$"../Camera/unitactionui/VBox/unloadbtn".disabled = false
			
			if ![GAMEDATA.UNIT.ALBATROSSTRANSPORT,GAMEDATA.UNIT.LEVIATHANBARGE].has(u.unit) and hp < maxhp:
				$"../Camera/unitactionui/VBox/repairbtn".disabled = false
			
			pass


# Called when the node enters the scene tree for the first time.
func _ready():
	cursortile = Vector2i(0,0)
	AllSIGNAL.connect("unitclick",Callable(self, "unitclick"))
	
	#print([1.0,1.2,2.0].reduce(func(n,accum):
		#return n + accum
		#)
	#)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



#
#func _unhandled_input(event):
	#var mapxy = $"../terrainmap/TileMap".local_to_map(get_global_mouse_position())
	#
	#if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_W:
			#cursormove(Vector2i(0,-1))
		#if event.keycode == KEY_S:
			#cursormove(Vector2i(0,1))
		#if event.keycode == KEY_A:
			#cursormove(Vector2i(-1,0))
		#if event.keycode == KEY_D:
			#cursormove(Vector2i(1,0))
		#if event.keycode == KEY_J:
			#select()
		#if event.keycode == KEY_K:
			#pass
		#
	#
	#
	#
	#return
	#if event is InputEventMouseMotion:
		#if selectmode == SELECT_MODE.MOVE:
			#var movement = GAMEDATA.UNIT_DATA.get(selectedunit.unit,{}).get("movement",0)
			#pathline(dijkstar_path($"..".path_matrix.get(movement),selectedunittile,mapxy))
			#pass
		##print(mapxy)
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#
			#var u = $"..".unit.get(mapxy,null)
			#if selectedunit != u and selectmode == SELECT_MODE.NONE and u.issleep() == false:
				#selectedunit = u
				#selectmode = SELECT_MODE.MOVE
				#selectedunittile = mapxy
				#movetileclear()
				#movetile(mapxy,u)
			#elif selectedunit != u and selectmode == SELECT_MODE.MOVE:
				#pass
				#
				#
				#
				#
			##print(mapxy)
			#
			#
			#


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
	
	if $"..".lockcontrol == true:
		return
	var mapxy = $"../terrainmap/TileMap".local_to_map(get_global_mouse_position())
	if event is InputEventMouseMotion:
		if cursortile == mapxy:
			return
		if selectmode == SELECT_MODE.MOVE:
			isnearby = false
			[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(v):
				if pathlinetile != []:
					if pathlinetile[-1]+v == mapxy:
						isnearby = true
				return v
				)
			var movement = GAMEDATA.UNIT_DATA.get(selectedunit.unit).get("movement")
			var speed = GAMEDATA.UNIT_DATA.get(selectedunit.unit).get("speed")
			var rangemin = GAMEDATA.UNIT_DATA.get(selectedunit.unit).get("rangemin")
			if pathlinetile.has(mapxy):
				cursortile = mapxy
				for i in range(len(pathlinetile)):
					if pathlinetile[-1] != mapxy:
						pathlinetile.pop_back()
						pathlinetile = pathlinetile
					else:
						break
			elif rangemin>1:
				if selectedunitmovetile.has(mapxy):
					if isnearby:
						var path = pathlinetile + [mapxy]
						var movespend = path.map(func(t):
							return $"../terrainmap/TileMap".get_cell_source_id(0,t)
							).map(func(t):
								return GAMEDATA.TERRAIN_DATA.get(t,{}).get(movement,INF)
								).reduce(func(t,accum):
									return t + accum
									) - GAMEDATA.TERRAIN_DATA.get($"../terrainmap/TileMap".get_cell_source_id(0,path[0]),{}).get(movement,INF)
						if (movespend > speed):
							cursortile = mapxy
							var p = $"..".path_matrix.get(movement).duplicate()
							$"..".path_matrix.get(movement).duplicate().keys().map(func(key):
								if $"..".unit.get(key,null) != null:
									if $"..".unit.get(key).player != selectedunit.player:
										p.erase(key)
								)
							pathlinetile = dijkstar_path(p,selectedunittile,mapxy)
						else:
							cursortile = mapxy
							pathlinetile = pathlinetile + [mapxy]
					else:
						cursortile = mapxy
						var p = $"..".path_matrix.get(movement).duplicate()
						$"..".path_matrix.get(movement).duplicate().keys().map(func(key):
							if $"..".unit.get(key,null) != null:
								if $"..".unit.get(key).player != selectedunit.player:
									p.erase(key)
							)
						var path = dijkstar_path(p,selectedunittile,mapxy)
						if path == []:
							pathlinetile = [selectedunittile]
						else:
							pathlinetile = path
					attacktile = []
				elif selectedunitattacktile.has(mapxy):
					cursortile = mapxy
					pathlinetile = [selectedunittile]
					attacktile = [mapxy]
				else:
					cursortile = mapxy
					pathlinetile = [selectedunittile]
					attacktile = []
					
				
				
				
				
				
			#if selectedunitmovetile.has(t) and selectedunitattacktile.has(t):
				
			else:
				if selectedunitmovetile.has(mapxy):
					if isnearby:
						var path = pathlinetile + [mapxy]
						var movespend = path.map(func(t):
							return $"../terrainmap/TileMap".get_cell_source_id(0,t)
							).map(func(t):
								return GAMEDATA.TERRAIN_DATA.get(t,{}).get(movement,INF)
								).reduce(func(t,accum):
									return t + accum
									) - GAMEDATA.TERRAIN_DATA.get($"../terrainmap/TileMap".get_cell_source_id(0,path[0]),{}).get(movement,INF)
						if (movespend > speed):
							cursortile = mapxy
							var p = $"..".path_matrix.get(movement).duplicate()
							$"..".path_matrix.get(movement).duplicate().keys().map(func(key):
								if $"..".unit.get(key,null) != null:
									if $"..".unit.get(key).player != selectedunit.player:
										p.erase(key)
								)
							pathlinetile = dijkstar_path(p,selectedunittile,mapxy)
						else:
							cursortile = mapxy
							pathlinetile = pathlinetile + [mapxy]
					else:
						cursortile = mapxy
						var p = $"..".path_matrix.get(movement).duplicate()
						$"..".path_matrix.get(movement).duplicate().keys().map(func(key):
							if $"..".unit.get(key,null) != null:
								if $"..".unit.get(key).player != selectedunit.player:
									p.erase(key)
							)
						var path = dijkstar_path(p,selectedunittile,mapxy)
						if path == []:
							pathlinetile = [selectedunittile]
						else:
							pathlinetile = path
					attacktile = []
				elif selectedunitattacktile.has(mapxy):
					cursortile = mapxy
					attacktile = [mapxy]
					if isnearby:
						pass
					else:
						for i in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),]:
							if selectedunitmovetile.has(i+mapxy) and $"..".unit.get(i+mapxy,null) == null:
								var p = $"..".path_matrix.get(movement).duplicate()
								$"..".path_matrix.get(movement).duplicate().keys().map(func(key):
									if $"..".unit.get(key,null) != null:
										if $"..".unit.get(key).player != selectedunit.player:
											p.erase(key)
									)
								pathlinetile = dijkstar_path(p,selectedunittile,i+mapxy)
								break
					
				else:
					cursortile = mapxy
					pathlinetile = [selectedunittile]
					attacktile = []
				
			#var movement = GAMEDATA.UNIT_DATA.get(selectedunit.unit,{}).get("movement",0)
			
			
			#if selectedunitmovetile.has(mapxy):
				
			
			#pathline(dijkstar_path($"..".path_matrix.get(movement),selectedunittile,mapxy))
			pass
	
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#var u = $"..".unit.get(mapxy,null)
			cursortile = mapxy
			select()

func cursormove(v):
	if selectmode == SELECT_MODE.NONE:
		var t = cursortile + v
		if $"../terrainmap/TileMap".get_cell_source_id(0,t) != -1:
			cursortile = t
	elif selectmode == SELECT_MODE.MOVE:
		var t = cursortile + v
		var path = pathlinetile + [t]
		var movement = GAMEDATA.UNIT_DATA.get(selectedunit.unit).get("movement")
		var speed = GAMEDATA.UNIT_DATA.get(selectedunit.unit).get("speed")
		var rangemin = GAMEDATA.UNIT_DATA.get(selectedunit.unit).get("rangemin")
		if selectedunitmovetile.has(t):
			var movespend = path.map(func(t):
				return $"../terrainmap/TileMap".get_cell_source_id(0,t)
				).map(func(t):
					return GAMEDATA.TERRAIN_DATA.get(t,{}).get(movement,INF)
					).reduce(func(t,accum):
						return t + accum
						) - GAMEDATA.TERRAIN_DATA.get($"../terrainmap/TileMap".get_cell_source_id(0,path[0]),{}).get(movement,INF)
			if (movespend > speed):
				cursortile = t
				pathlinetile = dijkstar_path($"..".path_matrix[movement],selectedunittile,t)
				if pathlinetile == []:
					pathlinetile.append(selectedunittile)
				$pathline.clear_points()
				print(pathlinetile)
				pathlinetile.map(func(t):
					$pathline.add_point(t*Vector2i(56,56)+Vector2i(28,28))
					return 0
					)
			elif (pathlinetile.has(t)):
				cursortile = t
				for i in range(len(pathlinetile)):
					if pathlinetile[-1] != t:
						pathlinetile.pop_back()
					else:
						break
				$pathline.clear_points()
				print(pathlinetile)
				pathlinetile.map(func(t):
					$pathline.add_point(t*Vector2i(56,56)+Vector2i(28,28))
					return 0
					)
			else:
				cursortile = t
				pathlinetile = path
				$pathline.clear_points()
				print(pathlinetile)
				pathlinetile.map(func(t):
					$pathline.add_point(t*Vector2i(56,56)+Vector2i(28,28))
					return 0
					)
		#elif selectedunitattacktile.has(t):
			#if rangemin > 1 :
				#pass
			#pass
		
		
		
		pass
	pass

func select():
	var u = $"..".unit.get(cursortile,null)
	var b = $"..".building.get(cursortile,null)
	if selectmode == SELECT_MODE.NONE:
		if b != null and u == null:
			selected_unit_for_unit_action_ui = null
			if GAMEDATA.BUILDING_DATA.get(b.get("building")).get("traits",[]).has(GAMEDATA.TERRAIN_TRAIT.CONSTRUCTION):
				if b.get("player") == $"..".currentplayer:
					AllSIGNAL.emit_signal("buildunit",b)
					pass
		elif u == null:
			selected_unit_for_unit_action_ui = null
			movetileclear()
			selectedunitmovetile.clear()
			selectedunitattacktile.clear()
			selectmode = SELECT_MODE.NONE
		elif u.issleep() == false:
			selected_unit_for_unit_action_ui = u
			selectedunit = u
			selectmode = SELECT_MODE.MOVE
			selectedunittile = cursortile
			$pathline.clear_points()
			pathlinetile.append(cursortile)
			movetileclear()
			movetile(cursortile,u)
	elif selectedunit == u:
		selected_unit_for_unit_action_ui = null
		movetileclear()
		selectedunitmovetile.clear()
		selectedunitattacktile.clear()
		selectmode = SELECT_MODE.NONE
	#elif selectedunit.player == u.player:
		#movetileclear()
		#selectedunitmovetile.clear()
		#selectedunitattacktile.clear()
		#selectmode = SELECT_MODE.NONE
	elif selectedunitmovetile.has(cursortile) and (u == null):
		#移动函数，需要校验
		try_move(selectedunit,pathlinetile)
		movetileclear()
		selectedunitmovetile.clear()
		selectedunitattacktile.clear()
		selectmode = SELECT_MODE.NONE
		selected_unit_for_unit_action_ui = null
	elif selectedunitattacktile.has(cursortile) and u == null:
		movetileclear()
		selectedunitmovetile.clear()
		selectedunitattacktile.clear()
		selectmode = SELECT_MODE.NONE
		selected_unit_for_unit_action_ui = null
	elif selectedunitattacktile.has(cursortile) and (selectedunit.player != u.player):
		#攻击函数，需要校验
		try_attack(selectedunit,pathlinetile)
		movetileclear()
		selectedunitmovetile.clear()
		selectedunitattacktile.clear()
		selectmode = SELECT_MODE.NONE
		selected_unit_for_unit_action_ui = null
	else:
		movetileclear()
		selectedunitmovetile.clear()
		selectedunitattacktile.clear()
		selectmode = SELECT_MODE.NONE
		selected_unit_for_unit_action_ui = null
		
	
	
	
	pass




func movetile(mapxy,u):
	if u != null:
		var movement = GAMEDATA.UNIT_DATA.get(u.unit,{}).get("movement",0)
		var speed = GAMEDATA.UNIT_DATA.get(u.unit,{}).get("speed",0)
		var path = $"..".path_matrix.get(movement).duplicate()
		$"..".path_matrix.get(movement).duplicate().keys().map(func(key):
			if $"..".unit.get(key,null) != null:
				if $"..".unit.get(key).player != selectedunit.player:
					path.erase(key)
			)
		dijkstar_tiles(path,mapxy,speed).map(func(t):
			#var selecttile = load("res://selecttile.tscn").instantiate()
			#selecttile.set_tile(0)
			#selecttile.position = (t * 56)
			#$movetile.add_child(selecttile)
			selectedunitmovetile.append(t)
			return 0
			)
		selectedunitmovetile.append(mapxy)
		
		var unitdata = GAMEDATA.UNIT_DATA.get(u.unit,{})
		
		if unitdata.get("rangemin",0) <= 0 and unitdata.get("rangemax",0) <= 0:
			pass
		elif unitdata.get("rangemin") <= 1 and unitdata.get("rangemax") <= 1:
			var attacktiled = {}
			selectedunitmovetile.map(func(t):
				[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(v):
					attacktiled[t+v] = 1
					return 0
					)
				return 0
				)
			attacktiled.keys().map(func(t):
				if selectedunitmovetile.has(t):
					attacktiled.erase(t)
				return 0
				)
			selectedunitattacktile = attacktiled.keys()
		else:
			var attacktiled = {}
			attacktiled[mapxy] = 1
			for i in range(unitdata.get("rangemax")):
				attacktiled.keys().map(func(key):
					[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(v):
						attacktiled[key+v] = 1
						return 0
						)
					)
			var t = {}
			t[mapxy] = 1
			for i in range(unitdata.get("rangemin")-1):
				t.keys().map(func(key):
					[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(v):
						t[key+v] = 1
						return 0
						)
					)
			t.keys().map(func(key):
				attacktiled.erase(key)
				return 0
				)
			selectedunitattacktile = attacktiled.keys()
		
		selectedunitmovetile.map(func(t):
			var selecttile = load("res://selecttile.tscn").instantiate()
			selecttile.position = (t * 56)
			$movetile.add_child(selecttile)
			selecttile.set_tile(1)
			if selectedunitattacktile.has(t):
				selecttile.set_tile(3)
			return 0
			)
		selectedunitattacktile.map(func(t):
			if selectedunitmovetile.has(t):
				return 0
			var selecttile = load("res://selecttile.tscn").instantiate()
			selecttile.position = (t * 56)
			$movetile.add_child(selecttile)
			selecttile.set_tile(2)
			return 0
			)
		#print(selectedunitmovetile)
		#print(selectedunitattacktile)
	pass

func movetileclear():
	selectedunitmovetile.clear()
	$movetile.get_children().map(func(n):
		n.queue_free()
		return 0
		)


func pathline(path):
	#print(path)
	$pathline.clear_points()
	path.map(func(t):
		$pathline.add_point(t*Vector2i(56,56)+Vector2i(28,28))
		)
	#


func try_move(u,p):
	#selectedunit,pathlinetile
	$"..".lockcontrol = true
	if len(p)<=1:
		$"..".lockcontrol = false
		print("不应移动")
		return
	if u.player != $"..".currentplayer:
		$"..".lockcontrol = false
		print("不属于当前玩家")
		return
	if $"..".unit.get(p[-1],null) != null:
		$"..".lockcontrol = false
		print("目标地点被占用")
		return
	u.z_index = 1
	var movetween = create_tween()
	unit_move(movetween,u,p)
	await movetween.finished
	var sleeptween = create_tween()
	unit_sleep(sleeptween,u,p)
	await sleeptween.finished
	u.z_index = 0
	$"..".lockcontrol = false


func try_attack(u,p):
	#selectedunit,pathlinetile
	$"..".lockcontrol = true
	
	var unitcoord = $"..".unit.find_key(u)
	var unitdata = GAMEDATA.UNIT_DATA.get(u.unit,0)
	var unittype = unitdata.get("type")
	var unittraits = unitdata.get("traits")
	var unitattack = unitdata.get("attack")
	var unitarmor = unitdata.get("armor")
	var unitweapon = unitdata.get("weapon")
	var unitrangemin = unitdata.get("rangemin")
	var unitrangemax = unitdata.get("rangemax")
	
	var goalunit = $"..".unit.get(attacktile[0],{})
	var goalunitcoord = $"..".unit.find_key(goalunit)
	var goalunitdata = GAMEDATA.UNIT_DATA.get(goalunit.get("unit"),{})
	var goalunittype = goalunitdata.get("type")
	var goalunittraits = goalunitdata.get("traits")
	var goalunitattack = goalunitdata.get("attack")
	var goalunitarmor = goalunitdata.get("armor")
	var goalunitweapon = goalunitdata.get("weapon")
	var goalunitrangemin = goalunitdata.get("rangemin")
	var goalunitrangemax = goalunitdata.get("rangemax")
	
	
	
	
	if u.player != $"..".currentplayer:
		$"..".lockcontrol = false
		print("不属于当前玩家")
		return
	if unitrangemin > 1:
		if !can_attack(u,unitdata,unitcoord,goalunit,goalunitdata,goalunitcoord,):
			$"..".lockcontrol = false
			print("单位无法攻击目标")
			return
		
		u.z_index = 1
		var attacktween = create_tween()
		unit_attack(u,goalunit,attacktween)
		await attacktween.finished
		u.z_index = 0
		
		if can_attack(goalunit,goalunitdata,goalunitcoord,u,unitdata,unitcoord,) and goalunittraits.has(GAMEDATA.UNIT_TRAIT.COUNTERBATTERY):
			goalunit.z_index = 1
			var counterattacktween = create_tween()
			unit_attack(goalunit,u,counterattacktween)
			await counterattacktween.finished
			goalunit.z_index = 0
		
		
		if u != null:
			var sleeptween = create_tween()
			unit_sleep(sleeptween,u,p)
			await sleeptween.finished
		
		$"..".lockcontrol = false
		
	else:
		if len(p) <= 1:
			if !can_attack(u,unitdata,unitcoord,goalunit,goalunitdata,goalunitcoord,):
				$"..".lockcontrol = false
				print("单位无法攻击目标")
				return
			
			u.z_index = 1
			var attacktween = create_tween()
			unit_attack(u,goalunit,attacktween)
			await attacktween.finished
			u.z_index = 0
			
			if can_attack(goalunit,goalunitdata,goalunitcoord,u,unitdata,unitcoord,):
				goalunit.z_index = 1
				var counterattacktween = create_tween()
				unit_attack(goalunit,u,counterattacktween)
				await counterattacktween.finished
				goalunit.z_index = 0
			
			if u != null:
				var sleeptween = create_tween()
				unit_sleep(sleeptween,u,p)
				await sleeptween.finished
			
			$"..".lockcontrol = false
			
		else:
			if !can_attack(u,unitdata,p[-1],goalunit,goalunitdata,goalunitcoord,):
				$"..".lockcontrol = false
				print("单位无法攻击目标")
				return
			print(p)
			var movetween = create_tween()
			unit_move(movetween,u,p)
			await movetween.finished
			print(p)
			
			u.z_index = 1
			var attacktween = create_tween()
			unit_attack(u,goalunit,attacktween)
			await attacktween.finished
			u.z_index = 0
			
			if can_attack(goalunit,goalunitdata,goalunitcoord,u,unitdata,p[-1]):
				goalunit.z_index = 1
				var counterattacktween = create_tween()
				unit_attack(goalunit,u,counterattacktween)
				await counterattacktween.finished
				goalunit.z_index = 0
			
			if u != null:
				var sleeptween = create_tween()
				unit_sleep(sleeptween,u,p)
				await sleeptween.finished
			
			
			$"..".lockcontrol = false
		
		
	
	




func unit_move(tween,u,p):
	#selectedunit,pathlinetile
	for i in range(len(p)-1):
		match _direction(p[i],p[i+1]):
			"w":
				tween.tween_callback(u.playani.bind("move_w"))
				tween.tween_property(u, "position", Vector2(-56,0), 0.3).as_relative()
			"s":
				tween.tween_callback(u.playani.bind("move_s"))
				tween.tween_property(u, "position", Vector2(0,56), 0.3).as_relative()
			"e":
				tween.tween_callback(u.playani.bind("move_e"))
				tween.tween_property(u, "position", Vector2(56,0), 0.3).as_relative()
			"n":
				tween.tween_callback(u.playani.bind("move_n"))
				tween.tween_property(u, "position", Vector2(0,-56), 0.3).as_relative()
	tween.tween_property(u, "position", Vector2(p[-1]*56)+Vector2(28,28), 0.1)
	$"..".unit[p[-1]] = u
	$"..".unit.erase(p[0])
	pass


func unit_attack(unit,goalunit,tween):
	
	var unitdata = GAMEDATA.UNIT_DATA.get(unit.get("unit"))
	var unitcoord = $"..".unit.find_key(unit)
	var goalunitdata = GAMEDATA.UNIT_DATA.get(goalunit.get("unit"))
	var goalunitcoord = $"..".unit.find_key(goalunit)
	
	
	var goalunitterraindefense = 0.0
	if goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.GROUND:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get($"../terrainmap/TileMap".get_cell_source_id(0,goalunitcoord)).get("grounddefense",0)
	elif goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.WINGS:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get($"../terrainmap/TileMap".get_cell_source_id(0,goalunitcoord)).get("airdefense",0)
	elif goalunitdata.get("type") == GAMEDATA.UNIT_TYPE.SEA:
		goalunitterraindefense = GAMEDATA.TERRAIN_DATA.get($"../terrainmap/TileMap".get_cell_source_id(0,goalunitcoord)).get("seadefense",0)
	
	
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
	
	var exp = load("res://smallexplosion.tscn").instantiate()
	exp.position = goalunitcoord*56 + Vector2i(28,28)
	$"..".add_child(exp)
	match _direction(unitcoord,goalunitcoord):
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
	
	



func unit_sleep(tween,u,p):
	u.actioned = true
	tween.tween_method(u.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(u.pauseani.bind())
	tween.tween_property(u, "position", Vector2(0,0), 0.1).as_relative()
	


func unitclick(unit):
	pass



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
		pathlist[key]["distance"] = path.get(start,{}).get(key,INF)
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
			var d = pathlist[next_node]["distance"] + path.get(next_node,{}).get(i,INF)
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

func can_attack(unit,unitdata,unitcoord,goalunit,goalunitdata,goalunitcoord)->bool:
	if unit == null or goalunit == null:
		return false
	
	var unittype = unitdata.get("type")
	var unittraits = unitdata.get("traits")
	var unitrangemin = unitdata.get("rangemin")
	var unitrangemax = unitdata.get("rangemax")
	
	var goalunittype = goalunitdata.get("type")
	var goalunittraits = goalunitdata.get("traits")
	
	if goalunittype == GAMEDATA.UNIT_TYPE.WINGS and !unittraits.has(GAMEDATA.UNIT_TRAIT.SKYSWEEPER):
		return false
	if goalunittraits.has(GAMEDATA.UNIT_TRAIT.SUBMERGED) and !unittraits.has(GAMEDATA.UNIT_TRAIT.ANTISUB):
		return false
	if !(goalunittype == GAMEDATA.UNIT_TYPE.SEA) and unittraits.has(GAMEDATA.UNIT_TRAIT.SUBMERGED):
		return false
	
	var distance = abs(goalunitcoord - unitcoord)
	var d = distance.x + distance.y
	if d>unitrangemax or d<unitrangemin:
		return false
	
	
	return true



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


func _on_extractbtn_pressed():
	var u = selected_unit_for_unit_action_ui
	var unitcoord = $"..".unit.find_key(u)
	var unitdata = GAMEDATA.UNIT_DATA.get(u.unit,0)
	var tile = $"../terrainmap/TileMap".get_cell_source_id(0,unitcoord,)
	u.resource = u.resource + 999
	if tile == 8:
		var oredeposit =[Vector2i(0,0),Vector2i(0,1),]
		$"../terrainmap/TileMap".set_cell(0,unitcoord,7,oredeposit[randi() % oredeposit.size()],0)
	elif tile == 7:
		var depletedoredeposit =[Vector2i(0,0),Vector2i(1,0),]
		$"../terrainmap/TileMap".set_cell(0,unitcoord,6,depletedoredeposit[randi() % depletedoredeposit.size()],0)
	var tween = create_tween()
	u.actioned = true
	tween.tween_method(u.setsleep.bind(),0.0,0.5,0.1)
	tween.tween_callback(u.pauseani.bind())
	tween.tween_property(u, "position", Vector2(0,0), 0.1).as_relative()
	selected_unit_for_unit_action_ui = null
	movetileclear()
	selectedunitmovetile.clear()
	selectedunitattacktile.clear()
	selectmode = SELECT_MODE.NONE
	
	
	
	pass # Replace with function body.


func _on_buildbtn_pressed():
	var u = selected_unit_for_unit_action_ui
	AllSIGNAL.emit_signal("buildunit",u)
	
	selected_unit_for_unit_action_ui = null
	movetileclear()
	selectedunitmovetile.clear()
	selectedunitattacktile.clear()
	selectmode = SELECT_MODE.NONE
	
	pass # Replace with function body.
