extends KinematicBody2D

var drink_water = load("res://PartyGuest/Actions/drink_water.gd").new()
var drink_alc = load("res://PartyGuest/Actions/drink_alc.gd").new()
var eat = load("res://PartyGuest/Actions/eat.gd").new()
var dance = load("res://PartyGuest/Actions/dance.gd").new()
var leave = load("res://PartyGuest/Actions/leave.gd").new()
var vomit = load("res://PartyGuest/Actions/vomit.gd").new()
var talk = load("res://PartyGuest/Actions/talk.gd").new()


var actions = [drink_water, eat, drink_alc, vomit, leave, dance]#, drink_alc, eat, dance, leave]
var best_r 
var best_a 
var action_heuristic
	
func best_action(guest, depth=1):#iterative deepening must be implemented
	best_r = -50
	best_a = false
	var best_talk
	for action in actions:
		#print("%s %s" %[action.action_name, action.heuristic(guest)])
		if action.prerequisite(guest):
			action_heuristic = action.heuristic(guest) * ((10 - guest.past_actions.slice(0,10).count(best_a)) / 10) #diminishing return, the more a guest performs an action the less fun it is
			#print(stepify(action_heuristic,0.01),"\t", action.action_name)
			if action_heuristic > best_r:
				best_r = action_heuristic
				best_a = action 
	#talk_to_all(guest)

	#print("best action for %s is %s" %[guest.bot_name, best_a.action_name])
	best_a.effect(guest)
	guest.past_actions.append(best_a)
	#print(best_a.action_name)
	var copy_guest = guest
	#copy_guest.guest_name = "bla"
	#print(copy_guest.guest_name, guest.guest_name)
	print(guest.guest_name, "\t", best_a.action_name)
	return best_a
	
func talk_to_all(guest):
	for other_guest in guest.like_other_agent:
		if talk.heuristic(guest, other_guest) > best_r:
			best_r = talk.heuristic(guest, other_guest)
			best_a = talk


