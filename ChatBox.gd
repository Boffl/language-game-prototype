extends Control

# onready var chatLog = get_node("VBoxContainer/Panel/RichTextLabel")
onready var chatLog = get_node("VBoxContainer/RichTextLabel")
# onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")
# onready var bot = get_node("../../../partyGuest")


var bot 
var username
var color
var prompt = ""
var key = OS.get_environment("GPT3-KEY")
 # we can change the names later, for now this makes the colors in the chat
var players = {'player1':{'name': 'player1', 'color': '#34c5f1'},
				'bot1':{'name': 'bot1', 'color': '#f1c234'},
				'bot2': {'name': 'bot2', 'color': '#ffffff'},
				}



func _input(event):
	# can I use this also to get the focus on the input field? would be more intuitiveü
	# inputField.grab_click_focus()
	
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			inputField.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.release_focus()

func add_message(player, text):
	username = players[player]['name']
	color = players[player]['color']
	chatLog.bbcode_text += '\n' # new line
	# change the color, so each bot and the player1 get their own color
	# the bbcode field is some sort of rich text format where [color=xyz]text, bla bla[/color] changes the color
	# alternatively we can just give a color to the player1 and all the bots have the same
	# color. at least for now we plan on just having one on one conversations.. but lets see
	chatLog.bbcode_text += '[color=' + color + ']' + '[' + username + ']: ' 
	chatLog.bbcode_text +=  text
	chatLog.bbcode_text += '[/color]'


func answer(bot, text):
	
	# Get the bot that the chatbox is attached to, it is the grandparent
	bot = get_parent().get_parent()
	bot.do_somethin()
	
	
	username = 'bot' + bot.bot_name
	# text color, could later store this with the bot itself?
	color = players['bot1']['color']
	
	prompt = chatLog.text + '\n[' +username + ']:'
	print(prompt.c_escape())
	
	
	var output = []
	var command = 'curl -u :'+key+' '
	command += """https:\/\/api.openai.com\/v1\/completions -H \"Content-Type: application/json\" """
	command += """-d \"{\\\"model\\\": \\\"text-davinci-002\\\", \\\"temperature\\\": 0, \\\"max_tokens\\\": 20"""
	command += ",\\\"prompt\\\":\\\""+prompt.c_escape()+"\\\""
	command += "}\""
	
	var exit_code = OS.execute("cmd.exe", ["/C",command], true, output)
	print(exit_code)
	print(command)
	print(output)
	if exit_code == 0:
		var output_dict = parse_json(output[0])
		var answer = output_dict['choices'][0]['text']
		chatLog.bbcode_text += '\n' # new line
		chatLog.bbcode_text += '[color=' + color + ']' + '[' + username + ']: ' + answer



func text_entered(text):
	if text != '':
		username = players['player1']['name']
		add_message(username, text)
		inputField.text = ''
		answer(bot, text)


func _ready():
	inputField.connect("text_entered", self, "text_entered")

	# print(output)
	



