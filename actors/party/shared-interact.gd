extends StaticBody3D

signal hovering
signal clicked
signal unhovering

func hover():
	var s = emit_signal("hovering")
	if s != OK:
		Global.printSignalError("shared-interact", "hover", "hovering")

func click():
	var s = emit_signal("clicked")
	if s != OK:
		Global.printSignalError("shared-interact", "click", "clicked")

func unhover():
	var s = emit_signal("unhovering")
	if s != OK:
		Global.printSignalError("shared-interact", "unhover", "unhovering")
