extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	G.connect("anifinished",Callable($".", "on_anifinished"))
	G.emit_signal("anifinished","55555")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass



func on_anifinished(text):
	print("11")
	print(text)
  #触发信号
