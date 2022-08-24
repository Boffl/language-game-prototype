class_name dance
 
extends Node2D

var action_name = "dance"
var wait_time = 10

func prerequisite(guest):
	#print("thirst %s" %partyGuest.thirst)
	return true
	
func heuristic(guest):
	return guest.like_to_dance + guest.intoxication/10 #TODO: like music thats playing
	

func effect(guest):
	guest.bored -= 0.1
	guest.tiredness += 0.02
	return wait_time

func prompt_add(guest):
	guest.prompt += " %s danced for a while." %[guest.guest_name]
