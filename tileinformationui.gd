extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	#$terrainui/Label._make_custom_tooltip = 111

	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var mapxy = $"../../terrainmap/TileMap".local_to_map(get_global_mouse_position())
			var sourceid = $"../../terrainmap/TileMap".get_cell_source_id(0,mapxy)
			var atlascoords = $"../../terrainmap/TileMap".get_cell_atlas_coords(0,mapxy)
			$terrainui/terrainmap/TileMap.set_cell(0,Vector2i(0,0),sourceid,atlascoords,0)
			$terrainui/Label.text = GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get("name","")
			$terrainui/Label.set_tooltip_text(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get("name",""))
			$terrainui/Label.tooltip_text = GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get("name","")
			$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "feet:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get(GAMEDATA.UNIT_MOVEMENT.FEET,""))
			$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "wheeled:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get(GAMEDATA.UNIT_MOVEMENT.WHEELED,""))
			$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "tracked:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get(GAMEDATA.UNIT_MOVEMENT.TRACKED,""))
			$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "wings:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get(GAMEDATA.UNIT_MOVEMENT.WINGS,""))
			$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "shallowwater:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get(GAMEDATA.UNIT_MOVEMENT.SHALLOWWATER,""))
			$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "deepwater:" + str(GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get(GAMEDATA.UNIT_MOVEMENT.DEEPWATER,""))
			$terrainui/Label2.text = GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get("description","")
			$terrainui/building.get_children().map(func(n):n.queue_free())
			for i in $terrainui/traitbox.get_children():
				i.queue_free()
			var terraintrait = GAMEDATA.TERRAIN_DATA.get(sourceid,{}).get("traits",[])
			for i in terraintrait:
				var tdata = GAMEDATA.TERRAIN_TRAIT_DATA.get(i)
				var t = TextureRect.new()
				t.texture = tdata.get("sprite")
				t.tooltip_text = str(tdata.get("name")) + ":\n" + str(tdata.get("description"))
				$terrainui/traitbox.add_child(t)
				pass
			if $"../..".building.get(mapxy,null) != null:
				var b = $"../..".building.get(mapxy,null)
				var buildingsprite = b.get_node("sprite").duplicate(0)
				$terrainui/Label.text = GAMEDATA.BUILDING_DATA.get(b.building,{}).get("name","")
				$terrainui/Label.tooltip_text = GAMEDATA.BUILDING_DATA.get(b.building,{}).get("name","")
				$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "feet:" + str(GAMEDATA.BUILDING_DATA.get(b.building,{}).get(GAMEDATA.UNIT_MOVEMENT.FEET,""))
				$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "wheeled:" + str(GAMEDATA.BUILDING_DATA.get(b.building,{}).get(GAMEDATA.UNIT_MOVEMENT.WHEELED,""))
				$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "tracked:" + str(GAMEDATA.BUILDING_DATA.get(b.building,{}).get(GAMEDATA.UNIT_MOVEMENT.TRACKED,""))
				$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "wings:" + str(GAMEDATA.BUILDING_DATA.get(b.building,{}).get(GAMEDATA.UNIT_MOVEMENT.WINGS,""))
				$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "shallowwater:" + str(GAMEDATA.BUILDING_DATA.get(b.building,{}).get(GAMEDATA.UNIT_MOVEMENT.SHALLOWWATER,""))
				$terrainui/Label.tooltip_text = $terrainui/Label.tooltip_text + "\n" + "deepwater:" + str(GAMEDATA.BUILDING_DATA.get(b.building,{}).get(GAMEDATA.UNIT_MOVEMENT.DEEPWATER,""))
				$terrainui/Label2.text = GAMEDATA.BUILDING_DATA.get(b.building,{}).get("description","")
				#print(buildingsprite)
				$terrainui/building.add_child(buildingsprite)
				for i in $terrainui/traitbox.get_children():
					i.queue_free()
				var buildtrait = GAMEDATA.BUILDING_DATA.get(sourceid,{}).get("traits",[])
				for i in buildtrait:
					var builddata = GAMEDATA.TERRAIN_TRAIT_DATA.get(i)
					var build = TextureRect.new()
					build.texture = builddata.get("sprite")
					build.tooltip_text = str(builddata.get("name")) + ":\n" + str(builddata.get("description"))
					$terrainui/traitbox.add_child(build)
					pass
			$unitui/unit.get_children().map(func(n):n.queue_free())
			$unitui/Label.text = ""
			$unitui/Label2.text = ""
			$unitui/Label.tooltip_text = ""
			for i in $unitui/traitbox.get_children():
				i.queue_free()
			if $"../..".unit.get(mapxy,null) != null:
				var u = $"../..".unit.get(mapxy,null)
				var unitsprite = u.get_node("sprite").duplicate(0)
				$unitui/unit.add_child(unitsprite)
				$unitui/Label.text = GAMEDATA.UNIT_DATA.get(u.unit,{}).get("name","")
				$unitui/Label2.text = GAMEDATA.UNIT_DATA.get(u.unit,{}).get("description","")
				var udata = GAMEDATA.UNIT_DATA.get(u.unit,{})
				
				var unitarmortex = TextureRect.new()
				var unitarmordata = GAMEDATA.UNIT_ARMOR_DATA.get(udata.get("armor"))
				unitarmortex.texture = unitarmordata.get("sprite")
				unitarmortex.tooltip_text = str(unitarmordata.get("name")) + ":\n" + str(unitarmordata.get("description"))
				$unitui/traitbox.add_child(unitarmortex)
				var hplab = Label.new()
				hplab.text = str(u.hp) + "/" + str(u.unitdata.get("hp"))
				$unitui/traitbox.add_child(hplab)
				
				var unitweapontex = TextureRect.new()
				var unitweapondata = GAMEDATA.UNIT_WEAPON_DATA.get(udata.get("weapon"))
				unitweapontex.texture = unitweapondata.get("sprite")
				unitweapontex.tooltip_text = str(unitweapondata.get("name")) + ":\n" + str(unitweapondata.get("description"))
				$unitui/traitbox.add_child(unitweapontex)
				var attacklab = Label.new()
				attacklab.text = str(u.unitdata.get("attack"))
				$unitui/traitbox.add_child(attacklab)
				
				var unittrait = u.unitdata.get("traits",[])
				for i in unittrait:
					var unittraitdata = GAMEDATA.UNIT_TRAIT_DATA.get(i)
					var unittraittex = TextureRect.new()
					unittraittex.texture = unittraitdata.get("sprite")
					unittraittex.tooltip_text = str(unittraitdata.get("name")) + "\n" + str(unittraitdata.get("description"))
					$unitui/traitbox.add_child(unittraittex)
					pass
				
			
			print(get_global_mouse_position())
			print(mapxy)
