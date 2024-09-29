extends Node2D

var playerboxleft
var playerbox = []
var colorlist = {
	"red" = GAMEDATA.COLOR_RED,
	"blue" = GAMEDATA.COLOR_BLUE,
	"green" = GAMEDATA.COLOR_GREEN,
	"yellow" = GAMEDATA.COLOR_YELLOW,
	"maroon" = GAMEDATA.COLOR_MAROON,
	"darkblue" = GAMEDATA.COLOR_DK_BLUE,
	"brown" = GAMEDATA.COLOR_BROWN,
	"olive" = GAMEDATA.COLOR_OLIVE,
	"orange" = GAMEDATA.COLOR_ORANGE,
	"teal" = GAMEDATA.COLOR_TEAL,
	"pink" = GAMEDATA.COLOR_PINK,
	"white" = GAMEDATA.COLOR_WHITE,
	"violet" = GAMEDATA.COLOR_VIOLET,
	"black" = GAMEDATA.COLOR_BLACK,
}
var MAX_PLAYER = 6
enum MOUSEMODE{TILE,UNIT,BUILDING}
var mousemode = MOUSEMODE.TILE:
	set(value):
		mousemode = value
		$Camera2D/Control/Control/Label.text = str(value)
		pass
var mousedata:Dictionary:
	set(value):
		mousedata = value
		$Camera2D/Control/Control/Label2.text = str(value)
		pass

const nearbytile =[
	Vector2i(-1,-1),Vector2i(0,-1),Vector2i(1,-1),
	Vector2i(-1,0),              Vector2i(1,0),
	Vector2i(-1,1),Vector2i(0,1),Vector2i(1,1),
	]

var mapdata = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	tileinit()
	playerboxinit()
	unitinit()
	buildinginit()
	
	_on_spin_box_value_changed(2)
	tilebtnsignal(MOUSEMODE.TILE,0)
	
	$Camera2D/Control/TabContainer/map/VBoxContainer/HBoxContainer/xnum.value = 2
	$Camera2D/Control/TabContainer/map/VBoxContainer/HBoxContainer/ynum.value = 2
	_on_mapxybtn_pressed()
	
	_on_load_map_file_selected("res://map/mapeditorinit")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	
	if event is InputEventKey and event.pressed:
			if event.keycode == KEY_UP:
				$Camera2D.position += Vector2(0,-30)
			if event.keycode == KEY_DOWN:
				$Camera2D.position += Vector2(0,30)
			if event.keycode == KEY_LEFT:
				$Camera2D.position += Vector2(-30,0)
			if event.keycode == KEY_RIGHT:
				$Camera2D.position += Vector2(30,0)
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print(get_global_mouse_position())
			print($terrainmap/TileMap.local_to_map(get_global_mouse_position()))
			var mapxy = $terrainmap/TileMap.local_to_map(get_global_mouse_position())
			#print()
			if (mapxy.x <= Gamemap.mapx ) and (mapxy.x >= -1) and (mapxy.y <= Gamemap.mapy ) and (mapxy.y >= -1):
				if mousemode == MOUSEMODE.TILE:
					set_terrain(mapxy,mousedata.tile)
				if mousemode == MOUSEMODE.BUILDING:
					set_building(mapxy,mousedata)
					pass
				if mousemode == MOUSEMODE.UNIT:
					set_unit(mapxy,mousedata)
					pass

func set_unit(mapxy,unitdata):
	if Gamemap.unit.get(mapxy,null) != null:
		Gamemap.unit[mapxy].queue_free()
	if unitdata.unit == -1:
		return
	var u = load("res://unit.tscn").instantiate()
	u.unit = unitdata.unit
	u.player = unitdata.player
	u.position = (mapxy * 56) + Vector2i(28,28)
	u.set_y_sort_enabled(1)
	$units.add_child(u)
	Gamemap.unit[mapxy] = u
	#print(Gamemap.unit)



func set_building(mapxy,buildingdata):
	if Gamemap.building.get(mapxy,null) != null:
		Gamemap.building[mapxy].queue_free()
	if buildingdata.building == -1:
		return
	var b = load("res://building.tscn").instantiate()
	b.building = buildingdata.building
	b.player = buildingdata.player
	b.position = (mapxy * 56) + Vector2i(28,28)
	b.set_y_sort_enabled(true)
	#print(b.is_y_sort_enabled())
	$buildings.add_child(b)
	Gamemap.building[mapxy] = b
	#print(Gamemap.building)
	
	pass

#func set_map_tile(mapxy,t):
	#set_terrain(mapxy,t)
	#
	#for i in nearbytile:
		#set_terrain(mapxy+i,$terrainmap/TileMap.get_cell_source_id(0,mapxy+i))
	#
	#

func set_terrain(mapxy,terrain):
	match terrain:
		0:
			var plains = [
				Vector2i(0,0),Vector2i(0,0),
				Vector2i(1,0),Vector2i(1,0),
				Vector2i(2,0),Vector2i(2,0),
				Vector2i(3,0),Vector2i(3,0),
				Vector2i(0,1),Vector2i(0,1),
				Vector2i(1,1),
				Vector2i(2,1),
				Vector2i(3,1),Vector2i(3,1),
				]
			$terrainmap/TileMap.set_cell(0,mapxy,0,plains[randi() % plains.size()],0)
		1:
			var forest =[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),]
			$terrainmap/TileMap.set_cell(0,mapxy,1,forest[randi() % forest.size()],0)
		2:
			var nearbyroad = 0b0000
			for i in [Vector2i(0,-1),Vector2i(-1,0),Vector2i(1,0),Vector2i(0,1),]:
				nearbyroad = nearbyroad << 1
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+i)
				if [2,].has(t):
					nearbyroad = nearbyroad | 0b0001
			
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,-1))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,-1)) < Vector2i(1,2):
					nearbyroad = nearbyroad | 0b1000
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,1))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,1)) < Vector2i(1,2):
					nearbyroad = nearbyroad | 0b0001
				
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(-1,0))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(-1,0)) > Vector2i(1,2):
					nearbyroad = nearbyroad | 0b0100
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(1,0))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(1,0)) > Vector2i(1,2):
					nearbyroad = nearbyroad | 0b0010
			
			
			
			match nearbyroad:
				0b0001:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(0,0),0)
				0b0011:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(1,0),0)
				0b0111:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(2,0),0)
				0b0101:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(3,0),0)
				
				0b1001:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(0,1),0)
				0b1011:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(1,1),0)
				0b1111:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(2,1),0)
				0b1101:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(3,1),0)
				
				0b1000:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(0,2),0)
				0b1010:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(1,2),0)
				0b1110:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(2,2),0)
				0b1100:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(3,2),0)
				
				0b0010:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(1,3),0)
				0b0110:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(2,3),0)
				0b0100:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(3,3),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy,2,Vector2i(0,0),0)
			
		3:
			var hills =[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),]
			$terrainmap/TileMap.set_cell(0,mapxy,3,hills[randi() % hills.size()],0)
		4:
			var mountains =[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),]
			$terrainmap/TileMap.set_cell(0,mapxy,4,mountains[randi() % mountains.size()],0)
		5:
			var desert =[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),]
			$terrainmap/TileMap.set_cell(0,mapxy,5,desert[randi() % desert.size()],0)
		6:
			var depletedoredeposit =[Vector2i(0,0),Vector2i(1,0),]
			$terrainmap/TileMap.set_cell(0,mapxy,6,depletedoredeposit[randi() % depletedoredeposit.size()],0)
		7:
			var oredeposit =[Vector2i(0,0),Vector2i(0,1),]
			$terrainmap/TileMap.set_cell(0,mapxy,7,oredeposit[randi() % oredeposit.size()],0)
		8:
			var enrichedoredeposit =[Vector2i(0,0),Vector2i(0,1),]
			$terrainmap/TileMap.set_cell(0,mapxy,8,enrichedoredeposit[randi() % enrichedoredeposit.size()],0)
		9:
			var nearbysea = 0b00000000
			for i in nearbytile:
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+i)
				nearbysea = nearbysea << 1
				if ![-1,9,10,11,15,16,17,18].has(t):
					nearbysea = nearbysea | 0b00000001
			
			if (nearbysea / 0b1000000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10100000
			if (nearbysea / 0b10000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10000100
			if (nearbysea / 0b1000 % 0b10) == 1:
				nearbysea = nearbysea | 0b00100001
			if (nearbysea / 0b10 % 0b10) == 1:
				nearbysea = nearbysea | 0b00000101
			#nearbysea = ~nearbysea
			match nearbysea:
				0b11111101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,0),0)
				0b10111101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,1),0)
				0b10111111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,2),0)
				0b11111111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,3),0)
				
				0b11110101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,0),0)
				0b10110101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,1),0)
				0b10110111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,2),0)
				0b11110111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,3),0)
				
				0b11100101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,0),0)
				0b10100101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,1),0)
				0b10100111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,2),0)
				0b11100111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,3),0)
				
				0b11101101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,0),0)
				0b10101101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,1),0)
				0b10101111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,2),0)
				0b11101111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,3),0)
				
				0b00100101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,4),0)
				0b10110100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,5),0)
				0b10010101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,6),0)
				0b10100001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,7),0)
				
				0b11100100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,4),0)
				0b10000000:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,5),0)
				0b00000100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,6),0)
				0b10000111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,7),0)
				
				0b11100001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,4),0)
				0b00100000:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,5),0)
				0b00000001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,6),0)
				0b00100111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,7),0)
				
				0b10000101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,4),0)
				0b10101001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,5),0)
				0b00101101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,6),0)
				0b10100100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,7),0)
				
				0b11110100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,8),0)
				0b10010100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,9),0)
				0b10000100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,10),0)
				0b10010111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(0,11),0)
				
				0b10100000:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,8),0)
				0b10000001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,9),0)
				0b00000000:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,10),0)
				0b00000111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,11),0)
				
				0b11100000:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,8),0)
				0b00100100:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,10),0)
				0b00000101:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(8,11),0)
				
				0b11101001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,8),0)
				0b00100001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,9),0)
				0b00101001:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,10),0)
				0b00101111:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(12,11),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy,9,Vector2i(4,10),0)
			
		10:
			var vertnearbybridge = 0b00
			var horinearbybridge = 0b00
			
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,-1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,-1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b01
				
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(-1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(-1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b01
					
			#$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(0,0),0)
			
			match vertnearbybridge:
				0b00:
					$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(1,1),0)
					match horinearbybridge:
						0b00:
							$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(2,2),0)
						0b01:
							$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(1,3),0)
						0b10:
							$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(3,3),0)
						0b11:
							$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(2,3),0)
				0b01:
					$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(0,0),0)
				0b10:
					$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(0,2),0)
				0b11:
					$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(0,1),0)
			
			if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,-1))):
				if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,1))):
					pass
					$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(1,1),0)
			
			
		11:
			var vertnearbybridge = 0b00
			var horinearbybridge = 0b00
			
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,-1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,-1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b01
				
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(-1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(-1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b01
					
			#$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(0,0),0)
			
			match vertnearbybridge:
				0b00:
					$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(1,1),0)
					match horinearbybridge:
						0b00:
							$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(2,2),0)
						0b01:
							$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(1,3),0)
						0b10:
							$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(3,3),0)
						0b11:
							$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(2,3),0)
				0b01:
					$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(0,0),0)
				0b10:
					$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(0,2),0)
				0b11:
					$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(0,1),0)
			
			if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,-1))):
				if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+Vector2i(0,1))):
					pass
					$terrainmap/TileMap.set_cell(0,mapxy,11,Vector2i(1,1),0)
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(-1,0)) > Vector2i(1,2):
					#horinearbybridge = horinearbybridge | 0b10
			
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(1,0)) > Vector2i(1,2):
					#horinearbybridge = horinearbybridge | 0b01
			
		12:
			
			var nearbycanyon = 0b00000000
			for i in nearbytile:
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+i)
				nearbycanyon = nearbycanyon << 1
				if ![12].has(t):
					nearbycanyon = nearbycanyon | 0b00000001
			
			if (nearbycanyon / 0b1000000 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b10100000
			if (nearbycanyon / 0b10000 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b10000100
			if (nearbycanyon / 0b1000 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b00100001
			if (nearbycanyon / 0b10 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b00000101
			#nearbycanyon = ~nearbycanyon
			match nearbycanyon:
				0b11111101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(0,0),0)
				0b10111101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(0,1),0)
				0b10111111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(0,2),0)
				0b11111111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(0,3),0)
				
				0b11110101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(1,0),0)
				0b10110101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(1,1),0)
				0b10110111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(1,2),0)
				0b11110111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(1,3),0)
				
				0b11100101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(2,0),0)
				0b10100101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(2,1),0)
				0b10100111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(2,2),0)
				0b11100111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(2,3),0)
				
				0b11101101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(3,0),0)
				0b10101101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(3,1),0)
				0b10101111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(3,2),0)
				0b11101111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(3,3),0)
				
				0b00100101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(4,0),0)
				0b10110100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(4,1),0)
				0b10010101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(4,2),0)
				0b10100001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(4,3),0)
				
				0b11100100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(5,0),0)
				0b10000000:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(5,1),0)
				0b00000100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(5,2),0)
				0b10000111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(5,3),0)
				
				0b11100001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(6,0),0)
				0b00100000:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(6,1),0)
				0b00000001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(6,2),0)
				0b00100111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(6,3),0)
				
				0b10000101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(7,0),0)
				0b10101001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(7,1),0)
				0b00101101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(7,2),0)
				0b10100100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(7,3),0)
				
				0b11110100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(8,0),0)
				0b10010100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(8,1),0)
				0b10000100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(8,2),0)
				0b10010111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(8,3),0)
				
				0b10100000:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(9,0),0)
				0b10000001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(9,1),0)
				0b00000000:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(9,2),0)
				0b00000111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(9,3),0)
				
				0b11100000:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(10,0),0)
				0b00100100:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(10,2),0)
				0b00000101:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(10,3),0)
				
				0b11101001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(11,0),0)
				0b00100001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(11,1),0)
				0b00101001:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(11,2),0)
				0b00101111:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(11,3),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy,12,Vector2i(9,2),0)
			
		13:
			$terrainmap/TileMap.set_cell(0,mapxy,13,Vector2i(0,0),0)
		14:
			$terrainmap/TileMap.set_cell(0,mapxy,14,Vector2i(0,0),0)
		15:
			var reef =[Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(0,3),]
			$terrainmap/TileMap.set_cell(0,mapxy,15,reef[randi() % reef.size()],0)
		16:
			var nearbysea = 0b00000000
			for i in nearbytile:
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+i)
				nearbysea = nearbysea << 1
				if ![-1,9,10,11,15,16,17,18].has(t):
					nearbysea = nearbysea | 0b00000001
			
			if (nearbysea / 0b1000000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10100000
			if (nearbysea / 0b10000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10000100
			if (nearbysea / 0b1000 % 0b10) == 1:
				nearbysea = nearbysea | 0b00100001
			if (nearbysea / 0b10 % 0b10) == 1:
				nearbysea = nearbysea | 0b00000101
			#nearbysea = ~nearbysea
			match nearbysea:
				0b11111101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,0),0)
				0b10111101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,1),0)
				0b10111111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,2),0)
				0b11111111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,3),0)
				
				0b11110101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,0),0)
				0b10110101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,1),0)
				0b10110111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,2),0)
				0b11110111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,3),0)
				
				0b11100101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,0),0)
				#0b10100101:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,1),0)
				0b10100111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,2),0)
				0b11100111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,3),0)
				
				0b11101101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,0),0)
				0b10101101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,1),0)
				0b10101111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,2),0)
				0b11101111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,3),0)
				
				#0b00100101:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,4),0)
				0b10110100:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,5),0)
				0b10010101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,6),0)
				#0b10100001:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,7),0)
				
				0b11100100:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,4),0)
				#0b10000000:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,5),0)
				#0b00000100:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,6),0)
				0b10000111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,7),0)
				
				0b11100001:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,4),0)
				#0b00100000:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,5),0)
				#0b00000001:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,6),0)
				0b00100111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,7),0)
				
				#0b10000101:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,4),0)
				0b10101001:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,5),0)
				0b00101101:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,6),0)
				#0b10100100:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,7),0)
				
				0b11110100:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,8),0)
				0b10010100:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,9),0)
				#0b10000100:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,10),0)
				0b10010111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,11),0)
				
				#0b10100000:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,8),0)
				#0b10000001:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,9),0)
				#0b00000000:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,10),0)
				0b00000111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(4,11),0)
				
				0b11100000:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,8),0)
				#0b00100100:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,10),0)
				#0b00000101:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(8,11),0)
				
				0b11101001:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,8),0)
				#0b00100001:
					#$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,9),0)
				0b00101001:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,10),0)
				0b00101111:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(12,11),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy,16,Vector2i(0,3),0)
			
		17:
			var archipelago =[Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(0,3),]
			$terrainmap/TileMap.set_cell(0,mapxy,17,archipelago[randi() % archipelago.size()],0)
		18:
			var rockformation =[Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(0,3),]
			$terrainmap/TileMap.set_cell(0,mapxy,18,rockformation[randi() % rockformation.size()],0)
	
	road_autotile_fix(mapxy)
	sea_autotile_fix(mapxy)
	canyon_autotile_fix(mapxy)
	shore_autotile_fix(mapxy)
	bridge_autotile_fix(mapxy)
	pass

func road_autotile_fix(mapxy):
	for tile in nearbytile:
		if $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile) != 2:
			continue
		else:
			var nearbyroad = 0b0000
			for i in [Vector2i(0,-1),Vector2i(-1,0),Vector2i(1,0),Vector2i(0,1),]:
				nearbyroad = nearbyroad << 1
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+i)
				if [2].has(t):
					nearbyroad = nearbyroad | 0b0001
			
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,-1))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(0,-1)) < Vector2i(1,2):
					nearbyroad = nearbyroad | 0b1000
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,1))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(0,1)) < Vector2i(1,2):
					nearbyroad = nearbyroad | 0b0001
				
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(-1,0))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(-1,0)) > Vector2i(1,2):
					nearbyroad = nearbyroad | 0b0100
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(1,0))):
				if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(1,0)) > Vector2i(1,2):
					nearbyroad = nearbyroad | 0b0010
			
			
			match nearbyroad:
				0b0001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(0,0),0)
				0b0011:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(1,0),0)
				0b0111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(2,0),0)
				0b0101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(3,0),0)
				
				0b1001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(0,1),0)
				0b1011:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(1,1),0)
				0b1111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(2,1),0)
				0b1101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(3,1),0)
				
				0b1000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(0,2),0)
				0b1010:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(1,2),0)
				0b1110:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(2,2),0)
				0b1100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(3,2),0)
				
				0b0010:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(1,3),0)
				0b0110:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(2,3),0)
				0b0100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(3,3),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,2,Vector2i(0,0),0)
			

func sea_autotile_fix(mapxy):
	
	for tile in nearbytile:
		if $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile) != 9:
			continue
		else:
			var nearbysea = 0b00000000
			for i in nearbytile:
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+i)
				nearbysea = nearbysea << 1
				if ![-1,9,10,11,15,16,17,18].has(t):
					nearbysea = nearbysea | 0b00000001
			
			if (nearbysea / 0b1000000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10100000
			if (nearbysea / 0b10000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10000100
			if (nearbysea / 0b1000 % 0b10) == 1:
				nearbysea = nearbysea | 0b00100001
			if (nearbysea / 0b10 % 0b10) == 1:
				nearbysea = nearbysea | 0b00000101
			#nearbysea = ~nearbysea
			match nearbysea:
				0b11111101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,0),0)
				0b10111101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,1),0)
				0b10111111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,2),0)
				0b11111111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,3),0)
				
				0b11110101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,0),0)
				0b10110101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,1),0)
				0b10110111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,2),0)
				0b11110111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,3),0)
				
				0b11100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,0),0)
				0b10100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,1),0)
				0b10100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,2),0)
				0b11100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,3),0)
				
				0b11101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,0),0)
				0b10101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,1),0)
				0b10101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,2),0)
				0b11101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,3),0)
				
				0b00100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,4),0)
				0b10110100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,5),0)
				0b10010101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,6),0)
				0b10100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,7),0)
				
				0b11100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,4),0)
				0b10000000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,5),0)
				0b00000100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,6),0)
				0b10000111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,7),0)
				
				0b11100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,4),0)
				0b00100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,5),0)
				0b00000001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,6),0)
				0b00100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,7),0)
				
				0b10000101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,4),0)
				0b10101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,5),0)
				0b00101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,6),0)
				0b10100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,7),0)
				
				0b11110100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,8),0)
				0b10010100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,9),0)
				0b10000100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,10),0)
				0b10010111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(0,11),0)
				
				0b10100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,8),0)
				0b10000001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,9),0)
				0b00000000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,10),0)
				0b00000111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,11),0)
				
				0b11100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,8),0)
				0b00100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,10),0)
				0b00000101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(8,11),0)
				
				0b11101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,8),0)
				0b00100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,9),0)
				0b00101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,10),0)
				0b00101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(12,11),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,9,Vector2i(4,10),0)
			

func canyon_autotile_fix(mapxy):
	
	for tile in nearbytile:
		if $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile) != 12:
			continue
		else:
			
	
			var nearbycanyon = 0b00000000
			for i in nearbytile:
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+i)
				nearbycanyon = nearbycanyon << 1
				if ![12].has(t):
					nearbycanyon = nearbycanyon | 0b00000001
			
			if (nearbycanyon / 0b1000000 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b10100000
			if (nearbycanyon / 0b10000 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b10000100
			if (nearbycanyon / 0b1000 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b00100001
			if (nearbycanyon / 0b10 % 0b10) == 1:
				nearbycanyon = nearbycanyon | 0b00000101
			#nearbycanyon = ~nearbycanyon
			match nearbycanyon:
				0b11111101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(0,0),0)
				0b10111101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(0,1),0)
				0b10111111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(0,2),0)
				0b11111111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(0,3),0)
				
				0b11110101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(1,0),0)
				0b10110101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(1,1),0)
				0b10110111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(1,2),0)
				0b11110111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(1,3),0)
				
				0b11100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(2,0),0)
				0b10100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(2,1),0)
				0b10100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(2,2),0)
				0b11100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(2,3),0)
				
				0b11101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(3,0),0)
				0b10101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(3,1),0)
				0b10101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(3,2),0)
				0b11101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(3,3),0)
				
				0b00100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(4,0),0)
				0b10110100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(4,1),0)
				0b10010101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(4,2),0)
				0b10100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(4,3),0)
				
				0b11100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(5,0),0)
				0b10000000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(5,1),0)
				0b00000100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(5,2),0)
				0b10000111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(5,3),0)
				
				0b11100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(6,0),0)
				0b00100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(6,1),0)
				0b00000001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(6,2),0)
				0b00100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(6,3),0)
				
				0b10000101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(7,0),0)
				0b10101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(7,1),0)
				0b00101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(7,2),0)
				0b10100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(7,3),0)
				
				0b11110100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(8,0),0)
				0b10010100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(8,1),0)
				0b10000100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(8,2),0)
				0b10010111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(8,3),0)
				
				0b10100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(9,0),0)
				0b10000001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(9,1),0)
				0b00000000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(9,2),0)
				0b00000111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(9,3),0)
				
				0b11100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(10,0),0)
				0b00100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(10,2),0)
				0b00000101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(10,3),0)
				
				0b11101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(11,0),0)
				0b00100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(11,1),0)
				0b00101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(11,2),0)
				0b00101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(11,3),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,12,Vector2i(9,2),0)
	pass

func shore_autotile_fix(mapxy):
	
	for tile in nearbytile:
		if $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile) != 16:
			continue
		else:
			var nearbysea = 0b00000000
			for i in nearbytile:
				var t = $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+i)
				nearbysea = nearbysea << 1
				if ![-1,9,10,11,15,16,17,18].has(t):
					nearbysea = nearbysea | 0b00000001
			
			if (nearbysea / 0b1000000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10100000
			if (nearbysea / 0b10000 % 0b10) == 1:
				nearbysea = nearbysea | 0b10000100
			if (nearbysea / 0b1000 % 0b10) == 1:
				nearbysea = nearbysea | 0b00100001
			if (nearbysea / 0b10 % 0b10) == 1:
				nearbysea = nearbysea | 0b00000101
			#nearbysea = ~nearbysea
			match nearbysea:
				0b11111101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,0),0)
				0b10111101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,1),0)
				0b10111111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,2),0)
				0b11111111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,3),0)
				
				0b11110101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,0),0)
				0b10110101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,1),0)
				0b10110111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,2),0)
				0b11110111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,3),0)
				
				0b11100101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,0),0)
				#0b10100101:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,1),0)
				0b10100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,2),0)
				0b11100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,3),0)
				
				0b11101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,0),0)
				0b10101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,1),0)
				0b10101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,2),0)
				0b11101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,3),0)
				
				#0b00100101:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,4),0)
				0b10110100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,5),0)
				0b10010101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,6),0)
				#0b10100001:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,7),0)
				
				0b11100100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,4),0)
				#0b10000000:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,5),0)
				#0b00000100:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,6),0)
				0b10000111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,7),0)
				
				0b11100001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,4),0)
				#0b00100000:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,5),0)
				#0b00000001:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,6),0)
				0b00100111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,7),0)
				
				#0b10000101:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,4),0)
				0b10101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,5),0)
				0b00101101:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,6),0)
				#0b10100100:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,7),0)
				
				0b11110100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,8),0)
				0b10010100:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,9),0)
				#0b10000100:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,10),0)
				0b10010111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,11),0)
				
				#0b10100000:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,8),0)
				#0b10000001:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,9),0)
				#0b00000000:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,10),0)
				0b00000111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(4,11),0)
				
				0b11100000:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,8),0)
				#0b00100100:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,10),0)
				#0b00000101:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(8,11),0)
				
				0b11101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,8),0)
				#0b00100001:
					#$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,9),0)
				0b00101001:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,10),0)
				0b00101111:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(12,11),0)
				
				_:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,16,Vector2i(0,3),0)

func bridge_autotile_fix(mapxy):
	for tile in nearbytile:
		if ![10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile)):
			continue
		if $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile) == 10:
			var vertnearbybridge = 0b00
			var horinearbybridge = 0b00
			
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,-1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,-1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(0,1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b01
				
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(-1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(-1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b01
					
			#$terrainmap/TileMap.set_cell(0,mapxy,10,Vector2i(0,0),0)
			
			match vertnearbybridge:
				0b00:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(1,1),0)
					match horinearbybridge:
						0b00:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(2,2),0)
						0b01:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(1,3),0)
						0b10:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(3,3),0)
						0b11:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(2,3),0)
				0b01:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(0,0),0)
				0b10:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(0,2),0)
				0b11:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(0,1),0)
			
			if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,-1))):
				if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,1))):
					pass
					$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(1,1),0)
			
		elif $terrainmap/TileMap.get_cell_source_id(0,mapxy+tile) == 11:
			var vertnearbybridge = 0b00
			var horinearbybridge = 0b00
			
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,-1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(0,-1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,1))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(0,1)) < Vector2i(1,2):
					vertnearbybridge = vertnearbybridge | 0b01
				
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(-1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+Vector2i(-1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b10
			if [10,11].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(1,0))):
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(1,0)) > Vector2i(1,2):
					horinearbybridge = horinearbybridge | 0b01
					
			#$terrainmap/TileMap.set_cell(0,mapxy+tile,10,Vector2i(0,0),0)
			
			match vertnearbybridge:
				0b00:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(1,1),0)
					match horinearbybridge:
						0b00:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(2,2),0)
						0b01:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(1,3),0)
						0b10:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(3,3),0)
						0b11:
							$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(2,3),0)
				0b01:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(0,0),0)
				0b10:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(0,2),0)
				0b11:
					$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(0,1),0)
			
			if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,-1))):
				if [0,1,2,3,4,5,6,7,8,12,13,14].has($terrainmap/TileMap.get_cell_source_id(0,mapxy+tile+Vector2i(0,1))):
					pass
					$terrainmap/TileMap.set_cell(0,mapxy+tile,11,Vector2i(1,1),0)
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(-1,0)) > Vector2i(1,2):
					#horinearbybridge = horinearbybridge | 0b10
			
				#if $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy+tile+Vector2i(1,0)) > Vector2i(1,2):
					#horinearbybridge = horinearbybridge | 0b01
			

func btn_action():
	print("aaa")
	pass

func playername(a,b):
	Gamemap.playername[b] = a
	pass

func playercolor(a,b):
	Gamemap.playercolor[b] = colorlist[colorlist.keys()[a]]
	AllSIGNAL.emit_signal("updatecolor")
	pass


func _on_spin_box_value_changed(value):
	var v = int(value)
	Gamemap.playernum = v
	$Camera2D/Control/TabContainer/player/VBoxContainer/GridContainer.columns = v+1
	playerbox.all(func(a):
		a.all(func(obj):
			obj.visible = true
			return 1
		)
		return 1
	)
	
	for i in range(v,MAX_PLAYER):
		
		playerbox[i].all(func(obj):
			obj.visible = false
			return 1
			)
	
	$Camera2D/Control/TabContainer/unit/VBoxContainer/OptionButton.clear()
	$Camera2D/Control/TabContainer/building/VBoxContainer/OptionButton.clear()
	$Camera2D/Control/TabContainer/building/VBoxContainer/OptionButton.add_item("nature")
	for i in range(value):
		$Camera2D/Control/TabContainer/unit/VBoxContainer/OptionButton.add_item("play_"+str(i))
		$Camera2D/Control/TabContainer/building/VBoxContainer/OptionButton.add_item("play_"+str(i))
	pass # Replace with function body.



func tileinit():
	var tilebtn = [
		load("res://sprites/editor/tile/plains.tres"),
		load("res://sprites/editor/tile/forest.tres"),
		load("res://sprites/editor/tile/road.tres"),
		load("res://sprites/editor/tile/hills.tres"),
		load("res://sprites/editor/tile/mountains.tres"),
		load("res://sprites/editor/tile/desert.tres"),
		load("res://sprites/editor/tile/depletedoredeposit.tres"),
		load("res://sprites/editor/tile/oredeposit.tres"),
		load("res://sprites/editor/tile/enrichedoredeposit.tres"),
		load("res://sprites/editor/tile/sea.tres"),
		load("res://sprites/editor/tile/bridge.tres"),
		load("res://sprites/editor/tile/highbridge.tres"),
		load("res://sprites/editor/tile/canyon.tres"),
		load("res://sprites/editor/tile/wasteland.tres"),
		load("res://sprites/editor/tile/volcano.tres"),
		load("res://sprites/editor/tile/reef.tres"),
		load("res://sprites/editor/tile/shore.tres"),
		load("res://sprites/editor/tile/archipelago.tres"),
		load("res://sprites/editor/tile/rockformation.tres"),
		]
	for i in range(len(tilebtn)):
		var btn = Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.icon = tilebtn[i] 
		btn.theme = load("res://maintheme.tres")
		$Camera2D/Control/TabContainer/tile/VBoxContainer/GridContainer.add_child(btn)
		btn.pressed.connect(tilebtnsignal.bind(MOUSEMODE.TILE,i))
	

func tilebtnsignal(mm,md):
	mousemode = MOUSEMODE.TILE
	mousedata = {"tile" = md}


func playerboxinit():
	playerboxleft = [
		MarginContainer.new(),
		Label.new(),
		Label.new(),
		#OptionButton.new(),
	]
	playerboxleft[0]
	playerboxleft[1].text = "playname"
	playerboxleft[2].text = "color"
	
	$Camera2D/Control/TabContainer/player/VBoxContainer/HBoxContainer/SpinBox.max_value = MAX_PLAYER
	
	Gamemap.playername = []
	Gamemap.playercolor = []
	
	for i in range(MAX_PLAYER):
		var t = [
			Label.new(),
			LineEdit.new(),
			OptionButton.new()
		]
		t[0].focus_mode =Control.FOCUS_NONE
		t[1].focus_mode =Control.FOCUS_NONE
		t[2].focus_mode =Control.FOCUS_NONE
		
		t[0].text = "player_" + str(i)
		t[1].text = "player" + str(i)
		t[1].text_changed.connect(playername.bind(i))
		Gamemap.playername.append("player" + str(i))
		playername("player" + str(i),i)
		
		colorlist.keys().all(func(c):
			t[2].add_item(c)
			return 1
			)
		t[2].select(i)
		t[2].item_selected.connect(playercolor.bind(i))
		Gamemap.playercolor.append([])
		playercolor(t[2].selected,i)
		
		
		playerbox.append(t)
		
		
	$Camera2D/Control/TabContainer/player/VBoxContainer/GridContainer.columns = MAX_PLAYER+1
	for i in range(3):
		$Camera2D/Control/TabContainer/player/VBoxContainer/GridContainer.add_child(playerboxleft[i])
		for j in playerbox:
			$Camera2D/Control/TabContainer/player/VBoxContainer/GridContainer.add_child(j[i])
	

func unitinit():
	var unitbtnimg = [
		"res://sprites/unit/annihilator.png",
		"res://sprites/unit/warmachine.png",
		"res://sprites/unit/jammer.png",
		"res://sprites/unit/blockade.png",
		"res://sprites/unit/lancer.png",
		"res://sprites/unit/spider.png",
		"res://sprites/unit/hcommando.png",
		"res://sprites/unit/commando.png",
		"res://sprites/unit/flak.png",
		"res://sprites/unit/scorpion.png",
		"res://sprites/unit/mortar.png",
		"res://sprites/unit/rocket.png",
		"res://sprites/unit/turret.png",
		"res://sprites/unit/stealth.png",
		"res://sprites/unit/albatross.png",
		"res://sprites/unit/raptor.png",
		"res://sprites/unit/vulture.png",
		"res://sprites/unit/condor.png",
		"res://sprites/unit/leviathan.png",
		"res://sprites/unit/hunter.png",
		"res://sprites/unit/corvette.png",
		"res://sprites/unit/uboat.png",
		"res://sprites/unit/battlecruiser.png",
		"res://sprites/unit/intrepid.png",
		]
	#var unit=[
		#GAMEDATA.UNIT.ANNIHILATORTANK,GAMEDATA.UNIT.WARMACHINE,
		#GAMEDATA.UNIT.JAMMERTRUCK,GAMEDATA.UNIT.BLOCKADE,GAMEDATA.UNIT.LANCERTANK,
		#GAMEDATA.UNIT.SPIDERTANK,GAMEDATA.UNIT.HEAVYCOMMANDO,
		#GAMEDATA.UNIT.STRIKECOMMANDO,GAMEDATA.UNIT.FLAKTANK,
		#GAMEDATA.UNIT.SCORPIONTANK,GAMEDATA.UNIT.MORTARTRUCK,
		#GAMEDATA.UNIT.ROCKETTRUCK,GAMEDATA.UNIT.TURRET,GAMEDATA.UNIT.STEALTHTANK,
		#GAMEDATA.UNIT.ALBATROSSTRANSPORT,GAMEDATA.UNIT.RAPTORFIGHTER,
		#GAMEDATA.UNIT.VULTUREDRONE,GAMEDATA.UNIT.CONDORBOMBER,
		#GAMEDATA.UNIT.LEVIATHANBARGE,GAMEDATA.UNIT.HUNTERSUPPORT,
		#GAMEDATA.UNIT.CORVETTEFIGHTER,GAMEDATA.UNIT.UBOAT,
		#GAMEDATA.UNIT.BATTLECRUISER,GAMEDATA.UNIT.INTREPID,
	#]
	
	var delbtn = Button.new()
	delbtn.focus_mode =Control.FOCUS_NONE
	delbtn.icon = load("res://sprites/editor/editdelbtn.tres")
	delbtn.theme = load("res://maintheme.tres")
	$Camera2D/Control/TabContainer/unit/VBoxContainer/GridContainer.add_child(delbtn)
	delbtn.pressed.connect(unitsignal.bind(MOUSEMODE.UNIT,-1))
	
	
	for i in range(len(unitbtnimg)):
		var btn = Button.new()
		var a = AtlasTexture.new()
		btn.focus_mode =Control.FOCUS_NONE
		a.atlas = load(unitbtnimg[i])
		a.region = Rect2(728,56,56,56)
		btn.icon = a
		btn.theme = load("res://maintheme.tres")
		$Camera2D/Control/TabContainer/unit/VBoxContainer/GridContainer.add_child(btn)
		btn.pressed.connect(unitsignal.bind(MOUSEMODE.UNIT,i))
	

func unitsignal(mm,md):
	mousemode = MOUSEMODE.UNIT
	mousedata = {
		"player" = $Camera2D/Control/TabContainer/unit/VBoxContainer/OptionButton.selected,
		"unit" = md,
	}


func buildinginit():
	var buildingbtnimg = [
		"res://sprites/building/147_capital_capital.png",
		"res://sprites/building/446_groundcontrol_groundcontrol.png",
		"res://sprites/building/571_aircontrol_aircontrol.png",
		"res://sprites/building/395_seacontrol_seacontrol.png",
		"res://sprites/building/173_factory_factory.png",
		"res://sprites/building/180_oilrefinery_oilrefinery.png",
		"res://sprites/building/370_oiladvanced_oiladvanced.png",
		"res://sprites/building/394_oilrig_oilrig.png",
		]
	
	var delbtn = Button.new()
	delbtn.focus_mode =Control.FOCUS_NONE
	delbtn.icon = load("res://sprites/editor/editdelbtn.tres")
	delbtn.theme = load("res://maintheme.tres")
	$Camera2D/Control/TabContainer/building/VBoxContainer/GridContainer.add_child(delbtn)
	delbtn.pressed.connect(buildingsignal.bind(MOUSEMODE.BUILDING,-1))
	
	for i in range(len(buildingbtnimg)):
		var btn = Button.new()
		var a = AtlasTexture.new()
		btn.focus_mode =Control.FOCUS_NONE
		a.atlas = load(buildingbtnimg[i])
		a.region = Rect2(56,56,56,56)
		btn.icon = a
		btn.theme = load("res://maintheme.tres")
		$Camera2D/Control/TabContainer/building/VBoxContainer/GridContainer.add_child(btn)
		btn.pressed.connect(buildingsignal.bind(MOUSEMODE.BUILDING,i))
	

func buildingsignal(mm,md):
	mousemode = MOUSEMODE.BUILDING
	mousedata = {
		"player" = $Camera2D/Control/TabContainer/building/VBoxContainer/OptionButton.selected-1,
		"building" = md,
	}



func _on_mapxybtn_pressed():
	Gamemap.mapx = int($Camera2D/Control/TabContainer/map/VBoxContainer/HBoxContainer/xnum.value)
	Gamemap.mapy = int($Camera2D/Control/TabContainer/map/VBoxContainer/HBoxContainer/ynum.value)
	#print(Gamemap.mapx)
	#print(Gamemap.mapy)
	$border.clear_points()
	$border.add_point(Vector2(0,0))
	$border.add_point(Vector2(Gamemap.mapx*56.0,0))
	$border.add_point(Vector2(Gamemap.mapx*56.0,Gamemap.mapy*56.0))
	$border.add_point(Vector2(0,Gamemap.mapy*56.0))
	
	$border2.clear_points()
	$border2.add_point(Vector2(0,0)+Vector2(-56,-56))
	$border2.add_point(Vector2(Gamemap.mapx*56.0,0)+Vector2(56,-56))
	$border2.add_point(Vector2(Gamemap.mapx*56.0,Gamemap.mapy*56.0)+Vector2(56,56))
	$border2.add_point(Vector2(0,Gamemap.mapy*56.0)+Vector2(-56,56))
	
	pass # Replace with function body.


func _on_output_pressed():
	mapdata = {
		playernum = Gamemap.playernum,
		playername = [],
		playercolor = [],
		
		mapx = Gamemap.mapx,
		mapy = Gamemap.mapy,
		terrain = {},
		unit = {},
		building = {},
	}
	for i in range(Gamemap.playernum):
		mapdata.playername.append(Gamemap.playername[i])
		mapdata.playercolor.append(Gamemap.playercolor[i])
	#terraindata
	for x in range(Gamemap.mapx):
		for y in range(Gamemap.mapy):
			var mapxy = Vector2i(x,y)
			mapdata.terrain[mapxy] = {
				sourceid = $terrainmap/TileMap.get_cell_source_id(0,mapxy),
				atlascoords = $terrainmap/TileMap.get_cell_atlas_coords(0,mapxy),
			}
			if $terrainmap/TileMap.get_cell_source_id(0,mapxy) == -1:
				mapdata.terrain.mapxy = {
					sourceid = 0,
					atlascoords = Vector2i(0,0),
				}
	#unitdata
	for key in Gamemap.unit:
		if Gamemap.unit.get(key,null) != null:
			mapdata.unit[key] = {
				player = Gamemap.unit.get(key,null).get("player"),
				unit = Gamemap.unit.get(key,null).get("unit"),
			}
	#buildingdata
	for key in Gamemap.building:
		if Gamemap.building.get(key,null) != null:
			mapdata.building[key] = {
				player = Gamemap.building.get(key,null).get("player"),
				building = Gamemap.building.get(key,null).get("building"),
			}
	print(mapdata)
	
	#var f = FileAccess.open("res://map/testmap/testmap.bmap",1)
	#var data = f.get_var()
	#print(data)
	#f.close()
	
	#var file = FileAccess.open("res://map/testmap/testmap.bmap",7)
	#file.store_var(mapdata)
	#file.close()
	
	#var path = "res://map/testmap"
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if dir.current_is_dir():
				#print("发现目录：" + file_name)
			#else:
				#print("发现文件：" + file_name)
				#print(FileAccess.open(path+"/"+file_name,1).get_var())
			#file_name = dir.get_next()
	#else:
		#print("尝试访问路径时出错。")
	$SaveMap.visible = true
	#print("aaaa")
	pass # Replace with function body.


func _on_save_map_file_selected(path):
	var file = FileAccess.open(path,7)
	file.store_var(mapdata)
	file.close()
	$SaveMap.visible = false
	pass # Replace with function body.


func _on_load_map_file_selected(path):
	var file = FileAccess.open(path,1)
	var data = file.get_var()
	load_map(data)
	pass # Replace with function body.

func load_map(data:Dictionary):
	#Gamemap.playernum = data.playernum
	$Camera2D/Control/TabContainer/player/VBoxContainer/HBoxContainer/SpinBox.value = data.playernum
	for i in range(data.playernum):
		Gamemap.playername[i] = data.playername[i]
		Gamemap.playercolor[i] = data.playercolor[i]
	#Gamemap.mapx = data.mapx
	$Camera2D/Control/TabContainer/map/VBoxContainer/HBoxContainer/xnum.value = data.mapx
	#Gamemap.mapy = data.mapy
	$Camera2D/Control/TabContainer/map/VBoxContainer/HBoxContainer/ynum.value = data.mapy
	_on_mapxybtn_pressed()
	for key in data.terrain:
		$terrainmap/TileMap.set_cell(0,key,data.terrain[key].sourceid,data.terrain[key].atlascoords,0)
	for key in data.unit:
		set_unit(key,{"player" = data.unit[key].player,"unit" = data.unit[key].unit})
	for key in data.building:
		set_building(key,{"player" = data.building[key].player,"building" =data.building[key].building,})
	$LoadMap.visible = false
	pass


func _on_load_map_btn_pressed():
	$LoadMap.visible = true
	pass # Replace with function body.
