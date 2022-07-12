extends KinematicBody2D


""" Constants """


const MAX_SPEED = 150
const ACCELERATION = 1000
const FRICTION = 2000

var velocity = Vector2.ZERO
var response = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	# Called at every computation step
	walking(delta)
	
	
func walking(delta):
	# input_vector: returns in what direction player wants to move in
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# MOVEMENT
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	# STOPPING
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide(velocity)
	

func interacting(delta):
	var bodies = get_node("TalkingArea").get_overlapping_areas()
	if bodies != []:
		if Input.is_action_just_pressed("ui_accept"):
			print("Let's talk!")
			
		
