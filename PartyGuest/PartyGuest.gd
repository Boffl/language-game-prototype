extends KinematicBody2D


""" Preloading Sprites"""

var partyguest_sprites = [preload("res://Assets/PartyGuest/PartyGuest_Sprites_1.png")]
							

onready var party_guest_area = get_node("PartyGuestArea")
onready var popup_node = get_node("DataCollection/Popup")

var leaving = false

var is_talking = false

var all_actions = load("res://PartyGuest/Actions/all_actions.gd").new()

# best action gets stored until either executed or abandoned
var next_action

var bot_name = "default"

# Values are filled individually in in the initialization
onready var chatBox = get_node("PartyGuestArea/CanvasLayer/ChatBox")

# list of lists of all past conversations
var past_conversations = []

# simple boolean, to stop movement, when talking
# movement is not yet implemented, but just to be consistent with the Player script
var can_move = true 

onready var animationTree = get_node("AnimationTree")
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var max_speed = rand_range(1200, 1300)

var possible_targets = ["Toilet", "WaterTable", "TestBeacon", "TestBeacon2", "WaterTable2"] # names of all the furniture items PartyGuest can target
var target_guest
var activity_message = ""
var timer_activity
var target_object = "" # type of target that PartyGuest is targeting (from possible_targets)
var path =  [] # path that PartyGuest follows is stored here

var possible_target_groups = ["watertables", "toilets", "foodtables", "false_group"] # group names of the furniture items

onready var LinePath = Line2D.new() # used for pathfinding
var host_name = "Nikolaj"



var guest_name # using just 'name' is not good, since it already an attribute in the namespace of the parent class
var present # True
var thirst # 0
var hunger # 0
var intoxication # 0
var tiredness # 0
var bored # 0
var have_alcohol # 100
var have_water # 100
var have_food # 100
var location # None
		# this is changed after the apartment is initialized
var sociability # random.uniform(0, 1)
var age # random.randint(18, 40)
var like_to_play # random.uniform(0, 1)
var like_to_drink # random.uniform(0, 1.2)
var aggression # random.uniform(0, 1)
var like_other_guests # {} #TODO
var character
# _init with arguments is not allowed here, see:
# https://github.com/godotengine/godot/issues/15866
var past_actions
var like_to_dance
var prompt = ""
var need_to_pee
var general_discomfort
var attr_vec
# _init with arguments is not allowed here, see:
# https://github.com/godotengine/godot/issues/15866
var new_action

#for cosine similarity


var animation_str = "Idle"


# for the classification
signal request_finished
var label

# for classification with GPT-3
var url = "https://api.openai.com/v1/completions"
var gpt3_key = GlobalSettings.api_key
var api_key_request = "Authorization: Bearer " + gpt3_key
var text = ""
var parameters = {}
# dictionary of tokens that are allowed as the answer
var logit_bias = {'4098': 100, '4483': 100, '270': 100, '1561': 100, '676': 100, '39463': 100, '296': 100, '5548': 100, '4144': 100, '47408': 100, '9280': 100, '67': 100, '7109': 100, '198': 100, '590': 100, '85': 100, '2666': 100, '16620': 100, '32638': 100, '1660': 100, '44542': 100}
# for testing_mode:
var labels = ["drink water", "drink alcohol", "eat", "dance", "leave", "pee", ""]
""" Steering"""

var ray_directions = []

var debug_variable

var characters = load_j()


func load_j():
	var file
	var path = "res://PartyGuest/Characters/characters.json"
	var data = {"hi": 1}
	file = File.new()
	file.open(path, File.READ)
	var d = file.get_as_text()
	d = parse_json(d)
	file.close()
	return d

func _ready():
	"""
	Called when PartyGuest enters the scene for the first time
	"""

	# (temporarily) remove ChatBox
	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)
	
	# pick a random texture for the PartyGuest
	get_node("Sprite").set_texture(partyguest_sprites[randi() % len(partyguest_sprites)])
	
	# set up Line in path for PartyGuest
	get_parent().get_parent().add_child(LinePath)
	LinePath.set_default_color(Color(1, 0.5, 0.5, 0.7))
	LinePath.set_width(5)
	
#	# timer for switching targets
#	timer_activity = Timer.new()
#	timer_activity.set_wait_time(rand_range(10, 20))
#	timer_activity.set_one_shot(false)
#	timer_activity.connect("timeout", self, "_on_timer_repetition")
#	self.add_child(timer_activity)
#	timer_activity.start()
	
	# empty the stats display text
	get_node("PartyGuestStats").set_text("")
	
	#initialize prompt
	prompt_init()
	
	new_action(all_actions.best_action(self).action_name)

	
	

func _physics_process(_delta):
	"""
	Updating Stats, Movement and Interaction Functions
	"""
	
	if can_move: # maybe have to put a different variable for doing an activity?
		if party_guest_area.get_overlapping_areas().size()>0:
			# this is a list of the overlapping areas. If there are multiple, the first will be
			# The area with the player, the second the one with the Interaction object and the third, fourth, etc
			# the one with other bots
			var areas = party_guest_area.get_overlapping_areas()
			
			if areas[0].get_parent().is_in_group(target_object):
				can_move = false 
				start_activity(areas[0].get_parent())
		
		# MOVEMENT
		if target_object != "":
			#target_coordinates = get_parent().get_node("Furniture/" + target_object).position
			move_to(_delta, coordinates_of_target(target_object))
		elif target_object == "":
			pass
			# wander()
	
	
	
	# ANIMATIONS
	animationTree.set("parameters/" + animation_str +"/blend_position", direction)
	
	
	
	# UPDATING STATS
	hunger += 0.00001
	thirst += 0.00001
	if intoxication > 0.00001:
		# to not have negative intoxication
		intoxication -= 0.00001
	tiredness += 0.0001
	bored += 0.00001
	need_to_pee += 0.00001


func start_activity(interaction_object):
	""" For interacting with Furniture """
	var current_action = all_actions.str_action_dict[next_action]
	var message = ""
	var wait_time = 0	
	# Exit: Leave the Party
	if interaction_object.is_in_group("exits"):
		self.queue_free()
	
	# WaterTable
	if interaction_object.is_in_group("watertables"):
		if current_action.action_name == "drink water":
			animation_str = "Drink"
			animationTree.get("parameters/playback").travel("Drink")
			message = guest_name + " is drinking water" # alc or water?
			wait_time = current_action.effect(self)
		elif current_action.action_name == "drink alcohol":
			animationTree.get("parameters/playback").travel("Drink")
			animation_str = "Drink"
			message = guest_name + " is having a drink" # alc or water?
			wait_time = current_action.effect(self)

	# Toilet
	if interaction_object.is_in_group("toilets"):
		if current_action.action_name == "pee":
			
			message = guest_name + " is going to the toilet."
			wait_time = current_action.effect(self)
		elif current_action.action_name == "vomit":
			message = guest_name + " is vomiting"
			wait_time = current_action.effect(self)
			
	#FoodTable
	if interaction_object.is_in_group("foodtables"):
		message = guest_name + " is eating something."
		wait_time = current_action.effect(self)
	
	#DanceFloor
	if interaction_object.is_in_group("dancefloors"):
		message = guest_name + " is dancing."
		wait_time = current_action.effect(self)

	if interaction_object.is_in_group("player"):
		wait_time = current_action.effect(self)
		message = guest_name + " wants to " + current_action.action_name + "."
	
	
	new_action = false 
	if wait_time != 0:
		# wait time is only zero when guest is leaving
		# TODO: fix the logic of the leave action? 
			# In a way that it can be used as the others
		get_node("ActivityTimer").wait_time = wait_time
		get_node("ActivityTimer").start()
	
	
	get_node("PartyGuestStats").set_text(message)
	

func _on_ActivityTimer_timeout():
	get_node("PartyGuestStats").set_text("Timer out")
	animation_str = "Idle"
	animationTree.get("parameters/playback").travel("Idle")
	if not is_talking:
		can_move = true
			
		get_node("PartyGuestStats").set_text("")
		# calculate new best action, call the new action function
		
		if not leaving and not new_action: 
			new_action(all_actions.best_action(self).action_name)


func new_action(action_name):
	# setting a target object for the new action
	get_node("PartyGuestStats").set_text("wants to " + action_name)
	new_action = true  # boolean to prevent calculating new best action before this
	# action is performed
	next_action = action_name
	if action_name == "drink water" or action_name == "drink alcohol":
		target_object = 'watertables'
	elif action_name == "vomit" or action_name == "pee":
		target_object = 'toilets'
	elif action_name == "dance":
		target_object = "dancefloors"
	elif action_name == "eat":
		target_object = "foodtables"
	elif action_name == "leave":
		get_node("PartyGuestStats").set_text(guest_name + " is leaving")
		leaving = true
		target_object = 'exits'
		get_node("Collision").disabled = true
	#else:target_object = 'player'
	print(action_name)
	
	#target_object = possible_target_groups[randi() % len(possible_target_groups)]
	
func get_random_guest(dict):
   return dict[randi() % dict.size()]


func wander():
	""" Makes Party Guest wander around """
	pass	
	
	
func coordinates_of_target(group_name):
	""" Given a furniture group name, picks an object from that category and returns coordinates """
	
	var objects_in_group = get_tree().get_nodes_in_group(group_name)
	var closest_object
	
	# checks if there are any objects in the group
	if objects_in_group.size() > 0:

		
		if objects_in_group[0].name == "Toilet":
			# check if there is someone in the toilet
			if objects_in_group[0].toilet_in_use(party_guest_area):
				# For now just wait, later wander maybe?
				return self.position  
			else:
				return objects_in_group[0].position
				
		else:
			closest_object = objects_in_group[0]
			# checks which possible object is closest (in absolute distance)
			for object in objects_in_group:
				if object.position.distance_to(self.position) < closest_object.position.distance_to(self.position):
					closest_object = object
			return closest_object.position
	
	# if there's no object in that group, it starts chasing the Player (just for fun lol)
	#elif target_object == 'guest':
	#	var convo_partner = target_guest
	#	if convo_partner in like_other_guests(): #Check if that person is still present
	#		return convo_partner.position
			
	#	else:
	#		return get_parent().get_node("Player").position
		
	#else:
	#	return get_parent().get_node("Player").position


func move_to(delta, target_coordinates):
	""" Pathfinding + Movement for the PartyGuests """
	
	# calculate path to target coordinates
	var path = get_parent().get_parent().get_node("Navigation2D").get_simple_path(self.position, target_coordinates)
	LinePath.points = path

	
	var distance_to_walk = max_speed * delta
	# following the path
	
	
	if path.size() > 1:
		direction = self.position.direction_to(path[1])
		var overlapping_bodies = get_node("PartyGuestArea").get_overlapping_bodies()
		
		# repells all bodies except the one in the target group
		if overlapping_bodies:
			if not overlapping_bodies[0].is_in_group(target_object):
				direction = direction.move_toward(direction - self.position.direction_to(overlapping_bodies[0].position), 50 * delta)
		
		velocity = direction * max_speed * delta

		move_and_slide(velocity)
	
	
	
	"""
	while distance_to_walk > 0 and path.size() > 1:
		var distance_to_next_point = position.distance_to(path[1]) 
		if distance_to_walk <= distance_to_next_point:
		# moves PartyGuest incrimentally to the next point
			position += position.direction_to(path[1]) * distance_to_walk
		# next point along the path is reached, the point is removed
		else:
			position = path[1]
			path.remove(1)
		distance_to_walk -= distance_to_next_point
		
	"""
		
""" ChatBox and ChatLog """
func start_conversation():
	is_talking = true
	can_move = false
	get_node("PartyGuestArea/CanvasLayer").add_child(chatBox)
	get_node("PartyGuestArea/CanvasLayer/ChatBox/VBoxContainer/HBoxContainer/LineEdit").grab_focus() # makes it possible to start typing immediately

	
func end_conversation():
	# past_conversations.append(get_node("PartyGuestArea/CanvasLayer/ChatBox").chat_log)
	# calculate sentiment of conversation or something
	var text = last_sentences() # take last sentences from the chabox
	data_collection(text)
	classify_conversation(text)
	is_talking = false
	can_move = true
	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)
	
	
func last_sentences(var num=4):
	# takes the last sentences from the chatbox
	var text = ""
	var all_sentences = chatBox.chatLog.text.split("\n")  
	var sentences = []
	# note this might give a problem if the model returns a \n
	# 	-> I tried this out and it does not seem to be a problem :)
	
	# choosing the last sentences, that are important for the classification
	var count
	if len(all_sentences)<num:
		count = len(all_sentences)
	else:
		count = num
	for i in count:
		sentences.append(all_sentences[-(i+1)])
	for i in count:
		# turning it around (before in the array the sentences are in backwards order
		text += sentences[count-i-1] + "\n"
	
	return text


func data_collection(var text):
	
	# put the text into the popup node
	popup_node.text = text
	# open the popup node
	popup_node.popup_centered_ratio(0.5)
	
	
func classify_conversation(var text):
	#  classify the conversation and choose an action
	# :param num: number of sentences to use (e.g. num=4 for using the last 4)
	
	if GlobalSettings.testing_mode:
		print("you are in testing mode, will chose action randomly")
		label = labels[randi() % labels.size()]
	
	else:
		
		text += "\nAfter the conversation " + guest_name + "went to "
		
		parameters = {
		"model": "text-davinci-002",
		"prompt": text,
		"temperature": 0.9,
		"max_tokens": 4,
		"frequency_penalty": 2,
		"presence_penalty": 0.2,
		"logit_bias": logit_bias,
		"stop": ["\""]
	}
		
		$HTTPRequest.request(url, ["Content-Type: application/json", api_key_request], true, HTTPClient.METHOD_POST, JSON.print(parameters))
		yield(self, "request_finished")
	
	
	print("Action from the conversation: ", label)

	if all_actions.str_action_dict.has(label):
		new_action(label)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
		# parse and extract answer
	var json = parse_json(body.get_string_from_utf8())

	# print(body.get_string_from_utf8())

	# catch errors in the response:
	if json.has("error"):
		# TODO: this should appear on the screen maybe. At least if it is a problem with the
		# API key, such that we can inform the users if their API key has expired
		label = "[color=#000000] There was an error with OpenAI: "
		label += json["error"]["message"] + "[/color]"
		print("There was an error with parsing the request:")
		print(json["error"]["message"])
	else:
		label = json['choices'][0]['text'].strip_edges(true, true)

		# signal that result has been yielded
	emit_signal("request_finished")


func init_bot():
	"""intialize the guests attributes"""
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var _names = ["Susanne", "Lisa", "Steven", "Martin", "Emily", "Samantha", "Emily", "Greta"]
	var index = rng.randi_range (0,characters.size() -1 )
	guest_name = _names[index]
	var character = characters[guest_name]
	#initialize variables that are same for all the guests
	present = true
	thirst = 0
	hunger = 0
	need_to_pee = 0
	intoxication = 0
	tiredness = 0
	bored = 0
	have_alcohol = 100
	have_water = 100
	have_food = 100
	location = 0# this is changed after the apartment is initialized
	past_actions = []
	
	#initialize variables that are different for all characters
	sociability = character.sociability
	age = character.age
	like_to_play = character.like_to_play
	like_to_drink = character.like_to_drink
	aggression = character.aggression
	like_other_guests = {} 
	like_to_dance = character.like_to_dance
	character =character.sociability
	attr_vec = [like_to_dance, like_to_drink, like_to_play, age, sociability]


func like_other_guests():
	return get_tree().get_nodes_in_group("bots")


func transfer_attributes(other_guest):
	"""Transfer all the attributes from a guest to another guest.
	this is usefull for simulation"""
	present = true
	thirst = other_guest.thirst
	hunger = other_guest.hunger
	intoxication = other_guest.intoxication
	tiredness = other_guest.tiredness
	bored = other_guest.bored
	have_alcohol = other_guest.have_alcohol
	have_water = other_guest.have_water
	have_food = other_guest.have_food
	location = other_guest.location
	past_actions = other_guest.past_actions
	
	#initialize variables that are different for all characters
	sociability = other_guest.sociability
	age = other_guest.age
	like_to_play = other_guest.like_to_play
	like_to_drink = other_guest.like_to_drink
	aggression = other_guest.aggression
	like_other_guests = other_guest.like_other_guests
	like_to_dance = other_guest.like_to_dance
	
	
func prompt_init():
	var file = File.new()
	file.open("res://data/adjectives.res", File.READ)
	var adjectives = str2var(file.get_as_text())
	file.close()
	prompt = "%s was an eccentric person. He was easily agitated and got angry frequently. " %[guest_name]
	prompt += " The people that knew him would often describe him as the worst person, they had ever met."
	prompt += " He would insult people without a reason and didn’t care for anyone."
	prompt += " His friends would describe him as a rude and eccentric person. He loved to drink and wreak havoc on any social situation."
	prompt = "None the less people would still invite him to parties and so it was. Steven was at a colleges home party and was already filled with chagrin."
	return prompt


func map_to_index(list, _float):
	var index = 0
	if index < _float:
		index = _float
	return list[int(len(list) * index)]


func prompt_update():
	"""update prompt to add current state of mind and biggest need"""
	var file = File.new()
	file.open("res://data/adjectives.res", File.READ)
	var adjectives = str2var(file.get_as_text())
	file.close()
	var need_adj = need(adjectives)
	prompt += " %s was %s and %s." %[guest_name, map_to_index(adjectives["intoxication"], intoxication), need_adj]


func need(adjectives):
	"""calculate biggest need. This information is used when updating the prompt"""
	var biggest_need = 0
	var attributes = [thirst, hunger, need_to_pee, bored]
	var attribute_names = ["thirst", "hunger", "need_to_pee", "bored"]
	for attribute in attributes:
		if attribute > biggest_need:
			biggest_need = attribute
	var index = attribute_names[attributes.find(biggest_need,0)]
	return map_to_index(adjectives[index], biggest_need)
	
			
		
