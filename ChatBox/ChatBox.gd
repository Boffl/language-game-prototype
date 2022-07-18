extends Control

# onready var chatLog = get_node("VBoxContainer/Panel/RichTextLabel")
onready var chatLog = get_node("VBoxContainer/RichTextLabel")
# onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")
# onready var bot = get_node("../../../partyGuest")


var partyGuest 
var username
var color
var answer
var prompt


signal request_finished

var url = "https://api.openai.com/v1/completions"
var gpt3_key = OS.get_environment("API_KEY")
var api_key_request = "Authorization: Bearer " + gpt3_key
var parameters 
var gpt3_prompt
var background_info = "You are at a party. All your friends are there. The party is in your apartment and you're the host. \n"

 # some general settings for the player and the bots
var players = {'player':{'name': 'you', 'color': '#34c5f1'},
				'bot':{'name': 'bot', 'color': '#840000'},
				}



func _input(event):
	# can I use this also to get the focus on the input field? would be more intuitiveü
	# inputField.grab_click_focus()
	
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			inputField.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.release_focus()

func add_message(username, text, color):
	chatLog.bbcode_text += '\n' # new line
	# change the color, so the bot and the player get their own color
	# the bbcode field is some sort of rich text format where [color=xyz]text, bla bla[/color] changes the color
	# as of now all bots have the same text color, in the future we could change this
	chatLog.bbcode_text += '[color=' + color + ']'  + username + ': ' 
	chatLog.bbcode_text +=  text
	chatLog.bbcode_text += '[/color]'


func text_entered(text):
	
	if text != '':
		username = players['player']['name']
		color = players['player']['color']
		add_message(username, text, color) # add message to the chatlog
		inputField.text = ''  # clear input field
		
		# get the party guest, and the corresponding prompt
		partyGuest = get_parent().get_parent().get_parent()
		username = partyGuest.guest_name
		color = players['bot']['color']
		
		# TODO: implement prompt design for party guests
		# promt = partyGuest.prompt
		prompt = background_info + "\n"
		prompt += "you are talking to " + username
		prompt += chatLog.text + "\n" 
		prompt += username + ": "
		print(prompt)
		
		# send prompt to api and wait for answer signal
		request_answer(prompt)
		yield(self, "request_finished")
		
		# add answer to the chat
		add_message(username, answer, color)


func _ready():
	inputField.connect("text_entered", self, "text_entered")
	$HTTPRequest.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	
	
	
func request_answer(prompt):
	
	parameters = {
		"model": "text-davinci-002",
		"prompt": prompt,
		"temperature": 0.5,
		"max_tokens": 40,
		"frequency_penalty": 0.5,
		"presence_penalty": 0.0,
		"stop": ["you:"]
		}
		
	$HTTPRequest.request(url, ["Content-Type: application/json", api_key_request], true, HTTPClient.METHOD_POST, JSON.print(parameters))
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	# parse and extract answer
	var json = parse_json(body.get_string_from_utf8())
	# print(body.get_string_from_utf8())
	
	# catch errors in the response:
	if json.has("error"):
		# TODO: this should appear on the screen maybe. At least if it is a problem with the 
		# API key, such that we can inform the users if their API key has expired
		print("There was an error with parsing the request:")
		print(json["error"]["message"])
	else:
		answer = json['choices'][0]['text'].strip_edges(true, true)
	
	# signal that result has been yielded
	emit_signal("request_finished")
	
	

