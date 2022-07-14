extends Node2D

var party_guest = preload("res://PartyGuest/PartyGuest.tscn")
var bots

func inivte_guests(num):
	
	for n in num:
		var bot = party_guest.instance()
		
		bot.init_bot()
		print(bot.bot_name)
		# choose a random location on path2D
		var bot_spawn_location = get_node("YSort/BotPath/BotSpawnLocation")
		bot_spawn_location.offset = randi()
		
		# set the bot's position to a random location
		bot.position = bot_spawn_location.position
		# add to a group to find them easily
		bot.add_to_group('bots')
		
		get_node("YSort").add_child(bot)
	

func _ready():
	randomize()
	inivte_guests(5)
	bots = get_tree().get_nodes_in_group("bots")
	bots[0].do_somethin()
	
	# set nr of guests
	get_node("Camera/StatsLabel").set_text("NR OF GUESTS: " + str(5))
	

