extends Camera2D
class_name PlayerCamera

func correct_zoom():
	var tween = create_tween()
	tween.tween_property(self, "zoom", Vector2(0.8, 0.8), 2.0).set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(func() :owner.show_ui())
