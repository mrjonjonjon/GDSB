@tool
extends Node2D

@export var z:float = 0
@export var width: float= 1
@export var height:float = 1
@export var depth:float = 1

@export var my_velocity:Vector3 = Vector3(0,0,0)



@export var fixZ:bool = false
@export var gravity_scale:float =1;


@export var debug_view:bool = false
var line_color= Color.BLUE



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		queue_redraw()
		adjust_col_shape()
		adjust_sprite()
		if not Engine.is_editor_hint():
			apply_gravity()

func apply_gravity():
	if not fixZ:
		z=clamp(z-gravity_scale,0,1000)


func adjust_col_shape():
	var col_shape=$Area2D/CollisionShape2D
	col_shape.scale=Vector2(width,depth)

	var vis_area = $Sprite/VisibleArea/CollisionShape2D
	vis_area.scale = Vector2(width,depth+height)
	vis_area.position.y=-(depth+height)/2 +depth/2

func adjust_sprite():
	var base = $Sprite

	base.position=Vector2(base.position.x,-z)
	var sprite = $Sprite/Bottom
	var tt_width = sprite.texture.get_width()
	var tt_height = sprite.texture.get_height()


	sprite.scale=Vector2(width/tt_width,height/tt_height)
	sprite.position=Vector2(0,depth/2 - height/2)

	var top_sprite = $Sprite/Top
	var t_width = top_sprite.texture.get_width()
	var t_height = top_sprite.texture.get_height()

	top_sprite.scale=Vector2(width/t_width,depth/t_height)
	top_sprite.position=Vector2(0,sprite.position.y-depth/2-height/2)


func _draw():
	if debug_view:
		var col_shape = $Area2D/CollisionShape2D.shape
	

		var top_left = Vector2(-width/2,-depth/2)
		var top_right = Vector2(width/2,-depth/2)
		var bottom_left =Vector2(-width/2,depth/2)
		var bottom_right = Vector2(width/2,depth/2)

		draw_line(top_left, top_right, Color.GREEN, 1.0)
		draw_line(top_right, bottom_right, Color.GREEN, 1.0)
		draw_line(bottom_right, bottom_left, Color.GREEN, 1.0)
		draw_line(bottom_left, top_left, Color.GREEN, 1.0)
