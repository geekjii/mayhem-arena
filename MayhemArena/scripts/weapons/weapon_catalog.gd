class_name WeaponCatalog
extends RefCounted

const DEFAULT_WEAPON_IDS := [1, 2, 3, 4, 5]
const CRATE_WEAPON_IDS := [6, 7, 8]

# Gun Mayhem Redux's five selectable default weapons. Numeric values are kept
# in the original 35 Hz Flash coordinate/frame scale wherever practical.
const WEAPONS := {
	1: {
		"name": "SAND HAWK",
		"tagline": "Balanced pistol",
		"primary_label": "Pistol Shot",
		"secondary_label": "Throw Gun",
		"ammo": 9,
		"primary": {
			"type": "bullet", "firepower": 23.0, "speed": 25.0,
			"spread": 2.0, "recoil": 1.0, "cooldown": 9,
		},
		"secondary": {
			"type": "throw_gun", "damage": 10.0, "knockback": 25.0,
			"speed": 25.0, "stun": 10, "cooldown": 40,
		},
	},
	2: {
		"name": "DUAL COOL PISTOLS",
		"tagline": "Two triggers, two pistols",
		"primary_label": "Shoot Gun #1",
		"secondary_label": "Shoot Gun #2",
		"ammo": 24,
		"primary": {
			"type": "bullet", "firepower": 9.5, "speed": 25.0,
			"spread": 6.0, "recoil": 0.4, "cooldown": 3,
			"semi_auto": true,
		},
		"secondary": {
			"type": "bullet", "firepower": 9.5, "speed": 25.0,
			"spread": 6.0, "recoil": 0.4, "cooldown": 3,
			"semi_auto": true,
		},
	},
	3: {
		"name": "ANGRY COW",
		"tagline": "Slow and powerful revolver",
		"primary_label": "Heavy Shot",
		"secondary_label": "Aimed Shot",
		"ammo": 6,
		"primary": {
			"type": "bullet", "firepower": 26.5, "speed": 35.0,
			"spread": 2.0, "recoil": 2.0, "cooldown": 15,
		},
		"secondary": {
			"type": "bullet", "firepower": 37.0, "speed": 47.0,
			"spread": 0.0, "recoil": 2.0, "cooldown": 35,
		},
	},
	4: {
		"name": "BLING PISTOL",
		"tagline": "Fast pistol with a bad idea",
		"primary_label": "Bling Shot",
		"secondary_label": "Make It Rain (-5 HP)",
		"ammo": 14,
		"primary": {
			"type": "bullet", "firepower": 19.0, "speed": 25.0,
			"spread": 2.0, "recoil": 1.0, "cooldown": 8,
		},
		"secondary": {
			"type": "make_it_rain", "self_damage": 5.0, "cooldown": 11,
		},
	},
	5: {
		"name": "KATANA",
		"tagline": "Close range, infinite use",
		"primary_label": "Slash Combo",
		"secondary_label": "Uppercut",
		"ammo": -1,
		"primary": {
			"type": "katana_combo", "damage": 20.0, "range": 65.0,
			"knockback": 12.0, "hitstop": 2, "cooldown": 25,
		},
		"secondary": {
			"type": "katana_uppercut", "damage": 20.0, "range": 75.0,
			"knockback": 25.0, "vertical": -10.0, "hitstop": 2,
			"cooldown": 25,
		},
	},
	6: {
		"name": "SCATTERGUN",
		"tagline": "Six pellets at close range",
		"primary_label": "Tight Blast",
		"secondary_label": "Wide Blast",
		"ammo": 8,
		"crate_only": true,
		"primary": {
			"type": "pellet_burst", "pellets": 6, "firepower": 13.5,
			"speed": 24.0, "spread": 18.0, "recoil": 3.0, "cooldown": 14,
		},
		"secondary": {
			"type": "pellet_burst", "pellets": 4, "firepower": 12.0,
			"speed": 22.0, "spread": 36.0, "recoil": 4.0, "cooldown": 19,
		},
	},
	7: {
		"name": "RAPID CARBINE",
		"tagline": "Fast automatic fire",
		"primary_label": "Full Auto",
		"secondary_label": "Precision Shot",
		"ammo": 32,
		"crate_only": true,
		"primary": {
			"type": "bullet", "firepower": 8.5, "speed": 30.0,
			"spread": 5.0, "recoil": 0.35, "cooldown": 2,
		},
		"secondary": {
			"type": "bullet", "firepower": 18.0, "speed": 34.0,
			"spread": 1.0, "recoil": 1.2, "cooldown": 10,
			"semi_auto": true,
		},
	},
	8: {
		"name": "ROCKET TUBE",
		"tagline": "Explosive area knockback",
		"primary_label": "Straight Rocket",
		"secondary_label": "Heavy Lob",
		"ammo": 4,
		"crate_only": true,
		"primary": {
			"type": "rocket", "damage": 22.0, "firepower": 42.0,
			"speed": 15.0, "spread": 1.0, "blast_radius": 105.0,
			"gravity": 0.0, "recoil": 4.0, "cooldown": 28,
		},
		"secondary": {
			"type": "rocket", "damage": 28.0, "firepower": 50.0,
			"speed": 11.0, "spread": 2.0, "blast_radius": 130.0,
			"gravity": 0.35, "recoil": 5.0, "cooldown": 40,
		},
	},
}

static func get_weapon(weapon_id: int) -> Dictionary:
	return WEAPONS.get(weapon_id, WEAPONS[1]).duplicate(true)

static func weapon_name_for(weapon_id: int) -> String:
	return str(WEAPONS.get(weapon_id, WEAPONS[1])["name"])

static func is_valid_weapon(weapon_id: int) -> bool:
	return WEAPONS.has(weapon_id)
