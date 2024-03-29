class_name eat
 
extends Node2D

var action_name = "eat"
var wait_time = 3

func prerequisite(guest):
	return guest.have_food > 0
	
	
func heuristic(guest):
	return guest.hunger + guest.intoxication/10
	

func effect(guest):
	if guest.hunger > 0.5:
		guest.hunger -= 0.5
	else:
		guest.hunger = 0
	if guest.intoxication > 0.05:
		guest.intoxication -= 0.05
	else:
		guest.intoxication = 0.5
	guest.have_food -= 1
	return wait_time

func prompt_add(guest):
	guest.prompt += " %s ate something." %[guest.guest_name]
