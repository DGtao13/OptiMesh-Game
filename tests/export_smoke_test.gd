extends SceneTree
var app
var checks: int=0
var failures: int=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, caption: String) -> void:
    checks+=1
    if not ok:
        failures+=1
        push_error(caption)
func press(caption: String) -> void:
    var item=app.find_caption(app.ui,caption)
    check(item!=null,"Available: "+caption)
    if item: item.pressed.emit()
func shot(name: String) -> void:
    await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_environment("OPTIMESH_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
    check(OS.has_feature("template") and not OS.has_feature("editor"),"Running exported template, not editor")
    check(not DirAccess.dir_exists_absolute("res://tests") and not DirAccess.dir_exists_absolute("res://docs") and not DirAccess.dir_exists_absolute("res://artifacts"),"Player package excludes development content")
    app=load("res://scenes/main.tscn").instantiate()
    root.add_child(app)
    await process_frame
    check(app.screen=="start","Export main menu")
    var old_entries: int=app.store.current_entries().size()
    if "--reopen" in OS.get_cmdline_user_args():
        check(old_entries>0 and app.store.data.effects==0.4,"Leaderboard and settings survive closing/reopening")
    await shot("menu")
    press("New Game  →")
    check(app.screen=="name","Name screen")
    app.name_input.text="Release QA"
    press("Continue  →")
    press("Start Demo  →")
    check(app.screen=="game" and app.guidance.active(),"Demo starts with tutorial")
    app.skip_tutorial()
    app.set_process(false)
    await shot("gameplay")
    app.show_settings()
    check(app.paused,"Settings pause game")
    app.store.data.effects=0.4
    app.sound.apply_settings()
    press("Test sound")
    check(app.sound.effects.stream==app.sound.tones.complete and app.sound.music.playing,"Exported music/effects playback routes")
    app.store.data.mute=true
    app.sound.apply_settings()
    check(app.sound.music.stream_paused and not app.sound.effects.playing,"Mute controls output")
    app.store.data.mute=false
    app.sound.apply_settings()
    press("Done")
    check(app.settings_overlay==null and app.store.last_error=="","Settings save")
    var original: int=DisplayServer.window_get_mode()
    var key=InputEventKey.new()
    key.keycode=KEY_F11
    key.pressed=true
    app._unhandled_key_input(key)
    await create_timer(0.25).timeout
    check(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN,"Fullscreen shortcut")
    app._unhandled_key_input(key)
    await create_timer(0.25).timeout
    check(DisplayServer.window_get_mode()==original,"Return to window")
    for minute in range(600):
        if app.screen=="game":
            var t: float=app.simulation.time_minutes
            if t>=630 and t<640:
                app.select_object("ev_2")
                app.apply_control("Fast")
            if t>=735 and t<740:
                app.select_object("flex")
                app.apply_control("Run")
            if app.simulation.dirty and app.simulation.cleaning_end<0:
                app.select_object("solar")
                app.apply_control("Clean")
            if t>=870 and t<875:
                app.select_object("ev_3")
                app.apply_control("Fast")
            if t>=930 and t<975:
                app.select_object("battery")
                app.apply_control("Discharge")
            app.advance_clock(1.0/app.pacing)
        if minute%10==0: await process_frame
    check(app.screen=="results" and app.results_values.ev_met==3,"Complete rendered exported day reaches results")
    check(app.store.current_entries().size()==old_entries+1 and app.store.last_error=="","Leaderboard writes locally")
    await shot("results")
    press("Play Again  →")
    check(app.screen=="game" and app.simulation.time_minutes==480,"Retry resets day")
    app.show_start()
    press("Leaderboard")
    check(app.screen=="leaderboard","Ranking screen")
    await shot("leaderboard")
    press("Main Menu")
    check(app.screen=="start","Return to menu")
    print("EXPORTED RELEASE SMOKE: %d checks, %d failures" % [checks,failures])
    print("EXPORTED USER DATA: "+OS.get_user_data_dir())
    app.queue_free()
    await process_frame
    await create_timer(0.3).timeout
    quit(0 if failures==0 else 1)
