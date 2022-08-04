class_name dance
 
extends Node2D

var action_name = "dance"
var wait_time = 10

func prerequisite(partyGuest):
	#print("thirst %s" %partyGuest.thirst)
	return true
	
func heuristic(partyGuest):
	return partyGuest.like_to_dance  #TODO: like music thats playing
	

func effect(partyGuest):
	partyGuest.bored -= 0.1
	partyGuest.tiredness += 0.02
	return wait_time

func prompt_add(guest):
	guest.prompt += " %s danced for a while." %[guest.guest_name]
