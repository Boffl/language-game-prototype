class_name drink_water
 
extends Node2D

var action_name = "drink water"
var wait_time = 5

func prerequisite(guest):
	return guest.have_water > 0
	
	
func heuristic(guest):
	return guest.thirst
	

func effect(guest):
	if guest.thirst > 0.5:
		guest.thirst -= 0.5
	else:
		guest.thirst = 0
	if guest.intoxication > 0.5:
		guest.intoxication -= 0.5
	else:
		guest.intoxication = 0
	guest.have_water -= 1
	guest.need_to_pee += 0.002
	#print(guest.thirst)
	return wait_time

func prompt_add(guest):
	guest.prompt += " %s drank some water." %[guest.guest_name]
