extends Popup

var labels = ["drink water", "drink alcohol", "eat", "dance", "leave", "pee", "Null"]
var chosen_index
onready var text_label = get_node("VBoxContainer/RichTextLabel")
onready var drop_down = get_node("VBoxContainer/HBoxContainer2/CenterContainer/OptionButton")
var text  # text displayed in the pop up window



# Called when the node enters the scene tree for the first time.
func _ready():
	
	# fill in the labels in the drop down menu
	for item in labels:
		drop_down.add_item(item)


func _on_Popup_about_to_show():
	# set the label. The text is changed before from the PartyGuest.gd script
	text_label.text = text 
	text = ""


func _on_Popup_confirmed():
	chosen_index = drop_down.selected
	# var data_row = labels[chosen_index] + "," + text_label.text
	# var file = File.new()
	# file.open("data.csv", file.WRITE)
	# file.store_line(data_row)
	# file.close()
	print(text_label.text, ", ", labels[chosen_index])


