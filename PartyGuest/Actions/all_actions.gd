extends KinematicBody2D

var drink_water = load("res://PartyGuest/Actions/drink_water.gd").new()
var drink_alc = load("res://PartyGuest/Actions/drink_alc.gd").new()
var eat = load("res://PartyGuest/Actions/eat.gd").new()
var dance = load("res://PartyGuest/Actions/dance.gd").new()
var leave = load("res://PartyGuest/Actions/leave.gd").new()
var vomit = load("res://PartyGuest/Actions/vomit.gd").new()
var talk = load("res://PartyGuest/Actions/talk.gd").new()


var actions = [drink_water, drink_alc, eat, dance, leave, vomit]#, drink_alc, eat, dance, leave]
var best_r 
var best_a 
var reward
var new_guest 
var guest_dict
var action_dict
	
var str_action_dict


func best_action(guest, depth=1):#iterative deepening must be implemented
	str_action_dict = {"drink water": drink_water, "drink alcohol": drink_alc, "eat": eat, "dance": dance, "leave": leave, "vomit": vomit}
	
	best_r = -50
	best_a = false
	guest_dict = {"":[0, guest]}
	
	for i in depth:
		action_dict = {}
		for key in guest_dict:
			print(key)
			for action in actions:
				guest = guest_dict[key][1]
				if action.prerequisite(guest):
					reward = action.heuristic(guest) * ((10 - guest.past_actions.slice(0,10).count(best_a)) / 10) #diminishing return, the more a guest performs an action the less fun it is
					new_guest = guest.duplicate()
					new_guest.transfer_attributes(guest)
					print(guest.thirst, "\t", new_guest.thirst)
					action.effect(new_guest)
					print(guest.thirst, "\t", new_guest.thirst)
					action_dict[key + action.action_name + ","] = [reward, new_guest]
		guest_dict = action_dict
	print(guest_dict)
	for key in guest_dict:
		if guest_dict[key][0] > best_r:
			best_a = key.split(",")[0]
			best_r = guest_dict[key][0]
	return str_action_dict[best_a]
		#add rewards
		#copy guest
		#effect

	
	
func talk_to_all(guest):
	for other_guest in guest.like_other_agent:
		if talk.heuristic(guest, other_guest) > best_r:
			best_r = talk.heuristic(guest, other_guest)
			best_a = talk
			
func sim_act(guest):
	for action in actions:
		#print("%s %s" %[action.action_name, action.heuristic(guest)])
		if action.prerequisite(guest):
			reward = action.heuristic(guest) * ((10 - guest.past_actions.slice(0,10).count(best_a)) / 10) #diminishing return, the more a guest performs an action the less fun it is
			#print(stepify(action_heuristic,0.01),"\t", action.action_name)
			if reward > best_r:
				best_r = reward
				best_a = action 

func best_act(guest):
	best_r = -50
	best_a = false
	var best_talk
	for action in actions:
		#print("%s %s" %[action.action_name, action.heuristic(guest)])
		if action.prerequisite(guest):
			reward = action.heuristic(guest) * ((10 - guest.past_actions.slice(0,10).count(best_a)) / 10) #diminishing return, the more a guest performs an action the less fun it is
			#print(stepify(action_heuristic,0.01),"\t", action.action_name)
			if reward > best_r:
				best_r = reward
				best_a = action 
	new_guest = guest.duplicate()
	#best_a.effect(guest_1)
	print(new_guest.guest_name, guest.guest_name)
	guest.past_actions.append(best_a)
	#print(best_a.action_name)
	var copy_guest = guest
	#copy_guest.guest_name = "bla"
	#print(copy_guest.guest_name, guest.guest_name)
	print(guest.guest_name, "\t", best_a.action_name)
	return best_a
