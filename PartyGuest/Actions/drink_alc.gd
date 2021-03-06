class_name drink_alc
 
extends Node2D

var action_name = "drink alcohol"
var wait_time = 4

func prerequisite(guest):
	return guest.have_alcohol > 0
	
	
func heuristic(guest):
	return guest.like_to_drink - guest.intoxication
	

func effect(guest):
	#print("intoxication before eating %s" %guest.intoxication)
	guest.have_alcohol -= 1
	guest.intoxication += 0.1
	guest.tiredness -= 0.01
	guest.thirst += 0.01
	#print("intoxication after eating %s" %guest.intoxication)
	return wait_time
