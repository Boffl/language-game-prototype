extends Control


var nr_of_guests = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("CenterContainer/VBoxContainer/StartButton").grab_focus()
	get_node("CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/GuestSlider").set_value(nr_of_guests)
	get_node("CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/GuestLabel").set_text("Number of Guests: " + str(nr_of_guests))
	get_node("CenterContainer/VBoxContainer/StartButton").rect_min_size = Vector2(200, 50)
	
	
	# export the values to the GlobalSettings
	GlobalSettings.nr_of_guests = nr_of_guests



func _on_GuestSlider_value_changed(value):
	nr_of_guests = value
	get_node("CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/GuestLabel").set_text("Number of Guests: " + str(nr_of_guests))
	
	# export values to GlobalSettings
	GlobalSettings.nr_of_guests = nr_of_guests
	


func _on_StartButton_pressed():
	# starts Party scene
	get_tree().change_scene("res://Party.tscn")
