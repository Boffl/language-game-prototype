class_name leave
 
extends Node2D

func prerequisite(guest):
	return true
	
	
func heuristic(guest):
	return guest.bored
	

func effect(guest):
	guest.present = false
	print(guest.present)
