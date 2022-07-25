class_name dance
 
extends Node2D

var action_name = "dance"

func prerequisite(partyGuest):
	#print("thirst %s" %partyGuest.thirst)
	return true
	
func heuristic(partyGuest):
	return partyGuest.like_to_dance  #TODO: like music thats playing
	

func effect(partyGuest):
	partyGuest.bored -= 0.1
	partyGuest.tiredness += 0.02
