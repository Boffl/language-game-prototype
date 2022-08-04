class_name talk
 
extends Node2D

var action_name = "talk"
var wait_time = 11

func prerequisite(guest):
	return true
	
	
func heuristic(guest, other_guest):
	return (guest.sociability + guest.like_other_guest[other_guest]) * 0.5
	

func effect(guest):
	#print("%s boredom before talking:  %s" %[guest.bot_name, guest.bored])
	guest.bored -= 0.5

	#print("%s boredom after talking:  %s" %[guest.bot_name, guest.bored])
	return wait_time

func prompt_add(guest):
	guest.prompt += " %s talked to %s for a while." %[guest.guest_name, "another guest"] #other guest
