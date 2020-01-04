extends "res://objects/Boss.gd"

#Resources
const Enemy = preload("res://objects/Enemy.tscn")

#Initialize
func _onready():
	hp = 10
	damage = 1
	anchorPos = Vector2(-9999,-9999)
	
	#Get screen limits
	screenSize = get_viewport().get_visible_rect().size
	horizontalMove = screenSize.x / 5
	
	velocity = Vector2(0,350)
	score = 100
	
	$HPGone.show()
	$HPLeft.show()
	
	state = "approaching"

#Override damage
func damagedBy(area):
	if (area.is_in_group("rockets") or area.is_in_group("bullets")) and invincibility == false:
		hp = hp - area.damage
		update_hp()
		if hp <= 0:
			explode()
		else:
			$SmallExplosion.start()
			#Turn on momentary invincibility
			invincibility = true
			$InvincibilityTimer.start()
			flash()
		
		#Generates a small off-shoot ship upon hit
		var newEnemy = Enemy.instance()
		newEnemy.connect("destroyed", get_parent(), "_on_enemy_destroyed") #Parent receives signal when enemy is destroyed
		newEnemy.position = position
		get_parent().add_child(newEnemy)
		newEnemy.initialize(450, 100)