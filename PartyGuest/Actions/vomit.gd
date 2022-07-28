class_name vomit
 
extends Node2D
var action_name = "vomit"
var wait_time = 6

func prerequisite(guest):
	return guest.intoxication > 0.9
	
func heuristic(guest):
	return 10
	
func effect(guest):
	print("%s left because they vomited" %guest.guest_name)
	guest.present = false
	return wait_time
