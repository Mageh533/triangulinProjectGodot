extends Node

export var difficulty = 5

var currentCamera
var time = 0
var errors = 0
onready var allCameras =  $AllCameras.get_children()
var possibleAnomalies = ["movedObject", "objectDissapeared", "additionalObject"]
var rooms = ["Hallway", "Room", "Bathroom", "Balcony", "Janitors_Closet"]
var currentUsedRooms = []
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
	$Structures/Hallway/ObjetoAdicional.visible = false
	$Structures/Room/ObjetoAdicional.visible = false
	$Structures/Bathroom/ObjetoAdicional.visible = false
	$Structures/Balcony/ObjetoAdicional.visible = false
	$Structures/JanitorCloset/ObjetoAdicional.visible = false
	
	onLobby()
	
func _process(delta):
	currentCamera = get_viewport().get_camera()
	$GUI/OnPC/CurrentCamera.text = currentCamera.name
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.text = "Buscando Anomalia... %s" % str(int($AnomalyCooldown.time_left))
	processTime(delta)
	processAnomalyCounter()

# My own Functions
func processAnomalyCounter():
	$GUI/OnPC/AnomalyCounter.text = "Anomalias Actuales: %s" % str(currentAnomalies.size())

func correctAnomalyReported(anomalyNumber):
	var anomalyRoomToFree = currentAnomalies[anomalyNumber]
	currentAnomalies.erase(anomalyNumber)
	currentUsedRooms.erase(anomalyRoomToFree[0])
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
	var randomRoom = randi() % rooms.size()
	while rooms[randomRoom] in currentUsedRooms and currentUsedRooms.size() < 5:
		randomRoom = randi() % rooms.size()
	var anomaly = possibleAnomalies[randi() % possibleAnomalies.size()]
	var room = rooms[randomRoom]
	currentAnomalies[currentAnomalies.size()] = [room, anomaly]
	currentUsedRooms.append(room)
	print(str(currentUsedRooms))
	$GUI/OnPC/AnomalyDetected.visible = true
	$GUI/OnPC/AnomalyDetected/Timer.start()
	print(str(currentAnomalies))

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
	print(currentRoomPressed)

func _on_Anomaly2_pressed():
	$AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "movedObject"
	currentRoomPressed = get_viewport().get_camera().name
	print(currentRoomPressed)

func _on_Anomaly3_pressed():
	$AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "objectDissapeared"
	currentRoomPressed = get_viewport().get_camera().name
	print(currentRoomPressed)

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

func _on_AnomalySpawner_timeout():
	if rand_range(1, 20) <= difficulty:
		generateRandomAnomaly()


func _on_DifficultyIncrease_timeout():
	difficulty += 1
