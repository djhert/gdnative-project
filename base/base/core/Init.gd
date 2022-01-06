extends Node

#onready var _next = preload("res://")

func _ready():
	#SceneManager.change_scene(_next)
	#SceneManager.fade_in("ANIM", 2.0, 0)
	#SceneManager.fade_out("ANIM", 2.0, 1)
	#SceneManager.connect("fade_in", self, "_onFade")
	#SceneManager.connect("fade_out", self, "_onFade")
	#SceneManager.quit()
	pass

func _onFade(num : int) -> void:
	pass
