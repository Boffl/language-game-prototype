class_name pee
 
extends Node2D
var wait_time = 10

var action_name = "Pee"

func prerequisite(guest):
	return true
	
	
func heuristic(guest):
	return guest.need_to_pee
	

func effect(guest):
	
	return wait_time
