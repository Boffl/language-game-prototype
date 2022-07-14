class_name drink_alc
 
extends Node2D

var action_name = "drink alcohol"

func prerequisite(guest):
	return guest.have_alcohol > 0
	
	
func heuristic(guest):
	return guest.like_to_drink - guest.intoxication
	

func effect(guest):
	print("hunger before eating %s" %guest.hunger)
	guest.have_alcohol -= 1
	guest.intoxication += 0.05
	guest.tiredness -= 0.01
	print("hunger after eating %s" %guest.hunger)
