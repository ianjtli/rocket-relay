extends "res://objects/Enemy.gd"

#Resources
export (PackedScene) var Enemy

#Override explosion
func explode():
	#Hide rocket
	$Sprite.hide()
	$Flames.hide()
	#Disable collisions during explosion animation
	$CollisionShape2D.set_deferred("disabled",true)
	#Show explosion
	$Explosion.start()
	#Trigger enemy destroyed actions
	emit_signal("destroyed", score)
	
	#Create specificatoin of off-shoot ship
	var newEnemy = Enemy.instance()
	newEnemy.connect("destroyed", get_parent(), "_on_enemy_destroyed") #Parent receives signal when enemy is destroyed
	newEnemy.position = position
	newEnemy.initialize(velocity.y, 200)
	
	#Stop movement
	velocity = Vector2(0,0)
	
	#Spawn the off-shoot after a short pause
	yield(get_tree().create_timer(.2),"timeout")
	get_parent().add_child(newEnemy)