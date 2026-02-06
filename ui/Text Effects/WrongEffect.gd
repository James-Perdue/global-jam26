@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name WrongEffect
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [wrong_effect param=2.0]hello[/wrong_effect] in text.
var bbcode := "ww"


func _process_custom_fx(char_fx: CharFXTransform) :
	var duration = char_fx.env.get("duration", 5)
	var t = (char_fx.elapsed_time*30) / duration
	var a = clamp(t,0,1)
	if t<1.3:
		char_fx.offset.x = ((8 * (sin((char_fx.elapsed_time)*90)))+3) * (2-t)
		char_fx.color = char_fx.env.get("color","red")
