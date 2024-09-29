extends Control

var turn = 0
var playernum = 0
var currentplayer = 0
var playeruiarray = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(num,name):
	playernum = num
	for i in range(num):
		var l = Label.new()
		l.text = name[i]
		$Panel/VBoxContainer.add_child(l)
		playeruiarray.append(l)
	$Panel/VBoxContainer/HBoxContainer/Label2.text = str(turn)
	playeruiarray[0].text = ">" + playeruiarray[0].text


func _on_button_pressed():
	if $"../..".lockcontrol == true:
		return
	#Consolecommands.emit_signal("test")
	#return
	AllSIGNAL.emit_signal("playerturnstart",currentplayer)
	if currentplayer >= playernum-1:
		turn = turn+1
		currentplayer = 0
	else:
		currentplayer = currentplayer+1
	AllSIGNAL.emit_signal("playerturnend",currentplayer)
	$"../..".turn = turn
	$"../..".currentplayer = currentplayer
	$Panel/VBoxContainer/HBoxContainer/Label2.text = str(turn)
	playeruiarray.map(func(l):
		l.text = l.text.replace(">","")
		return 0
		)
	playeruiarray[currentplayer].text = ">" + playeruiarray[currentplayer].text
	pass # Replace with function body.
