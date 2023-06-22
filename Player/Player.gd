extends KinematicBody2D


""" Constants """


const MAX_SPEED = 150
const ACCELERATION = 1000
const FRICTION = 2000

var velocity = Vector2.ZERO
var response = ""

var can_move = true  # simple boolean, to stop movement, when talking
var is_talking = false

var partyGuest
onready var animationTree = get_node("AnimationTree")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	get_node("InteractionLabel").hide()



func _physics_process(delta):
	# Called at every computation step
	walking(delta)
	interacting(delta)
	
	
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
	
	if can_move and input_vector != Vector2.ZERO:
		move_and_slide(velocity)
		var direction = input_vector
		animationTree.set("parameters/Idle/blend_position", direction)
	

func interacting(delta):
	var bodies = get_node("TalkingArea").get_overlapping_areas()
	if bodies.size() > 0 and bodies[0].get_parent().is_in_group('bots') \
	and not bodies[0].get_parent().leaving:
		
		get_node("InteractionLabel").show()
		
		# talking to the person
		if Input.is_action_just_pressed("ui_accept"):
			if not is_talking: # change the state only if not in state
				partyGuest = bodies[0].get_parent()
				is_talking = true
				can_move = false
				partyGuest.can_move = false
				get_node("InteractionLabel").set_text("press ESC to stop talking")
				
				partyGuest.start_conversation()
				print("Player is talking to " + partyGuest.guest_name)
		
		# cancel chatBox
		if Input.is_action_just_pressed("ui_cancel"):
			if is_talking:
				is_talking = false
				can_move = true
				partyGuest.end_conversation()
				# print("Player is no longer talking to " + partyGuest.guest_name)
				get_node("InteractionLabel").set_text("press SPACE to talk")
				# partyGuest.can_move = true Why was this here???
	
	# hide interaction label if not near any objects
	elif bodies.size() == 0:
		get_node("InteractionLabel").hide()
			
		
