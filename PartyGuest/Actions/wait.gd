class_name wait
 
extends Node2D

var action_name = "wait"
var actionTime = 5

func prerequisite(guest):
	return true
	
	
func heuristic(guest):
	return 0
	

func effect(guest):
	#print("agent is waiting")
	guest.bored += 0.1
	return actionTime
