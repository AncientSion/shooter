tool
extends Node

# Run this by right-clicking the script in the FileSystem and choosing "Run" 
# or by adding a button to your editor UI.
func sync_csv_to_resources():
	
	var file = File.new()
	file.open("res://csv/weapontemplates.csv", file.READ)
	var headers = file.get_csv_line() # Read the first line for headers
	
	while !file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < 2: continue # Skip empty lines
		
		var weapon = WeaponData.new()
		weapon.display_name = line[1]
		weapon.type = int(line[0])
		# ... Map other columns ...		
		
#		dict[header[0]] = int(csv[0])
#		dict[header[1]] = str(csv[1])
#		dict[header[2]] = int(csv[2])
#		dict[header[3]] = float(csv[3])
#		dict[header[4]] = int(csv[4])
#		dict[header[5]] = str(csv[5])
#		dict[header[6]] = str(csv[6])
#		dict[header[7]] = float(csv[7])
#		dict[header[8]] = int(csv[8])
#		dict[header[9]] = int(csv[9])
#		dict[header[10]] = int(csv[10])
#		dict[header[11]] = float(csv[11])
#		dict[header[12]] = int(csv[12])
#		dict[header[13]] = int(csv[13])
#		dict[header[14]] = int(csv[14])
#		dict[header[15]] = int(csv[15])
#		dict[header[16]] = float(csv[16])
#		dict[header[17]] = int(csv[17])
#		dict[header[18]] = int(csv[18])
#		dict[header[19]] = int(csv[19])
#		dict[header[20]] = int(csv[20])
#		dict[header[21]] = int(csv[21])
#		dict[header[22]] = float(csv[22])
#		dict[header[23]] = float(csv[23])
#		dict[header[24]] = float(csv[24])
			
			
			
		
		var save_path = "res://weapons/" + weapon.display_name.to_snake_case() + ".tres"
		ResourceSaver.save(weapon, save_path)
	
	print("Sync Complete!")
