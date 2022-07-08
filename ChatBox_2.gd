extends Control

onready var chatLog = get_node("VBoxContainer/Panel/VBoxContainer/RichTextLabel")
# onready var chatLog = get_node("VBoxContainer/RichTextLabel")
# onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")






 # we can change the names later, for now this makes the colors in the chat
var players = {'player1':{'name': 'player1', 'color': '#34c5f1'},
				'bot1':{'name': 'bot1', 'color': '#f1c234'},
				'bot2': {'name': 'bot2', 'color': '#ffffff'},
				}

var user_name = "player1"


func _input(event):
	# can I use this also to get the focus on the input field? would be more intuitiveü
	# inputField.grab_click_focus()
	
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			inputField.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.release_focus()

func add_message(player, text):
	var username = players[player]['name']
	var color = players[player]['color']
	chatLog.bbcode_text += '\n' # new line
	# change the color, so each bot and the player1 get their own color
	# the bbcode field is some sort of rich text format where [color=xyz]text, bla bla[/color] changes the color
	# alternatively we can just give a color to the player1 and all the bots have the same
	# color. at least for now we plan on just having one on one conversations.. but lets see
	chatLog.bbcode_text += '[color=' + color + ']' + '[' + username + ']: ' 
	chatLog.bbcode_text +=  text
	chatLog.bbcode_text += '[/color]'


func answer(bot, text):
	var username = players[bot]['name']
	var color = players[bot]['color']
	
	chatLog.bbcode_text += '\n' # new line
	chatLog.bbcode_text += '[color=' + color + ']' + '[' + username + ']: ' + text



func text_entered(text):
	if text != '':
		print(text)
		add_message(user_name, text)
		inputField.text = ''
		answer('bot1', text)


func _ready():
	inputField.connect("text_entered", self, "text_entered")


