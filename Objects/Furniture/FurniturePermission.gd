extends StaticBody2D



var free_to_use = true
export var max_nr_of_users = 3
var nr_of_current_users = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func toilet_in_use(party_guest_area):
	# check if toilet is in use by someone else
	var bodies = get_node("/root/Party/PrivacyArea").get_overlapping_areas()
	if bodies.size() > 1 and not party_guest_area in bodies:   # It will always overlap with the InteractionArea
		return true

func can_i_use():
	
	if max_nr_of_users < nr_of_current_users:
		nr_of_current_users += 1
		return true
	else:
		return false
	
