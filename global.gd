extends Node

var dataToSave = {}
var returnScene : String = "res://gui/MainMenu.tscn"

#Autoload data
func _ready():
	#Create space for rockets
	dataToSave = {
		BoringRocket = 0,
		Credits = 0,
		SoundOn = true,
		MusicOn = true
	}
	for i in ["Boring Rocket","Mini Rocket","Shield Rocket","Sword Rocket"]:
		dataToSave[i] = 0
		dataToSave[i + " Active"] = 1
		dataToSave[i + "Upgrade1"] = 0
		dataToSave[i + "Upgrade2"] = 0
		dataToSave[i + "Upgrade3"] = 0
		dataToSave[i + "Upgrade1Active"] = 0
		dataToSave[i + "Upgrade2Active"] = 0
		dataToSave[i + "Upgrade3Active"] = 0
	#Have boring and mini rockets at beginning of game
	dataToSave["Boring Rocket"] = 1
	dataToSave["Mini Rocket"] = 1
	
	#Create space for scores
	for i in range(0,15):
		dataToSave["level" + str(i)] = 0
	
	#Load data from file
	load_data()
#Load data from file
func load_data():
	var save_datafile = File.new()
	if not save_datafile.file_exists("user://save_file.save"):
		save_game()
	
	save_datafile.open("user://save_file.save", File.READ)
	var current_line = parse_json(save_datafile.get_line())
	for key in dataToSave:
		if dataToSave.has(key) and current_line.has(key):
			dataToSave[key] = current_line[key]
#Save data to file
func save_game():
	var save_datafile = File.new()
	save_datafile.open("user://save_file.save", File.WRITE)
	save_datafile.store_line(to_json(dataToSave))
	save_datafile.close()
	print("Game saved")


#Update score for the level if new high score
func updateScore(index, value):
	if value > dataToSave["level" + str(index)]:
		dataToSave["level" + str(index)] = value
		save_game()
#Returns the score for the level
func getScore(index):
	return dataToSave["level" + str(index)]


#Buy rocket
func buyRocket(rocketName):
	dataToSave[rocketName] = 1
	dataToSave[rocketName + " Active"] = 1
	save_game()
#Activate or deactivate rocket
func toggleRocket(rocketName):
	dataToSave[rocketName + " Active"] = 1 - dataToSave[rocketName + " Active"]
	save_game()
	return dataToSave[rocketName + " Active"]
#Buy upgrades
func buyRocketUpgrade(rocketName, number):
	dataToSave[rocketName + "Upgrade" + str(number)] = 1
	dataToSave[rocketName + "Upgrade" + str(number) + "Active"] = 1
	save_game()
#Activate or deactivate upgrades
func toggleUpgrade(rocketUpgrade):
	dataToSave[rocketUpgrade + "Active"] = 1 - dataToSave[rocketUpgrade + "Active"]
	save_game()
	return dataToSave[rocketUpgrade + "Active"]
#Returns the list of rockets and upgrades purchased
func getRocketList():
	return dataToSave
#Returns list of all rockets
func getAllRockets():
	var rockets = []
	var BoringRocket = load("res://rockets/Rocket.tscn")
	var MiniRocket = load("res://rockets/MiniRocket.tscn")
	var ShieldRocket = load("res://rockets/ShieldRocket.tscn")
	var SwordRocket = load("res://rockets/SwordRocket.tscn")
	rockets.append(BoringRocket.instance())
	rockets.append(MiniRocket.instance())
	rockets.append(ShieldRocket.instance())
	rockets.append(SwordRocket.instance())
	return rockets
#Returns list of rockets activated by the player
func getActiveRockets():
	var rockets = []
	var BoringRocket = load("res://rockets/Rocket.tscn")
	var MiniRocket = load("res://rockets/MiniRocket.tscn")
	var ShieldRocket = load("res://rockets/ShieldRocket.tscn")
	var SwordRocket = load("res://rockets/SwordRocket.tscn")
	if dataToSave["Boring Rocket"] == 1 and dataToSave["Boring Rocket Active"] == 1:
		rockets.append(BoringRocket.instance())
	if dataToSave["Mini Rocket"] == 1 and dataToSave["Mini Rocket Active"] == 1:
		rockets.append(MiniRocket.instance())
	if dataToSave["Shield Rocket"] == 1 and dataToSave["Shield Rocket Active"] == 1:
		rockets.append(ShieldRocket.instance())
	if dataToSave["Sword Rocket"] == 1 and dataToSave["Sword Rocket Active"] == 1:
		rockets.append(SwordRocket.instance())
	return rockets

#Credits
func getCredits():
	return dataToSave["Credits"]
func addCredits(numCredits):
	dataToSave["Credits"] += numCredits
	save_game()
func spendCredits(numCredits):
	dataToSave["Credits"] -= numCredits
	save_game()


#Get sound/music status
func getSoundOn():
	return dataToSave["SoundOn"]
func getMusicOn():
	return dataToSave["MusicOn"]
#Toggle sound/music
func toggleSound():
	dataToSave["SoundOn"] = !dataToSave["SoundOn"]
	save_game()
func toggleMusic():
	if get_node("/root/Music").is_playing():
		get_node("/root/Music").stop()
		dataToSave["MusicOn"] = false
	else:
		get_node("/root/Music").play()
		dataToSave["MusicOn"] = true
	save_game()