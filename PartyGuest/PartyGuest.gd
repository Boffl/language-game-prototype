extends KinematicBody2D


""" Preloading Sprites"""

var partyguest_sprites = [preload("res://Assets/PartyGuest/PartyGuest1.png"),
							preload("res://Assets/PartyGuest/PartyGuest2.png"),
							preload("res://Assets/PartyGuest/PartyGuest3.png")]
							



# Values are filled individually in in the initialization
onready var chatBox = get_node("PartyGuestArea/CanvasLayer/ChatBox")

# list of lists of all past conversations
var past_conversations = []

# simple boolean, to stop movement, when talking
# movement is not yet implemented, but just to be consistent with the Player script
var can_move = true 

var velocity
var reaction_time = 100
var max_speed = rand_range(20, 30)

var path =  []
var target_coordinates = ''
var target_object = "TestBeacon"
var timer_activity
var timer_doing_activity
var activity_message = ""

var possible_targets = ["Toilet", "WaterTable", "TestBeacon", "TestBeacon2", "WaterTable2"]

onready var LinePath = Line2D.new()

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
var like_other_agent # {} #TODO
# _init with arguments is not allowed here, see:
# https://github.com/godotengine/godot/issues/15866


func _ready():
	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)
	
	# pick a random texture for the PartyGuest
	get_node("Sprite").set_texture(partyguest_sprites[randi() % len(partyguest_sprites)])
	
	# spawn in path for PartyGuest
	get_parent().get_parent().add_child(LinePath)
	LinePath.set_default_color(Color(1, 0.5, 0.5, 0.7))
	LinePath.set_width(5)
	
	timer_activity = Timer.new()
	timer_activity.set_wait_time(rand_range(5, 10))
	timer_activity.set_one_shot(false)
	timer_activity.connect("timeout", self, "_on_timer_repetition")
	self.add_child(timer_activity)
	timer_activity.start()
	
	get_node("PartyGuestStats").set_text("")
	
	

func _physics_process(_delta):
	
	# PICKS NEW TARGET EVERY 5-10 seconds
	# MOVEMENT
	if can_move and target_object != "":
		target_coordinates = get_parent().get_node("Furniture/" + target_object).position
		move_to(_delta, target_coordinates)
	
	if get_node("PartyGuestArea").get_overlapping_areas().size() == 0:
		get_node("PartyGuestStats").set_text("")
	

	
	
	# UPDATING STATS
	hunger += 0.00001
	thirst += 0.00001
	intoxication -= 0.00001
	tiredness += 0.000001

""" Everything for Interacting with Objects """

func _on_PartyGuestArea_area_entered(area):
	var interaction_object = area.get_parent()
	if interaction_object.is_in_group('toilets'):
		start_activity("going to the toilet.")
	elif interaction_object.is_in_group('watertables'):
		start_activity("having a drink.")


func _on_timer_repetition():
	target_object = possible_targets[randi() % len(possible_targets)]



func start_activity(message):
	get_node("PartyGuestStats").set_text(guest_name + " is " + message)
	print("Done")

	
	
	


func set_path(target_object):
	pass


func move_to(delta, target_coordinates):
	""" Pathfinding + Movement for the PartyGuests """
	

	# not finished yet :0
	path = get_parent().get_parent().get_node("Navigation2D").get_simple_path(self.position, target_coordinates)
	LinePath.points = path
	

	var distance_to_walk = max_speed * delta
	# Move the player along the path until he has run out of movement or the path ends.
	
	while distance_to_walk > 0 and path.size() > 0:
		var distance_to_next_point = position.distance_to(path[0])
		if distance_to_walk <= distance_to_next_point:
			# The player does not have enough movement left to get to the next point.
			position += position.direction_to(path[0]) * distance_to_walk
		else:
			# The player get to the next point
			position = path[0]
			path.remove(0)
		# Update the distance to walk
		distance_to_walk -= distance_to_next_point
		
	
	#velocity = target_coordinates - self.position
	#move_and_slide(velocity * delta * max_speed)







func do_somethin():
	pass
	# print('player is talking to %s thirst: %s hunger: %s' % [bot_name, thirst, hunger])

func init_bot():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	#name
	var file = File.new()
	file.open("res://data/names.res", File.READ)
	var names = str2var(file.get_as_text())
	file.close()
	var index = rng.randi_range(0, len(names) - 1)
	guest_name = names[index]
	
	present = true
	thirst = 0
	hunger = 0
	intoxication = 0
	tiredness = 0
	bored = 0
	have_alcohol = 100
	have_water = 100
	have_food = 100
	location = 0
			# this is changed after the apartment is initialized
	sociability = rng.randf_range(0,1)
	age = rng.randi_range(18, 40)
	like_to_play = rng.randf_range(0,1)
	like_to_drink = rng.randf_range(0,1.2)
	aggression = rng.randf_range(0,1)
	like_other_agent # {} #TODO



func start_conversation():
	get_node("PartyGuestArea/CanvasLayer").add_child(chatBox)
	get_node("PartyGuestArea/CanvasLayer/ChatBox/VBoxContainer/HBoxContainer/LineEdit").grab_focus() # makes it possible to start typing immediately

	
func end_conversation():
	# past_conversations.append(get_node("PartyGuestArea/CanvasLayer/ChatBox").chat_log)
	
	# calculate sentiment of conversation or something
	
	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)



