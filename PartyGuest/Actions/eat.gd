class_name eat
 
extends Node2D

var action_name = "eat"

func prerequisite(guest):
	return guest.have_food > 0
	
	
func heuristic(guest):
	return guest.hunger
	

func effect(guest):
	guest.hunger -= 0.5
	guest.intoxication -= 0.05
	guest.have_food -= 1

