extends Area2D

onready var chatBox = get_node("ChatBox")


func _ready():
	self.remove_child(chatBox)


func _on_PartyGuestArea_body_entered(body):
	if body.name == "Player":
		# get the bot that the chat-box is connected to
		var bot = get_parent()
		bot.do_somethin()
		self.add_child(chatBox)


func _on_PartyGuestArea_body_exited(body):
	if body.name == "Player":
		self.remove_child(chatBox)
