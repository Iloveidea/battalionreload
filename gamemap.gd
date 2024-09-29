extends Node

var gamemap = Map.new("11","222",10)
var path_matrix :Dictionary= {}

var playernum = 3
var playername = ["player1","player2","player3",]
var playercolor = [
	GAMEDATA.COLOR_COIN_GRAY,
	GAMEDATA.COLOR_COIN_GOLD,
	GAMEDATA.COLOR_TEAL,
]

var turn = 0
var currentplayer = 0


var mapx = 10
var mapy = 10

var terrain = {
}

var building = {
}

var unit:Dictionary = {}



func _ready():
	gamemap.terrain = [
		[[0,0,0],[0,0,1],[0,0,1],[0,0,1],[0,2,0],[0,0,0],[0,0,0],[0,2,0],[0,2,1],[0,3,1],[0,0,1],[0,2,0],[0,2,1],[0,1,0],[0,0,0],[0,0,1],[0,1,0],[0,3,1],[0,3,1]],
		[[0,3,1],[0,0,1],[0,3,1],[0,2,0],[1,0,0],[1,3,0],[1,3,0],[0,1,1],[5,1,0],[0,3,1],[0,3,0],[0,0,1],[0,1,1],[9,0,8],[9,8,8],[9,8,8],[9,8,8],[9,12,8],[0,3,0]],
		[[0,3,0],[0,0,1],[0,3,0],[0,3,1],[0,2,1],[0,1,0],[0,2,0],[0,3,0],[0,3,0],[0,3,0],[0,0,1],[0,3,0],[0,2,0],[9,0,9],[9,4,10],[9,4,10],[9,4,10],[9,12,10],[0,0,1]],
		[[0,1,1],[0,3,1],[0,1,1],[0,0,0],[0,3,0],[0,0,1],[0,3,1],[0,0,1],[0,0,1],[0,0,0],[0,1,1],[0,2,1],[0,3,0],[9,0,9],[9,4,10],[9,4,10],[9,4,10],[9,12,10],[0,0,1]],
		[[0,1,0],[6,0,0],[0,3,1],[0,1,0],[0,0,0],[9,4,3],[9,4,4],[9,8,4],[9,8,3],[9,8,0],[9,8,3],[9,8,3],[9,8,3],[9,0,10],[9,4,10],[9,4,10],[9,4,10],[9,12,10],[0,3,1]],
		[[0,3,1],[0,1,0],[0,1,0],[0,2,0],[0,2,1],[0,3,0],[9,0,9],[9,12,10],[0,0,1],[9,0,1],[0,1,0],[0,0,1],[0,0,1],[9,0,11],[9,4,11],[9,4,11],[9,4,11],[9,12,11],[0,0,0]],
		[[0,2,0],[0,2,1],[0,3,1],[0,3,0],[9,4,3],[9,8,3],[9,4,7],[9,12,11],[0,0,1],[9,0,1],[0,1,1],[0,2,0],[0,0,0],[0,3,1],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,2,1]],
		[[0,3,0],[3,2,0],[0,0,0],[0,3,0],[0,3,0],[0,3,1],[0,0,0],[0,1,0],[0,3,0],[9,0,1],[0,3,0],[0,1,0],[0,3,0],[0,3,1],[0,1,0],[0,3,0],[0,2,0],[0,3,1],[0,3,1]],
		[[0,0,0],[0,0,0],[0,2,0],[0,0,0],[5,2,0],[0,2,1],[0,0,0],[1,1,0],[0,1,1],[9,0,1],[0,2,0],[0,2,0],[0,0,0],[0,3,1],[0,1,0],[0,1,0],[0,2,0],[0,1,0],[0,3,0]],
		[[0,3,1],[0,0,1],[0,3,1],[0,0,0],[0,3,1],[0,1,0],[0,0,1],[0,0,0],[0,3,0],[9,0,2],[0,2,0],[0,1,0],[0,3,1],[0,2,1],[0,0,1],[0,2,0],[0,2,1],[0,1,0],[0,2,1]],
		]
	gamemap.unit = {
		Vector2i(4,3) : {
			"player" : 0,
			"unitid" : 1,
			"unitobj" : null,
			"unit" : GAMEDATA.UNIT.WARMACHINE,
			"unitname" : "1st Annihilator Tank",
			"hp": 1,
			"direction" : "w",
			"unitflag" : [],
			"resource" : 0,
			"isaction" : false,
		},
		Vector2i(4,4) : {
			"player" : 1,
			"unitid" : 2,
			"unitobj" : null,
			"unit" : GAMEDATA.UNIT.ANNIHILATORTANK,
			"unitname" : "2nd Annihilator Tank",
			"hp": 140,
			"direction" : "e",
			"unitflag" : [],
			"resource" : 0,
			"isaction" : false,
		},
		Vector2i(4,5) : {
			"player" : 2,
			"unitid" : 3,
			"unitobj" : null,
			"unit" : GAMEDATA.UNIT.SCORPIONTANK,
			"unitname" : "3rd Annihilator Tank",
			"hp": 140,
			"direction" : "e",
			"unitflag" : [],
			"resource" : 0,
			"isaction" : false,
		},
	}
	
	gamemap.mapx = 19
	gamemap.mapy = 10
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass