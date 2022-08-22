extends KinematicBody2D


""" Preloading Sprites"""

var partyguest_sprites = [preload("res://Assets/PartyGuest/PartyGuest1.png"),
							preload("res://Assets/PartyGuest/PartyGuest2.png"),
							preload("res://Assets/PartyGuest/PartyGuest3.png")]
							



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

var velocity = Vector2.ZERO
var max_speed = rand_range(1200, 1300)

var possible_targets = ["Toilet", "WaterTable", "TestBeacon", "TestBeacon2", "WaterTable2"] # names of all the furniture items PartyGuest can target

var activity_message = ""
var timer_activity
var target_object = "" # type of target that PartyGuest is targeting (from possible_targets)
var path =  [] # path that PartyGuest follows is stored here

var possible_target_groups = ["watertables", "toilets", "false_group"] # group names of the furniture items

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
var like_other_guest # {} #TODO
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


#for cosine similarity


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
var labels = ["drink water", "drink alcohol", "eat", "dance", "leave", "pee"]
""" Steering"""

var ray_directions = []


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
	
	# MOVEMENT
	if can_move and target_object != "":
		#target_coordinates = get_parent().get_node("Furniture/" + target_object).position
		move_to(_delta, coordinates_of_target(target_object))
	elif can_move and target_object == "":
		wander()

	# UPDATING STATS
	hunger += 0.000001
	thirst += 0.000001
	intoxication -= 0.00001
	tiredness += 0.000001
	need_to_pee += 0.00001



""" Everything for Interacting with Objects """

func _on_PartyGuestArea_area_entered(area):
	""" Used for performing an action """

	var interaction_object = area.get_parent()
	
	# checks if the object is of the target type, then starts activity
	if interaction_object.is_in_group(target_object):
		start_activity(interaction_object)


func _on_PartyGuestArea_area_exited(area):
	if not area.get_parent().is_in_group("bots") or area.get_parent().is_in_group("Player"):
		get_node("PartyGuestStats").set_text("")	


func start_activity(interaction_object):
	""" For interacting with Furniture """
	var current_action = all_actions.str_action_dict[next_action]
	var message = ""
	var wait_time = 0
	
	# Exit: Leave the Party
	if interaction_object.is_in_group("exits"):
		print("Leaving")
		self.queue_free()
	
	# WaterTable
	if interaction_object.is_in_group("watertables"):
		message = guest_name + " is having a drink."
		wait_time = current_action.effect(self)

	# Toilet
	if interaction_object.is_in_group("toilets"):
		message = guest_name + " is going to the toilet."
		wait_time = current_action.effect(self)
	
	#FoodTable
	if interaction_object.is_in_group("foodtables"):
		message = guest_name + " is eating something."
		wait_time = current_action.effect(self)
	
	#DanceFloor
	if interaction_object.is_in_group("dancefloors"):
		message = guest_name + "is dancing."
		wait_time = current_action.effect(self)

	if interaction_object.is_in_group("player"):
		wait_time = current_action.effect(self)
		message = guest_name + " wants to " + current_action.action_name + "."
	
	
	if wait_time != 0:
		can_move = false
		get_node("ActivityTimer").wait_time = wait_time
		get_node("ActivityTimer").start()
	
	
	get_node("PartyGuestStats").set_text(message)
	





func _on_ActivityTimer_timeout():
	can_move = true
	new_action(all_actions.best_action(self).action_name)

	



func new_action(action_name):
	next_action = action_name
	if action_name == "drink water" or action_name == "drink alcohol":
		target_object = 'watertables'
	elif action_name == "vomit":
		target_object = 'toilets'
	elif action_name == "dance":
		target_object = "dancefloors"
	elif action_name == "leave":
		target_object = 'exits'
	else:
		target_object = 'player'
	
	#target_object = possible_target_groups[randi() % len(possible_target_groups)]
	
	
func wander():
	""" Makes Party Guest wander around """
	pass
	
	
	
func coordinates_of_target(group_name):
	""" Given a furniture group name, picks an object from that category and returns coordinates """
	
	var objects_in_group = get_tree().get_nodes_in_group(group_name)
	var closest_object
	
	# checks if there are any objects in the group
	if objects_in_group.size() > 0:
		closest_object = objects_in_group[0]
		# checks which possible object is closest (in absolute distance)
		for object in objects_in_group:
			if object.position.distance_to(self.position) < closest_object.position.distance_to(self.position):
				closest_object = object
		return closest_object.position
	
	# if there's no object in that group, it starts chasing the Player (just for fun lol)
	else:
		return get_parent().get_node("Player").position


func move_to(delta, target_coordinates):
	""" Pathfinding + Movement for the PartyGuests """
	
	# calculate path to target coordinates
	var path = get_parent().get_parent().get_node("Navigation2D").get_simple_path(self.position, target_coordinates)
	LinePath.points = path

	
	var distance_to_walk = max_speed * delta
	# following the path
	
	
	if path.size() > 1:
		var direction = self.position.direction_to(path[1])
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
	get_node("PartyGuestArea/CanvasLayer").add_child(chatBox)
	get_node("PartyGuestArea/CanvasLayer/ChatBox/VBoxContainer/HBoxContainer/LineEdit").grab_focus() # makes it possible to start typing immediately

	
func end_conversation():
	# past_conversations.append(get_node("PartyGuestArea/CanvasLayer/ChatBox").chat_log)
	# calculate sentiment of conversation or something
	classify_conversation(4)

	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)


func classify_conversation(var num):
	#  classify the conversation and choose an action
	# :param num: number of sentences to use (e.g. num=4 for using the last 4)
	
	if GlobalSettings.testing_mode:
		print("you are in testing mode, will chose action randomly")
		label = labels[randi() % labels.size()]
	
	else:
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
			sentences.append(all_sentences[-i])
		text = "" # empty variable
		for i in count:
			# turning it around (before in the array the sentences are in backwards order
			text += sentences[count-i-1] + "\n"
		
		text += "After the conversation " + guest_name + "went to "
		
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
		print("in the dict")
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




func do_somethin():
	pass
	# print('player is talking to %s thirst: %s hunger: %s' % [bot_name, thirst, hunger])

func init_bot():
	"""intialize the guests attributes"""
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	#name randomly chosen from a name list
	var file = File.new()
	file.open("res://data/names.res", File.READ)
	var names = str2var(file.get_as_text())
	file.close()
	var index = rng.randi_range(0, len(names) - 1)
	guest_name = names[index]
	

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
	sociability = rng.randf_range(0,1)
	age = rng.randi_range(18, 40)
	like_to_play = rng.randf_range(0,1)
	like_to_drink = rng.randf_range(0,1.2)
	aggression = rng.randf_range(0,1)
	like_other_guest = {} 
	like_to_dance = rng.randf_range(0,1)
	character = rng.randf_range(0,1)
	attr_vec = [like_to_dance, like_to_drink, like_to_play, age, sociability, intoxication]

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
	like_other_guest = other_guest.like_other_guest
	like_to_dance = other_guest.like_to_dance
	
	
func prompt_init():
	var file = File.new()
	file.open("res://data/adjectives.res", File.READ)
	var adjectives = str2var(file.get_as_text())
	file.close()
	#print("sociability", adjectives["sociability"])
	prompt = "%s was at a party with some friends. The party was hosted by %s. "  %[guest_name, host_name] 
	prompt += "%s was a %s person. " %[guest_name, map_to_index(adjectives["sociability"], sociability)]
	prompt += "Most people said that %s was %s, and usually %s." % [guest_name, map_to_index(adjectives["character"], character), map_to_index(adjectives["aggression"], aggression)]
	#print(get_node("Party").hour)
	return prompt

func map_to_index(list, _float):
	return list[int(len(list) * _float)]
	
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
	
			
		
