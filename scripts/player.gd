extends CharacterBody3D

@onready var camera_mount = $cameraMount
@onready var animation_player = $Visuals/mixamo_base/AnimationPlayer
@onready var animation_tree = $Visuals/mixamo_base/AnimationTree
@onready var visualsNode = $Visuals



@export var blend_speed = 5
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.4

enum {IDLE, RUN, WALK, KICK}

const JUMP_VELOCITY = 4.5

var SPEED = 2.0
var curAnim = IDLE
var walking_speed = 2.0
var running_speed = 5.0
var run_val=0
var walk_val = 0
var idle_val = 0
var kick_val = 0
var running = false
var isLocked = false




func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visualsNode.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
func handle_animations(delta):
	match curAnim:
		IDLE:
			run_val = lerpf(run_val, 0, blend_speed*delta)
			walk_val = lerpf(walk_val, 0, blend_speed*delta)
			#kick_val = lerpf(kick_val, 0, blend_speed*delta)
		RUN:
			run_val = lerpf(run_val, 1, blend_speed*delta)
			walk_val = lerpf(walk_val, 0, blend_speed*delta)
			#kick_val = lerpf(kick_val, 0, blend_speed*delta)
		WALK:
			run_val = lerpf(run_val, 0, blend_speed*delta)
			walk_val = lerpf(walk_val, 1, blend_speed*delta)
			#kick_val = lerpf(kick_val, 0, blend_speed*delta)
		#KICK:
			#run_val = lerpf(run_val, 0, blend_speed*delta)
			#walk_val = lerpf(walk_val, 0, blend_speed*delta)
			#kick_val = lerpf(kick_val, 1, blend_speed*delta)
func update_tree():
	animation_tree["parameters/walk/blend_amount"] = walk_val
	animation_tree["parameters/run/blend_amount"] = run_val
func _physics_process(delta: float) -> void:
	# Add the gravity.
	handle_animations(delta)
	update_tree()
	if !animation_player.is_playing():
		isLocked = false
	if Input.is_action_just_pressed("attack") && is_on_floor():
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			isLocked = true

	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !isLocked:
			if !running:
				if animation_player.current_animation != "walking":
					#animation_player.play("walking")
					curAnim = WALK
					
			else:
				if animation_player.current_animation != "running":
					#animation_player.play("running")
					curAnim = RUN
					
			visualsNode.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !isLocked:
			if animation_player.current_animation != "idle":
				#animation_player.play("idle")
				curAnim = IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if !isLocked:
		move_and_slide()
