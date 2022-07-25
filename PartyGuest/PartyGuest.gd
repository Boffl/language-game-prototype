extends KinematicBody2D


""" Preloading Sprites"""

var partyguest_sprites = [preload("res://Assets/PartyGuest/PartyGuest1.png"),
							preload("res://Assets/PartyGuest/PartyGuest2.png"),
							preload("res://Assets/PartyGuest/PartyGuest3.png")]
							

var all_actions = load("res://PartyGuest/Actions/all_actions.gd").new()

# best action gets stored until either executed or abandoned
var best_action

var bot_name = "default"

# Values are filled individually in in the initialization
onready var chatBox = get_node("PartyGuestArea/CanvasLayer/ChatBox")

# list of lists of all past conversations
var past_conversations = []

# simple boolean, to stop movement, when talking
# movement is not yet implemented, but just to be consistent with the Player script
var can_move = true 

var velocity
var max_speed = rand_range(20, 30)

var possible_targets = ["Toilet", "WaterTable", "TestBeacon", "TestBeacon2", "WaterTable2"] # names of all the furniture items PartyGuest can target

var activity_message = ""
var timer_activity
var target_object = "" # type of target that PartyGuest is targeting (from possible_targets)
var path =  [] # path that PartyGuest follows is stored here

var possible_target_groups = ["watertables", "toilets", "false_group"] # group names of the furniture items

onready var LinePath = Line2D.new() # used for pathfinding

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
# _init with arguments is not allowed here, see:
# https://github.com/godotengine/godot/issues/15866
var past_actions
var like_to_dance
var prompt


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
	
	# timer for switching targets
	timer_activity = Timer.new()
	timer_activity.set_wait_time(rand_range(5, 10))
	timer_activity.set_one_shot(false)
	timer_activity.connect("timeout", self, "_on_timer_repetition")
	self.add_child(timer_activity)
	timer_activity.start()
	
	# empty the stats display text
	get_node("PartyGuestStats").set_text("")
	
	

func _physics_process(_delta):
	"""
	Updating Stats, Movement and Interaction Functions
	"""
	
	# MOVEMENT
	if can_move and target_object != "":
		#target_coordinates = get_parent().get_node("Furniture/" + target_object).position
		move_to(_delta, coordinates_of_target(target_object))
	

	# UPDATING STATS
	hunger += 0.00001
	thirst += 0.00001
	intoxication -= 0.00001
	tiredness += 0.000001



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
	
	var message = ""
	
	# WaterTable
	if interaction_object.is_in_group("watertables"):
		message = "having a drink."
		best_action.effect(self)
		
	
	# Toilet
	if interaction_object.is_in_group("toilets"):
		message = "going to the toilet."
		best_action.effect(self)
		
	
	get_node("PartyGuestStats").set_text(guest_name + " is " + message)
	
	


func _on_timer_repetition():
	
	best_action = all_actions.best_action(self)
	
	if best_action.action_name == "drink water" or "drink alcohol":
		target_object = 'watertables'
	elif best_action.action_name == "vomit":
		target_object = 'toilets'
	else:
		target_object = "none"
	
	
	#target_object = possible_target_groups[randi() % len(possible_target_groups)]
	
	


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
	path = get_parent().get_parent().get_node("Navigation2D").get_simple_path(self.position, target_coordinates)
	LinePath.points = path
	
	var distance_to_walk = max_speed * delta
	# following the path
	while distance_to_walk > 0 and path.size() > 0:
		var distance_to_next_point = position.distance_to(path[0]) 
		if distance_to_walk <= distance_to_next_point:
		# moves PartyGuest incrimentally to the next point
			position += position.direction_to(path[0]) * distance_to_walk
		# next point along the path is reached, the point is removed
		else:
			position = path[0]
			path.remove(0)
		distance_to_walk -= distance_to_next_point
		



""" ChatBox and ChatLog """

func start_conversation():
	get_node("PartyGuestArea/CanvasLayer").add_child(chatBox)
	get_node("PartyGuestArea/CanvasLayer/ChatBox/VBoxContainer/HBoxContainer/LineEdit").grab_focus() # makes it possible to start typing immediately

	
func end_conversation():
	# past_conversations.append(get_node("PartyGuestArea/CanvasLayer/ChatBox").chat_log)
	# calculate sentiment of conversation or something
	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)





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
	like_other_guest # {} #TODO
	like_to_dance = rng.randf_range(0,1)
	
func like_other_bots(bots):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for other_bot in bots:
		like_other_guest[other_bot] = rng.randf_range(0,1)




