class_name leave
 
extends Node2D

var action_name = "leave"
var wait_time = 1

func prerequisite(guest):
	return true
	
	
func heuristic(guest):
<<<<<<< HEAD
	return discomfort(guest) * 0.2
=======
	return discomfort(guest) * 0.05
>>>>>>> 9b6a2058fd69ffd895862d4f2a567ecf26453e60
	

func effect(guest):
	#print("agent left")
	guest.present = false
	return wait_time

func discomfort(guest):
	return guest.tiredness + guest.hunger + guest.thirst + guest.bored
	
func prompt_add(guest):
	guest.prompt += " %s left." %[guest.guest_name]
