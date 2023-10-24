
extends Node2D

@export var groups=[]
@export var do=false


@export var debug_view:bool = false

var arrowhead_length = 5
var onetime=true
var g={}
var indeg={}
var froms=[]
var tos=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _draw():
	if debug_view:
		for i in range(len(froms)):
			draw_arrow(froms[i],tos[i])


func draw_arrow(node1, node2):
	print("drawing arrow")
	var node1_position = node1.position
	var node2_position = node2.position

	draw_line(node1_position, node2_position, Color.YELLOW, 1)

	var direction = (node2_position - node1_position).normalized()
	var arrowhead_p1 = node2_position - direction * arrowhead_length + direction.orthogonal() * arrowhead_length * 0.5
	var arrowhead_p2 = node2_position - direction * arrowhead_length - direction.orthogonal() * arrowhead_length * 0.5

	# Define the points of the arrowhead
	var arrowhead_points = PackedVector2Array([node2_position, arrowhead_p1, arrowhead_p2])

	# Draw a filled blue triangle for the arrowhead
	draw_colored_polygon(arrowhead_points,Color(0, 0, 1))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	if true:
		froms.clear()
		tos.clear()
		sort()
		assign_z_index()
		do=false
		onetime=false

func order(block1,block2):
	if block1.position.y+block1.depth/2 <block2.position.y - block2.depth/2:
		return -1#block 1 rendered first. ie block 2 shows on top
	if block2.position.y+block2.depth/2 <block1.position.y - block1.depth/2:
		return 1

	if block1.z+block1.height <block2.z:
		return -1

	if block2.z+block2.height <block1.z:
		return 1
		
	return -1 if block1.position.y<block2.position.y else 1

func add_to_dict(dict,key,val):
	if key in dict:
		if val not in dict[key]:
			dict[key].append(val)
			indeg[val]=1 if val not in indeg else indeg[val]+1
	else:
		dict[key]=[val]
		indeg[val]=1 if val not in indeg else indeg[val]+1
	
func dfs(block,seen):
	var ans=[]
	#print(block.name)
	ans.append(block.name)
	seen[block]=null
	var overlapping_areas = block.get_node('Sprite/VisibleArea').get_overlapping_areas()
	#print('ol',overlapping_areas)
	for area in overlapping_areas:
		var other_block = area.get_node('../..')
		
		if order(block,other_block)==-1:
			add_to_dict(g,block.name,other_block.name)
			#if a is rendered before b, a->b
			#draw_arrow(block,other_block)
			froms.append(block)
			tos.append(other_block)
		elif order(block,other_block)==1:
			add_to_dict(g,other_block.name,block.name)
			#draw_arrow(other_block,block)
			froms.append(other_block)
			tos.append(block)
	

	for area in overlapping_areas:
		var other_block = area.get_node('../..')
		if seen.has(other_block):continue
		ans+=dfs(other_block,seen)
	return ans
func z_dfs(block,seen,curnum):
	print('setting node zindex ',block.name,' to ',curnum)
	block.get_node("Sprite").z_index=curnum
	#block.visible = false
	seen[block.name]=null
	if block.name in g:
		for n in g[block.name]:
			if n in seen:continue
			
			z_dfs(get_node(NodePath(n)),seen,curnum+1)


func assign_z_index():
	
	var all_blocks = get_tree().get_nodes_in_group("blocks")
	for block in all_blocks:
		
		if block.name in indeg:continue
		print('zzzzz',block.name)
		z_dfs(block,{},0)

		
	
func sort():
	g.clear()
	indeg.clear()

	groups=[]
	var used={}
	var all_blocks = get_tree().get_nodes_in_group("blocks")

	for block in all_blocks:

		
		if used.has(block.name):continue
		#print('dfs from ',block.name,block.position)
		var group=dfs(block,{})
		groups.append(group)
		for gm in group:
			used[gm]=null

	print(g,indeg)
	return groups
