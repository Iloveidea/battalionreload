extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _make_custom_tooltip(for_text):
	var label = Label.new()
	label.text = "for_text"
	return label

