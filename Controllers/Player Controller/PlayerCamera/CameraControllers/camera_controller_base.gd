extends Node
class_name CameraControllerBase

@export var camera: Camera2D
@export var zoom_speed: float
@export var pan_speed: float

@export var can_pan: bool
@export var can_zoom: bool
@export var can_rotate: bool

@export var min_zoom: = 0.5
@export var max_zoom: = 2.0

# Rotatin. TODO: Decide if whether to keep rotation.
@export var rotation_speed: float = 0.0

func limit_zoom():
	camera.zoom.x = clampf(camera.zoom.x, min_zoom, max_zoom)
	camera.zoom.y = clampf(camera.zoom.y, min_zoom, max_zoom)
