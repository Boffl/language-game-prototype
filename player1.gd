extends KinematicBody2D

const SPEED = 200

var velocity = Vector2(0,0)
func _physics_process(_delta):
	if Input.is_action_pressed("right"):
			velocity.x = SPEED
	elif Input.is_action_pressed("left"):
			velocity.x = -SPEED
	else:
		velocity.x = 0

		
	if Input.is_action_pressed("up"):
		# Note, idk, why but to work correctly here it needs to be negaitve speed
		# I have not figured out why this is the case
			velocity.y = -SPEED
	elif Input.is_action_pressed("down"):
			velocity.y = SPEED
	else:
		velocity.y = 0
	velocity = move_and_slide(velocity)

func _ready():
	pass
