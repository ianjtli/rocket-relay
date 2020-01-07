extends Node

#Resources
export (PackedScene) var Enemy
export (PackedScene) var DoubleEnemy
export (PackedScene) var Rocket
export (PackedScene) var MiniRocket
export (PackedScene) var ShieldRocket
export (PackedScene) var Powerup
export (PackedScene) var HpPowerup
const HpSprite = preload("res://gui/HpSprite.tscn")
var starTexture : Texture = preload("res://images/Star.png")

#Gameplay variables
var score : int
var scoreFromEnemies : int
var scoreFromPowerups : int
var scoreFromHP : int
var distance : float
var finishLine : float
var levelEnded : bool

#Rocket tracking
var rockets = []
var rocketHp : int

#GUI-related variables
onready var screenSize = get_viewport().get_visible_rect().size
var moveDistance
var initialMousePos
const minGestureDist = 20
var showInstructions = false

#Level definition variables
var levelIndex = 0
var bossLevel = false
var starThreshold = [0,0,0]

#Enemy spawns
var nextPowerup
var nextEnemy
var nextDifficultyUp
var enemySpeed
var enemyLeftRight = 0
var enemyLeftRightChance = 0

### Initial setup ###

#Initialization of level
func _ready():
	randomize()
	initialMousePos = Vector2(0, 0)
	moveDistance = screenSize.x / 3 - 30
	score = 0
	scoreFromEnemies = 0
	scoreFromPowerups = 0
	distance = 0
	levelEnded = false
	rocketHp = 5
	$GUI/PauseButton.show()
	
	setupLevel()
	_onready()
	updateHpBar(0)
	
	if levelIndex == 1:
		showInstructions = true
		showInstructions()
#Set level defaults
func setupLevel():
	pass
func _onready():
	addRockets()
	
	initializeGUI()
func addRockets():
	#Add rockets
	for thisRocket in rockets:
		thisRocket.connect("damaged", self, "_on_rocket_damaged") #Receives signal when rocket is destroyed
		thisRocket.connect("destroyed", self, "_on_rocket_destroyed") #Receives signal when rocket is destroyed
		thisRocket.connect("powerupCollected", self, "_on_powerup") #Receives signal when rocket collects bonus
		add_child(thisRocket)
		thisRocket.toggleActive(false)
	rockets[0].toggleActive(true)
	
	#Show queue of rockets
	updateRocketQueue()
func initializeGUI():
	#Reset GUI
	updateScore(0)

#Show instructions (for first level)
func showInstructions():
	$GUI/Instruction.show()
	$GUI/NextInstruction.show()
	
	showInstructionsControls()
#How to control rocket
func showInstructionsControls():
	$GUI/Arrows.show()
	$GUI/Instruction.text = "Swipe to control your rocket"
#What to collect or avoid
func showInstructionsGameAttributes():
	$GUI/Arrows.hide()
	$GUI/Examples.show()
	$GUI/Instruction.text = "Avoid or destroy enemies\n\nCollect green power cells for points, collect repair packs to increase HP"
#Next instruction
func _on_NextInstruction_pressed():
	if $GUI/Instruction.text == "Swipe to control your rocket":
		showInstructionsGameAttributes()
	else:
		showInstructions = false
		$GUI/Instruction.hide()
		$GUI/NextInstruction.hide()
		$GUI/Examples.hide()
		$GUI/Arrows.hide()


### Game processing ###

#Processing
func _process(delta):
	#If instructions are not being shown, process level
	if showInstructions == false:
		_callprocess(delta)
		#Spawn powerups and enemies
		spawnObjects(delta)
func _callprocess(delta):
	#Update distance progress indicator
	distance += delta * 10
	if !levelEnded and distance < finishLine:
		$GUI/DistanceBar.value = float(distance) / finishLine * 100
		$GUI/DistanceBar/Sprite.position.x = float(distance) / finishLine * $GUI/DistanceBar.rect_size.x
	
	#Level complete
	if distance >= finishLine and !levelEnded:
		endLevel(true)
func spawnObjects(delta):
	pass


### User input ###

#Tracks mouse gestures
func _unhandled_input(event):
	_oninput(event)
func _oninput(event):
	#Saves initial drag point
	if event is InputEventMouseButton and event.is_pressed():
		initialMousePos = event.position
		#Show mouse gesture indicator
		$GUI/MouseStart.position = event.position
		$GUI/MouseStart.show()
		$GUI/MouseStart/MouseStart2.show()
	#Move left/right if mouse has been dragged left/right
	elif event is InputEventMouseButton and !event.is_pressed():
		var mouseDiff = event.position - initialMousePos
		#Left/right swipe
		if abs(mouseDiff.x) > abs(mouseDiff.y) + 10:
			if mouseDiff.x < -minGestureDist:
				moveLeft(false)
			elif mouseDiff.x > minGestureDist:
				moveRight(false)
		elif abs(mouseDiff.y) > abs(mouseDiff.x) + 10:
			#Down swipe
			if mouseDiff.y > minGestureDist:
				switchRocketTrigger(false)
			#Up swipe
			elif mouseDiff.y < -minGestureDist:
				useSpecial(false)
		#Reset state variables
		initialMousePos = Vector2(0, 0)
		$GUI/GestureDescription.text = ""
		$GUI/MouseStart.hide()
		$GUI/MouseStart/MouseStart2.hide()
		$GUI/MouseStart/MouseStart2.position = Vector2(0,0)
		$GUI/MouseStart/MouseStart2.modulate = Color(1,1,1)
	#Preview which action will happen upon mouse-up
	elif event is InputEventMouseMotion and initialMousePos != Vector2(0, 0):
		var mouseDiff = event.position - initialMousePos
		#Update indicator
		$GUI/MouseStart/MouseStart2.position = mouseDiff.normalized() * clamp(mouseDiff.length() / 5, 0, 10)
		$GUI/GestureDescription.text = ""
		$GUI/MouseStart/MouseStart2.modulate = Color(1,1,1)
		#Left/right swipe
		if abs(mouseDiff.x) > abs(mouseDiff.y) + 10:
			if mouseDiff.x < -minGestureDist:
				moveLeft(true)
			elif mouseDiff.x > minGestureDist:
				moveRight(true)
		#Down swipe
		elif abs(mouseDiff.y) > abs(mouseDiff.x) + 10:
			#Down swipe
			if mouseDiff.y > minGestureDist:
				switchRocketTrigger(true)
			#Up swipe
			elif mouseDiff.y < -minGestureDist:
				useSpecial(true)
	#Keyboard controls for rocket movement
	elif Input.is_action_pressed("ui_left"):
		moveLeft(false)
	elif Input.is_action_pressed("ui_right"):
		moveRight(false)
	elif Input.is_action_just_pressed("ui_down"):
		switchRocketTrigger(false)
	elif Input.is_action_pressed("ui_up"):
		useSpecial(false)
	#Quit level
	elif Input.is_action_pressed("ui_cancel"):
		$GUI/PauseMenu._on_QuitButton_pressed()
	#Pause/unpause game
	elif Input.is_action_pressed("ui_pause"):
		_on_PauseButton_pressed()
func moveLeft(preview):
	if !preview:
		rockets[0].moveLeft()
	else:
		$GUI/GestureDescription.text = "Move left"
		$GUI/MouseStart/MouseStart2.modulate = Color(0,0,1)
func moveRight(preview):
	if !preview:
		rockets[0].moveRight()
	else:
		$GUI/GestureDescription.text = "Move right"
		$GUI/MouseStart/MouseStart2.modulate = Color(0,0,1)
func switchRocketTrigger(preview):
	if !preview:
		switchRockets(1)
	else:
		$GUI/GestureDescription.text = "Switch rockets"
		$GUI/MouseStart/MouseStart2.modulate = Color(1,0,0)
func useSpecial(preview):
	if !preview:
		rockets[0].useSpecial()
	elif rockets[0].specialAvailable == true:
		$GUI/GestureDescription.text = rockets[0].specialDesc
		$GUI/MouseStart/MouseStart2.modulate = Color(0,1,0)

#Pause/unpause
func _on_PauseButton_pressed():
	$GUI/PauseMenu/VBox/QuitButton.text = "Back to Menu"#Reset text that requires confirmation to quit
	get_tree().paused = true
	$GUI/PauseMenu.showType("pause")


### Rocket events ###

#Switch rockets
func switchRockets(switchPlace):
	#Copy position of current rocket to next rocket
	rockets[switchPlace].position = rockets[0].position
	
	#Continue any pending movement to next rocket
	if rockets[0].state == "MovingRight":
		rockets[switchPlace].moveRight()
	elif rockets[0].state == "MovingLeft":
		rockets[switchPlace].moveLeft()
	
	#Deactivate current rocket, activate next rocket
	rockets[0].toggleActive(false)
	rockets[switchPlace].toggleActive(true)
	
	#Move next rocket to current rocket slot
	var tempRocket = rockets[0]
	rockets[0] = rockets[switchPlace]
	for i in range(switchPlace,rockets.size() - 1):
		rockets[i] = rockets[i+1]
	rockets[rockets.size() - 1] = tempRocket
	
	updateRocketQueue()
	updateRocketGUI()

#Show queue of rockets
func updateRocketQueue():
	#For each inactive rocket, show a copy of that rocket in the queue (along with active abilities and timers)
	if rockets.size() >= 2:
		updateRocketSlot($GUI/RocketQueue/Rocket1,rockets[1])
	if rockets.size() >= 3:
		updateRocketSlot($GUI/RocketQueue/Rocket2,rockets[2])
	else:
		$GUI/RocketQueue/Rocket2.hide()
	if rockets.size() >= 4:
		updateRocketSlot($GUI/RocketQueue/Rocket3,rockets[3])
	else:
		$GUI/RocketQueue/Rocket3.hide()
#Update the slot for the inactive rocket
func updateRocketSlot(slot,inactiveRocket):
	var tempRocket
	if slot.get_children().size() > 0:
		tempRocket = slot.get_child(0)
		slot.remove_child(tempRocket)
		tempRocket.queue_free()
	slot.add_child(inactiveRocket.duplicate())
	tempRocket = slot.get_child(0)
	tempRocket.show()
	tempRocket.position = Vector2(30,33)
	
	copyTimers(tempRocket,inactiveRocket)
#Copy timers from inactive rocket to queue placeholder rocket
func copyTimers(rocket,rocketToCopy):
	if rocketToCopy.get_node("SpecialTimer").is_stopped() == false:
		rocket.get_node("SpecialTimer").wait_time = rocketToCopy.get_node("SpecialTimer").time_left
		rocket.get_node("SpecialTimer").start()
	if rocketToCopy.get_node("CDTimer").is_stopped() == false:
		rocket.get_node("CDTimer").wait_time = rocketToCopy.get_node("CDTimer").time_left
		rocket.get_node("CDTimer").start()
func updateRocketGUI():
	pass

#Swap this rocket with current rocket
func _on_Rocket1_pressed():
	switchRockets(1)
func _on_Rocket2_pressed():
	switchRockets(2)
func _on_Rocket3_pressed():
	switchRockets(3)

### Update score and hp

#When powerup is collected
func _on_powerup(thisPowerup):
	#Update score
	updateScore(thisPowerup.scoreIncrease)
	scoreFromPowerups += thisPowerup.scoreIncrease
	#Update rocket hp
	updateHpBar(thisPowerup.hpIncrease)

#When rocket is damaged, update rocket hp display
func _on_rocket_damaged():
	updateHpBar(-1)

#When enemy is destroyed, increase score
func _on_enemy_destroyed(scoreUp):
	updateScore(scoreUp)
	scoreFromEnemies += scoreUp

#Update score in GUI
func updateScore(scoreIncrease):
	if rocketHp > 0:
		score += scoreIncrease
		if levelIndex == 13:
			$GUI/ScoreLabel.text = " Score: " + str(round(score)) + "     Your high score: " + str(round(global.getScore(13)))
		else:
			$GUI/ScoreLabel.text = "Level " + str(levelIndex) + " Score: " + str(round(score))
		
		#Turn green for .3 seconds
		$GUI/ScoreLabel.modulate = Color(0,1,0)
		yield(get_tree().create_timer(.3), "timeout")
		$GUI/ScoreLabel.modulate = Color(1,1,1)

#Update the HP display
func updateHpBar(hpChange):
	rocketHp = min(rocketHp + hpChange, 10)
	#If hp hits zero, end level as a failure
	if rocketHp <= 0:
		endLevel(false)
	
	#Update HP label
	$GUI/HpLabel.text = str(rocketHp) + " HP"
	
	var hpSprites = get_tree().get_nodes_in_group("hpSprites")
	#Remove excess HP sprites
	if rocketHp < hpSprites.size():
		for i in range(rocketHp,hpSprites.size()):
			hpSprites[i].queue_free()
	#Add new HP sprites
	else:
		for i in range(get_tree().get_nodes_in_group("hpSprites").size(),rocketHp):
			var newHpSprite = HpSprite.instance()
			newHpSprite.position = Vector2(15, -20 - i * 30)
			$GUI/HpLabel.add_child(newHpSprite)



### End of level ###
#End level (win or lose)
func endLevel(win):
	levelEnded = true
	$GUI/PauseMenu.levelEnded = true
	
	#Display message
	if win == false:
		$GUI/PauseMenu.showType("lose")
		rockets[0].explode()
		
		if levelIndex == 13: #Track high score (instead of stars) for endless level
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text = "Your score: " + str(score)
			if score > global.getScore(13):
				global.updateScore(13, score)
				$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n   New high score!"
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n\nEarned " + str(score) + " credits"
		else:
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text = "Level " + str(levelIndex) + " failed"
			#Show score breakdown
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n\nEarned " + str(score) + " credits"
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n   " + str(scoreFromEnemies) + " from enemies"
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n   " + str(scoreFromPowerups) + " from power cells"
		#Update credits
		global.addCredits(score)
	else:
		$GUI/PauseMenu.showType("win")
		#Bonus points for hp left on rockets
		if bossLevel == true:
			scoreFromHP = rocketHp * 10
		else:
			scoreFromHP = rocketHp * 5
		$GUI/PauseMenu/VBox/LevelCompleteLabel.text = "Level " + str(levelIndex) + " completed!"
		
		#Earn credits
		updateScore(scoreFromHP)
		$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n\nEarned " + str(score) + " credits"
		$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n   " + str(scoreFromEnemies) + " from enemies"
		$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n   " + str(scoreFromPowerups) + " from power cells"
		$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n   " + str(scoreFromHP) + " from HP remaining"
		global.addCredits(score)
		if global.getScore(levelIndex) == 0:
			$GUI/PauseMenu/VBox/LevelCompleteLabel.text += "\n+50 credits for first-time clear"
			global.addCredits(50)
		
		#Update stars for this level
		if score > starThreshold[0]:
			$GUI/PauseMenu/VBox/Stars/Stars/Star1.texture = starTexture
			global.updateScore(levelIndex, 1)
		if score > starThreshold[1]:
			$GUI/PauseMenu/VBox/Stars/Stars/Star2.texture = starTexture
			global.updateScore(levelIndex, 2)
		if score > starThreshold[2]:
			$GUI/PauseMenu/VBox/Stars/Stars/Star3.texture = starTexture
			global.updateScore(levelIndex, 3)
		
		#If last level
		if levelIndex == 12:
			$GUI/PauseMenu/VBox/NextButton.text = "Play Endless"
		else:
			$GUI/PauseMenu/VBox/NextButton.text = "Next Level"
	
	#Wait 1 second before pausing everything
	yield(get_tree().create_timer(.5),"timeout")
	get_tree().paused = true
	#Update GUI
	$GUI/PauseButton.hide()

func _on_BackButton_pressed():
	get_tree().paused = false
	get_tree().change_scene(global.returnScene)
	queue_free()


