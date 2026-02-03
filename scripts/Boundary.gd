extends Node2D

var isPlayer:bool = false
var isWeapon:bool = false
var isObstacle = true
var faction = -1
var display = "Boundary"

var minDmg = 30
var maxDmg = 40
var dmgType = 1
var impactForce = Vector2.ZERO

var dmgZones = {"DmgNormal": 1}
var id = -1
var destroyed = false

func _on_Bound_area_entered(area):
	if area.name == "Sight" or area.name == "Shield":
		return
#	print(area.owner.get_class(), " did ENTER boundary, position is :", area.owner.global_position)
#	print(area.owner.get_class(), " is out of bounds, pos: ", area.owner.global_position, " area: ", area.name)
	area.owner.enterBoundary()
	
func _on_Bound_area_exited(area):
	if area.name == "Sight" or area.name == "Shield":
		return
#	print(area.owner.get_class(), " did EXIT boundary, position is :", area.owner.global_position)
	var pos = area.owner.global_position
	if pos.x > 0 and pos.x < Globals.WIDTH and pos.y > 0 and pos.y < Globals.ROADY:
		area.owner.exitBoundary()
	
func canExplodeOnContact():
	return false
	
func getDamageObject():
	return self
	
func getRamDamage():
#	return false
	var ramBullet = Globals.BULLET.instance()
	Globals.curScene.get_node("Refs").add_child(ramBullet)
	ramBullet.minDmg = 10
	ramBullet.maxDmg = 10
#	print("ramBullet from ", self.display, ": ", ramBullet.minDmg, " - ", ramBullet.maxDmg)
	ramBullet.set_physics_process(false)
	ramBullet.disableTriggerCollisionNodes()
	ramBullet.hide()
	ramBullet.position = global_position
#	var effect = (ramBullet.minDmg + ramBullet.maxDmg) * self.velocity.length() * mass
#	ramBullet.impactForce = Globals.getRecoilForce(ramBullet.minDmg, ramBullet.maxDmg, self.velocity.length()) * mass / 2
	return ramBullet

func getPointOfImpact(impactedEntity):
	return impactedEntity.global_position
	
func getAttackAngle(impactedEntity):
	return 0

func postImpacting():
	return false
	
func takeDamage(entity, totalDmg:int):
	return
	
func get_class():
	return "Boundary"
	
func has_active_omni_shield():
	return false
