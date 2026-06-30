local types = require(script.Parent.Types)

export type Template = {
	last_login_time: number,
	skills: { [string]: types.Skill },
	player_level: number,
	player_xp: number,
	money: number,
	garage: string,
	passes: { string }, -- Bought or received passes (bigger inventory, speed, etc..)
	spent_robux: number,
	sold_cars: number,
	driven_kms: number,
	cars: { [string]: types.Vehicle },
	garage_slots: { string },
	codex: { string },
	used_codes: { string },
	inventory: { types.InventoryItem },
	settings: {
		field_of_view: number,
		drive_permission: "all" | "friends" | "no-one",
		speed_unit: "metric" | "imperial",
		show_controls: boolean,
		start_drive_mode: "sport" | "comfort",
		start_transmission: "semi" | "auto",
		music_volume: number,
		engine_volume: number,
		ui_volume: number,
	},
}

local template: Template = {
	last_login_time = 0 :: number,
	skills = {} :: { [string]: types.Skill },
	player_level = 1,
	player_xp = 0,
	money = 10000,
	garage = "BasicGarage",
	passes = {} :: { string }, -- Bought or received passes (bigger inventory, speed, etc..)
	spent_robux = 0,
	sold_cars = 0,
	driven_kms = 0,
	cars = {} :: { [string]: types.Vehicle & { car_id: string } },
	garage_slots = {} :: { string },
	codex = {} :: { string },
	used_codes = {} :: { string },
	inventory = {} :: { types.InventoryItem },
	settings = {
		field_of_view = 100,
		drive_permission = "friends" :: "all" | "friends" | "no-one",
		speed_unit = "metric" :: "metric" | "imperial",
		show_controls = true,
		start_drive_mode = "sport" :: "sport" | "comfort",
		start_transmission = "auto" :: "semi" | "auto",
		music_volume = 50,
		engine_volume = 100,
		ui_volume = 80,
	},
}

return template
