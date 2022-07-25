class_name drink_water
 
extends Node2D

var action_name = "drink water"

func prerequisite(guest):
	return guest.have_water > 0
	
	
func heuristic(guest):
	return guest.thirst
	

func effect(guest):
	#print(guest.thirst)
	guest.thirst -= 0.5
	guest.intoxication -= 0.5
	guest.have_water -= 1
	#print(guest.thirst)
