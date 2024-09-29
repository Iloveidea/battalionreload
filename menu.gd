extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_campaign_btn_pressed():
	pass # Replace with function body.


func _on_scenario_btn_pressed():
	
	pass # Replace with function body.


func _on_map_editer_btn_pressed():
	get_tree().change_scene_to_file("res://mapeditor.tscn")
	pass # Replace with function body.


func _on_option_btn_pressed():
	pass # Replace with function body.


func _on_quit_btn_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_selectmap_btn_pressed():
	$FileDialog.visible = true
	pass # Replace with function body.


func _on_file_dialog_file_selected(path):
	var game = load("res://Main.tscn").instantiate()
	game.map = path
	get_tree().get_root().add_child(game)
	$".".queue_free()
	#get_tree().change_scene_to_packed(game)
	pass # Replace with function body.


func _on_file_dialog_canceled():
	$FileDialog.visible = false
	pass # Replace with function body.
