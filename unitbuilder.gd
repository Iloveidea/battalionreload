extends Window


var builder
var resource = 0:
	set(value):
		resource = value
		$Scroll/Center/VBox/HBox/unitbg/Label.text = str(value)

var groundunitbtn = {}
var airunitbtn = {}
var seaunitbtn = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	AllSIGNAL.connect("buildunit",Callable($".", "callbuilduniter"))
	unitinit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func unitinit():
	GAMEDATA.UNIT_TYPE.GROUND
	GAMEDATA.UNIT_TYPE.WINGS
	GAMEDATA.UNIT_TYPE.SEA
	var groundunit = {
		GAMEDATA.UNIT.STRIKECOMMANDO:"res://sprites/unit/commando.png",
		GAMEDATA.UNIT.HEAVYCOMMANDO:"res://sprites/unit/hcommando.png",
		GAMEDATA.UNIT.FLAKTANK:"res://sprites/unit/flak.png",
		GAMEDATA.UNIT.LANCERTANK:"res://sprites/unit/lancer.png",
		GAMEDATA.UNIT.SCORPIONTANK:"res://sprites/unit/scorpion.png",
		GAMEDATA.UNIT.SPIDERTANK:"res://sprites/unit/spider.png",
		GAMEDATA.UNIT.STEALTHTANK:"res://sprites/unit/stealth.png",
		GAMEDATA.UNIT.JAMMERTRUCK:"res://sprites/unit/jammer.png",
		GAMEDATA.UNIT.MORTARTRUCK:"res://sprites/unit/mortar.png",
		GAMEDATA.UNIT.ROCKETTRUCK:"res://sprites/unit/rocket.png",
		GAMEDATA.UNIT.ANNIHILATORTANK:"res://sprites/unit/annihilator.png",
	}
	
	for i in groundunit.keys():
		var btn = Button.new()
		var a = AtlasTexture.new()
		btn.focus_mode =Control.FOCUS_NONE
		a.atlas = load(groundunit[i])
		a.region = Rect2(728,56,56,56)
		btn.icon = a
		btn.text = str(GAMEDATA.UNIT_DATA.get(i).get("cost",INF))
		btn.theme = load("res://maintheme.tres")
		$Scroll/Center/VBox/HBox2/Grid.add_child(btn)
		btn.pressed.connect(objbuild.bind(i))
		btn.disabled = true
		groundunitbtn[i] = btn
	
	var airunit = {
		GAMEDATA.UNIT.RAPTORFIGHTER:"res://sprites/unit/raptor.png",
		GAMEDATA.UNIT.VULTUREDRONE:"res://sprites/unit/vulture.png",
		GAMEDATA.UNIT.CONDORBOMBER:"res://sprites/unit/condor.png",
	}
	
	for i in airunit.keys():
		var btn = Button.new()
		var a = AtlasTexture.new()
		btn.focus_mode =Control.FOCUS_NONE
		a.atlas = load(airunit[i])
		a.region = Rect2(728,56,56,56)
		btn.icon = a
		btn.text = str(GAMEDATA.UNIT_DATA.get(i).get("cost",INF))
		btn.theme = load("res://maintheme.tres")
		$Scroll/Center/VBox/HBox2/Grid2.add_child(btn)
		btn.pressed.connect(objbuild.bind(i))
		btn.disabled = true
		airunitbtn[i] = btn
		#btn.pressed.connect(unitsignal.bind(MOUSEMODE.UNIT,i))
		
	
	
	
	var seaunit = {
		GAMEDATA.UNIT.INTREPID:"res://sprites/unit/intrepid.png",
		GAMEDATA.UNIT.HUNTERSUPPORT:"res://sprites/unit/hunter.png",
		GAMEDATA.UNIT.UBOAT:"res://sprites/unit/uboat.png",
		GAMEDATA.UNIT.CORVETTEFIGHTER:"res://sprites/unit/corvette.png",
		GAMEDATA.UNIT.BATTLECRUISER:"res://sprites/unit/battlecruiser.png",
		
	}
	
	for i in seaunit.keys():
		var btn = Button.new()
		var a = AtlasTexture.new()
		btn.focus_mode =Control.FOCUS_NONE
		a.atlas = load(seaunit[i])
		a.region = Rect2(728,56,56,56)
		btn.icon = a
		btn.text = str(GAMEDATA.UNIT_DATA.get(i).get("cost",INF))
		btn.theme = load("res://maintheme.tres")
		$Scroll/Center/VBox/HBox2/Grid3.add_child(btn)
		btn.pressed.connect(objbuild.bind(i))
		btn.disabled = true
		seaunitbtn[i] = btn
		#btn.pressed.connect(unitsignal.bind(MOUSEMODE.UNIT,i))
		
	
	#for i in range(len(unitbtnimg)):
		#var btn = Button.new()
		#var a = AtlasTexture.new()
		#btn.focus_mode =Control.FOCUS_NONE
		#a.atlas = load(unitbtnimg[i])
		#a.region = Rect2(728,56,56,56)
		#btn.icon = a
		#btn.theme = load("res://maintheme.tres")
		#$Camera2D/Control/TabContainer/unit/VBoxContainer/GridContainer.add_child(btn)
		#btn.pressed.connect(unitsignal.bind(MOUSEMODE.UNIT,i))
	


#func unitsignal(mm,md):
	#mousemode = MOUSEMODE.UNIT
	#mousedata = {
		#"player" = $Camera2D/Control/TabContainer/unit/VBoxContainer/OptionButton.selected,
		#"unit" = md,
	#}


func _on_cancelbtn_pressed():
	$".".visible = 0
	pass # Replace with function body.


func callbuilduniter(obj):
	for i in groundunitbtn:
		groundunitbtn[i].disabled = false
	for i in airunitbtn:
		airunitbtn[i].disabled = false
	for i in seaunitbtn:
		seaunitbtn[i].disabled = false
	#for i in seaunitbtn:
		#seaunitbtn[i].disabled = true
	$".".visible = 1
	builder = obj
	if builder.is_building():
		var neartile = [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),]
		[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(tile):
			var terrain = $"../terrainmap/TileMap".get_cell_source_id(0,tile+$"..".building.find_key(builder),)
			if ![9,11,15,16,17,18].has(terrain):
				for i in seaunitbtn:
					seaunitbtn[i].disabled = true
			return 0
			)
		resource = 9999
	if builder.is_unit():
		#var neartile = [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),]
		#[Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),].map(func(tile):
			#var terrain = $"../terrainmap/TileMap".get_cell_source_id(0,tile+$"..".unit.find_key(builder),)
			#if [9,11,15,16,17,18].has(terrain):
				#for i in seaunitbtn:
					#seaunitbtn[i].disabled = false
			#return 0
			#)
		resource = builder.resource
	
	print("ready to build")
	pass

func objbuild(unit):
	$".".visible = 0
	if builder.is_building():
		builder.try_build_unit(unit)
	if builder.is_unit():
		builder.try_build_unit(unit)
