extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("TopContainer/VBoxContainer/WinStats").set_text(GlobalSettings.win_message)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ReturnButton_pressed():
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
	pass # Replace with function body.
