extends Node2D

@export var player = 0:
	set(value):
		player = value
		if value <= -1 :
			color = GAMEDATA.naturecolor
			$sprite.material.set_shader_parameter("newcolor5",Color(0.678, 0.718, 0.667))
			$sprite.material.set_shader_parameter("newcolor6",Color(0.49, 0.6, 0.541))
			$sprite.material.set_shader_parameter("newcolor7",Color(0.373, 0.435, 0.396))
			$sprite.material.set_shader_parameter("newcolor8",Color(0.137, 0.231, 0.329))
		else :
			color = Gamemap.playercolor[value]
			$sprite.material.set_shader_parameter("newcolor5",Color(1, 1, 0.863))
			$sprite.material.set_shader_parameter("newcolor6",Color(1, 0.914, 0.459))
			$sprite.material.set_shader_parameter("newcolor7",Color(1, 0.914, 0.459))
			$sprite.material.set_shader_parameter("newcolor8",Color(0.588, 0.306, 0.22))
		
		#var playercolor = Gamemap.playercolor.duplicate(true)
		#playercolor.reverse()
		#playercolor.append(GAMEDATA.naturecolor.duplicate(true))
		#playercolor.reverse()
		#color = playercolor[value]
		
@export var buildingid = 0
@export var building = GAMEDATA.BUILDING.COMMANDCENTER:
	set(value):
		building = value
		$sprite.texture = GAMEDATA.BUILDING_DATA.get(value).get("sprite")
@export var buildingname = ""
@export var buildingsprite = "res://sprites/unitframes/annihilator.tres":
	set(value):
		$sprite.texture = value
@export var color = [Color(0.471, 0.573, 0.937),Color(0.141, 0.384, 0.816),Color(0.098, 0.243, 0.694),Color(0.071, 0.133, 0.396)]:
	set(value):
		color = value
		if value == []:
			return
		$sprite.material.set_shader_parameter("newcolor4",value[1])
		$sprite.material.set_shader_parameter("newcolor3",value[2])
		$sprite.material.set_shader_parameter("newcolor2",value[3])
		$sprite.material.set_shader_parameter("newcolor1",value[4])
		
@export var buildingflag = []



# Called when the node enters the scene tree for the first time.
func _ready():
	AllSIGNAL.connect("updatecolor",Callable($".", "_updatecolor"))
	#print(player)
	#print(color)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func try_build_unit(unitid):

	var u = load("res://unit.tscn").instantiate()
	u.player = player
	u.unit = unitid
	var tile = $"../..".building.find_key($".")
	u.position = (tile * 56) + Vector2i(28,28)
	$"../..".unit[tile] = u
	$"../../unit".add_child(u)
	u.actioned = true
	u.setsleep(0.5)
	u.pauseani()



func _updatecolor():
	player = player


func is_unit()->bool:
	return false

func is_building()->bool:
	return true



