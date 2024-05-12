extends Placable
class_name KnightsHouse

var house_data :HouseData:
	set(value):
		house_data = value
		if !house_data:
			return
		house_data.add_food_to_limit()
