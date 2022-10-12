extends KinematicBody2D

var drink_water = load("res://PartyGuest/Actions/drink_water.gd").new()
var drink_alc = load("res://PartyGuest/Actions/drink_alc.gd").new()
var eat = load("res://PartyGuest/Actions/eat.gd").new()
var dance = load("res://PartyGuest/Actions/dance.gd").new()
var leave = load("res://PartyGuest/Actions/leave.gd").new()
var vomit = load("res://PartyGuest/Actions/vomit.gd").new()
var pee = load("res://PartyGuest/Actions/pee.gd").new()

var actions = [drink_water, drink_alc, eat, dance, leave, vomit, pee]#, drink_alc, eat, dance, leave]

var best_r 
var best_a 
var reward
var new_guest 
var guest_dict
var action_dict
var dim_return
var rewards_actions

var str_action_dict = {"drink water": drink_water, "drink alcohol": drink_alc,
							"eat": eat, "dance": dance, "leave": leave, "vomit": vomit, "pee":pee}


func best_action(guest):
	#Calculates the action with the biggest expected reward for a guest
	rewards_actions = []
	best_r = -50
	best_a = false

	for action in actions:
		if action.prerequisite(guest):
			dim_return = ((5 - guest.past_actions.slice(-5,-1).count(action.action_name)) / 5)
			reward = action.heuristic(guest) * dim_return #diminishing return, the more a guest performs an action the less fun it is
			rewards_actions.append("%s: %s" %[action.action_name, reward])
			if reward > best_r:
				best_r = reward
				best_a = action 
	guest.past_actions.append(best_a.action_name)
	best_a.prompt_add(guest)
	guest.prompt_update()

	return best_a
