class_name leave
 
extends Node2D

var action_name = "leave"
var wait_time = 1

func prerequisite(guest):
	return true
	
	
func heuristic(guest):
	return guest.bored + guest.tiredness
	

func effect(guest):
	#print("agent left")
	guest.present = false
	return wait_time

func discomfort(guest):
	return guest.tiredness + guest.hunger + guest.thirst + guest.boredom
	
func prompt_add(guest):
	guest.prompt += " %s left." %[guest.guest_name]
