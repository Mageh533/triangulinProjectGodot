extends Node

signal kickPlayerOutOfPC
signal forcePlayerTurnAround

export var difficulty = 5
export var shadowDifficulty = 5

var currentCamera
var time = 0
var errors = 0
var anomalyCounter = 0

var pcEnabled = true
var keyChoice = false
var keyGiven = []
var timeLeft = true

onready var allCameras =  $AllCameras.get_children()

var possibleAnomalies = ["movedObject", "objectDissapeared", "additionalObject"]
var rooms = ["Hallway", "Room", "Bathroom", "Balcony", "Janitors_Closet"]

var currentUsedRooms = []
var currentAnomalies = {}
var originalPositions = {}
var possibleKeys = []
var currentlyUsedKeys = []
var correctKeyToGive
var anomalyPressed = null
var currentRoomPressed = null

# Built in _functions

func _ready():
	randomize()
	setUpScene()
	hideAnomalies()
	onLobby()
	
func _process(delta):
	currentCamera = get_viewport().get_camera()
	$GUI/OnPC/CurrentCamera.text = currentCamera.name
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.text = "Buscando Anomalia... %s" % str(int($Timers/AnomalyCooldown.time_left))
	processTime(delta)
	processAnomalyCounter()
	whileAnomaliesAreActive()
	if (errors > 4) or (time > 600) or (currentAnomalies.size() > 4) and $GUI/OnPC/AnimatedSprite.modulate.a < 1:
		$GUI/OnPC/AnimatedSprite.modulate.a += 0.5 * delta
	if currentAnomalies.size() > 4 and timeLeft:
		timeLeft = false
		playerFailed()

# My own Functions
func setUpScene():
	$GUI/OnPC/IncidentMenu.visible = false
	$GUI/OnPC/AnomalyDetected.visible = false
	$GUI/OnPC/IncidentMenu/Panel/CooldownCounter.visible = false
	$GUI/OnPC/ReportedStatus.visible = false
	$Structures/Lobby/Sombra.visible = false
	$GUI/Normal/Subtitles.visible = false
	$GUI/Keys.visible = false
	$Structures/Lobby/desktop/LlaveDeHotel.visible = false
	$GUI/OnPC/GameOver.visible = false
	$Structures/Lobby/JumpscareGodot.visible = false
	$GUI/GameOver.visible = false

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
	for i in rooms.size():
		resetRoomAfterFixedAnomaly(rooms[i])

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
	$GUI/OnPC/CorrectAnomaly.play()
	
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
		playerFailed()
	$GUI/OnPC/ReportedStatus.visible = true
	$GUI/OnPC/ReportedStatus/Bad.visible = true
	$GUI/OnPC/ReportedStatus/Good.visible = false
	$GUI/OnPC/ReportedStatus/ReportedTimer.start()
	$GUI/OnPC/IncorrectAnomaly.play()
	
func onUsingPC():
	$GUI/Normal.visible = false
	$GUI/OnPC.visible = true
	
func onLobby():
	$GUI/Normal.visible = true
	$GUI/OnPC.visible = false

func levelCompleted():
	timeLeft = false
	playerFailed()

func processTime(delta):
	if time >= 600:
		if timeLeft:
			levelCompleted()
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
	anomalyCounter = anomalyCounter + 1
	currentUsedRooms.append(room)
	$GUI/OnPC/AnomalyDetected.visible = true
	$GUI/OnPC/AnomalyDetected/Timer.start()
	$Structures/Lobby/Anomaly.play()
	print(str(currentAnomalies))

func reportAnomaly():
	var currentRoom = currentRoomPressed
	var reportedAnomaly = anomalyPressed
	print("Room: %s and anomaly: %s " % [currentRoom, reportedAnomaly])
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
		var chosen = false
		if possibleAnomalies[1] in currentAnomalies[i]:
			var room = currentAnomalies[i]
			var objects = get_node("Structures/" + room[0] + "/Objetos").get_children()
			while !chosen:
				# Choses a random object that isnt aditional or moved, then makes it invisible
				var randomObject = objects[randi() % (objects.size())]
				if not "Adicional" in randomObject.name and not "Movido" in randomObject.name:
					randomObject.visible = false
					chosen = true
		elif possibleAnomalies[0] in currentAnomalies[i]:
			var room = currentAnomalies[i]
			var objects = get_node("Structures/" + room[0] + "/Objetos").get_children()
			while !chosen:
				# Choses a random object until it finds a move one (there can be multiple so this solution works well enough)
				var randomObject = objects[randi() % (objects.size())]
				var ogObject = objects[randi() % (objects.size())]
				if "Movido" in randomObject.name and "Original" in ogObject.name:
					ogObject.visible = false
					randomObject.visible = true
					chosen = true
		elif possibleAnomalies[2] in currentAnomalies[i]:
			var room = currentAnomalies[i]
			var objects = get_node("Structures/" + room[0] + "/Objetos").get_children()
			while !chosen:
				# Choses a random object until it finds an additional one (there can be multiple so this works better than a for loop)
				var randomObject = objects[randi() % (objects.size())]
				if "Adicional" in randomObject.name:
					randomObject.visible = true
					chosen = true

func resetRoomAfterFixedAnomaly(room):
	# Get all the objects
	var roomObjects = get_node("Structures/" + room + "/Objetos").get_children()
	# Put them back to how they should be
	for i in roomObjects.size():
		if "Adicional" in roomObjects[i].name or "Movido" in roomObjects[i].name:
			roomObjects[i].visible = false
		else:
			roomObjects[i].visible = true

func createShadowEvent():
	var correctKeySet = false
	emit_signal("forcePlayerTurnAround")
	# Clear the arrays from previous events
	possibleKeys.clear()
	currentlyUsedKeys.clear()
	keyGiven.clear()
	$Structures/Lobby/Sombra.visible = true
	$Structures/Lobby/Sombra/Bell.play()
	var randomKey = int(rand_range(001, 999))
	$GUI/Normal/Subtitles.text = "Hola, quiero una llave para la habitacion: %s" % str(randomKey)
	$Structures/Lobby/Sombra/Dialogue.play()
	
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
		$Structures/Lobby/Sombra/Correct.play()
		$GUI/Normal/Subtitles.visible = true
		$Timers/SubtitleTimer.start()
		resetKeyMeshes()
		resetKeyButtons()
	else:
		$Timers/ShadowEventTime.stop()
		$GUI/Normal/Subtitles.visible = true
		$GUI/Normal/Subtitles.text = "Me tomas por bobo? Me enfado"
		$Structures/Lobby/Sombra/Wrong.play()
		$Timers/SubtitleTimer.start()
		resetKeyMeshes()
		resetKeyButtons()
		failedShadowEvent()
	keyGiven.clear()
	$Structures/Lobby/desktop/LlaveDeHotel.visible = false
	keyChoice = false

func failedShadowEvent():
	$Structures/Lobby/Sombra.visible = false
	$Structures/Lobby/desktop/PCDisabled.play()
	pcEnabled = false
	keyGiven.clear()
	emit_signal("kickPlayerOutOfPC", false)
	onLobby()
	$Timers/DisablePC.start()

func flickerLight():
	$Structures/Lobby/SpotLight.visible = false
	$Timers/GameOverTimers/LightFlicker.start()

func playerFailed():
	# Disable all elements
	$GUI/OnPC/LeavePC.visible = false
	$GUI/OnPC/GoLeft.visible = false
	$GUI/OnPC/GoLeft.visible = false
	$GUI/OnPC/GoRight.visible = false
	$GUI/OnPC/CurrentCamera.visible = false
	$GUI/OnPC/Report.visible = false
	$GUI/OnPC/IncidentMenu.visible = false
	$GUI/OnPC/ReportedStatus.visible = false
	$GUI/OnPC/Time.visible = false
	$GUI/OnPC/AnomalyCounter.visible = false
	# Show the label and static
	$GUI/OnPC/GameOver.visible = true
	# Start timer
	$Timers/GameOverTimers/KickPlayerOfPc.start()
	# Stop all gameplay
	$Structures/Lobby/Sombra.visible = false
	$Timers/AnomalySpawner.autostart = false
	$Timers/AnomalySpawner.stop()
	$Timers/ShadowSpawner.autostart = false
	$Timers/ShadowSpawner.stop()
	$Timers/ShadowEventTime.stop()
	# Flicker lights to stop the player from seeing the briefcase open
	flickerLight()

# Signal Functions

func _on_Anomaly1_pressed():
	$Timers/AnomalyCooldown.start()
	$GUI/OnPC/MenuOpen.play()
	cooldownCounter()
	anomalyPressed = "additionalObject"
	currentRoomPressed = get_viewport().get_camera().name

func _on_Anomaly2_pressed():
	$Timers/AnomalyCooldown.start()
	$GUI/OnPC/MenuOpen.play()
	cooldownCounter()
	anomalyPressed = "movedObject"
	currentRoomPressed = get_viewport().get_camera().name

func _on_Anomaly3_pressed():
	$Timers/AnomalyCooldown.start()
	$GUI/OnPC/MenuOpen.play()
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
	$Structures/Lobby/desktop/PCUse2.play()
	$GUI/Normal.visible = false


func _on_LeavePC_button_up():
	$Structures/Lobby/desktop/PCUse.play()
	onLobby()


func _on_Player_onPc():
	onUsingPC()
	$AllCameras/Hallway.current = true


func _on_GoRight_button_up():
	var currentRoom = 0
	$Structures/Lobby/desktop/PCUse.play()
	for i in allCameras.size():
		if allCameras[i].name == currentCamera.name:
			currentRoom = i
	if currentRoom + 1 < allCameras.size():
		allCameras[currentRoom + 1].current = true
	else:
		allCameras[0].current = true

func _on_GoLeft_button_up():
	var currentRoom = 0
	$Structures/Lobby/desktop/PCUse.play()
	for i in allCameras.size():
		if allCameras[i].name == currentCamera.name:
			currentRoom = i
	if currentRoom - 1 >= 0:
		allCameras[currentRoom - 1].current = true
	else:
		allCameras[allCameras.size() - 1].current = true

func _on_Report_pressed():
	$Structures/Lobby/desktop/PCUse.play()
	if $GUI/OnPC/IncidentMenu.visible == false:
		$GUI/OnPC/IncidentMenu.visible = true
	$GUI/OnPC/MenuOpen.play()
	

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

func _on_AnomalySpawner_timeout():
	if rand_range(1, 20) <= difficulty:
		generateRandomAnomaly()


func _on_DifficultyIncrease_timeout():
	difficulty += 1
	shadowDifficulty += 1


func _on_SubtitleTimer_timeout():
	$GUI/Normal/Subtitles.visible = false

func _on_ShadowSpawner_timeout():
	if rand_range(1, 20) < shadowDifficulty and $Timers/DisablePC.is_stopped():
		createShadowEvent()


func _on_TurnAround_pressed():
	if $Timers/ShadowEventTime.time_left > 0:
		if $GUI/Keys.visible:
			$GUI/Keys.visible = false
		else:
			$GUI/Keys.visible = true
	else:
		$GUI/Keys.visible = false
	
	if keyChoice:
		$GUI/Keys.visible = false
		$Timers/ShadowEventTime.stop()
		$Structures/Lobby/desktop/LlaveDeHotel.visible = true
		$Timers/GiveKey.start()
		$Structures/Lobby/desktop/KeyPickup.play()


func _on_ShadowEventTime_timeout():
	$GUI/Keys.visible = false
	$GUI/Normal/Subtitles.visible = true
	$GUI/Normal/Subtitles.text = "Me ignoras? y me enfado"
	$Structures/Lobby/Sombra/Ignore.play()
	$Timers/SubtitleTimer.start()
	resetKeyMeshes()
	resetKeyButtons()
	failedShadowEvent()


func _on_key1_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel1.visible = false
	keyGiven.append(int($GUI/Keys/key1.text))
	keyGiven.append(1)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key2_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel2.visible = false	
	keyGiven.append(int($GUI/Keys/key2.text))
	keyGiven.append(2)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key3_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel3.visible = false
	keyGiven.append(int($GUI/Keys/key3.text))
	keyGiven.append(3)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key4_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel4.visible = false
	keyGiven.append(int($GUI/Keys/key4.text))
	keyGiven.append(4)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key5_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel5.visible = false
	keyGiven.append(int($GUI/Keys/key5.text))
	keyGiven.append(5)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key6_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel6.visible = false
	keyGiven.append(int($GUI/Keys/key6.text))
	keyGiven.append(6)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key7_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel7.visible = false
	keyGiven.append(int($GUI/Keys/key7.text))
	keyGiven.append(7)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key8_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel8.visible = false
	keyGiven.append(int($GUI/Keys/key8.text))
	keyGiven.append(8)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key9_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel9.visible = false
	keyGiven.append(int($GUI/Keys/key9.text))
	keyGiven.append(9)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_key10_pressed():
	keyChoice = true
	$GUI/Keys.visible = false
	$Structures/Lobby/TableDeLlaves/Llaves/LlaveDeHotel10.visible = false
	keyGiven.append(int($GUI/Keys/key10.text))
	keyGiven.append(10)
	$Structures/Lobby/desktop/KeyPickup.play()


func _on_DisablePC_timeout():
	pcEnabled = true


func _on_GiveKey_timeout():
	reviewKeyChoice(keyGiven[0], keyGiven[1])


func _on_KickPlayerOfPc_timeout():
	onLobby()
	var death = errors > 4 or currentAnomalies.size() > 4
	emit_signal("kickPlayerOutOfPC", death)
	if time >= 600:
		$GUI/GameOver.visible = true
	else:	
		$Timers/GameOverTimers/Jumpscare.start()


func _on_LightFlicker_timeout():
	$Structures/Lobby/SpotLight.visible = true


func _on_Jumpscare_timeout():
	$Structures/Lobby/Jumpscare.current = true
	$Structures/Lobby/JumpscareGodot.visible = true
	$Structures/Lobby/JumpscareGodot/Jumpscare.play("Jumpscare")
	$Structures/Lobby/JumpscareGodot/Jumpscare2.play()
	$Timers/GameOverTimers/GameOver.start()

func _on_GameOver_timeout():
	$GUI/GameOver.visible = true


func _on_Retry_pressed():
	print(get_tree().reload_current_scene())
