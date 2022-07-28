class_name pee
 
extends Node2D
var wait_time = 6

func prerequisite(guest):
	print("thirst %s" %guest.thirst)
	
	
func heuristic():
	pass
	

func effect():
	
	return wait_time
