extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_tile(t):
	$select.visible = 0
	$selectorange.visible = 0
	$selectmix.visible = 0
	if t == 1:
		$select.visible = 1
	elif t == 2:
		$selectorange.visible = 1
	elif t == 3:
		$selectmix.visible = 1


func set_attacktarget(t):
	$"attacktarget-".visible = 0
	$"attacktarget=".visible = 0
	$"attacktarget+".visible = 0
	if t == "-":
		$"attacktarget-".visible = 1
	elif t == "=":
		$"attacktarget=".visible = 1
	elif t == "+":
		$"attacktarget+".visible = 1
