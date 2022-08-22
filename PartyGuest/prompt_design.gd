extends Node
var prompt




func prompt_init(PartyGuest):
	var file = File.new()
	file.open("res://data/adjectives.res", File.READ)
	var adjectives = str2var(file.get_as_text())
	file.close()
	#print(adjectives["aggression"])
	prompt = "My name is %s and I am %s years old. "  %[PartyGuest.guest_name, PartyGuest.age]
	prompt += "This evening I am at a party, hosted by my friend Hostname."
	PartyGuest.prompt = prompt
	
func fun():
	return 2
