extends KinematicBody2D

var drink_water = load("res://PartyGuest/Actions/drink_water.gd").new()
var drink_alc = load("res://PartyGuest/Actions/drink_alc.gd").new()
var eat = load("res://PartyGuest/Actions/eat.gd").new()
var dance = load("res://PartyGuest/Actions/dance.gd").new()
var leave = load("res://PartyGuest/Actions/leave.gd").new()
var vomit = load("res://PartyGuest/Actions/vomit.gd").new()
var talk = load("res://PartyGuest/Actions/talk.gd").new()
var pee = load("res://PartyGuest/Actions/pee.gd").new()

var actions = [drink_water, drink_alc, eat, dance, leave, vomit, pee]#, drink_alc, eat, dance, leave]
#var actions = [drink_alc]#, eat, dance, leave, vomit, pee]#, drink_alc, eat, dance, leave]
var best_r 
var best_a 
var reward
var new_guest 
var guest_dict
var action_dict
var dim_return
var str_action_dict = {"drink water": drink_water, "drink alcohol": drink_alc, 
							"eat": eat, "dance": dance, "leave": leave, "vomit": vomit, "Pee": pee,
							"pee": pee} # just because...


func best_act(guest, depth=1):#iterative deepening must be implemented
	
	best_r = -50
	best_a = false
	guest_dict = {"":[0, guest]}
	
	for i in depth:
		action_dict = {}
		for key in guest_dict:
			for action in actions:
				guest = guest_dict[key][1]
				if action.prerequisite(guest):
					reward = action.heuristic(guest) * ((10 - guest.past_actions.slice(0,10).count(best_a)) / 10) #diminishing return, the more a guest performs an action the less fun it is
					new_guest = guest.duplicate()
					new_guest.transfer_attributes(guest)
					#print(guest.thirst, "\t", new_guest.thirst)
					action.effect(new_guest)
					#print(guest.thirst, "\t", new_guest.thirst)
					action_dict[key + action.action_name + ","] = [reward, new_guest]
		guest_dict = action_dict
	for key in guest_dict:
		if guest_dict[key][0] > best_r:
			best_a = key.split(",")[0]
			best_r = guest_dict[key][0]
	#print(str_action_dict[best_a])
	return str_action_dict[best_a]
		#add rewards
		#copy guest
		#effect

	
	
func talk_to_all(guest):
	#print(guest.like_other_guest)
	for other_guest in guest.like_other_guest:
		reward = talk.heuristic(guest, other_guest) * ((20 - guest.past_actions.slice(0,20).count(talk)) / 20) #diminishing return, the more a guest performs an action the less fun it is
		if reward > best_r:
			best_r = reward
			best_a = talk

			


func best_action(guest):
	best_r = -50
	best_a = false
	var best_talk
	for action in actions:
		#print("%s %s" %[action.action_name, action.heuristic(guest)])
		if action.prerequisite(guest):
			dim_return = (20 - guest.past_actions.slice(0,20).count(action.action_name))/float(20)
			reward = action.heuristic(guest) * dim_return #diminishing return, the more a guest performs an action the less fun it is
			#print(stepify(action_heuristic,0.01),"\t", action.action_name)
			if reward > best_r:
				best_r = reward
				best_a = action 
	#talk_to_all(guest)
	
	guest.past_actions.append(best_a.action_name)

	#best_a.effect(guest)
	#print(guest.guest_name, "\t", guest.past_actions.slice(0,20))
	#print(guest.prompt)
	best_a.prompt_add(guest)
	guest.prompt_update()
	#print(guest.prompt)
	return best_a
