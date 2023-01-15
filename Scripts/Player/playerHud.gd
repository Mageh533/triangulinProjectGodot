extends CanvasLayer

func updateBattery(battery):
	$Battery.text = "Battery: %s" % str(battery)

func updateNoise(noise):
	$Noise.text = "Noise: %s" % str(noise)


func _on_Player_flashlightOn(battery):
	updateBattery(battery)


func _on_Player_madeNoise(noise):
	updateNoise(noise)
