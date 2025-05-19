extends Node

const PROJECTILE: PackedScene = preload("res://src/projectile/Projectile.tscn")

var force: float = 400
var damage: float = 0
var projectiles_per_shot: int = 1



func create_projectile() -> Projectile:
	var new_projectile: Projectile = PROJECTILE.instantiate()
	
	new_projectile.force = force
	new_projectile.damage = damage
	return new_projectile
