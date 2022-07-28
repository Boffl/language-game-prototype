class_name fight
 
extends Node2D
var wait_time = 8

func prerequisite(guest):
	print("thirst %s" %guest.thirst)
	
	
func heuristic():
	pass
	

func effect():
	pass
	return wait_time
