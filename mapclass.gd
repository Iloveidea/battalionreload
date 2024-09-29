class_name Map
extends Node
var mapname : String
var mapdescription : String
var turns : int
#var year : int
#var month : int
#var day : int
#var season : String

var playerdata : Array
var mapx : int
var mapy : int
var terrain : Array
var building : Dictionary
var unit : Dictionary

func _init(name = "untitled",description = "description",turn = 10):
	mapname = name
	mapdescription = description
	turns = turn
	pass
