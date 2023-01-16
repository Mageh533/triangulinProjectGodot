extends Node

var currentCamera
var time = 0
var errors = 0
onready var allCameras =  $AllCameras.get_children()
var possibleAnomalies = ["movedObject", "objectDissapeared", "additionalObject"]
var rooms = ["Hallway", "Room", "Bathroom", "Balcony", "Janitor's Closet"]
var currentAnomalies = {}
var anomalyPressed = null
var currentRoomPressed = null

# Built in _functions

func _ready():
	randomize()
	$GUI/OnPC/IncidentMenu.visible = false
	$GUI/OnPC/AnomalyDetected.visible = false
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.visible = false
	$GUI/OnPC/ReportedStatus.visible = false
	onLobby()
	
func _process(delta):
	currentCamera = get_viewport().get_camera()
	$GUI/OnPC/CurrentCamera.text = currentCamera.name
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.text = "Buscando Anomalia... %s" % str(int($AnomalyCooldown.time_left))
	processTime(delta)

# My own Functions
func correctAnomalyReported(anomalyNumber):
	currentAnomalies.erase(anomalyNumber)
	$GUI/OnPC/ReportedStatus.visible = true
	$GUI/OnPC/ReportedStatus/Bad.visible = false
	$GUI/OnPC/ReportedStatus/Good.visible = true
	$GUI/OnPC/ReportedStatus/ReportedTimer.start()
	
func incorrectAnomalyReported():
	errors += 1
	if errors == 1:
		$Structures/Lobby/MaletaArriba/Animacion.play("Fase1")
	elif errors == 2:
		$Structures/Lobby/MaletaArriba/Animacion.play("Fase2")
	elif errors == 3:
		$Structures/Lobby/MaletaArriba/Animacion.play("Fase3")
	elif errors == 4:
		$Structures/Lobby/MaletaArriba/Animacion.play("Fase4")
	elif errors == 5:
		$Structures/Lobby/MaletaArriba/Animacion.play("Fase5")
		$Structures/Lobby/Godot.visible = false
	$GUI/OnPC/ReportedStatus.visible = true
	$GUI/OnPC/ReportedStatus/Bad.visible = true
	$GUI/OnPC/ReportedStatus/Good.visible = false
	$GUI/OnPC/ReportedStatus/ReportedTimer.start()
	
func onUsingPC():
	$GUI/Normal.visible = false
	$GUI/OnPC.visible = true
	
func onLobby():
	$GUI/Normal.visible = true
	$GUI/OnPC.visible = false
	
func processTime(delta):
	if time / 10 > 10:
		$GUI/OnPC/Time.text = "22:%s" % str(int(time / 10))
	else:
		$GUI/OnPC/Time.text = "22:0%s" % str(int(time / 10))
	time += 1 * delta
	
func cooldownCounter():
	$GUI/OnPC/IncidentMenu/Panel/Anomaly1.disabled = true
	$GUI/OnPC/IncidentMenu/Panel/Anomaly2.disabled = true
	$GUI/OnPC/IncidentMenu/Panel/Anomaly3.disabled = true
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.visible = true
	
func generateRandomAnomaly():
	var anomaly = possibleAnomalies[rand_range(0, possibleAnomalies.size() - 1)]
	var room = rooms[rand_range(0, possibleAnomalies.size() - 1)]
	currentAnomalies[currentAnomalies.size()] = [room, anomaly]
	$GUI/OnPC/AnomalyDetected.visible = true
	$GUI/OnPC/AnomalyDetected/Timer.start()

func reportAnomaly():
	var currentRoom = currentRoomPressed
	var reportedAnomaly = anomalyPressed
	var correctKey = null
	for i in currentAnomalies:
		if currentAnomalies[i] == [currentRoom, reportedAnomaly]:
			correctKey = i
	return correctKey

func reviewAnomaly():
	var correctKey = reportAnomaly()
	if correctKey != null:
		correctAnomalyReported(correctKey)
	else:
		incorrectAnomalyReported()
	
# Signal Functions

func _on_Anomaly1_pressed():
	$AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "additionalObject"
	currentRoomPressed = get_viewport().get_camera().name

func _on_Anomaly2_pressed():
	$AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "movedObject"
	currentRoomPressed = get_viewport().get_camera().name

func _on_Anomaly3_pressed():
	$AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "objectDissapeared"
	currentRoomPressed = get_viewport().get_camera().name

func _on_AnomalyCooldown_timeout():
	$GUI/OnPC/IncidentMenu/Panel/Anomaly1.disabled = false
	$GUI/OnPC/IncidentMenu/Panel/Anomaly2.disabled = false
	$GUI/OnPC/IncidentMenu/Panel/Anomaly3.disabled = false
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.visible = false
	reviewAnomaly()
	

func _on_UsePC_button_up():
	$GUI/Normal.visible = false


func _on_LeavePC_button_up():
	onLobby()


func _on_Player_onPc():
	onUsingPC()
	$AllCameras/Hallway.current = true


func _on_GoRight_button_up():
	var currentRoom = 0
	for i in allCameras.size():
		if allCameras[i].name == currentCamera.name:
			currentRoom = i
	if currentRoom + 1 < allCameras.size():
		allCameras[currentRoom + 1].current = true
	else:
		allCameras[0].current = true

func _on_GoLeft_button_up():
	var currentRoom = 0
	for i in allCameras.size():
		if allCameras[i].name == currentCamera.name:
			currentRoom = i
	if currentRoom - 1 >= 0:
		allCameras[currentRoom - 1].current = true
	else:
		allCameras[allCameras.size() - 1].current = true

func _on_Report_pressed():
	if $GUI/OnPC/IncidentMenu.visible == false:
		$GUI/OnPC/IncidentMenu.visible = true
	generateRandomAnomaly()
	print(str(currentAnomalies))

func _on_LeaveIncident_pressed():
	$GUI/OnPC/IncidentMenu.visible = false

func _on_Player_canUsePC(status):
	if status:
		$GUI/Normal/UsePC.visible = true
	else:
		$GUI/Normal/UsePC.visible = false

func _on_Timer_timeout():
	$GUI/OnPC/AnomalyDetected.visible = false


func _on_ReportedTimer_timeout():
	$GUI/OnPC/ReportedStatus.visible = false
	anomalyPressed = null
	currentRoomPressed = null
