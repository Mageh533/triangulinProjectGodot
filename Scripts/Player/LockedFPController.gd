extends KinematicBody

signal canUsePC
signal onPc

onready var head = get_node("Head")
var turned = false
var onCamera = false

func _ready():
	$Head/Camera.current = true

func _process(delta):
	keyboardControls(delta)
	if $AnimationPlayer.is_playing() == true:
		if $AnimationPlayer.get_current_animation_position() > 0.49:
			emit_signal("onPc")
	if head.rotation.y < deg2rad(-5):
		emit_signal("canUsePC", true)
	else:
		emit_signal("canUsePC", false)
		
func leavePc():
	onCamera = false
	$Head/Camera.current = true
	$AnimationPlayer.play("RESET")

func keyboardControls(delta):
	if Input.is_action_pressed("move_left"):
		head.rotate_y(deg2rad(100) * delta)
	if Input.is_action_pressed("move_right"):
		head.rotate_y(deg2rad(-100) * delta)
	if turned == false:
		head.rotation.y = clamp(head.rotation.y, deg2rad(-10), deg2rad(89))
	else:
		head.rotation.y = clamp(head.rotation.y, deg2rad(180), deg2rad(180))

func _on_Button_button_up():
	if turned:
		turned = false
		head.rotate_y(deg2rad(180))
	else:
		turned = true
		head.rotate_y(deg2rad(180))


func _on_UsePC_button_up():
	if !(onCamera) and head.rotation.y < deg2rad(-5):
		onCamera = true
		$AnimationPlayer.play("useCamera")

func _on_LeavePC_button_up():
	leavePc()


func _on_Main_kickPlayerOutOfPC():
	leavePc()
