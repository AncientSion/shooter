
func loadItemTemplatesJSON():
	var file_path = "res://json/items.json"
	var file = File.new()
	file.open(file_path, File.READ)
	var content_as_text = file.get_as_text()
	var json = parse_json(content_as_text)
	
	for item in json:
		item.type = int(item.type)
	for n in json:
		itemTemplates.append(n)


func getItemByName(display):
	for n in itemTemplates:
		#print("getSpecificBaseWeaponByName")
		#print(n.display)
		if n.display == display:
			return constructItem(n)
			
func constructItem(pick):
	print("constructItem ", pick.display)
	var base = Globals.get(pick.constructor).instance()
	if pick.script != "":
		var string = str("res://scenes/Utilities/Item_", pick.script, ".gd")
		base.set_script(load(string))
	base.constructNew(pick)
	return base
