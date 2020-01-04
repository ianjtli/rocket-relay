extends "res://gui/Instructions.gd"

var creditText : Dictionary

func _ready():
	#Hide everything except switch rockets
	for n in $GUI/Arrows.get_children():
		n.hide()
	$GUI/Instruction.show()
	$GUI/Arrows/SwitchInstruction.show()
	$GUI/Arrows/SwitchInstruction.text = "Next credit"
	
	#Text for credits
	creditText = {
		"Boring Rocket": "Game design and development by\nIan Li",
		"Mini Rocket": "Music from\nPunch Deck\n\nSound Effects from\nGavin Thibodeau aka Embra",
		"Shield Rocket": "Art by\nIan Li",
		"Sword Rocket": "Thanks for playing!"
	}
	$GUI/Instruction.text = "\n\n\n\n" + creditText[rockets[0].rocketName]
	
	#Hide score, HP
	$GUI/ScoreLabel.hide()
	$GUI/HpLabel.hide()
	$GUI/NextInstruction.hide()

#Move to next credit
func switchRocketTrigger(preview):
	if !preview:
		switchRockets(1)
		$GUI/Instruction.text = "\n\n\n\n" + creditText[rockets[0].rocketName]
	else:
		$GUI/GestureDescription.text = "Next Credit"
		$GUI/Arrows/SwitchInstruction.modulate = Color(1,0,0)
		$GUI/MouseStart/MouseStart2.modulate = Color(1,0,0)

#Override
func showNextInstruction():
	pass

#Override, don't show hp bar
func updateHpBar(hpChange):
	for hpSprite in get_tree().get_nodes_in_group("hpSprites"):
		hpSprite.queue_free()
