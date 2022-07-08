extends KinematicBody2D


# Declare member variables here. Examples:

# Values are filled individually in in the initialization
var personality
var bot_name

# _init with arguments is not allowed here, see:
# https://github.com/godotengine/godot/issues/15866


func do_somethin():
	print('player is talking to bot' + bot_name)


