class_name drink_water
 
extends Node2D

var action_name = "drink water"
var wait_time = 5

func prerequisite(guest):
	return guest.have_water > 0
	
	
func heuristic(guest):
	return guest.thirst
	

func effect(guest):
	guest.thirst -= 0.5
	guest.intoxication -= 0.5
	guest.have_water -= 1
	guest.need_to_pee += 0.001
	#print(guest.thirst)
	return wait_time
