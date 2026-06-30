local Configuration = {
	
	defaultCarData = {
		["Body"] = {
			["Front Bumper"] = "Bumper1",
			["Front Fender"] = "Fender1",
			["Headlight"] = "Headlight1",
			["Hood"] = "Hood1",
			["Rear Bumper"] = "Bumper1",
			["Rear Fender"] = "Fender1",
			["Skirt"] = "Skirt1",
		},
		["Paint"] = {
			["Primary Paint"] = "#ffffff" ,
			["Secondary Paint"] = "#ffffff" ,
		},
		["Performance"] = {
			Engine = {
				PeakTorque = "180",
				PeakTorqueRPM = "4200",
				IdleRPM = "1100",
				IdleTorque = "80",
				IdleTorqueCurve = "0.25",
				Redline = "8500",
				RedlineTorque = "150",
				RedlineTorqueCurve = "0.4",
				VVLTorque = "15",
				VVLRPM = "6000",
				VVLTime = "0.4",
				VVLCurve = "0.003",
				HPLimit = "350",
			},
			
			Turbo = {
				Turbochargers = "1",
				T_Boost = "0.5",
				T_PeakRPM = "4000",
				T_IdleBoost = "0.1",
				T_Curve = "0.3",
				T_Efficiency = "0.7",
				T_SpoolIncrease = "0.2",
				T_SpoolDecrease = "0.1",
				
			},
			
		},
	},
	
	
	Tune = {
	BodyKit = {
		
			["Front Bumper"] = {
				Bumper1 = {},
				Bumper2 = {},
				Bumper3 = {},
				Bumper4 = {},
				Bumper5 = {},
				Bumper6 = {},
				Bumper7 = {},
			},
			["Front Fender"] = {
				Fender1 = {},
				Fender2 = {},
				Fender3 = {},
				Fender4 = {},
			},
			["Headlight"] = {
				Headlight1 = {},
			},
			["Hood"] = {
				Hood1 = {},
				Hood2 = {},
				Hood3 = {},
				Hood4 = {},
			},
			["Rear Bumper"] = {
				Bumper1 = {},
				Bumper2 = {},
				Bumper3 = {},
				Bumper4 = {},
				Bumper5 = {},
			},
			["Rear Fender"] = {
				Fender1 = {},
				Fender2 = {},
			},
			["Skirt"] = {
				Skirt1 = {},
				Skirt2 = {},
				Skirt3 = {},
				Skirt4 = {},
			},
			["Spoiler"] = {
			},
		
	},
	PerformanceTuning = {
		
			Engine = {
				["Engine Level1"] = {	
					Values = {
						PeakTorque = "180",
						PeakTorqueRPM = "4200",
						IdleRPM = "1100",
						IdleTorque = "80",
						IdleTorqueCurve = "0.25",
						Redline = "8500",
						RedlineTorque = "150",
						RedlineTorqueCurve = "0.4",
						VVLTorque = "15",
						VVLRPM = "6000",
						VVLTime = "0.4",
						VVLCurve = "0.003",
						HPLimit = "350",
					},
				},
				["Engine Level2"] = {
					Values = {
						PeakTorque = "208",
						PeakTorqueRPM = "4480",
						IdleRPM = "1200",
						IdleTorque = "89",
						IdleTorqueCurve = "0.274",
						Redline = "9000",
						RedlineTorque = "169",
						RedlineTorqueCurve = "0.42",
						VVLTorque = "20",
						VVLRPM = "6340",
						VVLTime = "0.5",
						VVLCurve = "0.002",
						HPLimit = "400",
					},
				},
				["Engine Level3"] = {
					Values = {
						PeakTorque = "250",
						PeakTorqueRPM = "4800",
						IdleRPM = "1300",
						IdleTorque = "100",
						IdleTorqueCurve = "0.35",
						Redline = "9500",
						RedlineTorque = "200",
						RedlineTorqueCurve = "0.5",
						VVLTorque = "25",
						VVLRPM = "6500",
						VVLTime = "0.6",
						VVLCurve = "0.004",
						HPLimit = "450",
					},
				},
				["Engine Level4"] = {
					Values = {
						PeakTorque = "300",
						PeakTorqueRPM = "5000",
						IdleRPM = "1400",
						IdleTorque = "110",
						IdleTorqueCurve = "0.4",
						Redline = "10000",
						RedlineTorque = "250",
						RedlineTorqueCurve = "0.6",
						VVLTorque = "30",
						VVLRPM = "7000",
						VVLTime = "0.7",
						VVLCurve = "0.005",
						HPLimit = "500",
					},
				},
			},

			Turbo = {
				["Turbo Level1"] = {
					Values = {
						Turbochargers = "1",
						T_Boost = "0.5",
						T_PeakRPM = "4000",
						T_IdleBoost = "0.1",
						T_Curve = "0.3",
						T_Efficiency = "0.7",
						T_SpoolIncrease = "0.2",
						T_SpoolDecrease = "0.1",
					},
				},
				["Turbo Level2"] = {
					Values = {
						Turbochargers = "1",
						T_Boost = "0.8",
						T_PeakRPM = "4500",
						T_IdleBoost = "0.2",
						T_Curve = "0.5",
						T_Efficiency = "0.8",
						T_SpoolIncrease = "0.3",
						T_SpoolDecrease = "0.2",
					},
				},

			},
				

		
		
			
	},
		Paint = {
			["Metallic Black"] = {
				HexCode = "#0d1116"
			},
			["Metallic Graphite Black"] = {
				HexCode = "#1c1d21"
			},
			["Metallic Dark Silver"] = {
				HexCode = "#454b4f"
			},
			["Metallic Silver"] = {
				HexCode = "#999da0"
			},
			["Metallic Blue Silver"] = {
				HexCode = "#c2c4c6"
			},
			["Metallic Red"] = {
				HexCode = "#c00e1a"
			},
			["Metallic Torino Red"] = {
				HexCode = "#da1918"
			},
			["Metallic Blaze Red"] = {
				HexCode = "#a51e23"
			},
			["Metallic Sunrise Orange"] = {
				HexCode = "#d44a17"
			},
			["Metallic Classic Gold"] = {
				HexCode = "#c2944f"
			},
			["Metallic Orange"] = {
				HexCode = "#f78616"
			},
			["Matte Red"] = {
				HexCode = "#cf1f21"
			},
			["Matte Dark Red"] = {
				HexCode = "#732021"
			},
			["Matte Orange"] = {
				HexCode = "#f27d20"
			},
			["Matte Yellow"] = {
				HexCode = "#ffc91f"
			},
			["Metallic Dark Green"] = {
				HexCode = "#132428"
			},
			["Metallic Racing Green"] = {
				HexCode = "#122e2b"
			},
			["Metallic Sea Green"] = {
				HexCode = "#12383c"
			},
			["Metallic Olive Green"] = {
				HexCode = "#31423f"
			},
			["Metallic Green"] = {
				HexCode = "#155c2d"
			},
			["Metallic Midnight Blue"] = {
				HexCode = "#222e46"
			},
			["Metallic Dark Blue"] = {
				HexCode = "#233155"
			},
			["Metallic Saxony Blue"] = {
				HexCode = "#304c7e"
			},
			["Metallic Blue"] = {
				HexCode = "#47578f"
			},
			["Metallic Mariner Blue"] = {
				HexCode = "#637ba7"
			},
			["Metallic Harbor Blue"] = {
				HexCode = "#394762"
			},
			["Metallic Diamond Blue"] = {
				HexCode = "#d6e7f1"
			},
			["Metallic Surf Blue"] = {
				HexCode = "#76afbe"
			},
			["Metallic Nautical Blue"] = {
				HexCode = "#345e72"
			},
			["Metallic Bright Blue"] = {
				HexCode = "#0b9cf1"
			},
			["Metallic Purple Blue"] = {
				HexCode = "#2f2d52"
			},
			["Metallic Spinnaker Blue"] = {
				HexCode = "#282c4d"
			},
			["Metallic Ultra Blue"] = {
				HexCode = "#2354a1"
			}
		}	
	},
}

return Configuration
