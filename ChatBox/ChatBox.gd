extends Control

# onready var chatLog = get_node("VBoxContainer/Panel/RichTextLabel")
onready var chatLog = get_node("VBoxContainer/RichTextLabel")
# onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")
# onready var bot = get_node("../../../partyGuest")


var bot 
var username
var color
var bot_answer


signal request_finished

var url = "https://api.openai.com/v1/completions"
var gpt3_key = OS.get_environment("API-KEY")
var api_key_request = "Authorization: Bearer " + gpt3_key
var parameters 
var gpt3_prompt
var background_info = "You are at a party. All your friends are there. The party is in your apartment and you're the host. \n"

var chat_log = []

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
	bot = get_parent().get_parent().get_parent()
	bot.do_somethin()
	
	username = 'bot' + bot.bot_name
	# text color, could later store this with the bot itself?
	color = players['bot1']['color']

	chatLog.bbcode_text += '\n' # new line
	chatLog.bbcode_text += '[color=' + color + ']' + '[' + username + ']: ' + text



func text_entered(text):
	if text != '':
		username = players['player1']['name']
		add_message(username, text)
		inputField.text = ''
		
		# send prompt to api and wait for answer signal
		request_answer(text)
		yield(self, "request_finished")
		
		# pass answer to bot
		answer(bot, bot_answer)


func _ready():
	inputField.connect("text_entered", self, "text_entered")
	$HTTPRequest.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	
	
	
func request_answer(prompt):
	chat_log.append("You: " + prompt)

	gpt3_prompt = background_info + PoolStringArray(chat_log).join("\n") + "\n Friend:"
	
	parameters = {
		"model": "text-davinci-002",
		"prompt": gpt3_prompt,
		"temperature": 0.5,
		"max_tokens": 40,
		"top_p": 1.0,
		"frequency_penalty": 0.5,
		"presence_penalty": 0.0,
		"stop": ["You:"]
		}
		
	$HTTPRequest.request(url, ["Content-Type: application/json", api_key_request], true, HTTPClient.METHOD_POST, JSON.print(parameters))
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	# parse and extract answer
	var json = parse_json(body.get_string_from_utf8())
	print(body.get_string_from_utf8())
	bot_answer = json['choices'][0]['text'].strip_edges(true, true)
	chat_log.append("Friend: " + bot_answer)
	
	# signal that result has been yielded
	emit_signal("request_finished")
	
	

