class_name leave
 
extends Node2D

var action_name = "leave"
var wait_time = 3

func prerequisite(guest):
	return true
	
	
func heuristic(guest):
	return guest.bored + guest.tiredness
	

func effect(guest):
	#print("agent left")
	guest.present = false
	return wait_time
