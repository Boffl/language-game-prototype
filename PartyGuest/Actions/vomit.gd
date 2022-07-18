class_name vomit
 
extends Node2D
var action_name = "vomit"

func prerequisite(guest):
	return guest.intoxication > 0.9
	
func heuristic(guest):
	return 10
	
func effect(guest):
	print("%s left because they vomited" %guest.bot_name)
	guest.present = false
