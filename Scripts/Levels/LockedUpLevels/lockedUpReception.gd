extends Node

signal kickPlayerOutOfPC

export var difficulty = 5
export var shadowDifficulty = 5

var currentCamera
var anomalyCounter = 0
var time = 0
var errors = 0

var pcEnabled = true

onready var allCameras =  $AllCameras.get_children()

var possibleAnomalies = ["movedObject", "objectDissapeared", "additionalObject"]
var rooms = ["Hallway", "Room", "Bathroom", "Balcony", "Janitors_Closet"]

var currentUsedRooms = []
var currentAnomalies = {}
var possibleKeys = []
var currentlyUsedKeys = []
var correctKeyToGive
var anomalyPressed = null
var currentRoomPressed = null

# Built in _functions

func _ready():
	randomize()
	$GUI/OnPC/IncidentMenu.visible = false
	$GUI/OnPC/AnomalyDetected.visible = false
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.visible = false
	$GUI/OnPC/ReportedStatus.visible = false
	$Structures/Lobby/Sombra.visible = false
	$GUI/Normal/Subtitles.visible = false
	$GUI/Keys.visible = false
	hideAnomalies()	
	onLobby()
	
func _process(delta):
	currentCamera = get_viewport().get_camera()
	$GUI/OnPC/CurrentCamera.text = currentCamera.name
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.text = "Buscando Anomalia... %s" % str(int($Timers/AnomalyCooldown.time_left))
	processTime(delta)
	processAnomalyCounter()
	whileAnomaliesAreActive()

# My own Functions
func resetKeyMeshes():
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel1.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel2.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel3.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel4.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel5.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel6.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel7.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel8.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel9.visible = true
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel10.visible = true
	$Structures/Lobby/Sombra.visible = false

func hideAnomalies():
	$Structures/Hallway/ObjetoAdicional.visible = false
	$Structures/Room/ObjetoAdicional.visible = false
	$Structures/Bathroom/ObjetoAdicional.visible = false
	$Structures/Balcony/ObjetoAdicional.visible = false
	$Structures/Janitors_Closet/ObjetoAdicional.visible = false
	$Structures/Hallway/ObjetoMovido.visible = false
	$Structures/Room/ObjetoMovido.visible = false
	$Structures/Bathroom/ObjetoMovido.visible = false
	$Structures/Balcony/ObjetoMovido.visible = false
	$Structures/Janitors_Closet/ObjetoMovido.visible = false

func resetKeyButtons():
	$GUI/Keys/key1.visible = true
	$GUI/Keys/key2.visible = true
	$GUI/Keys/key3.visible = true
	$GUI/Keys/key4.visible = true
	$GUI/Keys/key5.visible = true
	$GUI/Keys/key6.visible = true
	$GUI/Keys/key7.visible = true
	$GUI/Keys/key8.visible = true
	$GUI/Keys/key9.visible = true
	$GUI/Keys/key10.visible = true

func processAnomalyCounter():
	$GUI/OnPC/AnomalyCounter.text = "Anomalias Actuales: %s" % str(currentAnomalies.size())

func correctAnomalyReported(anomalyNumber):
	var anomalyRoomToFree = currentAnomalies[anomalyNumber]
	currentAnomalies.erase(anomalyNumber)
	resetRoomAfterFixedAnomaly(anomalyRoomToFree[0])
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
	while rooms[randomRoom] in currentUsedRooms and currentUsedRooms.size() < 5: # Prevent more than one anomaly in the same room
		randomRoom = randi() % rooms.size()
	var anomaly = possibleAnomalies[randi() % possibleAnomalies.size()]
	var room = rooms[randomRoom]
	currentAnomalies[anomalyCounter] = [room, anomaly]
	anomalyCounter += 1
	currentUsedRooms.append(room)
	$GUI/OnPC/AnomalyDetected.visible = true
	$GUI/OnPC/AnomalyDetected/Timer.start()
	$Structures/Lobby/Anomaly.play()
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

func whileAnomaliesAreActive():
	# Makes the anomalies happen visually
	for i in currentAnomalies:
		if possibleAnomalies[0] in currentAnomalies[i]:
			var room = currentAnomalies[i]
			var roomAnomalyObject = get_node("Structures/" + room[0] + "/Objeto")
			var roomAnomalyObject2 = get_node("Structures/" + room[0] + "/ObjetoMovido")
			roomAnomalyObject.visible = false
			roomAnomalyObject2.visible = true
		elif possibleAnomalies[1] in currentAnomalies[i]:
			var room = currentAnomalies[i]
			var roomAnomalyObject = get_node("Structures/" + room[0] + "/Objeto")
			roomAnomalyObject.visible = false
		elif possibleAnomalies[2] in currentAnomalies[i]:
			var room = currentAnomalies[i]
			var roomAnomalyObject = get_node("Structures/" + room[0] + "/ObjetoAdicional")
			roomAnomalyObject.visible = true

func resetRoomAfterFixedAnomaly(room):
	# Get all the objects
	var roomObject = get_node("Structures/" + room + "/Objeto")
	var roomAdditionalObject = get_node("Structures/" + room + "/ObjetoAdicional")
	var movedObject = get_node("Structures/" + room + "/ObjetoMovido")
	# Put them back to how they should be
	roomObject.visible = true
	roomAdditionalObject.visible = false
	movedObject.visible = false

func createShadowEvent():
	var correctKeySet = false
	# Clear the arrays from previous events
	possibleKeys.clear()
	currentlyUsedKeys.clear()
	$Structures/Lobby/Sombra.visible = true
	$Structures/Lobby/Sombra/Bell.play()
	var randomKey = int(rand_range(001, 999))
	$GUI/Normal/Subtitles.text = "Hola, quiero una llave para la habitacion: %s" % str(randomKey)
	correctKeyToGive = randomKey
	$GUI/Normal/Subtitles.visible = true
	$Timers/SubtitleTimer.start()
	$Timers/ShadowEventTime.start()
	# Prepare the array, correct key goes first then some dummy ones
	while possibleKeys.size() < 10:
		if !(correctKeySet):
			possibleKeys.append(randomKey)
			correctKeySet = true
		else:
			possibleKeys.append(int(rand_range(001, 999)))
	
	while currentlyUsedKeys.size() < 10:
		var randomKeyButton = randi() % 10 + 1
		if !(randomKeyButton in currentlyUsedKeys):
			var keyButton = get_node("GUI/Keys/key" + str(randomKeyButton))
			keyButton.text = str(possibleKeys.front())
			possibleKeys.pop_front()
			currentlyUsedKeys.append(randomKeyButton)

func reviewKeyChoice(key, keyButton):
	var keyMesh = get_node("Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel" + str(keyButton))
	var guiKeyButton = get_node("GUI/Keys/key" + str(keyButton))
	guiKeyButton.visible = false
	keyMesh.visible = false
	if key == correctKeyToGive:
		$Timers/ShadowEventTime.stop()
		$GUI/Normal/Subtitles.text = "Gracias"
		$GUI/Normal/Subtitles.visible = true
		$Timers/SubtitleTimer.start()
		resetKeyMeshes()
		resetKeyButtons()
	else:
		$Timers/ShadowEventTime.stop()
		$GUI/Normal/Subtitles.visible = true
		$GUI/Normal/Subtitles.text = "Me tomas por bobo? Me enfado"
		$Timers/SubtitleTimer.start()
		resetKeyMeshes()
		resetKeyButtons()
		failedShadowEvent()

func failedShadowEvent():
	$Structures/Lobby/Sombra.visible = false
	pcEnabled = false
	emit_signal("kickPlayerOutOfPC")
	onLobby()
	$Timers/DisablePC.start()

# Signal Functions

func _on_Anomaly1_pressed():
	$Timers/AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "additionalObject"
	currentRoomPressed = get_viewport().get_camera().name

func _on_Anomaly2_pressed():
	$Timers/AnomalyCooldown.start()
	cooldownCounter()
	anomalyPressed = "movedObject"
	currentRoomPressed = get_viewport().get_camera().name

func _on_Anomaly3_pressed():
	$Timers/AnomalyCooldown.start()
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

func _on_LeaveIncident_pressed():
	$GUI/OnPC/IncidentMenu.visible = false

func _on_Player_canUsePC(status):
	if status and pcEnabled:
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


func _on_SubtitleTimer_timeout():
	$GUI/Normal/Subtitles.visible = false

func _on_ShadowSpawner_timeout():
	if rand_range(1, 20) < shadowDifficulty and $Timers/DisablePC.is_stopped():
		createShadowEvent()


func _on_TurnAround_pressed():
	if $GUI/Keys.visible:
		$GUI/Keys.visible = false
	else:
		$GUI/Keys.visible = true


func _on_ShadowEventTime_timeout():
	$GUI/Normal/Subtitles.visible = true
	$GUI/Normal/Subtitles.text = "No me haces caso y me enfado"
	$Timers/SubtitleTimer.start()
	resetKeyMeshes()
	resetKeyButtons()
	failedShadowEvent()


func _on_key1_pressed():
	reviewKeyChoice(int($GUI/Keys/key1.text), 1)


func _on_key2_pressed():
	reviewKeyChoice(int($GUI/Keys/key2.text), 2)


func _on_key3_pressed():
	reviewKeyChoice(int($GUI/Keys/key3.text), 3)


func _on_key4_pressed():
	reviewKeyChoice(int($GUI/Keys/key4.text), 4)


func _on_key5_pressed():
	reviewKeyChoice(int($GUI/Keys/key5.text), 5)


func _on_key6_pressed():
	reviewKeyChoice(int($GUI/Keys/key6.text), 6)


func _on_key7_pressed():
	reviewKeyChoice(int($GUI/Keys/key7.text), 7)


func _on_key8_pressed():
	reviewKeyChoice(int($GUI/Keys/key8.text), 8)


func _on_key9_pressed():
	reviewKeyChoice(int($GUI/Keys/key9.text), 9)


func _on_key10_pressed():
	reviewKeyChoice(int($GUI/Keys/key10.text), 10)


func _on_DisablePC_timeout():
	pcEnabled = true
