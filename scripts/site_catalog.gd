extends RefCounted
## Static demonstration data. Controls change intent only; no energy model exists.

static func objects() -> Dictionary:
	return {
		"building": {"name": "Westbrook Office", "type": "BUILDING", "code": "BLD", "color": "#537f8b", "description": "A compact workplace with rooftop generation and three charging bays.", "values": [["Occupancy", "42 / 60 people"], ["Floor area", "1,200 m²"], ["Base demand", "18.4 kW"], ["Opening hours", "08:00 – 18:00"]], "controls": ["Overview", "Schedule"], "mode": "Overview"},
		"solar": {"name": "Rooftop solar", "type": "SOLAR ARRAY", "code": "PV", "color": "#ddaa3b", "description": "The office roof hosts a 32-panel photovoltaic array.", "values": [["Generation", "12.8 kW"], ["Installed capacity", "20.0 kWp"], ["Inverter status", "Online"], ["Today so far", "8.6 kWh"]], "controls": ["Overview", "Forecast"], "mode": "Overview"},
		"hvac": {"name": "Climate system", "type": "HVAC", "code": "AC", "color": "#6d99ba", "description": "Choose a comfort setting for the office climate system.", "values": [["Indoor temperature", "22.4 °C"], ["Target temperature", "22.0 °C"], ["Current power", "6.2 kW"], ["Comfort", "Comfortable"]], "controls": ["Eco", "Normal", "Boost"], "mode": "Normal"},
		"inverter": {"name": "Solar inverter", "type": "ELECTRICAL EQUIPMENT", "code": "INV", "color": "#c99242", "description": "Converts rooftop DC generation to the site's AC supply.", "values": [["AC output", "12.8 kW"], ["Rated power", "20.0 kW"], ["Efficiency", "97.2 %"], ["Status", "Online"]], "controls": ["Overview", "Diagnostics"], "mode": "Overview"},
		"battery": {"name": "Site battery", "type": "BATTERY STORAGE", "code": "BAT", "color": "#2b9985", "description": "Set the battery's operating intent. Energy readings are fixed demo values.", "values": [["State of charge", "64 %"], ["Stored energy", "32 / 50 kWh"], ["Current power", "0.0 kW"], ["Power limit", "15.0 kW"]], "controls": ["Charge", "Hold", "Discharge"], "mode": "Hold"},
		"grid": {"name": "Grid connection", "type": "METER & TRANSFORMER", "code": "GRID", "color": "#8b80ad", "description": "The site's connection to the public electricity grid.", "values": [["Grid import", "11.8 kW"], ["Import limit", "60.0 kW"], ["Electricity price", "€0.18 / kWh"], ["Meter status", "Connected"]], "controls": ["Overview", "Meter"], "mode": "Overview"},
		"ev_1": ev("01", "38 %", "80 %", "12:30", "Normal"),
		"ev_2": ev("02", "62 %", "90 %", "17:00", "Low"),
		"ev_3": ev("03", "21 %", "80 %", "15:45", "Pause")
	}

static func ev(number: String, soc: String, target: String, departure: String, mode: String) -> Dictionary:
	return {"name": "EV charger " + number, "type": "EV CHARGING BAY", "code": "EV " + number, "color": "#2b9985", "description": "Choose the charging intent for this bay. The connected EV is a demonstration vehicle.", "values": [["EV state of charge", soc], ["Charge target", target], ["Departure", departure], ["Charger capacity", "11.0 kW"]], "controls": ["Pause", "Low", "Normal", "Fast"], "mode": mode}
