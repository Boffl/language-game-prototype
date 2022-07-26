extends Node2D

var party_guest = preload("res://PartyGuest/PartyGuest.tscn")
var bots
var prompt_init = load("res://PartyGuest/prompt_design.gd").new()
var best_a
var time_out

func inivte_guests(num):

	for n in num:
		var bot = party_guest.instance()
		
		bot.init_bot()
		best_action(bot)
		prompt_init.prompt_init(bot)
		#print(bot.prompt)
		
		# print(bot.bot_name)
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
	get_node("UI/StatsLabel").set_text("NR OF GUESTS: " + str(get_tree().get_nodes_in_group("bots").size()))
	
	
func _physics_process(delta):
	
	# UPDATE STATS
	get_node("UI/StatsLabel").set_text("NR OF GUESTS: " + str(get_tree().get_nodes_in_group("bots").size()))
	

func best_action(bot):
	var actions = load("res://PartyGuest/Actions/all_actions.gd").new()
	best_a = actions.best_action(bot)
		# Create a timer node
	time_out = best_a.effect(bot)
	var t = Timer.new()
	t.set_wait_time(time_out)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	if bot.present:
		best_action(bot)
	else:
		t.queue_free()
	
