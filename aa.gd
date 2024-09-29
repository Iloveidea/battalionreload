extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	G.connect("anifinished",Callable($".", "on_anifinished"))
	#print(get_node(".."))
	#get_node("..").queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_finished():
	G.emit_signal("anifinished","66666")
	pass # Replace with function body.


func _on_animation_looped():
	#G.emit_signal("anifinished")
	pass # Replace with function body.
