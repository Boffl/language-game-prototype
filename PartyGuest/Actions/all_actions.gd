extends KinematicBody2D

var drink_water = load("res://PartyGuest/Actions/drink_water.gd").new()
var drink_alc = load("res://PartyGuest/Actions/drink_alc.gd").new()
var eat = load("res://PartyGuest/Actions/eat.gd").new()
var dance = load("res://PartyGuest/Actions/dance.gd").new()
var leave = load("res://PartyGuest/Actions/leave.gd").new()
var vomit = load("res://PartyGuest/Actions/vomit.gd").new()

var actions = [drink_water, eat, drink_alc, vomit]#, drink_alc, eat, dance, leave]

func best_action(guest, depth=1):#iterative deepening must be implemented
	var best_r = -50
	var best_a = false
	for action in actions:
		print("%s %s" %[action.action_name, action.heuristic(guest)])
		if action.prerequisite(guest):
			if action.heuristic(guest) > best_r:
				best_r = action.heuristic(guest)
				best_a = action
	print("best action for %s is %s" %[guest.bot_name, best_a.action_name])
	best_a.effect(guest)
	return best_a
