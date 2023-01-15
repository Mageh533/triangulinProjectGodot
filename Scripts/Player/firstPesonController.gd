extends KinematicBody

#signals
signal flashlightOn
signal madeNoise

# Gameplay Variables
export var flashlightEnabled = true
var flashlight = false
var flashlightBattery = 100
var noise = 0

# Normal variables
export var speed = 3
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 2
var snap

# Vector variables
var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

# Mouse variables
var cam_accel = 40
export var mouse_sens = 0.1
onready var camera = $Head/FirstPerson
onready var head = $Head

# Lock mouse into window
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Standard Mouselook
func playerMouseLook(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x*mouse_sens))
		head.rotate_x(deg2rad(-event.relative.y*mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

# Keyboard controls
func playerKeyboardControls(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
		
	# Basic Sprint
	if Input.is_action_pressed("sprint"):
		speed = 6
		if noise < 50:
			noise += 50 * delta
	else:
		speed = 3
		
	# Flashlight
	if Input.is_action_just_released("flashlightToggle"):
		if flashlight:
			flashlight = false
		else:
			flashlight = true
	if Input.is_action_just_released("reload"):
		if flashlightBattery < 100:
			flashlightBattery += 5
			emit_signal("flashlightOn", int(flashlightBattery))
			if noise < 30:
				noise += 5
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if !($playerAnims.is_playing()):
		if Engine.get_frames_per_second() > Engine.iterations_per_second:
			camera.set_as_toplevel(true)
			camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
			camera.rotation.y = rotation.y
			camera.rotation.x = head.rotation.x
		else:
			camera.set_as_toplevel(false)
			camera.global_transform = head.global_transform
	lowerNoisePerTick(delta)

func _physics_process(delta):
	if !($playerAnims.is_playing()):
		playerKeyboardControls(delta)
	if flashlightEnabled:
		flashlightWork(delta)

func _input(event):
	if !($playerAnims.is_playing()):
		playerMouseLook(event)

func flashlightWork(delta):
	if flashlight and flashlightBattery > 0:
		$Head/FlashLight.visible = true
		flashlightBattery -= 10 * delta
		emit_signal("flashlightOn", int(flashlightBattery))
	else:
		$Head/FlashLight.visible = false
		
	if flashlightBattery < 30:
		$Head/FlashLight.light_energy = rand_range(0, 1)
	else:
		$Head/FlashLight.light_energy = 2

func playWakeUpAnim():
	$playerAnims.play("wakeUp")

func lowerNoisePerTick(delta):
	if noise > 0:
		noise -= 20 * delta
	elif noise < 0:
		noise = 0
	emit_signal("madeNoise", int(noise))
