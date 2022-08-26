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
#var actions = [leave]#, eat, dance, leave, vomit, pee]#, drink_alc, eat, dance, leave]
var best_r 
var best_a 
var reward
var new_guest 
var guest_dict
var action_dict
var dim_return
var rewards_actions

var str_action_dict = {"drink water": drink_water, "drink alcohol": drink_alc,
							"eat": eat, "dance": dance, "leave": leave, "vomit": vomit, "talk":talk, "pee":pee}


func best_action(guest):
	#next line for debug
	rewards_actions = []
	
	best_r = -50
	best_a = false
	var best_talk
	for action in actions:
		#print("%s %s" %[action.action_name, action.heuristic(guest)])
		if action.prerequisite(guest):
			dim_return = ((5 - guest.past_actions.slice(0,5).count(action.action_name)) / 5)
			reward = action.heuristic(guest) * dim_return #diminishing return, the more a guest performs an action the less fun it is
			#print(stepify(action_heuristic,0.01),"\t", action.action_name)
			rewards_actions.append("%s: %s" %[action.action_name, reward])
			if reward > best_r:
				best_r = reward
				best_a = action 
	talk_to_all(guest)
	guest.past_actions.append(best_a.action_name)
	best_a.prompt_add(guest)
	guest.prompt_update()

	#Debug stuff
	print(rewards_actions)
	print(guest.guest_name, ":\t",guest.past_actions)
	return best_a


func talk_to_all(guest):
	for other_guest in guest.like_other_guests():
		if guest != other_guest:
			var guest_sim = cosine_sim(guest.attr_vec, other_guest.attr_vec)
			#print("guest_sim:", guest_sim)
			reward = (guest_sim*0.1 + talk.heuristic(guest, other_guest)) * ((5 - guest.past_actions.slice(0,5).count(talk.action_name)) / 5) #diminishing return, the more a guest performs an action the less fun it is
			rewards_actions.append("%s: %s" %[talk.action_name, reward])
			if reward > best_r:
				best_r = reward
				best_a = talk

func vec_len(vec):
	"""Calculate vector length. Vector should be in format: [x, y, z,...]"""
	var res = 0
	for dim in vec:
		res += pow(dim,2)
	return sqrt(res)

func dot_prod(vec1, vec2):
	"""Calculate the Dot Product ot two vectors. Vectors should be in format: [x, y, z,...]"""
	var res = 0
	var index = 0
	for dim in vec1:
		res += vec1[index] * vec2[index] 
		index += 1
	return res

func cosine_sim(vec1, vec2):
	var base = vec_len(vec1) * vec_len(vec2)
	if base == 0:
		base += 0.001
	return dot_prod(vec1, vec2)/base




