extends Node2D

class_name Trajectory

@export var FORCE : float = 1000

@onready var fake_ball: CharacterBody2D = $FakeBall
var img : CompressedTexture2D = preload("res://Assets/Ball/ball_outline.png")

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag and visible:
		queue_redraw()

func _draw() -> void:
	update_trajectory()

func get_forward_direction() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())


#draw_circle(position: Vector2, radius: float, color: Color, filled: bool = true, width: float = -1.0, antialiased: bool = false)

func update_trajectory() -> void:
	var velocity : Vector2 = FORCE * get_forward_direction()
	var line_start : Vector2 = global_position
	var line_end : Vector2
	var timestep : float = 0.05
	var ball_collision : int = 0
	#var colors : PackedColorArray = [Color.DIM_GRAY,Color.LIGHT_GRAY]
	
	fake_ball.global_position = line_start
	
	for i : int in 35:
		line_end = line_start + (velocity * timestep)
		
		var collision : KinematicCollision2D = fake_ball.move_and_collide(velocity * timestep)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			#var pointA : Vector2 = line_start - global_position
			#var pointB : Vector2 = line_end - global_position
			#draw_dashed_line(pointA, pointB,Color.LIGHT_YELLOW)
			#draw_circle(pointA,10,Color.AQUAMARINE,false,2.0,true)
			#draw_circle((pointA + pointB)/2,6,Color.AQUAMARINE,false,1.0,true)
			line_start = fake_ball.global_position
			ball_collision += 1
			if ball_collision >= 2:
				break
			continue
		
		#var ray : Dictionary = raycast_query2d(line_start,line_end)
		
		#if not ray.is_empty():
			#velocity = velocity.bounce(ray.normal)
			#var pointA : Vector2 = line_start - global_position
			#var pointB : Vector2 = line_end - global_position
			#draw_line(pointA, pointB,Color.YELLOW,5)
			#line_start = ray.position
			#ray_collision += 1
			#if ray_collision >= 2:
				#break
			#continue
		
		var pointA : Vector2 = line_start - global_position + Vector2(-8,-8)
		var pointB : Vector2 = line_end - global_position + Vector2(-8,-8)
		draw_texture(img,pointA)
		draw_texture(img,pointB)
		line_start = line_end

#func raycast_query2d(pointA : Vector2, pointB : Vector2) -> Dictionary:
	#var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	#var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(pointA,pointB)
	#var result : Dictionary = space_state.intersect_ray(query)
	#
	#if result:
		#return result
	 #
	#return {}
