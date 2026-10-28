

-- Find the vehicles and inject VZ fields into them. If not found, warning. If it is not defined here, ignore.
VZ_Vehicles_Config = {
	Offroad = {
		price = 10000,
		health = 500,
		AR_Multiplier = 2, -- Acceptance radius multiplier
		Damage_Radius_sq_Mult = 2^2, -- Damage radius multiplier
	},

	CamperVan = {
		price = 7500,
		health = 1000,
		AR_Multiplier = 4,
		Damage_Radius_sq_Mult = 4^2,
	},

	Van = {
		price = 8500,
		health = 1500,
		AR_Multiplier = 4,
		Damage_Radius_sq_Mult = 4^2,
	},

	Wagon = {
		price = 6000,
		health = 750,
		AR_Multiplier = 2,
		Damage_Radius_sq_Mult = 2^2,
	},

	Sedan = {
		price = 9000,
		health = 600,
		AR_Multiplier = 2,
		Damage_Radius_sq_Mult = 2^2,
	},

	SUV = {
		price = 8000,
		health = 900,
		AR_Multiplier = 2,
		Damage_Radius_sq_Mult = 2^2,
	},

	Hatchback = {
		price = 12000,
		health = 700,
		AR_Multiplier = 2,
		Damage_Radius_sq_Mult = 2^2,
	},

	Pickup = {
		price = 5000,
		health = 500,
		AR_Multiplier = 2,
		Damage_Radius_sq_Mult = 2^2,
	},

	SportsCar = {
		price = 15000,
		health = 500,
		AR_Multiplier = 2,
		Damage_Radius_sq_Mult = 2^2,
	},

	TruckBox = {
		price = 9000,
		health = 1250,
		AR_Multiplier = 4,
		Damage_Radius_sq_Mult = 4^2,
	}
}