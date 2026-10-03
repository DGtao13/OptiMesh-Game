extends "res://scripts/main.gd"
const Model = preload("res://scripts/management_simulation.gd")
const Reference = preload("res://scripts/reference_runs.gd")
const Store = preload("res://scripts/local_store.gd")
const Audio = preload("res://scripts/game_audio.gd")
const Activity = preload("res://scripts/site_activity.gd")
const Face = preload("res://scripts/opti_face.gd")
var store = Store.new()
var sound
var mode_name := "Demo"
var pacing := 1.25
var task_panel: Panel
var task_buttons: Array = []
var face
var activity
var message_target := "building"
var message_age := 0.0
var known_status: Dictionary = {}
var rank := 0
var compared: Dictionary = {}
var session_recorded := false
var settings_overlay: Control
var speech_tween: Tween
var last_speech := ""
var grid_warning := false
var comfort_warning := false

func _ready() -> void:
	simulation=Model.new()
	sound=Audio.new()
	sound.settings=store.data
	add_child(sound)
	super._ready()

func button(text: String, rect: Rect2, callback: Callable, parent: Node = null, primary: bool = false) -> Button:
	var item=super.button(text,rect,callback,parent,primary)
	item.pressed.connect(func(): sound.cue("click") if is_instance_valid(sound) else null)
	return item

func show_start() -> void:
	super.show_start()
	for item in all_labels(ui):
		if "local desktop prototype" in item.text: item.text="Local office challenge · 8 or 20 min"
		elif "Explore a small workplace" in item.text: item.text="Run an office day. Keep services ready and discover what coordinated energy can do."
	# Separate menu links, comfortably outside the welcome card.
	button("Leaderboard",Rect2(80,910,240,55),show_leaderboard)
	button("Audio / display",Rect2(335,910,245,55),show_settings)

func brand(show_version: bool = true) -> void:
	super.brand(show_version)
	for item in all_labels(ui):
		if item.text=="GUIDED OFFICE DAY  /  03": item.text="EXHIBITION OFFICE DAY  /  04"

func show_modes() -> void:
	super.show_modes()
	var demo_button=find_caption(ui,"Start Demo  →")
	for connection in demo_button.pressed.get_connections(): demo_button.pressed.disconnect(connection.callable)
	demo_button.pressed.connect(func(): mode_name="Demo"; start_demo())
	var unavailable=find_caption(ui,"Not available yet")
	if unavailable:
		unavailable.text="Start Normal  →"
		unavailable.disabled=false
		for connection in unavailable.pressed.get_connections(): unavailable.pressed.disconnect(connection.callable)
		unavailable.pressed.connect(func(): mode_name="Normal"; start_demo())
	for node in all_labels(ui):
		if node.text=="COMING LATER": node.text="TAKE YOUR TIME"
		elif "More scenarios" in node.text: node.text="The same fair office challenge at a slower pace: about 20 minutes, plus time to plan."
		elif "Simulate a clear office day" in node.text: node.text="Eight minutes of site management: EVs, comfort, weather, maintenance and a grid challenge."

func find_caption(node: Node, caption: String) -> Button:
	if node is Button and node.text==caption: return node
	for child in node.get_children():
		var found=find_caption(child,caption)
		if found: return found
	return null

func all_labels(node: Node) -> Array:
	var items: Array=[]
	if node is Label: items.append(node)
	for child in node.get_children(): items.append_array(all_labels(child))
	return items

func start_demo() -> void:
	if screen=="modes" and mode_name!="Normal": mode_name="Demo"
	pacing=0.5 if mode_name=="Normal" else 1.25
	known_status.clear()
	session_recorded=false
	compared.clear()
	task_buttons.clear()
	task_panel=null
	face=null
	activity=null
	message_age=0
	grid_warning=false
	comfort_warning=false
	super.start_demo()
	for item in all_labels(intro_overlay):
		if "Get EV 01" in item.text: item.text="Keep the office ready for everyone."
		elif "Manage one office" in item.text: item.text="Charge vehicles on time, keep people comfortable and finish tasks. Coordinate power to lower costs and peaks."
		elif "Inspect the site" in item.text: item.text="Opti will flag arrivals, weather and changing deadlines. Click a task to find its controls. Learn the basics first, or skip."

func show_game() -> void:
	super.show_game()
	for item in all_labels(ui):
		if item.text=="DEMO": item.text=mode_name.to_upper()
	site.living_site=true
	site.position=Vector2(445,340)
	site.scale=Vector2.ONE*0.7
	site.clip_contents=true
	activity=Activity.new()
	activity.model=simulation
	activity.reduced=not store.data.ambient
	site.add_child(activity)
	task_panel=panel(Rect2(55,285,350,620))
	label("TASKS · CLICK TO MANAGE",Rect2(18,12,314,30),17,GREEN,task_panel)
	for i in range(7):
		var item=button("",Rect2(12,53+i*78,326,72),func(): pass,task_panel)
		item.add_theme_font_size_override("font_size",16)
		item.alignment=HORIZONTAL_ALIGNMENT_LEFT
		task_buttons.append(item)
	var old_assistant=assistant_message.get_parent()
	ui.remove_child(old_assistant)
	old_assistant.queue_free()
	var old_snapshot=snapshot_label.get_parent()
	old_snapshot.visible=false
	var companion=panel(Rect2(445,815,980,220),Color("#dae9e0"))
	face=Face.new()
	place(face,Rect2(18,18,56,56),companion)
	guide_title=label("OPTI · YOUR SITE COLLEAGUE",Rect2(90,20,620,30),19,GREEN,companion)
	assistant_message=paragraph("",Rect2(25,83,925,115),23,INK,companion)
	guide_button=button("Inspect",Rect2(680,18,150,45),guide_action,companion)
	guide_skip=button("Skip",Rect2(842,18,112,45),skip_tutorial,companion)
	button("Settings",Rect2(1550,30,155,50),show_settings)
	refresh_guidance()
	refresh_simulation_ui()

func guide_action() -> void:
	if guidance.active(): super.guide_action()
	else:
		select_object(message_target)
		simulation.notices.clear()
		context_note="Watch your tasks and target ETAs. Choose when to store solar, charge vehicles and run the wash."
		refresh_guidance()

func refresh_guidance() -> void:
	super.refresh_guidance()
	if not guidance.active():
		guide_button.visible=true
		guide_button.text="Show system"
		guide_skip.visible=true
		guide_skip.text="Got it"
	if is_instance_valid(face):
		face.worried=simulation.grid_kw>18 or simulation.inside_c>25
		face.queue_redraw()
	if last_speech!=assistant_message.text:
		last_speech=assistant_message.text
		if speech_tween and speech_tween.is_valid(): speech_tween.kill()
		assistant_message.modulate.a=0.35
		speech_tween=assistant_message.create_tween()
		speech_tween.tween_property(assistant_message,"modulate:a",1.0,0.25)

func skip_tutorial() -> void:
	if guidance.active(): super.skip_tutorial()
	else:
		context_note="Check tasks on the left. Completed and missed requirements stay visible."
		simulation.notices.clear()
		refresh_guidance()

func show_inspector_empty() -> void:
	super.show_inspector_empty()
	for item in all_labels(inspector):
		if "LIVE SIMULATION" in item.text: item.text="YOUR JOB\nKeep vehicles ready, rooms comfortable and tasks on time. Click a task for its controls."

func _sync_readings() -> void:
	super._sync_readings()
	objects.solar.description="Weather and dust affect generation. Cleaning costs €2 and takes 15 minutes offline."
	objects.solar.controls=["Overview","Clean"]
	objects.solar.values[3]=["Panels / weather",("Cleaning" if simulation.cleaning_end>elapsed_minutes else ("Dirty · 75%" if simulation.dirty else "Clean"))+" / "+("Clouds" if simulation.weather_factor(elapsed_minutes)<1 else "Clear")]
	objects.hvac.type="OFFICE CLIMATE"
	objects.hvac.description="Eco saves power but allows heat buildup. Normal balances cooling; Boost cools faster. Aim for 20–25°C."
	objects.hvac.mode=simulation.hvac_mode
	objects.hvac.values=[["Inside / outside","%.1f / %.1f°C" % [simulation.inside_c,simulation.outside_c]],["Cooling power","%.1f kW" % simulation.hvac_kw],["Comfortable time","%.0f%%" % simulation.comfort_percent()],["Required comfort","95% of the office day"]]
	objects.flex={"name":"Equipment wash","type":"FLEXIBLE OFFICE LOAD","code":"WASH","color":"#6d99ba","description":"Run a 6 kW equipment wash for 60 minutes between 11:00 and 15:00. You may pause and resume; progress is retained.","values":[["Runtime","%.0f / 60 min" % simulation.flex_minutes],["Power","%.1f kW" % simulation.flex_kw],["Deadline","15:00"],["State","Running" if simulation.flex_kw>0 else "Waiting / complete"]],"controls":["Run","Pause"],"mode":"Run" if simulation.flex_running else "Pause"}
	for v in simulation.vehicles:
		var soc: float=v.energy/v.capacity*100
		var eta: float=elapsed_minutes+(v.capacity*v.target/100-v.energy)*60/maxf(v.power*0.9,0.0001)
		var state: String="Departed" if v.departed else ("Connected" if elapsed_minutes>=v.arrival else "Not arrived")
		objects[v.id].type="EV CHARGING BAY"
		objects[v.id].description="Choose its charge rate. Meet the target before departure; arrival and deadline are shown below."
		objects[v.id].mode=v.mode
		objects[v.id].values=[["Charge / target","%.1f%% / %.0f%%" % [soc,v.target]],["Power / maximum","%.1f / %.0f kW" % [v.power,v.maximum]],["Arrival / departure",time_text(v.arrival)+" / "+time_text(v.departure)],["State",state],["Target ETA",time_text(eta) if v.power>0 else ("Target reached" if soc>=v.target-0.001 else "No charging")],["Departure result","%.1f%% · %s" % [v.departure_soc,"Ready" if v.success else "Missed"] if v.departed else "Pending"]]

func _control_note() -> String:
	return "Real controls · changes affect energy, tasks and your final score."

func apply_control(mode: String) -> void:
	if selected_id=="" or day_finished: return
	var accepted: bool=simulation.control(selected_id,mode)
	if selected_id in ["grid","building","inverter"] or (selected_id=="solar" and mode=="Overview"): accepted=true
	context_note=(objects[selected_id].name+" · "+mode+" selected. Check the live power and task progress.") if accepted else "That action is unavailable now. Check arrival, deadline or maintenance state."
	message_target=selected_id
	if accepted: objects[selected_id].mode=mode
	guidance.controlled(selected_id)
	sound.cue("clean" if selected_id=="solar" and mode=="Clean" and accepted else "click")
	refresh_simulation_ui()
	_update_mode_buttons()
	feedback.text=_control_note()
	refresh_guidance()

func refresh_simulation_ui() -> void:
	super.refresh_simulation_ui()
	if not is_instance_valid(task_panel): return
	simulation.update_tasks()
	var active:=0
	for task in simulation.tasks:
		if task.status=="active": active+=1
	objective_label.text="%s · %d active tasks · Keep services ready, cost and peaks low" % [mode_name,active]
	clock_detail.text="1× = %.2f min/s · %.1f kW office" % [pacing,simulation.building_kw]
	grid_title.text="GRID · IMPORTING" if simulation.grid_kw>=0 else "GRID · EXPORTING"
	grid_label.add_theme_color_override("font_color",Color("#ad5143") if elapsed_minutes>=930 and elapsed_minutes<975 and simulation.grid_kw>18 else INK)
	grid_detail.text="LIMIT 18 kW · until 16:15" if elapsed_minutes>=930 and elapsed_minutes<975 else "In %.1f / out %.1f kWh · €%.2f" % [simulation.imported_kwh,simulation.exported_kwh,simulation.electricity_cost_eur]
	solar_detail.text="Battery %.0f%% · Climate %.1f°C" % [simulation.battery_soc(),simulation.inside_c]
	var next: Array=[]
	for event in Model.Scenario.EVENTS:
		if event[0]>elapsed_minutes:
			next=event
			break
	upcoming_label.text=time_text(next[0])+" · "+str(next[1]).replace("_"," ").capitalize() if not next.is_empty() else "18:00 · Results"
	ev_status_label.text="18 kW grid limit at 15:30" if elapsed_minutes<930 else "Comfort target: 95% of day"
	for i in range(task_buttons.size()):
		var item: Button=task_buttons[i]
		item.visible=i<simulation.tasks.size()
		if not item.visible: continue
		var task: Dictionary=simulation.tasks[i]
		item.text=("✓ " if task.status=="completed" else ("× " if task.status=="failed" else "• "))+task.title+" · "+time_text(task.deadline)+"\n"+task.progress
		item.tooltip_text=task.description+" · "+task.status.capitalize()
		item.add_theme_color_override("font_color",Color("#ad5143") if task.status=="failed" else GREEN if task.status=="completed" else INK)
		for connection in item.pressed.get_connections(): item.pressed.disconnect(connection.callable)
		item.pressed.connect(select_object.bind(task.object))
		if known_status.get(task.id,"active")!=task.status:
			context_note=("Nice work: " if task.status=="completed" else "Requirement missed: ")+task.title+". "+task.progress
			message_target=task.object
			sound.cue("complete" if task.status=="completed" else "warning")
			refresh_guidance()
		known_status[task.id]=task.status

func advance_clock(delta: float) -> void:
	if screen!="game" or paused or day_finished: return
	simulation.advance(delta*speed*pacing)
	message_age+=delta
	var urgent_index: int=-1
	for index in range(simulation.notices.size()):
		if simulation.notices[index].type in ["arrival","surprise","dust","limit"]:
			urgent_index=index
			break
	if not guidance.active() and not simulation.notices.is_empty() and (message_age>=5 or urgent_index>=0):
		var note: Dictionary=simulation.notices.pop_at(urgent_index if urgent_index>=0 else 0)
		context_note=note.text
		message_target=note.object
		message_age=0
		if note.type in ["arrival","surprise","dust","limit"] and speed>1:
			set_speed(1) # Give players time to read and react at exhibition speed.
		sound.cue("warning" if note.type in ["surprise","limit","dust"] else "arrival" if note.type=="arrival" else "departure" if note.type=="departure" else "complete")
		refresh_guidance()
	if not day_finished and message_age>=5:
		var overloaded: bool=elapsed_minutes>=930 and elapsed_minutes<975 and simulation.grid_kw>18
		var hot: bool=simulation.inside_c>24.8
		if (overloaded and not grid_warning) or (hot and not comfort_warning):
			context_note="Grid limit exceeded. Discharge the battery or reduce charging/cooling power." if overloaded else "The office is getting warm. Normal or Boost cooling can protect comfort."
			message_target="grid" if overloaded else "hvac"
			sound.cue("warning")
			message_age=0
			refresh_guidance()
		grid_warning=overloaded
		comfort_warning=hot
	if day_finished: show_results()

func reset_clock() -> void:
	start_demo()

func show_results() -> void:
	results_values=simulation.summary()
	compared={"Normal":Reference.run(false),"Player":results_values,"OptiMesh demo":Reference.run(true)}
	if not session_recorded:
		rank=store.record(player_name,results_values,mode_name)
		session_recorded=true
	clear_screen("results")
	brand()
	sound.cue("results")
	label("Your office day, complete.",Rect2(100,125,1600,80),48)
	label("%s · %d / 1000 points · Local rank #%d (%s)" % [player_name,results_values.score,rank,mode_name],Rect2(105,213,1700,55),29,GREEN)
	label("Same scenario, three real simulated runs · OptiMesh demo is an offline reference strategy",Rect2(105,278,1700,40),22,MUTED)
	var columns: Array=["Normal","Player","OptiMesh demo"]
	for i in range(3):
		var r: Dictionary=compared[columns[i]]
		var card=panel(Rect2(100+i*580,340,540,475),Color("#dae9e0") if i==1 else PAPER)
		label(columns[i],Rect2(28,20,484,50),30,GREEN,card)
		label("€%.2f" % r.cost,Rect2(28,83,484,70),52,INK,card)
		label("Total energy + maintenance cost",Rect2(28,151,484,30),17,MUTED,card)
		var bar=ColorRect.new()
		bar.color=GREEN if i==1 else Color("#91b7ab")
		place(bar,Rect2(28,195,clampf(r.cost/45.0,0,1)*460,9),card)
		paragraph("EVs ready  %d / 3     Comfort  %.0f%%\nGrid import  %.1f kWh     Peak  %.1f kW\nExport  %.1f kWh     Solar used*  %.0f%%\nWash  %s     Grid limit  %s\nBattery  %.0f%%     Cycling  %.2f" % [r.ev_met,r.comfort,r.import,r.peak,r.export,r.utilization,"Done" if r.flex else "Missed","Met" if r.grid else "Exceeded",r.battery_soc,r.cycles],Rect2(28,230,484,217),23,INK,card)
	var missed: Array=[]
	for task in results_values.tasks:
		if task.status=="failed": missed.append(task.title)
	paragraph("Learn from today: "+(", ".join(missed)+" missed. Check deadlines and target ETAs next time." if not missed.is_empty() else "All requirements met. Try shifting more power to solar and reducing your peak."),Rect2(105,838,1700,65),22,MUTED)
	label("*Solar used = generation minus export; stored energy is not traced.",Rect2(105,910,1280,30),17,MUTED)
	button("How scoring works",Rect2(1470,903,330,45),show_score_help)
	if store.last_error!="": label(store.last_error,Rect2(105,875,1700,30),18,Color("#ad5143"))
	button("Play Again  →",Rect2(100,966,520,60),start_demo,null,true)
	button("Leaderboard",Rect2(665,966,520,60),show_leaderboard)
	button("Main Menu",Rect2(1230,966,570,60),func(): mode_name="Demo"; show_start())

func show_score_help() -> void:
	var overlay=Control.new()
	place(overlay,Rect2(0,0,1920,1080))
	var shade=ColorRect.new()
	shade.color=Color(0.12,0.22,0.25,0.45)
	place(shade,Rect2(0,0,1920,1080),overlay)
	var card=panel(Rect2(490,220,940,640),PAPER,overlay)
	label("Balanced service, then efficiency",Rect2(40,30,860,60),36,INK,card)
	paragraph("Up to 1000 points: EVs 450 · comfort 150 · wash 100 · grid limit 70 · cleaning 30 · cost 80 · peak 50 · solar use 50 · battery cycling 20.\n\nAn EV missing its departure caps the score at 600. Comfort below 80% or an unfinished wash caps it at 650.\n\nCost and peak points fall as your bill approaches €45 or peak approaches 60 kW. Solar-use points follow its percentage. Battery points decline over three equivalent cycles.\n\nComparisons use identical schedules and weather. The reference is a demo heuristic, not a production algorithm.",Rect2(40,120,860,400),22,INK,card)
	button("Got it",Rect2(40,550,860,60),func(): overlay.get_parent().remove_child(overlay); overlay.queue_free(),card,true)

func show_leaderboard() -> void:
	clear_screen("leaderboard")
	brand()
	label("Local leaderboard",Rect2(170,150,1500,80),48)
	label("Top runs on this laptop · Demo and Normal use the same scenario",Rect2(175,245,1500,45),23,MUTED)
	for i in range(mini(10,store.data.entries.size())):
		var entry: Dictionary=store.data.entries[i]
		var row=panel(Rect2(170,320+i*56,1560,50))
		label("#%d  %s" % [i+1,entry.name],Rect2(20,8,580,40),23,INK,row)
		label("%d pts · €%.2f · %s" % [entry.score,entry.cost,entry.mode],Rect2(650,8,850,40),23,GREEN,row)
	button("Main Menu",Rect2(170,940,350,60),func(): mode_name="Demo"; show_start())
	label("Administrator: Ctrl+Shift+Delete, then confirm reset",Rect2(650,950,1100,40),20,MUTED)

func show_settings() -> void:
	if is_instance_valid(settings_overlay): return
	var was_paused:=paused
	paused=true
	settings_overlay=Control.new()
	place(settings_overlay,Rect2(0,0,1920,1080))
	var shade=ColorRect.new()
	shade.color=Color(0.12,0.22,0.25,0.45)
	place(shade,Rect2(0,0,1920,1080),settings_overlay)
	var card=panel(Rect2(590,240,740,600),PAPER,settings_overlay)
	label("Audio and display",Rect2(40,30,660,60),38,INK,card)
	for i in range(2):
		var key: String=["music","effects"][i]
		label(key.capitalize()+" volume",Rect2(40,120+i*100,660,40),24,INK,card)
		var slider=HSlider.new()
		slider.max_value=1
		slider.step=0.01
		slider.value=store.data[key]
		place(slider,Rect2(40,167+i*100,660,35),card)
		slider.value_changed.connect(func(value): store.data[key]=value; sound.apply_settings())
	var mute=CheckButton.new()
	mute.text="Mute all audio"
	mute.button_pressed=store.data.mute
	place(mute,Rect2(40,338,660,50),card)
	mute.toggled.connect(func(value): store.data.mute=value; sound.apply_settings())
	var ambient=CheckButton.new()
	ambient.text="Ambient people, clouds and birds"
	ambient.button_pressed=store.data.ambient
	place(ambient,Rect2(40,405,660,50),card)
	ambient.toggled.connect(func(value):
		store.data.ambient=value
		if is_instance_valid(activity): activity.reduced=not value
	)
	button("Done",Rect2(40,515,660,55),func(): store.save(); settings_overlay.get_parent().remove_child(settings_overlay); settings_overlay.queue_free(); settings_overlay=null; paused=was_paused,card,true)

func _unhandled_key_input(event: InputEvent) -> void:
	if screen=="leaderboard" and event is InputEventKey and event.pressed and event.keycode==KEY_DELETE and event.ctrl_pressed and event.shift_pressed:
		var dialog=ConfirmationDialog.new()
		dialog.dialog_text="Erase all local leaderboard entries? Audio settings will stay."
		add_child(dialog)
		dialog.confirmed.connect(func(): store.data.entries=[]; store.save(); show_leaderboard(); dialog.queue_free())
		dialog.canceled.connect(dialog.queue_free)
		dialog.popup_centered(Vector2i(600,180))
		return
	if is_instance_valid(settings_overlay): return
	super._unhandled_key_input(event)
