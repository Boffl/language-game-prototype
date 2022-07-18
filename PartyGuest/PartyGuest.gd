extends KinematicBody2D






# Declare member variables here. Examples:

# Values are filled individually in in the initialization
onready var chatBox = get_node("PartyGuestArea/CanvasLayer/ChatBox")

# list of lists of all past conversations
var past_conversations = []


var bot_name
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
	bot_name = names[index]
	
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

func _physics_process(_delta):
	hunger += 0.00001
	thirst += 0.00001
	intoxication -= 0.00001
	tiredness += 0.000001


func start_conversation():
	get_node("PartyGuestArea/CanvasLayer").add_child(chatBox)

	
func end_conversation():
	past_conversations.append(get_node("PartyGuestArea/CanvasLayer/ChatBox").chat_log)
	
	# calculate sentiment of conversation or something
	
	get_node("PartyGuestArea/CanvasLayer").remove_child(chatBox)


