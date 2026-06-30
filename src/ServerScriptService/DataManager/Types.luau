local module = {}

export type WheelPositions = "FL" | "FR" | "RL" | "RR"
export type CarWheel = {
	camber: number,
	toe: number,
	tire: "road" | "sport" | "drift",
	rim_name: string, -- RIM1
	rim_color: string, -- #123456
	rim_diameter: number, -- R18
	rim_width: number, -- mm
	tire_profile: number, -- %
}

export type EngineChipTuning = {
	power_limit: number,
	boost: number,
	ignition: number,
	fuel_mix: number,
	valve_timing: number,
}

export type EnginePart = {
	name: string,
	condition: number,
	driven_kms: number,
}

export type Transmission = {
	transmission_type: string,
	condition: number,
	gear_ratios: { number },
}

export type Engine = {
	engine_type: string,
	transmission: Transmission,
	oil_quality: number,
	engine_tolerance: number, -- for example (0.95 - 1.05)
	installed_parts: { EnginePart },
	custom_tune: EngineChipTuning,
}

--- Inventory
export type BaseItem = {
	item_id: string,
	item_name: string,
}

export type CoolantBottleItem = {
	item_type: "coolant_bottle",
	amount: number,
}

export type OilBottleItem = {
	item_type: "oil_bottle",
	oil_grade: string,
	amount: number,
}

export type JerryCanItem = {
	item_type: "jerry_can",
	amount: number,
}

export type EnginePartItem = {
	item_type: "engine_part",
	condition: number,
	driven_kms: number,
	part_category: string,
}

export type RimItem = {
	item_type: "rim",
	condition: number,
	rim_name: string,
	rim_diameter: number,
	rim_width: number,
	rim_color: string,
}

export type TireItem = {
	item_type: "tire",
	condition: number,
	tire_compound: "road" | "sport" | "drift",
	tire_profile: number,
}

export type CompleteWheelItem = {
	item_type: "wheel",
	condition: number,
	rim_data: RimItem,
	tire_data: TireItem,
}

export type InventoryItem =
	BaseItem
	& (CoolantBottleItem | OilBottleItem | JerryCanItem | EnginePartItem | RimItem | TireItem | CompleteWheelItem)

export type VehicleBody = {
	front_bumper: string,
	front_fender: string,
	headlight: {
		type: string,
		color: string,
	},
	hood: string,
	rear_bumper: string,
	rear_fender: string,
	skirt: string,
	exhaust: string,
	spoiler: string,
	window_tint: number,
}

export type Skill = {
	experience: number,
	level: number,
}

export type Vehicle = {
	vehicle_name: string,
	body: VehicleBody,
	body_colors: { [string]: string },
	body_dirty: number,
	fuel: number,
	odometer: number,
	license_plate: string,
	engine: Engine,
	active_fault_codes: { string },
	ride_height: number,
	wheels: { [WheelPositions]: CarWheel },
}

return module
