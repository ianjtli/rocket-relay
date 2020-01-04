extends "res://levels/Level.gd"

#Level definition: enemy spawns
var powerupDist : int
var enemyDist : int
var spawnUpDist : int
var spawnGap : int
var enemiesPerWave : int
var doubleEnemiesSpawned : int
var doubleEnemiesPerWave : int = 0
var maxEnemiesPerWave : int
var maxSpeed : int = 800
var lastPowerupX : int = 9999
var bossFightStarted
var dualSpawn : bool = false

#Reused
var newPowerup
var powerupCounter : int = 0

#Set up level
func setupLevel():
	bossFightStarted = false
	
	rockets = global.getActiveRockets()
	#Set level definition based on level number
	call("setup" + str(levelIndex))
	
	#Powerup spawn controls
	powerupDist = 15
	nextPowerup = powerupDist
	nextDifficultyUp = spawnUpDist
func setup1():
	finishLine = 400
	#Enemy spawn controls
	enemyDist = 30
	spawnUpDist = 100
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 350
	enemiesPerWave = 1
	maxEnemiesPerWave = 3
	#Star point threshold
	starThreshold = [30,40,55]
func setup2():
	finishLine = 500
	#Enemy spawn controls
	enemyDist = 25
	spawnUpDist = 100
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 350
	enemyLeftRightChance = 20
	enemiesPerWave = 1
	maxEnemiesPerWave = 4
	#Star point threshold
	starThreshold = [30,45,60]
func setup3():
	finishLine = 500
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 400
	enemyLeftRightChance = 30
	enemiesPerWave = 2
	maxEnemiesPerWave = 5
	#Star point threshold
	starThreshold = [35,50,65]
#Second set of levels has full waves of enemies
func setup5():
	finishLine = 400
	#Enemy spawn controls
	enemyDist = 30
	spawnUpDist = 100
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 350
	enemyLeftRightChance = 20
	enemiesPerWave = 1
	maxEnemiesPerWave = 3
	#Star point threshold
	starThreshold = [70,80,90]
	#Double up spawns for higher difficulty
	dualSpawn = true
func setup6():
	finishLine = 500
	#Enemy spawn controls
	enemyDist = 25
	spawnUpDist = 100
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 350
	enemyLeftRightChance = 20
	enemiesPerWave = 1
	maxEnemiesPerWave = 3
	#Star point threshold
	starThreshold = [70,100,120]
	#Double up spawns for higher difficulty
	dualSpawn = true
func setup7():
	finishLine = 500
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 400
	enemyLeftRightChance = 30
	enemiesPerWave = 2
	maxEnemiesPerWave = 3
	#Star point threshold
	starThreshold = [90,120,140]
	#Double up spawns for higher difficulty
	dualSpawn = true
#Third set of levels feature double-enemies
func setup9():
	finishLine = 400
	#Enemy spawn controls
	enemyDist = 25
	spawnUpDist = 100
	spawnGap = 120
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 350
	enemyLeftRightChance = 0
	enemiesPerWave = 3
	maxEnemiesPerWave = 5
	doubleEnemiesPerWave = 2
	#Star point threshold
	starThreshold = [90,120,160]
func setup10():
	finishLine = 500
	#Enemy spawn controls
	enemyDist = 25
	spawnUpDist = 100
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 350
	enemyLeftRightChance = 0
	enemiesPerWave = 3
	maxEnemiesPerWave = 5
	doubleEnemiesPerWave = 2
	#Star point threshold
	starThreshold = [110,140,180]
func setup11():
	finishLine = 500
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 70
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 400
	enemyLeftRightChance = 0
	enemiesPerWave = 4
	maxEnemiesPerWave = 6
	doubleEnemiesPerWave = 3
	#Star point threshold
	starThreshold = [130,160,200]

#Spawn enemies and powerups
func spawnObjects(delta):
	#Disallow spawns in last stretch (unless it's a boss fight)
	if (finishLine - distance > 30 or bossFightStarted) and !levelEnded:
		#Spawn powerups
		if distance >= nextPowerup:
			powerupCounter += 1
			nextPowerup = distance + powerupDist
			
			if !bossFightStarted:
				#Determine powerup horizontal location
				lastPowerupX = (randi() % 3 - 1) * moveDistance
				#Create the powerup
				newPowerup = Powerup.instance()
				newPowerup.position = Vector2(lastPowerupX, rockets[0].position.y - 1000)
				add_child(newPowerup)
			
			#Spawn hp powerups
			if powerupCounter == 6:
				powerupCounter = 0
				newPowerup = HpPowerup.instance()
				newPowerup.position = Vector2((randi() % 3 - 1) * moveDistance, rockets[0].position.y - 1100)
				add_child(newPowerup)
		#Spawn enemies
		if distance >= nextEnemy:
			doubleEnemiesSpawned = 0
			for i in range(0,enemiesPerWave):
				var newEnemy
				var spawnX = randi() % 3 - 1
				#Generate double-enemy ships up until the max
				if doubleEnemiesPerWave > doubleEnemiesSpawned:
					newEnemy = DoubleEnemy.instance()
					doubleEnemiesSpawned += 1
				else:
					newEnemy = Enemy.instance()
				newEnemy.connect("destroyed", self, "_on_enemy_destroyed") #Receives signal when enemy is destroyed
				newEnemy.position = Vector2(spawnX * moveDistance, rockets[0].position.y - 800 - spawnGap * i)
				add_child(newEnemy)
				if randi() % 100 <= enemyLeftRightChance:
					newEnemy.initialize(enemySpeed, rand_range(enemyLeftRight/2, enemyLeftRight))
				else:
					newEnemy.initialize(enemySpeed, 0)
				
				#For 2nd set of levels, double up each enemy spawn in a wave
				if dualSpawn == true:
					newEnemy = Enemy.instance()
					newEnemy.connect("destroyed", self, "_on_enemy_destroyed") #Receives signal when enemy is destroyed
					if spawnX == 1:
						newEnemy.position = Vector2((spawnX-1)%3 * moveDistance, rockets[0].position.y - 800 - spawnGap * i)
					else:
						newEnemy.position = Vector2((spawnX+1)%3 * moveDistance, rockets[0].position.y - 800 - spawnGap * i)
					add_child(newEnemy)
					newEnemy.initialize(enemySpeed, 0)
			nextEnemy = distance + enemyDist
		
		#Update spawn rates to increase difficulty as level goes on
		if distance >= nextDifficultyUp:
			call("updateSpawn" + str(levelIndex), delta)
			nextDifficultyUp = distance + spawnUpDist
func updateSpawn1(delta):
	#Number of enemies
	enemiesPerWave = clamp(enemiesPerWave + 1, 1, maxEnemiesPerWave)
	if enemiesPerWave % 2 == 0 or enemiesPerWave == maxEnemiesPerWave:
		enemySpeed = clamp(enemySpeed + 50, 300, maxSpeed)
func updateSpawn2(delta):
	#Number of enemies
	enemiesPerWave = clamp(enemiesPerWave + 1, 1, maxEnemiesPerWave)
	#Enemy move speed
	if enemiesPerWave % 2 == 1 or enemiesPerWave == maxEnemiesPerWave:
		enemySpeed = clamp(enemySpeed + 50, 300, maxSpeed)
	#Enemy horizontal speed
	if enemySpeed % 100 == 0:
		enemyLeftRight = clamp(enemyLeftRight + 50, 0, 200)
	#Enemy horizontal move chance
	if enemyLeftRight >= 200:
		enemyLeftRightChance = clamp(enemyLeftRightChance + 10, 0, 100)
func updateSpawn3(delta):
	#Number of enemies
	enemiesPerWave = clamp(enemiesPerWave + 1, 1, maxEnemiesPerWave)
	#Enemy move speed
	if enemiesPerWave % 2 == 1 or enemiesPerWave == maxEnemiesPerWave:
		enemySpeed = clamp(enemySpeed + 50, 300, maxSpeed)
	#Enemy horizontal speed
	if enemySpeed % 100 == 0:
		enemyLeftRight = clamp(enemyLeftRight + 50, 0, 200)
	#Enemy horizontal move chance
	if enemyLeftRight >= 200:
		enemyLeftRightChance = clamp(enemyLeftRightChance + 10, 0, 100)
func updateSpawn5(delta):
	updateSpawn2(delta)
func updateSpawn6(delta):
	updateSpawn3(delta)
func updateSpawn7(delta):
	updateSpawn3(delta)
func updateSpawn9(delta):
	updateSpawn2(delta)
func updateSpawn10(delta):
	updateSpawn3(delta)
func updateSpawn11(delta):
	updateSpawn3(delta)