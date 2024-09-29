extends Node2D

@export var tiles = []:
	set(value):
		tiles = value
		$".".add_child(Marker2D.new())
		var nodes = $".".get_children()
		nodes.all(func(node):
			node.queue_free()
			return 1
		)
		if value == [] :return
		value.all(func(tile):
			var node = TextEdit.new()
			node.position = tile*56+Vector2i(28,28)
			node.mouse_filter = 2
			node.editable = 0
			$".".add_child(node)
			return 1
		)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
