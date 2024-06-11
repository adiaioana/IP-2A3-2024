extends Node



# MAP DATA #####################################################################
var selectedRegion

var spice = {}
var oldStormPosition
var stormPosition = 0;
var shieldDestroyed : bool = false;
# Define the dictionary with zones and their properties
var territories = {
	"funeral-plain": {"spice": 2, "forces": 3},
	"the-great-flat": {"spice": 3, "forces": 4},
}

var territorySpice = [
	{"sector": "funeral-plain", "spice": "4"},
	{"sector": "the-great-flat", "spice": "2"}
]

var forces = {}

var territoryForces = [
	{"name": "the-great-flat", "forces": {"harkonnen": 4, "space_guild": 2}},
	{"name": "funeral-plain", "forces": {"atreides": 4, "emperor": 10}}
]
# api gives sectionId, faction and nr of forces
# sectionId -> name 
# struct with names and factionid and forces

var sections_goofy_dict = {
	6: "meridian-1",
	84: "cielago-west-1",
	3: "cielago-depression-1",
	0: "cielago-north-1",
	7: "meridian-2",
	8: "cielago-south-2",
	4: "cielago-depression-2",
	1: "cielago-north-2",
	9: "cielago-south-3",
	10: "cielago-east-3",
	5: "cielago-depression-3",
	2: "cielago-north-3",
	11: "cielago-east-4",
	16: "south-mesa-4",
	14: "false-wall-south-4",
	12: "harg-pass-4",
	17: "south-mesa-5",
	32: "tueks-sietch",
	28: "pasty-mesa-5",
	15: "false-wall-south-5",
	13: "harg-pass-5",
	24: "minor-erg-5",
	19: "false-wall-east-5",
	18: "south-mesa-6",
	29: "pasty-mesa-6",
	25: "minor-erg-6",
	20: "false-wall-east-6",
	33: "red-chasm",
	30: "pasty-mesa-7",
	26: "minor-erg-7",
	21: "false-wall-east-7",
	36: "gara-kulon",
	31: "pasty-mesa-8",
	34: "shield-wall-8",
	27: "minor-erg-8",
	22: "false-wall-east-8",
	43: "sihaya-ridge",
	42: "basin",
	44: "old-gap-9",
	41: "rim-wall-west",
	40: "hole-in-rock",
	35: "shield-wall-9",
	37: "imperial-basin-9",
	23: "false-wall-east-9",
	45: "old-gap-10",
	47: "arrakeen",
	38: "imperial-basin-10",
	54: "broken-land-11",
	46: "old-gap-11",
	51: "tsimpo-11",
	39: "imperial-basin-11",
	50: "carthag",
	48: "arsunt-11",
	55: "broken-land-12",
	58: "plastic-basin-12",
	52: "tsimpo-12",
	56: "hagga-basin-12",
	49: "arsunt-12",
	61: "rock-outcroppings-13",
	59: "plastic-basin-13",
	53: "tsimpo-13",
	57: "hagga-basin-13",
	62: "rock-outcroppings-14",
	68: "bight-cliff-14",
	67: "sietch-tabr",
	60: "plastic-basin-14",
	63: "wind-pass-14",
	69: "bight-cliff-15",
	71: "funeral-plain",
	70: "great-flat",
	64: "wind-pass-15",
	72: "greater-flat",
	65: "wind-pass-16",
	76: "habbanya-erg-16",
	73: "false-wall-west-16",
	78: "wind-pass-north-17",
	66: "wind-pass-17",
	74: "false-wall-west-17",
	77: "habbanya-erg-17",
	80: "habbanya-ridge-flat-17",
	82: "habbanya-sietch",
	79: "wind-pass-north-18",
	83: "cielago-west-18",
	75: "false-wall-west-18",
	81: "habbanya-ridge-flat-18",
	85: "polar-sink"
}

var sector_dict = {
	"meridian-1": 1,
	"cielago-west-1": 1,
	"cielago-depression-1": 1,
	"cielago-north-1": 1,
	"meridian-2": 2,
	"cielago-south-2": 2,
	"cielago-depression-2": 2,
	"cielago-north-2": 2,
	"cielago-south-3": 3,
	"cielago-east-3": 3,
	"cielago-depression-3": 3,
	"cielago-north-3": 3,
	"cielago-east-4": 4,
	"south-mesa-4": 4,
	"false-wall-south-4": 4,
	"harg-pass-4": 4,
	"south-mesa-5": 5,
	"tueks-sietch": 5,
	"pasty-mesa-5": 5,
	"false-wall-south-5": 5,
	"harg-pass-5": 5,
	"minor-erg-5": 5,
	"false-wall-east-5": 5,
	"south-mesa-6": 6,
	"pasty-mesa-6": 6,
	"minor-erg-6": 6,
	"false-wall-east-6": 6,
	"red-chasm": 6,
	"pasty-mesa-7": 7,
	"minor-erg-7": 7,
	"false-wall-east-7": 7,
	"gara-kulon": 8,
	"pasty-mesa-8": 8,
	"shield-wall-8": 8,
	"minor-erg-8": 8,
	"false-wall-east-8": 8,
	"sihaya-ridge": 9,
	"basin": 9,
	"old-gap-9": 9,
	"rim-wall-west": 9,
	"hole-in-rock": 9,
	"shield-wall-9": 9,
	"imperial-basin-9": 9,
	"false-wall-east-9": 9,
	"old-gap-10": 10,
	"arrakeen": 10,
	"imperial-basin-10": 10,
	"broken-land-11": 11,
	"old-gap-11": 11,
	"tsimpo-11": 11,
	"imperial-basin-11": 11,
	"carthag": 11,
	"arsunt-11": 11,
	"broken-land-12": 12,
	"plastic-basin-12": 12,
	"tsimpo-12": 12,
	"hagga-basin-12": 12,
	"arsunt-12": 12,
	"rock-outcroppings-13": 13,
	"plastic-basin-13": 13,
	"tsimpo-13": 13,
	"hagga-basin-13": 13,
	"rock-outcroppings-14": 14,
	"bight-cliff-14": 14,
	"sietch-tabr": 14,
	"plastic-basin-14": 14,
	"wind-pass-14": 14,
	"bight-cliff-15": 15,
	"funeral-plain": 15,
	"great-flat": 15,
	"wind-pass-15": 15,
	"greater-flat": 16,
	"wind-pass-16": 16,
	"habbanya-erg-16": 16,
	"false-wall-west-16": 16,
	"wind-pass-north-17": 17,
	"wind-pass-17": 17,
	"false-wall-west-17": 17,
	"habbanya-erg-17": 17,
	"habbanya-ridge-flat-17": 17,
	"habbanya-sietch": 17,
	"wind-pass-north-18": 18,
	"cielago-west-18": 18,
	"false-wall-west-18": 18,
	"habbanya-ridge-flat-18": 18,
	"polar-sink": -1
}

var sections_dict = {
	"meridian-1": 6,
	"cielago-west-1": 84,
	"cielago-depression-1": 3,
	"cielago-north-1": 0,
	"meridian-2": 7,
	"cielago-south-2": 8,
	"cielago-depression-2": 4,
	"cielago-north-2": 1,
	"cielago-south-3": 9,
	"cielago-east-3": 10,
	"cielago-depression-3": 5,
	"cielago-north-3": 2,
	"cielago-east-4": 11,
	"south-mesa-4": 16,
	"false-wall-south-4": 14,
	"harg-pass-4": 12,
	"south-mesa-5": 17,
	"tueks-sietch": 32,
	"pasty-mesa-5": 28,
	"false-wall-south-5": 15,
	"harg-pass-5": 13,
	"minor-erg-5": 24,
	"false-wall-east-5": 19,
	"south-mesa-6": 18,
	"pasty-mesa-6": 29,
	"minor-erg-6": 25,
	"false-wall-east-6": 20,
	"red-chasm": 33,
	"pasty-mesa-7": 30,
	"minor-erg-7": 26,
	"false-wall-east-7": 21,
	"gara-kulon": 36,
	"pasty-mesa-8": 31,
	"shield-wall-8": 34,
	"minor-erg-8": 27,
	"false-wall-east-8": 22,
	"sihaya-ridge": 43,
	"basin": 42,
	"old-gap-9": 44,
	"rim-wall-west": 41,
	"hole-in-rock": 40,
	"shield-wall-9": 35,
	"imperial-basin-9": 37,
	"false-wall-east-9": 23,
	"old-gap-10": 45,
	"arrakeen": 47,
	"imperial-basin-10": 38,
	"broken-land-11": 54,
	"old-gap-11": 46,
	"tsimpo-11": 51,
	"imperial-basin-11": 39,
	"carthag": 50,
	"arsunt-11": 48,
	"broken-land-12": 55,
	"plastic-basin-12": 58,
	"tsimpo-12": 52,
	"hagga-basin-12": 56,
	"arsunt-12": 49,
	"rock-outcroppings-13": 61,
	"plastic-basin-13": 59,
	"tsimpo-13": 53,
	"hagga-basin-13": 57,
	"rock-outcroppings-14": 62,
	"bight-cliff-14": 68,
	"sietch-tabr": 67,
	"plastic-basin-14": 60,
	"wind-pass-14": 63,
	"bight-cliff-15": 69,
	"funeral-plain": 71,
	"great-flat": 70,
	"wind-pass-15": 64,
	"greater-flat": 72,
	"wind-pass-16": 65,
	"habbanya-erg-16": 76,
	"false-wall-west-16": 73,
	"wind-pass-north-17": 78,
	"wind-pass-17": 66,
	"false-wall-west-17": 74,
	"habbanya-erg-17": 77,
	"habbanya-ridge-flat-17": 80,
	"habbanya-sietch": 82,
	"wind-pass-north-18": 79,
	"cielago-west-18": 83,
	"false-wall-west-18": 75,
	"habbanya-ridge-flat-18": 81,
	"polar-sink": 85
}

var territory_dict = {
	"meridian-1": {"origin_sector": "meridian", "neighbours": [1, 3]},
	"cielago-west-1": {"origin_sector": "cielago-west", "neighbours": [1, 3]},
	"cielago-depression-1": {"origin_sector": "cielago-depression", "neighbours": [1, 3]},
	"cielago-north-1": {"origin_sector": "cielago-north", "neighbours": [1, 3]},
	"meridian-2": {"origin_sector": "meridian", "neighbours": [1, 3]},
	"cielago-south-2": {"origin_sector": "cielago-south", "neighbours": [1, 3]},
	"cielago-depression-2": {"origin_sector": "cielago-depression", "neighbours": [1, 3]},
	"cielago-north-2": {"origin_sector": "cielago-north", "neighbours": [1, 3]},
	"cielago-south-3": {"origin_sector": "cielago-south", "neighbours": [1, 3]},
	"cielago-east-3": {"origin_sector": "cielago-east", "neighbours": [1, 3]},
	"cielago-depression-3": {"origin_sector": "cielago-depression", "neighbours": [1, 3]},
	"cielago-north-3": {"origin_sector": "cielago-north", "neighbours": [1, 3]},
	"cielago-east-4": {"origin_sector": "cielago-east", "neighbours": [1, 3]},
	"south-mesa-4": {"origin_sector": "south-mesa", "neighbours": [1, 3]},
	"false-wall-south-4": {"origin_sector": "false-wall-south", "neighbours": [1, 3]},
	"harg-pass-4": {"origin_sector": "harg-pass", "neighbours": [1, 3]},
	"south-mesa-5": {"origin_sector": "south-mesa", "neighbours": [1, 3]},
	"tueks-sietch": {"origin_sector": "tueks-sietch", "neighbours": [1, 3]},
	"pasty-mesa-5": {"origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	"false-wall-south-5": {"origin_sector": "false-wall-south", "neighbours": [1, 3]},
	"harg-pass-5": {"origin_sector": "harg-pass", "neighbours": [1, 3]},
	"minor-erg-5": {"origin_sector": "minor-erg", "neighbours": [1, 3]},
	"false-wall-east-5": {"origin_sector": "false-wall-east", "neighbours": [1, 3]},
	"south-mesa-6": {"origin_sector": "south-mesa", "neighbours": [1, 3]},
	"pasty-mesa-6": {"origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	"minor-erg-6": {"origin_sector": "minor-erg", "neighbours": [1, 3]},
	"false-wall-east-6": {"origin_sector": "false-wall-east", "neighbours": [1, 3]},
	"red-chasm": {"origin_sector": "red-chasm", "neighbours": [1, 3]},
	"pasty-mesa-7": {"origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	"minor-erg-7": {"origin_sector": "minor-erg", "neighbours": [1, 3]},
	"false-wall-east-7": {"origin_sector": "false-wall-east", "neighbours": [1, 3]},
	"gara-kulon": {"origin_sector": "gara-kulon", "neighbours": [1, 3]},
	"pasty-mesa-8": {"origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	"shield-wall-8": {"origin_sector": "shield-wall", "neighbours": [1, 3]},
	"minor-erg-8": {"origin_sector": "minor-erg", "neighbours": [1, 3]},
	"false-wall-east-8": {"origin_sector": "false-wall-east", "neighbours": [1, 3]},
	"sihaya-ridge": {"origin_sector": "sihaya-ridge", "neighbours": [1, 3]},
	"basin": {"origin_sector": "basin", "neighbours": [1, 3]},
	"old-gap-9": {"origin_sector": "old-gap", "neighbours": [1, 3]},
	"rim-wall-west": {"origin_sector": "rim-wall-west", "neighbours": [1, 3]},
	"hole-in-rock": {"origin_sector": "hole-in-rock", "neighbours": [1, 3]},
	"shield-wall-9": {"origin_sector": "shield-wall", "neighbours": [1, 3]},
	"imperial-basin-9": {"origin_sector": "imperial-basin", "neighbours": [1, 3]},
	"false-wall-east-9": {"origin_sector": "false-wall-east", "neighbours": [1, 3]},
	"old-gap-10": {"origin_sector": "old-gap", "neighbours": [1, 3]},
	"arrakeen": {"origin_sector": "arrakeen", "neighbours": [1, 3]},
	"imperial-basin-10": {"origin_sector": "imperial-basin", "neighbours": [1, 3]},
	"broken-land-11": {"origin_sector": "broken-land", "neighbours": [1, 3]},
	"old-gap-11": {"origin_sector": "old-gap", "neighbours": [1, 3]},
	"tsimpo-11": {"origin_sector": "tsimpo", "neighbours": [1, 3]},
	"imperial-basin-11": {"origin_sector": "imperial-basin", "neighbours": [1, 3]},
	"carthag": {"origin_sector": "carthag", "neighbours": [1, 3]},
	"arsunt-11": {"origin_sector": "arsunt", "neighbours": [1, 3]},
	"broken-land-12": {"origin_sector": "broken-land", "neighbours": [1, 3]},
	"plastic-basin-12": {"origin_sector": "plastic-basin", "neighbours": [1, 3]},
	"tsimpo-12": {"origin_sector": "tsimpo", "neighbours": [1, 3]},
	"hagga-basin-12": {"origin_sector": "hagga-basin", "neighbours": [1, 3]},
	"arsunt-12": {"origin_sector": "arsunt", "neighbours": [1, 3]},
	"rock-outcroppings-13": {"origin_sector": "rock-outcroppings", "neighbours": [1, 3]},
	"plastic-basin-13": {"origin_sector": "plastic-basin", "neighbours": [1, 3]},
	"tsimpo-13": {"origin_sector": "tsimpo", "neighbours": [1, 3]},
	"hagga-basin-13": {"origin_sector": "hagga-basin", "neighbours": [1, 3]},
	"rock-outcroppings-14": {"origin_sector": "rock-outcroppings", "neighbours": [1, 3]},
	"bight-cliff-14": {"origin_sector": "bight-cliff", "neighbours": [1, 3]},
	"sietch-tabr": {"origin_sector": "sietch-tabr", "neighbours": [1, 3]},
	"plastic-basin-14": {"origin_sector": "plastic-basin", "neighbours": [1, 3]},
	"wind-pass-14": {"origin_sector": "wind-pass", "neighbours": [1, 3]},
	"bight-cliff-15": {"origin_sector": "bight-cliff", "neighbours": [1, 3]},
	"funeral-plain": {"origin_sector": "funeral-plain", "neighbours": [1, 3]},
	"great-flat": {"origin_sector": "great-flat", "neighbours": [1, 3]},
	"wind-pass-15": {"origin_sector": "wind-pass", "neighbours": [1, 3]},
	"greater-flat": {"origin_sector": "greater-flat", "neighbours": [1, 3]},
	"wind-pass-16": {"origin_sector": "wind-pass", "neighbours": [1, 3]},
	"habbanya-erg-16": {"origin_sector": "habbanya-erg", "neighbours": [1, 3]},
	"false-wall-west-16": {"origin_sector": "false-wall-west", "neighbours": [1, 3]},
	"wind-pass-north-17": {"origin_sector": "wind-pass-north", "neighbours": [1, 3]},
	"wind-pass-17": {"origin_sector": "wind-pass", "neighbours": [1, 3]},
	"false-wall-west-17": {"origin_sector": "false-wall-west", "neighbours": [1, 3]},
	"habbanya-erg-17": {"origin_sector": "habbanya-erg", "neighbours": [1, 3]},
	"habbanya-ridge-flat-17": {"origin_sector": "habbanya-ridge-flat", "neighbours": [1, 3]},
	"habbanya-sietch": {"origin_sector": "habbanya-sietch", "neighbours": [1, 3]},
	"wind-pass-north-18": {"origin_sector": "wind-pass-north", "neighbours": [1, 3]},
	"cielago-west-18": {"origin_sector": "cielago-west", "neighbours": [1, 3]},
	"false-wall-west-18": {"origin_sector": "false-wall-west", "neighbours": [1, 3]},
	"habbanya-ridge-flat-18": {"origin_sector": "habbanya-ridge-flat", "neighbours": [1, 3]},
	"polar-sink": {"origin_sector": "polar-sink", "neighbours": [1, 3]}
}

var spice_goofy_to_section_dict = {
	0: 2,
	1: 8,
	2: 17,
	3: 27,
	4: 33,
	5: 43,
	6: 45,
	7: 55,
	8: 57,
	9: 62,
	10: 70,
	11: 71,
	12: 76,
	13: 78,
	14: 81
} 

var territoryData = [
	{"name": "meridian-1", "origin_sector": "meridian", "neighbours": [1, 3]},
	{"name": "cielago-west-1", "origin_sector": "cielago-west", "neighbours": [1, 3]},
	{"name": "cielago-depression-1", "origin_sector": "cielago-depression", "neighbours": [1, 3]},
	{"name": "cielago-north-1", "origin_sector": "cielago-north", "neighbours": [1, 3]},
	{"name": "meridian-2", "origin_sector": "meridian", "neighbours": [1, 3]},
	{"name": "cielago-south-2", "origin_sector": "cielago-south", "neighbours": [1, 3]},
	{"name": "cielago-depression-2", "origin_sector": "cielago-depression", "neighbours": [1, 3]},
	{"name": "cielago-north-2", "origin_sector": "cielago-north", "neighbours": [1, 3]},
	{"name": "cielago-south-3", "origin_sector": "cielago-south", "neighbours": [1, 3]},
	{"name": "cielago-east-3", "origin_sector": "cielago-east", "neighbours": [1, 3]},
	{"name": "cielago-depression-3", "origin_sector": "cielago-depression", "neighbours": [1, 3]},
	{"name": "cielago-north-3", "origin_sector": "cielago-north", "neighbours": [1, 3]},
	{"name": "cielago-east-4", "origin_sector": "cielago-east", "neighbours": [1, 3]},
	{"name": "south-mesa-4", "origin_sector": "south-mesa", "neighbours": [1, 3]},
	{"name": "false-wall-south-4", "origin_sector": "false-wall-south", "neighbours": [1, 3]},
	{"name": "harg-pass-4", "origin_sector": "harg-pass", "neighbours": [1, 3]},
	{"name": "south-mesa-5", "origin_sector": "south-mesa", "neighbours": [1, 3]},
	{"name": "tueks-sietch", "origin_sector": "tueks-sietch", "neighbours": [1, 3]},
	{"name": "pasty-mesa-5", "origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	{"name": "false-wall-south-5", "origin_sector": "false-wall-south", "neighbours": [1, 3]},
	{"name": "harg-pass-5", "origin_sector": "harg-pass", "neighbours": [1, 3]},
	{"name": "minor-erg-5", "origin_sector": "minor-erg", "neighbours": [1, 3]},
	{"name": "false-wall-east-5", "origin_sector": "false-wall-east", "neighbours": [1, 3]},
	{"name": "south-mesa-6", "origin_sector": "south-mesa", "neighbours": [1, 3]},
	{"name": "pasty-mesa-6", "origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	{"name": "minor-erg-6", "origin_sector": "minor-erg", "neighbours": [1, 3]},
	{"name": "false-wall-east-6", "origin_sector": "false-wall-east", "neighbours": [1, 3]},
	{"name": "red-chasm", "origin_sector": "red-chasm", "neighbours": [1, 3]},
	{"name": "pasty-mesa-7", "origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	{"name": "minor-erg-7", "origin_sector": "minor-erg", "neighbours": [1, 3]},
	{"name": "false-wall-east-7", "origin_sector": "false-wall-east", "neighbours": [1, 3]},
	{"name": "gara-kulon", "origin_sector": "gara-kulon", "neighbours": [1, 3]},
	{"name": "pasty-mesa-8", "origin_sector": "pasty-mesa", "neighbours": [1, 3]},
	{"name": "shield-wall-8", "origin_sector": "shield-wall", "neighbours": [1, 3]},
	{"name": "minor-erg-8", "origin_sector": "minor-erg", "neighbours": [1, 3]},
	{"name": "false-wall-east-8", "origin_sector": "false-wall-east", "neighbours": [1, 3]},
	{"name": "sihaya-ridge", "origin_sector": "sihaya-ridge", "neighbours": [1, 3]},
	{"name": "basin", "origin_sector": "basin", "neighbours": [1, 3]},
	{"name": "old-gap-9", "origin_sector": "old-gap", "neighbours": [1, 3]},
	{"name": "rim-wall-west", "origin_sector": "rim-wall-west", "neighbours": [1, 3]},
	{"name": "hole-in-rock", "origin_sector": "hole-in-rock", "neighbours": [1, 3]},
	{"name": "shield-wall-9", "origin_sector": "shield-wall", "neighbours": [1, 3]},
	{"name": "imperial-basin-9", "origin_sector": "imperial-basin", "neighbours": [1, 3]},
	{"name": "false-wall-east-9", "origin_sector": "false-wall-east", "neighbours": [1, 3]},
	{"name": "old-gap-10", "origin_sector": "old-gap", "neighbours": [1, 3]},
	{"name": "arrakeen", "origin_sector": "arrakeen", "neighbours": [1, 3]},
	{"name": "imperial-basin-10", "origin_sector": "imperial-basin", "neighbours": [1, 3]},
	{"name": "broken-land-11", "origin_sector": "broken-land", "neighbours": [1, 3]},
	{"name": "old-gap-11", "origin_sector": "old-gap", "neighbours": [1, 3]},
	{"name": "tsimpo-11", "origin_sector": "tsimpo", "neighbours": [1, 3]},
	{"name": "imperial-basin-11", "origin_sector": "imperial-basin", "neighbours": [1, 3]},
	{"name": "carthag", "origin_sector": "carthag", "neighbours": [1, 3]},
	{"name": "arsunt-11", "origin_sector": "arsunt", "neighbours": [1, 3]},
	{"name": "broken-land-12", "origin_sector": "broken-land", "neighbours": [1, 3]},
	{"name": "plastic-basin-12", "origin_sector": "plastic-basin", "neighbours": [1, 3]},
	{"name": "tsimpo-12", "origin_sector": "tsimpo", "neighbours": [1, 3]},
	{"name": "hagga-basin-12", "origin_sector": "hagga-basin", "neighbours": [1, 3]},
	{"name": "arsunt-12", "origin_sector": "arsunt", "neighbours": [1, 3]},
	{"name": "rock-outcroppings-13", "origin_sector": "rock-outcroppings", "neighbours": [1, 3]},
	{"name": "plastic-basin-13", "origin_sector": "plastic-basin", "neighbours": [1, 3]},
	{"name": "tsimpo-13", "origin_sector": "tsimpo", "neighbours": [1, 3]},
	{"name": "hagga-basin-13", "origin_sector": "hagga-basin", "neighbours": [1, 3]},
	{"name": "rock-outcroppings-14", "origin_sector": "rock-outcroppings", "neighbours": [1, 3]},
	{"name": "bight-cliff-14", "origin_sector": "bight-cliff", "neighbours": [1, 3]},
	{"name": "sietch-tabr", "origin_sector": "sietch-tabr", "neighbours": [1, 3]},
	{"name": "plastic-basin-14", "origin_sector": "plastic-basin", "neighbours": [1, 3]},
	{"name": "wind-pass-14", "origin_sector": "wind-pass", "neighbours": [1, 3]},
	{"name": "bight-cliff-15", "origin_sector": "bight-cliff", "neighbours": [1, 3]},
	{"name": "funeral-plain", "origin_sector": "funeral-plain", "neighbours": [1, 3]},
	{"name": "great-flat", "origin_sector": "great-flat", "neighbours": [1, 3]},
	{"name": "wind-pass-15", "origin_sector": "wind-pass", "neighbours": [1, 3]},
	{"name": "greater-flat", "origin_sector": "greater-flat", "neighbours": [1, 3]},
	{"name": "wind-pass-16", "origin_sector": "wind-pass", "neighbours": [1, 3]},
	{"name": "habbanya-erg-16", "origin_sector": "habbanya-erg", "neighbours": [1, 3]},
	{"name": "false-wall-west-16", "origin_sector": "false-wall-west", "neighbours": [1, 3]},
	{"name": "wind-pass-north-17", "origin_sector": "wind-pass-north", "neighbours": [1, 3]},
	{"name": "wind-pass-17", "origin_sector": "wind-pass", "neighbours": [1, 3]},
	{"name": "false-wall-west-17", "origin_sector": "false-wall-west", "neighbours": [1, 3]},
	{"name": "habbanya-erg-17", "origin_sector": "habbanya-erg", "neighbours": [1, 3]},
	{"name": "habbanya-ridge-flat-17", "origin_sector": "habbanya-ridge-flat", "neighbours": [1, 3]},
	{"name": "habbanya-sietch", "origin_sector": "habbanya-sietch", "neighbours": [1, 3]},
	{"name": "wind-pass-north-18", "origin_sector": "wind-pass-north", "neighbours": [1, 3]},
	{"name": "cielago-west-18", "origin_sector": "cielago-west", "neighbours": [1, 3]},
	{"name": "false-wall-west-18", "origin_sector": "false-wall-west", "neighbours": [1, 3]},
	{"name": "habbanya-ridge-flat-18", "origin_sector": "habbanya-ridge-flat", "neighbours": [1, 3]},
	{"name": "polar-sink", "origin_sector": "polar-sink", "neighbours": [1, 3]}
]






