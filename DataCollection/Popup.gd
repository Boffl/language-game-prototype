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
	# preparing for the file, with escape characters and enclosed in quotes
	var conversation = "\"" + text_label.text.c_escape() + "\""
	
	# here are the labels, note that text_label refers to the RichTextLabel
	# element from Godot... 
	var label = labels[chosen_index]
	var file = File.new()
	
	# writing into a txt file, because Godot gets all weird when there is a
	# .csv in the folder...
	file.open("data.txt", file.READ_WRITE)  # READ_WRITE is method to append
	file.seek_end()  # go to end of file
	file.store_line(label + "," + conversation)
	file.close()
	print("Datapoint saved to data.txt")



