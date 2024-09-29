extends Node2D

@export var linedata = []:
	set(value):
		linedata = value
		if value == [] :return
		if len(value)<2 :return
		$".".clear_points()
		value.all(func(tile):
			$".".add_point(tile*56+Vector2i(28,28))
			return 1
		)
		
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
