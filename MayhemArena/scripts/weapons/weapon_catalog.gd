class_name WeaponCatalog
extends RefCounted

const DEFAULT_WEAPON_IDS := [1, 2, 3, 4, 5]
const CRATE_WEAPON_IDS := [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]

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
		"name": "SHOTGUN",
		"tagline": "Five shells and a BOOM blast",
		"primary_label": "Shotgun Blast",
		"secondary_label": "BOOM Blast",
		"ammo": 6,
		"crate_only": true,
		"primary": {
			"type": "pellet_burst", "pellets": 5, "firepower": 10.0,
			"speed": 25.0, "spread": 30.0, "recoil": 8.0, "cooldown": 15,
			"ammo_cost": 1,
		},
		"secondary": {
			"type": "pellet_burst", "pellets": 8, "firepower": 10.0,
			"speed": 25.0, "spread": 30.0, "recoil": 16.0, "cooldown": 24,
			"ammo_cost": 2,
			"text_effect": "BOOM!",
		},
	},
	7: {
		"name": "M4",
		"tagline": "Rifle fire with a four-round blast",
		"primary_label": "Rifle Shot",
		"secondary_label": "Four-Round Blast",
		"ammo": 30,
		"crate_only": true,
		"primary": {
			"type": "bullet", "firepower": 17.0, "speed": 25.0,
			"spread": 4.0, "recoil": 0.5, "cooldown": 5,
		},
		"secondary": {
			"type": "pellet_burst", "pellets": 5, "firepower": 10.0,
			"speed": 25.0, "spread": 30.0, "recoil": 8.0, "cooldown": 24,
			"ammo_cost": 4,
			"semi_auto": true,
		},
	},
	8: {
		"name": "HOMING MISSILE",
		"tagline": "Lock-on missile with a joke variant",
		"primary_label": "Homing Missile",
		"secondary_label": "Joke Missile",
		"ammo": 3,
		"crate_only": true,
		"primary": {
			"type": "homing", "damage": 32.0, "firepower": 32.0,
			"speed": 12.0, "spread": 0.0, "recoil": 8.0, "cooldown": 35,
			"turning": 1.1, "life": 100,
		},
		"secondary": {
			"type": "homing_jokes", "damage": 32.0, "firepower": 32.0,
			"speed": 10.0, "spread": 0.0, "recoil": 8.0, "cooldown": 35,
			"turning": 0.5, "life": 70,
		},
	},
	9: {
		"name": "AK-47", "tagline": "Rifle with a brutal stock strike",
		"primary_label": "Rifle Shot", "secondary_label": "Stock Strike", "ammo": 30, "crate_only": true,
		"primary": {"type": "bullet", "firepower": 18.5, "speed": 25.0, "spread": 4.0, "recoil": 0.5, "cooldown": 5},
		"secondary": {"type": "melee", "damage": 9.0, "range": 75.0, "min_y": -30.0, "max_y": 20.0, "knockback": 22.5, "vertical": -1.0, "hitstop": 2, "cooldown": 22},
	},
	10: {
		"name": "BASEBALL BAT", "tagline": "Huge knockback or a fast baseball",
		"primary_label": "Home Run", "secondary_label": "Pitch", "ammo": 5, "crate_only": true,
		"primary": {"type": "melee", "damage": 34.0, "range": 75.0, "min_y": -30.0, "max_y": 20.0, "knockback": 70.0, "vertical": -10.0, "hitstop": 2, "cooldown": 28, "ammo_on_hit": true},
		"secondary": {"type": "bat_throw", "damage": 10.0, "range": 70.0, "min_y": -30.0, "max_y": 20.0, "knockback": 70.0, "vertical": -10.0, "hitstop": 2, "speed": 40.0, "cooldown": 28},
	},
	11: {
		"name": "BOW", "tagline": "Straight arrow or triple shot",
		"primary_label": "Arrow", "secondary_label": "Triple Arrow", "ammo": 10, "crate_only": true,
		"primary": {"type": "arrow", "damage": 20.0, "firepower": 34.0, "speed": 30.0, "angle": -3.0, "spread": 0.0, "recoil": 0.0, "cooldown": 20},
		"secondary": {"type": "arrow_burst", "damage": 20.0, "firepower": 34.0, "speed": 30.0, "angles": [-13.0, 7.0, -3.0], "ammo_cost": 3, "recoil": 0.0, "cooldown": 30},
	},
	12: {
		"name": "SNIPER", "tagline": "Slow, accurate and devastating",
		"primary_label": "Sniper Shot", "secondary_label": "Aimed Shot", "ammo": 5, "crate_only": true,
		"primary": {"type": "bullet", "firepower": 65.0, "speed": 25.0, "spread": 1.0, "recoil": 5.0, "cooldown": 48},
		"secondary": {"type": "bullet", "firepower": 65.0, "speed": 25.0, "spread": 0.0, "recoil": 5.0, "cooldown": 55, "semi_auto": true, "text_effect": "BOOM!"},
	},
	13: {
		"name": "MP5K", "tagline": "Compact automatic fire",
		"primary_label": "Auto Fire", "secondary_label": "Burst Fire", "ammo": 40, "crate_only": true,
		"primary": {"type": "bullet", "firepower": 14.0, "speed": 25.0, "spread": 6.0, "recoil": 0.4, "cooldown": 4},
		"secondary": {"type": "bullet_burst", "shots": 3, "firepower": 14.0, "speed": 25.0, "spread": 6.0, "recoil": 0.35, "ammo_cost": 3, "cooldown": 13, "semi_auto": true},
	},
	14: {
		"name": "UZI", "tagline": "Fast machine pistol",
		"primary_label": "Auto Fire", "secondary_label": "Wide Fire", "ammo": 45, "crate_only": true,
		"primary": {"type": "bullet", "firepower": 13.0, "speed": 25.0, "spread": 7.0, "recoil": 0.3, "cooldown": 3},
		"secondary": {"type": "bullet", "firepower": 11.5, "speed": 25.0, "spread": 20.0, "recoil": 0.3, "cooldown": 5},
	},
	15: {
		"name": "MINI GUN", "tagline": "Steady rapid fire",
		"primary_label": "Mini Fire", "secondary_label": "Mini Fire", "ammo": 150, "crate_only": true,
		"primary": {"type": "bullet", "firepower": 13.0, "speed": 25.0, "spread": 7.0, "recoil": 0.6, "cooldown": 3},
		"secondary": {"type": "bullet", "firepower": 13.0, "speed": 25.0, "spread": 7.0, "recoil": 0.6, "cooldown": 3},
	},
	16: {
		"name": "UMBRELLA", "tagline": "Block shots or strike back",
		"primary_label": "Umbrella Strike", "secondary_label": "Open Umbrella", "ammo": 100, "crate_only": true,
		"primary": {"type": "melee", "damage": 17.0, "range": 80.0, "min_y": -30.0, "max_y": 20.0, "knockback": 28.0, "vertical": -10.0, "hitstop": 2, "stun": 15, "cooldown": 25},
		"secondary": {"type": "umbrella_open", "cooldown": 1, "semi_auto": true},
	},
	17: {
		"name": "THROWING KNIFE", "tagline": "Stab close or throw a knife",
		"primary_label": "Knife Stab", "secondary_label": "Throw Knife", "ammo": 10, "crate_only": true,
		"primary": {"type": "melee", "damage": 25.0, "range": 75.0, "min_y": -30.0, "max_y": 20.0, "knockback": 19.0, "vertical": 0.0, "hitstop": 2, "respect_umbrella": true, "cooldown": 22},
		"secondary": {"type": "knife", "damage": 10.0, "firepower": 19.0, "speed": 30.0, "angle": -7.0, "spread": 0.0, "recoil": 0.0, "cooldown": 24},
	},
	18: {
		"name": "BOMB", "tagline": "Bouncing explosive with two throws",
		"primary_label": "Bouncy Bomb", "secondary_label": "Heavy Bomb", "ammo": 5, "crate_only": true,
		"primary": {"type": "bomb", "damage": 32.0, "firepower": 40.0, "speed": 11.0, "recoil": 0.0, "cooldown": 30, "blast_radius": 50.0, "gravity": 1.26, "bounce": true},
		"secondary": {"type": "bomb", "damage": 32.0, "firepower": 40.0, "speed": 16.0, "recoil": 0.0, "cooldown": 30, "blast_radius": 50.0, "gravity": 1.26, "bounce": false},
	},
}

static func get_weapon(weapon_id: int) -> Dictionary:
	return WEAPONS.get(weapon_id, WEAPONS[1]).duplicate(true)

static func weapon_name_for(weapon_id: int) -> String:
	return str(WEAPONS.get(weapon_id, WEAPONS[1])["name"])

static func is_valid_weapon(weapon_id: int) -> bool:
	return WEAPONS.has(weapon_id)
