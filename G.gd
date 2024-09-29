extends Node


var ani = []
var willplayani = []
var playingani = []
var finishedani = []

# Called when the node enters the scene tree for the first time.
func _ready():
	AllSIGNAL.connect("anifinished",Callable($".", "_on_anifinished"))
	ani.append([1,1,"move",[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(2,1),Vector2i(3,1),Vector2i(3,2),Vector2i(3,3),Vector2i(4,3),Vector2i(5,3),Vector2i(5,2),Vector2i(5,1),Vector2i(6,1),Vector2i(7,1),Vector2i(8,1),Vector2i(9,1),Vector2i(10,1)],1])
	ani.append([2,1,"move",[Vector2i(10,1),Vector2i(10,2)],1])
	ani.append([3,1,"move",[Vector2i(10,2),Vector2i(10,3)],1])
	ani.append([4,1,"attack",[Vector2i(10,3),Vector2i(10,4)],1])
	ani.append([5,1,"sleep",[],1])
	ani.append([6,1,"sethp",[30],1])
	ani.append([7,1,"wakeup",[],1])
	#ani.append([3,0,"standby",[],1])
	#print(ani)
	#for i in range(ani.size()):
	#	var tempani = ani.duplicate()
	#	tempani.remove_at(i)
	#	var anii = ani[i]
	#	for j in range(tempani.size()):
	#		var tempanij  = tempani[j]
	#		print(ani[1])
	#		print(tempanij[1])
	#		if anii[1] == tempanij[1] : continue
	#		pass
	#	print(tempani)
	#	print(ani)
	#	print(i)

	pass
	#var i = 1
	#var tempani = ani
	#tempani.remove_at(i)
	#print(tempani)
	pass # Replace with function body.

func _on_anifinished(aniarr):
	finishedani.append(aniarr)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	if finishedani != []:
		for i in range(playingani.size()):
			var aaa = playingani[i]
			if aaa[0] == finishedani[0][0] and aaa[1] == finishedani[0][1]:
				playingani.remove_at(i)
				finishedani.clear()
				return
	
	
	if willplayani != []:
		AllSIGNAL.emit_signal("playani",willplayani[0])
		playingani.append(willplayani[0])
		willplayani.remove_at(0)
		return
	
	
	if playingani == [] and ani !=[]: 
		willplayani.append(Array(ani[0]))
		ani.remove_at(0)
		return
	#for i in range(finishedani.size()):
		#for j in range(playingani.size()):
			#if finishedani[i][0] == playingani[j][0] and finishedani[i][1] == playingani[j][1]:
				#playingani.remove_at(j)
				#break
	#finishedani.clear()
	
	
	
	
	
	pass
