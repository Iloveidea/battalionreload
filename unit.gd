extends Node2D

@export var player = 0:
	set(value):
		player = value
		color = Gamemap.playercolor[value]
@export var unitid = 0
@export var unit = GAMEDATA.UNIT.ANNIHILATORTANK:
	set(value):
		unit = value
		unitdata = GAMEDATA.UNIT_DATA.get(value)
		unitsprite = GAMEDATA.UNIT_FRAME.get(value)
var unitdata = GAMEDATA.UNIT_DATA.get(GAMEDATA.UNIT.ANNIHILATORTANK)
@export var unitname = ""
@export var unitsprite = "res://sprites/unitframes/annihilator.tres":
	set(value):
		$sprite.set_sprite_frames(value)
		if direction == "e" :
			$sprite.play("idle_e")
		elif direction == "w" :
			$sprite.play("idle_w")
		elif direction == "s" :
			$sprite.play("idle_e")
		else :
			$sprite.play("idle_w")
@export var unitaudio = "Annihilator Tank"
@export var color = [Color(0.471, 0.573, 0.937),Color(0.141, 0.384, 0.816),Color(0.098, 0.243, 0.694),Color(0.071, 0.133, 0.396)]:
	set(value):
		color = value
		if value == []:
			return
		$sprite.material.set_shader_parameter("newcolor4",value[1])
		$sprite.material.set_shader_parameter("newcolor3",value[2])
		$sprite.material.set_shader_parameter("newcolor2",value[3])
		$sprite.material.set_shader_parameter("newcolor1",value[4])
var hpbarstyle = StyleBoxFlat.new()
@export var hp = 100:
	set(value):
		var maxhp = unitdata.get("hp")
		hp = min(value,maxhp)
		if value <= 0 : dead()
		var hpbarvalue = int((float(hp)/float(maxhp))*100.0)
		$ProgressBar.value = hpbarvalue
		$ProgressBar2.value = hpbarvalue
		$ProgressBar3.value = hpbarvalue
		$ProgressBar4.value = hpbarvalue
		if hpbarvalue < 35 :
			hpbarstyle.bg_color = Color("ff0000")
		elif hpbarvalue < 65 :
			hpbarstyle.bg_color = Color("ffff00")
		else :
			hpbarstyle.bg_color = Color("00ff00")
@export var type = ""
@export var movement = 25
@export var speed = 6
@export var attack = 25
@export var rangemin = 1
@export var rangemax = 1
@export var armor = "heavy"
@export var weapon = "heavy"
@export var traits = []
@export var direction = "e"
@export var actioned = false
@export var isinvisible = false
#@export var issleep = false
@export var unitflag = []
@export var cost = 525
@export var resource : int= 0:
	set(value):
		resource = int(value)
		$Resourcelab/Label.text = str(resource)

var transporthp = 0
var transportunit = null:
	set(value):
		transportunit = value
		if value == null:
			
			return


func sethp(h):
	hp = h


func playani(ani):
	$sprite.play(ani)

func pauseani():
	$sprite.pause()

func setsleep(s):
	$sprite.material.set_shader_parameter("sleep",s)

func dead():
	var exp = preload("res://explosion.tscn").instantiate()
	exp.position = position
	$"..".add_child.call_deferred(exp)
	$".".queue_free()

func _ready():
	AllSIGNAL.connect("playerturnstart",Callable($".", "turnstart"))
	AllSIGNAL.connect("playerturnend",Callable($".", "turnend"))
	AllSIGNAL.connect("playani",Callable($".", "_on_playani"))
	AllSIGNAL.connect("updatecolor",Callable($".", "_updatecolor"))
	#print(unitsprite)
	#$sprite.set_sprite_frames(load(unitsprite))
	$sprite.play("idle_e")
	$ProgressBar.add_theme_stylebox_override("fill", hpbarstyle)
	$ProgressBar2.add_theme_stylebox_override("fill", hpbarstyle)
	$ProgressBar3.add_theme_stylebox_override("fill", hpbarstyle)
	$ProgressBar4.add_theme_stylebox_override("fill", hpbarstyle)
	hp = unitdata.get("hp")
	
	var image
	image = Image.new().load_from_file("res://sprites/567_wm_build_side_wm_build_side.png")
	image = image.get_region(Rect2i(0,0,56,56))
	#image.flip_x()
	var leftbitmap = BitMap.new()
	leftbitmap.create_from_image_alpha(image,0.1)
	$wmbuild/left.texture_click_mask = leftbitmap
	image.flip_y()
	var rightbitmap = BitMap.new()
	rightbitmap.create_from_image_alpha(image,0.1)
	$wmbuild/right.texture_click_mask = rightbitmap
	
	image = Image.new().load_from_file("res://sprites/184_wm_build_down_wm_build_down.png")
	image = image.get_region(Rect2i(0,0,56,56))
	var downbitmap = BitMap.new()
	downbitmap.create_from_image_alpha(image,0.1)
	$wmbuild/down.texture_click_mask = downbitmap
	
	image = Image.new().load_from_file("res://sprites/123_wm_build_up_wm_build_up.png")
	image = image.get_region(Rect2i(0,0,56,56))
	var upbitmap = BitMap.new()
	upbitmap.create_from_image_alpha(image,0.1)
	$wmbuild/up.texture_click_mask =upbitmap
	
	image = Image.new().load_from_file("res://sprites/448_wm_build_cancel_wm_build_cancel.png")
	image = image.get_region(Rect2i(0,0,56,56))
	var cancelbitmap = BitMap.new()
	cancelbitmap.create_from_image_alpha(image,0.1)
	$wmbuild/cancel.texture_click_mask =cancelbitmap
	
	
	
	#$Sprite2D.texture = ImageTexture.new().create_from_image(bitmap.convert_to_image())
	
	#color = [Color(0.471, 0.573, 0.937),Color(0.141, 0.384, 0.816),Color(0.098, 0.243, 0.694),Color(0.071, 0.133, 0.396)]
	#unitsprite = GAMEDATA.UNIT_FRAME.BATTLECRUISER
	#$ProgressBar2.fill.bg_color = Vector4(1,1,1,1)
	#$ProgressBar2.theme_override_styles.fill.bg_color = Vector4(1,1,1,1)
	#$".".queue_free()
	#print($sprite.get_sprite_frames.get_animation_names())
	#var tween = get_tree().create_tween()
	#tween.tween_property($".", "position", Vector2(100, 0), 1).as_relative()
	#tween.tween_callback($sprite.play.bind("firing_e")).set_delay(2)
	#tween.tween_property($".", "position", Vector2(200, 200), 1).as_relative()
	#tween.connect(self,_ani_completed)
	#G.connect("playani",Callable($".", "_on_playani"))
	#$sprite.play("idle_e")
	#var tween = get_tree().create_tween()
	#tween.tween_callback($sprite.play("move_e")).set_delay(2)

	#tween.tween_property($sprite, "play", "move_n", 3)
	#$sprite.play("move_e")
	#tween.tween_property($".", "position", Vector2(100, 0), 3).as_relative()
	#$sprite.play("move_s")
	#tween.tween_property($".", "position", Vector2(100, 100), 3).as_relative()
	#tween.tween_callback($sprite.play("firing_e"))
	#tween.tween_property($sprite, "animation", "firing_e", 1)
	#tween.connect("finished",Callable(self,"effect_completed"))

	#$sprite.material.set_shader_parameter("aacolor",Vector4(1,0,0,1))
	pass # Replace with function body.
	#var s = $sprite.sprite_frames.get_frame_count("move_s")
	#var d = $sprite.sprite_frames.get_animation_speed("move_s")
	#print(s)
	#print(1/d)
	#print(s*(1/d))

func turnstart(player):
	actioned = false
	var tween = create_tween()
	tween.tween_method(setsleep.bind(),$sprite.material.get_shader_parameter("sleep"),0.0,0.1)
	tween.tween_callback($sprite.play.bind("idle_e"))
	pass

func turnend(player):
	
	pass




func _on_playani(arr):
	#var tween = create_tween()
	#if anitype == "move":
	#	pass
	if arr[1] != unitid : return
	if arr[2] == "move" : _create_move_tween(arr)
	elif arr[2] == "attack" : _create_attack_tween(arr)
	elif arr[2] == "sleep" : _create_sleep_tween(arr)
	elif arr[2] == "sethp" : _create_sethp_tween(arr)
	elif arr[2] == "wakeup" : _create_wakeup_tween(arr)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _create_wakeup_tween(arr):
	var aniid = arr[0]
	var aniunitid = arr[1]
	if direction == "e" :
		$sprite.play("idle_e")
	elif direction == "w" :
		$sprite.play("idle_w")
	elif direction == "s" :
		$sprite.play("idle_e")
	else :
		$sprite.play("idle_w")
	$sprite.material.set_shader_parameter("sleep",0.0)
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", Vector2(0,0), 0.1).as_relative()
	tween.connect("finished",Callable(self,"_ani_completed").bind(aniid,aniunitid))

func _create_sethp_tween(arr):
	hp = arr[3][0]
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", Vector2(0,0), 0.1).as_relative()

func _create_sleep_tween(arr):
	var aniid = arr[0]
	var aniunitid = arr[1]
	if direction == "e" :
		$sprite.play("move_e")
		$sprite.pause()
	elif direction == "w" :
		$sprite.play("move_w")
		$sprite.pause()
	elif direction == "s" :
		$sprite.play("move_s")
		$sprite.pause()
	else :
		$sprite.play("move_n")
		$sprite.pause()
	$sprite.material.set_shader_parameter("sleep",0.5)
	var tween = get_tree().create_tween()
	tween.tween_property($".", "position", Vector2(0,0), 0.1).as_relative()
	tween.connect("finished",Callable(self,"_ani_completed").bind(aniid,aniunitid))

func _create_attack_tween(arr):
	var aniid = arr[0]
	var aniunitid = arr[1]
	var anitype = arr[2]
	var aniflag = arr[3]
	var anitime = arr[4]
	
	if aniunitid != unitid : return
	
	var tween = get_tree().create_tween()
	
	var tflag = Vector2(aniflag[1] - aniflag[0]).angle()
	
	if tflag > 0 :
		if tflag < PI/4 :
			tween.tween_callback($sprite.play.bind("firing_e"))
			direction = "e"
		elif tflag > PI/4*3 :
			tween.tween_callback($sprite.play.bind("firing_w"))
			direction = "w"
		else :
			tween.tween_callback($sprite.play.bind("firing_s"))
			direction = "s"
	else :
		if tflag > -PI/4 :
			tween.tween_callback($sprite.play.bind("firing_e"))
			direction = "e"
		elif tflag < -PI/4*3 :
			tween.tween_callback($sprite.play.bind("firing_n"))
			direction = "n"
		else :
			tween.tween_callback($sprite.play.bind("firing_s"))
			direction = "s"
	
	
	var s = $sprite.sprite_frames.get_frame_count("firing_s")
	var d = $sprite.sprite_frames.get_animation_speed("firing_s")
	tween.tween_property($".", "position", Vector2(0,0), s*(1/d)+0.1).as_relative()
	tween.connect("finished",Callable(self,"_ani_completed").bind(aniid,aniunitid))
	pass

func _create_move_tween(arr):
	
	var aniid = arr[0]
	var aniunitid = arr[1]
	var anitype = arr[2]
	var aniflag = arr[3]
	var anitime = arr[4]
	
	if aniunitid != unitid : return
	
	var tween = get_tree().create_tween()
	
	var tflag = []
	
	for i in range(aniflag.size()-1):
		tflag.append(aniflag[i+1] - aniflag[i])
	
	
	for i in tflag:
		if i == Vector2i(-1,0):
			tween.tween_callback($sprite.play.bind("move_w"))
			direction = "w"
		elif i == Vector2i(0,-1):
			tween.tween_callback($sprite.play.bind("move_n"))
			direction = "n"
		elif i == Vector2i(1,0):
			tween.tween_callback($sprite.play.bind("move_e"))
			direction = "e"
		elif i == Vector2i(0,1):
			tween.tween_callback($sprite.play.bind("move_s"))
			direction = "s"
		tween.tween_property($".", "position", Vector2(i*56), 0.3).as_relative()
	tween.connect("finished",Callable(self,"_ani_completed").bind(aniid,aniunitid))
	pass

func _ani_completed(aniid,aniunitid):
	AllSIGNAL.emit_signal("anifinished",[aniid,aniunitid])
	pass

func _direction(form,to)->String:
	if form.x > to.x : return "w"
	if form.x < to.x : return "e"
	if form.y > to.y : return "n"
	return "s"


func _on_panel_2_mouse_entered():
	if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.CONSTRUCTOR):
		$Resourcelab.visible = true
	pass # Replace with function body.


func _on_panel_2_mouse_exited():
	$Resourcelab.visible = false
	pass # Replace with function body.

func _updatecolor():
	player = player


func _on_texture_button_mouse_entered():
	if unitdata.get("traits",[]).has(GAMEDATA.UNIT_TRAIT.CONSTRUCTOR):
		$Resourcelab.visible = true
	pass # Replace with function body.


func _on_texture_button_mouse_exited():
	$Resourcelab.visible = false
	pass # Replace with function body.


func _on_texture_button_pressed():
	AllSIGNAL.emit_signal("unitclick",self)
	#print(self)
	pass # Replace with function body.

func is_unit()->bool:
	return true

func is_building()->bool:
	return false

func issleep()->bool:
	return !$sprite.is_playing()


func try_build_unit(bulidunitid):
	$"../..".lockcontrol = true
	$wmbuild/up.visible = true
	$wmbuild/down.visible = true
	$wmbuild/left.visible = true
	$wmbuild/right.visible = true
	$wmbuild/cancel.visible = true
	
	#btn.pressed.connect(objbuild.bind(i))
	$wmbuild/up.pressed.disconnect(_on_up_pressed.bind(bulidunitid))
	$wmbuild/up.pressed.connect(_on_up_pressed.bind(bulidunitid))
	$wmbuild/down.pressed.disconnect(_on_down_pressed.bind(bulidunitid))
	$wmbuild/down.pressed.connect(_on_down_pressed.bind(bulidunitid))
	$wmbuild/left.pressed.disconnect(_on_left_pressed.bind(bulidunitid))
	$wmbuild/left.pressed.connect(_on_left_pressed.bind(bulidunitid))
	$wmbuild/right.pressed.disconnect(_on_right_pressed.bind(bulidunitid))
	$wmbuild/right.pressed.connect(_on_right_pressed.bind(bulidunitid))
	
	var unitmovement = GAMEDATA.UNIT_DATA.get(bulidunitid,{}).get("movement",GAMEDATA.UNIT_MOVEMENT.NONE)
	var tile = $"../..".unit.find_key($".")
	if GAMEDATA.TERRAIN_DATA.get($"../../terrainmap/TileMap".get_cell_source_id(0,tile + Vector2i(0,-1)),{}).get(unitmovement,INF)==INF:
		$wmbuild/up.visible = false
	if GAMEDATA.TERRAIN_DATA.get($"../../terrainmap/TileMap".get_cell_source_id(0,tile + Vector2i(0,1)),{}).get(unitmovement,INF)==INF:
		$wmbuild/down.visible = false
	if GAMEDATA.TERRAIN_DATA.get($"../../terrainmap/TileMap".get_cell_source_id(0,tile + Vector2i(-1,0)),{}).get(unitmovement,INF)==INF:
		$wmbuild/left.visible = false
	if GAMEDATA.TERRAIN_DATA.get($"../../terrainmap/TileMap".get_cell_source_id(0,tile + Vector2i(1,0)),{}).get(unitmovement,INF)==INF:
		$wmbuild/right.visible = false
	
	if $"../..".unit.get(tile + Vector2i(0,-1)) != null:
		$wmbuild/up.visible = false
	if $"../..".unit.get(tile + Vector2i(0,1)) != null:
		$wmbuild/down.visible = false
	if $"../..".unit.get(tile + Vector2i(-1,0)) != null:
		$wmbuild/left.visible = false
	if $"../..".unit.get(tile + Vector2i(1,0)) != null:
		$wmbuild/right.visible = false
	
	
	#var u = load("res://unit.tscn").instantiate()
	#u.player = player
	#u.unit = bulidunitid
	#var tile = $"../..".building.find_key($".")
	#u.position = (tile * 56) + Vector2i(28,28)
	#$"../..".unit[tile] = u
	#$"../../unit".add_child(u)
	#u.actioned = true
	#u.setsleep(0.5)
	#u.pauseani()






func _on_cancel_pressed():
	$"../..".lockcontrol = false
	$wmbuild/up.visible = false
	$wmbuild/down.visible = false
	$wmbuild/left.visible = false
	$wmbuild/right.visible = false
	$wmbuild/cancel.visible = false
	pass # Replace with function body.



func _on_up_pressed(bulidunitid):
	$"../..".lockcontrol = false
	$wmbuild/up.visible = false
	$wmbuild/down.visible = false
	$wmbuild/left.visible = false
	$wmbuild/right.visible = false
	$wmbuild/cancel.visible = false
	var u = load("res://unit.tscn").instantiate()
	u.player = player
	u.unit = bulidunitid
	var tile = $"../..".unit.find_key($".")
	u.position = (tile * 56) + Vector2i(28,28)
	$"../..".unit[tile+Vector2i(0,-1)] = u
	$"../../unit".add_child(u)
	u.actioned = true
	var tween = create_tween()
	tween.tween_callback(u.playani.bind("move_n"))
	tween.tween_property(u, "position", Vector2(0,-56), 0.3).as_relative()
	await tween.finished
	u.setsleep(0.5)
	u.pauseani()
	$".".setsleep(0.5)
	$".".pauseani()


func _on_down_pressed(bulidunitid):
	$"../..".lockcontrol = false
	$wmbuild/up.visible = false
	$wmbuild/down.visible = false
	$wmbuild/left.visible = false
	$wmbuild/right.visible = false
	$wmbuild/cancel.visible = false
	var u = load("res://unit.tscn").instantiate()
	u.player = player
	u.unit = bulidunitid
	var tile = $"../..".unit.find_key($".")
	u.position = (tile * 56) + Vector2i(28,28)
	$"../..".unit[tile+Vector2i(0,1)] = u
	$"../../unit".add_child(u)
	u.actioned = true
	var tween = create_tween()
	tween.tween_callback(u.playani.bind("move_s"))
	tween.tween_property(u, "position", Vector2(0,56), 0.3).as_relative()
	await tween.finished
	u.setsleep(0.5)
	u.pauseani()
	$".".setsleep(0.5)
	$".".pauseani()
	pass # Replace with function body.


func _on_left_pressed(bulidunitid):
	$"../..".lockcontrol = false
	$wmbuild/up.visible = false
	$wmbuild/down.visible = false
	$wmbuild/left.visible = false
	$wmbuild/right.visible = false
	$wmbuild/cancel.visible = false
	var u = load("res://unit.tscn").instantiate()
	u.player = player
	u.unit = bulidunitid
	var tile = $"../..".unit.find_key($".")
	u.position = (tile * 56) + Vector2i(28,28)
	$"../..".unit[tile+Vector2i(-1,0)] = u
	$"../../unit".add_child(u)
	u.actioned = true
	var tween = create_tween()
	tween.tween_callback(u.playani.bind("move_w"))
	tween.tween_property(u, "position", Vector2(-56,0), 0.3).as_relative()
	await tween.finished
	u.setsleep(0.5)
	u.pauseani()
	$".".setsleep(0.5)
	$".".pauseani()
	pass # Replace with function body.


func _on_right_pressed(bulidunitid):
	$"../..".lockcontrol = false
	$wmbuild/up.visible = false
	$wmbuild/down.visible = false
	$wmbuild/left.visible = false
	$wmbuild/right.visible = false
	$wmbuild/cancel.visible = false
	var u = load("res://unit.tscn").instantiate()
	u.player = player
	u.unit = bulidunitid
	var tile = $"../..".unit.find_key($".")
	u.position = (tile * 56) + Vector2i(28,28)
	$"../..".unit[tile+Vector2i(1,0)] = u
	$"../../unit".add_child(u)
	u.actioned = true
	var tween = create_tween()
	tween.tween_callback(u.playani.bind("move_e"))
	tween.tween_property(u, "position", Vector2(56,0), 0.3).as_relative()
	await tween.finished
	u.setsleep(0.5)
	u.pauseani()
	$".".setsleep(0.5)
	$".".pauseani()
	pass # Replace with function body.
