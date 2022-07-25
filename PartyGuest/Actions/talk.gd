class_name talk
 
extends Node2D

var action_name = "talk"

func prerequisite(guest):
	return guest.have_food > 0
	
	
func heuristic(guest, other_guest):
	return guest.sociability + guest.like_other_agent[other_guest]
	

func effect(guest):
	#print("%s boredom before talking:  %s" %[guest.bot_name, guest.bored])
	guest.bored -= 0.5

	#print("%s boredom after talking:  %s" %[guest.bot_name, guest.bored])
