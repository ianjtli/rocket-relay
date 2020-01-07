extends Control

var levelEnded : bool
var tips : Array = ["switch rockets when your ability is on cooldown to take advantage of teammates' abilities",
	"some rockets become a lot more useful with upgrades, use credits to upgrade their abilities in the upgrade shop",
	"mini rocket's ability avoids all enemies for a short duration, use it to get out of impossible situations",
	"smaller and faster rockets may be able to better maneuver in tight spots"]

#Show labels/buttons based on state of game
func showType(type):
	show()
	if type == "win":
		$Background.show()
		$VBox.rect_position.y = 0
		$VBox/LevelCompleteLabel.show()
		$VBox/TipLabel.hide()
		$VBox/Stars.show()
		$VBox/StarsTip.show()
		$VBox/NextButton.show()
		$VBox/UpgradeButton.show()
		$VBox/UnpauseButton.hide()
		$VBox/RestartButton.hide()
	elif type == "lose":
		$Background.show()
		$VBox.rect_position.y = 0
		$VBox/LevelCompleteLabel.show()
		showTips()
		$VBox/Stars.hide()
		$VBox/StarsTip.hide()
		$VBox/NextButton.hide()
		$VBox/UpgradeButton.show()
		$VBox/UnpauseButton.hide()
		$VBox/RestartButton.show()
	elif type == "pause":
		$Background.hide()
		$VBox.rect_position.y = 150
		$VBox/LevelCompleteLabel.hide()
		$VBox/TipLabel.hide()
		$VBox/Stars.hide()
		$VBox/StarsTip.hide()
		$VBox/NextButton.hide()
		$VBox/UpgradeButton.hide()
		$VBox/UnpauseButton.show()
		$VBox/RestartButton.show()

#Randomly select a tip to show
func showTips():
	$VBox/TipLabel.show()
	var randNum = randi() % tips.size()
	$VBox/TipLabel.text = "Tip: " + tips[randNum]

#Unpause
func _on_UnpauseButton_pressed():
	$VBox/QuitButton.text = "Back to Menu"#Reset text that requires confirmation to quit
	get_tree().paused = false
	hide()

#Restart level
func _on_RestartButton_pressed():
	#Clean up
	for entity in get_tree().get_nodes_in_group("powerups"):
    	entity.queue_free()
	for entity in get_tree().get_nodes_in_group("rockets"):
    	entity.queue_free()
	for entity in get_tree().get_nodes_in_group("obstacles"):
    	entity.queue_free()
	#Reset level
	get_parent().get_parent()._ready()
	#Unpause
	get_tree().paused = false
	hide()

#Quit level
func _on_QuitButton_pressed():
	#If already confirmed, exit level
	if $VBox/QuitButton.text == "Confirm quit?" or levelEnded == true:
		get_tree().paused = false
		get_tree().change_scene(global.returnScene)
		get_parent().get_parent().queue_free()
	else:
		$VBox/QuitButton.text = "Confirm quit?"

#Move on to next level
func _on_NextButton_pressed():
	get_tree().paused = false
	
	var levelNum = get_parent().get_parent().levelIndex + 1
	#Loads level based on button pressed
	var next_level_resource
	if levelNum == 4 or levelNum == 8 or levelNum == 12 or levelNum == 13: #Boss levels
		next_level_resource = load("res://levels/BossLevel.tscn")
	else:
		next_level_resource = load("res://levels/StandardLevel.tscn")
	var next_level = next_level_resource.instance()
	next_level.levelIndex = levelNum
	next_level.setupLevel()
	get_tree().get_root().add_child(next_level)
	get_parent().get_parent().queue_free()

#Go to rocket upgrade shop
func _on_UpgradeButton_pressed():
	get_tree().paused = false
	
	get_tree().change_scene("res://gui/RocketGuide.tscn")
	get_parent().get_parent().queue_free()
