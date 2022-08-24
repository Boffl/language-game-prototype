extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#get_node("CenterContainer/VBoxContainer/MainMenu").rect_min_size = Vector2(200, 50)
	
	
	# export the values to the GlobalSettings
	


func _on_MainMenu_pressed():
	print("hi")
	# starts Party scene
	print("Return to main menu")
	get_tree().change_scene("res://MainMenu.tscn")
