extends Node2D

# Time Variables
export (int) var second = 0 #16 * 360
export (int) var minute = 0
export (int) var hour = 0
var hour_str
var minute_str
var time_speed = 70


var party_guest = preload("res://PartyGuest/PartyGuest.tscn")
var bots
var best_a
var time_out
var num_guests


""" Pathfinding """
onready var walkable_tiles = get_node("Rooms/Navigation")
onready var pathfinding = get_node("Pathfinding")


func inivte_guests(num):

	for n in num:
		var bot = party_guest.instance()
		
		bot.init_bot()
		#best_action(bot)
		#prompt_init.prompt_init(bot)
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
		
	#for g in get_tree().get_nodes_in_group("bots"):
	# 	g.like_other_bots(get_tree().get_nodes_in_group("bots"))


func _ready():
	randomize()
	inivte_guests(GlobalSettings.nr_of_guests)
	bots = get_tree().get_nodes_in_group("bots")
	#bots[0].do_somethin()
	
	# set nr of guests
	get_node("UI/StatsLabel").set_text("NR OF GUESTS: " + str(get_tree().get_nodes_in_group("bots").size()))

	


func _physics_process(delta):
	
	# update time
	second += int(floor(delta * time_speed))
	minute = second / 60 % 60
	hour = (second / 3600) % 24
	if hour < 10:
		hour_str = "0" + str(hour)
	else: hour_str = str(hour)
	if minute < 10:
		minute_str = "0" + str(minute)
	else: minute_str = str(minute)	
	# show time
	get_node("UI/StatsLabel").set_text(hour_str + ":" + minute_str)
	
	# Ending the game? 
	num_guests = get_tree().get_nodes_in_group("bots").size()
	if num_guests <= 2:
		# elapsed_time = [hour, minute, second]
		GlobalSettings.win_message = construct_lose_message()
		get_tree().change_scene("res://GameOver/GameOverScreen.tscn")
	
	elif hour >= 5:  # for debugging put minute >=5 or so
		GlobalSettings.win_message = construct_win_message()
		get_tree().change_scene("res://GameWon/GameWonScreen.tscn")


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
	
#	if bot.present:
#		best_action(bot)
#	else:
#		t.queue_free()


func construct_win_message():
	var message = ""
	message += "You invited " + str(GlobalSettings.nr_of_guests) + " guests and " + str(get_tree().get_nodes_in_group("bots").size()) + " stayed until the party ended. \n"
	message += str(get_tree().get_nodes_in_group("bots")[0].guest_name) + " and " + str(get_tree().get_nodes_in_group("bots")[1].guest_name) + " had a lot of fun. \n"
	
	return message


func construct_lose_message():
	var message = "Almost everyone has left left. \n"
	var num_guests_left = get_tree().get_nodes_in_group("bots").size()
	return message



func _on_StartButton_pressed():
	print("trying to reload scene")
	get_tree().reload_current_scene()
