extends "res://levels/StandardLevel.gd"

export (PackedScene) var Boss
export (PackedScene) var Boss2
var bossNum

func setup4():
	bossLevel = true
	finishLine = 100
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 100
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 400
	enemyLeftRight = 0
	enemyLeftRightChance = 30
	enemiesPerWave = 3
	maxEnemiesPerWave = 5
	#Star point threshold
	starThreshold = [80,120,140]
func setup8():
	bossLevel = true
	finishLine = 100
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 70
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 400
	enemyLeftRightChance = 30
	enemiesPerWave = 2
	maxEnemiesPerWave = 2
	#Star point threshold
	starThreshold = [100,150,180]
	#Double up spawns
	dualSpawn = true
func setup12():
	bossLevel = true
	finishLine = 100
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 80
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 400
	enemyLeftRightChance = 30
	enemiesPerWave = 4
	maxEnemiesPerWave = 5
	doubleEnemiesPerWave = 2
	#Star point threshold
	starThreshold = [150,210,250]
func setup13():
	bossLevel = true
	finishLine = 20000
	#Enemy spawn controls
	enemyDist = 20
	spawnUpDist = 80
	spawnGap = 80
	nextEnemy = enemyDist + 4
	#Initial enemy settings
	enemySpeed = 300
	enemyLeftRight = 0
	enemyLeftRightChance = 0
	enemiesPerWave = 3
	maxEnemiesPerWave = 8
	doubleEnemiesPerWave = 0
	#Star point threshold
	starThreshold = [5000,10000,20000]

func updateSpawn4(delta):
	#Number of enemies
	enemiesPerWave = clamp(enemiesPerWave + 1, 1, maxEnemiesPerWave)
	#Enemy move speed
	if enemiesPerWave % 2 == 1:
		enemySpeed = clamp(enemySpeed + 50, 300, maxSpeed)
	#Enemy horizontal speed
	if enemySpeed % 100 == 0:
		enemyLeftRight = clamp(enemyLeftRight + 50, 0, 200)
	#Enemy horizontal move chance
	if enemyLeftRight >= 200:
		enemyLeftRightChance = clamp(enemyLeftRightChance + 15, 0, 100)
func updateSpawn8(delta):
	updateSpawn4(delta)
func updateSpawn12(delta):
	updateSpawn11(delta)
func updateSpawn13(delta):
	#Number of enemies
	if enemiesPerWave < maxEnemiesPerWave:
		enemiesPerWave += 1
	elif doubleEnemiesPerWave < maxEnemiesPerWave:
		doubleEnemiesPerWave += 1
	#Enemy move speed
	if enemiesPerWave % 2 == 0 or doubleEnemiesPerWave == maxEnemiesPerWave:
		enemySpeed = clamp(enemySpeed + 50, 300, maxSpeed)
	#Enemy horizontal speed
	if enemiesPerWave == maxEnemiesPerWave:
		enemyLeftRight = clamp(enemyLeftRight + 50, 0, 200)
	#Enemy horizontal move chance
	if enemyLeftRight >= 200:
		enemyLeftRightChance = clamp(enemyLeftRightChance + 15, 0, 100)


func _callprocess(delta):
	#Update score and distance
	distance += delta * 10
	if !levelEnded and distance < finishLine:
		$GUI/DistanceBar.value = float(distance) / finishLine * 100
		$GUI/DistanceBar/Sprite.position.x = float(distance) / finishLine * $GUI/DistanceBar.rect_size.x
	#Start boss fight
	if distance >= finishLine and !bossFightStarted:
		spawnBoss()
		bossFightStarted = true
		
		#Reduce enemies
		enemiesPerWave = 2

#Spawns the boss
func spawnBoss():
	var newBoss
	#1st and 2nd boss are similar, 3rd boss is tougher and spawns enemies when damaged
	if levelIndex == 4 or levelIndex == 8:
		newBoss = Boss.instance()
	elif levelIndex == 12 or levelIndex == 13:
		newBoss = Boss2.instance()
	newBoss.connect("destroyed", self, "_on_boss_destroyed") #Receives signal when enemy is destroyed
	newBoss.position = Vector2(0, rockets[0].position.y - 800)
	add_child(newBoss)
	
	#2nd boss has more hp
	if levelIndex == 8:
		newBoss.hp = 8
	
	#If they ever reach the end of the "endless" level
	if levelIndex == 13:
		var bossTwo = Boss2.instance()
		bossTwo.connect("destroyed", self, "_on_boss_destroyed") #Receives signal when enemy is destroyed
		bossTwo.position = Vector2(0, rockets[0].position.y - 800)
		add_child(bossTwo)

#End level when boss defeated
func _on_boss_destroyed(scoreUp):
	_on_enemy_destroyed(scoreUp)
	
	endLevel(true)