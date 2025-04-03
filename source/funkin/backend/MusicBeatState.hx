package funkin.backend;

import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.GraphicCacheSprite;
import funkin.backend.system.Controls;
import funkin.backend.scripting.DummyScript;
import flixel.FlxState;
import flixel.FlxSubState;
import funkin.backend.scripting.events.*;
import funkin.backend.scripting.Script;
import funkin.backend.scripting.ScriptPack;
import funkin.backend.system.interfaces.IBeatReceiver;
import funkin.backend.system.Conductor;
import funkin.options.PlayerSettings;

#if TOUCH_CONTROLS
/*
@author of the code is sysource_xyz and HomuHomu of github images mobile.pngs (i rob sorry:(...)
*/
import mobile.funkin.backend.utils.MobileData;
import mobile.objects.Hitbox;
import mobile.objects.TouchPad;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
#end

class MusicBeatState extends FlxState implements IBeatReceiver {
    private var lastBeat:Float = 0;
    private var lastStep:Float = 0;

    public var graphicCache:GraphicCacheSprite = new GraphicCacheSprite();

    #if TOUCH_CONTROLS
    public var touchPad:TouchPad;
    public var hitbox:Hitbox;
    public var hboxCam:FlxCamera;
    public var tpadCam:FlxCamera;
    #end

    public var cancelConductorUpdate:Bool = false;

    public var curStep(get, never):Int;
    public var curBeat(get, never):Int;
    public var curMeasure(get, never):Int;
    public var curStepFloat(get, never):Float;
    public var curBeatFloat(get, never):Float;
    public var curMeasureFloat(get, never):Float;
    public var songPos(get, never):Float;

    inline function get_curStep():Int
        return Conductor.curStep;
    inline function get_curBeat():Int
        return Conductor.curBeat;
    inline function get_curMeasure():Int
        return Conductor.curMeasure;
    inline function get_curStepFloat():Float
        return Conductor.curStepFloat;
    inline function get_curBeatFloat():Float
        return Conductor.curBeatFloat;
    inline function get_curMeasureFloat():Float
        return Conductor.curMeasureFloat;
    inline function get_songPos():Float
        return Conductor.songPosition;

    public var controls(get, never):Controls;
    public var controlsP1(get, never):Controls;
    public var controlsP2(get, never):Controls;

    public var stateScripts:ScriptPack;
    public var scriptsAllowed:Bool = true;

    public static var lastScriptName:String = null;
    public static var lastStateName:String = null;

    public var scriptName:String = null;

    public static var skipTransOut:Bool = false;
    public static var skipTransIn:Bool = false;

    inline function get_controls():Controls
        return PlayerSettings.solo.controls;
    inline function get_controlsP1():Controls
        return PlayerSettings.player1.controls;
    inline function get_controlsP2():Controls
        return PlayerSettings.player2.controls;

    public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
        super();
        this.scriptsAllowed = #if SOFTCODED_STATES scriptsAllowed #else false #end;

        if (lastStateName != (lastStateName = Type.getClassName(Type.getClass(this)))) {
            lastScriptName = null;
        }
        this.scriptName = scriptName != null ? scriptName : lastScriptName;
        lastScriptName = this.scriptName;
    }

    function loadScript() {
        var className = Type.getClassName(Type.getClass(this));
        if (stateScripts == null)
            (stateScripts = new ScriptPack(className)).setParent(this);
        if (scriptsAllowed) {
            if (stateScripts.scripts.length == 0) {
                var scriptName = this.scriptName != null ? this.scriptName : className.substr(className.lastIndexOf(".") + 1);
                for (i in funkin.backend.assets.ModsFolder.getLoadedMods()) {
                    var path = Paths.script('data/states/${scriptName}/LIB_$i');
                    var script = Script.create(path);
                    if (script is DummyScript) continue;
                    script.remappedNames.set(script.fileName, '$i:${script.fileName}');
                    stateScripts.add(script);
                    script.load();
                }
            } else stateScripts.reload();
        }
    }

    public override function tryUpdate(elapsed:Float):Void {
        if (persistentUpdate || subState == null) {
            call("preUpdate", [elapsed]);
            update(elapsed);
            call("postUpdate", [elapsed]);
        }

        if (_requestSubStateReset) {
            _requestSubStateReset = false;
            resetSubState();
        }
        if (subState != null) {
            subState.tryUpdate(elapsed);
        }
    }

    override function create() {
        loadScript();
        Framerate.offset.y = 0;
        super.create();
        call("create");
    }

    public override function createPost() {
        super.createPost();
        persistentUpdate = true;
        call("postCreate");
        if (!skipTransIn)
            openSubState(new MusicBeatTransition(null));
        skipTransIn = false;
        skipTransOut = false;
    }

    public function call(name:String, ?args:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic {
        if (stateScripts != null)
            return stateScripts.call(name, args);
        return defaultVal;
    }

    public function event<T:CancellableEvent>(name:String, event:T):T {
        if (stateScripts != null)
            stateScripts.call(name, [event]);
        return event;
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.F5) {
            loadScript();
        }
        call("update", [elapsed]);

        super.update(elapsed);
    }

    public override function destroy() {
        #if TOUCH_CONTROLS
        removeTouchPad();
        removeHitbox();
        #end

        super.destroy();
        graphicCache.destroy();
        call("destroy");
        stateScripts = FlxDestroyUtil.destroy(stateScripts);
    }

    public function addTouchPad(DPad:String, Action:String):Void {
        #if TOUCH_CONTROLS
        touchPad = new TouchPad(DPad, Action);
        add(touchPad);
        #end
    }

    public function removeTouchPad():Void {
        #if TOUCH_CONTROLS
        if (touchPad != null) {
            remove(touchPad);
            touchPad = FlxDestroyUtil.destroy(touchPad);
        }

        if (tpadCam != null) {
            FlxG.cameras.remove(tpadCam);
            tpadCam = FlxDestroyUtil.destroy(tpadCam);
        }
        #end
    }

    public function addHitbox(?defaultDrawTarget:Bool = false):Void {
        #if TOUCH_CONTROLS
        hitbox = new Hitbox(Options.extraHints);

        hboxCam = new FlxCamera();
        hboxCam.bgColor.alpha = 0;
        FlxG.cameras.add(hboxCam, defaultDrawTarget);

        hitbox.cameras = [hboxCam];
        hitbox.visible = false;
        add(hitbox);
        #end
    }

    public function removeHitbox():Void {
        #if TOUCH_CONTROLS
        if (hitbox != null) {
            remove(hitbox);
            hitbox = FlxDestroyUtil.destroy(hitbox);
        }

        if (hboxCam != null) {
            FlxG.cameras.remove(hboxCam);
            hboxCam = FlxDestroyUtil.destroy(hboxCam);
        }
        #end
    }

    public function addTouchPadCamera(?defaultDrawTarget:Bool = false):Void {
        #if TOUCH_CONTROLS
        if (touchPad != null) {
            tpadCam = new FlxCamera();
            tpadCam.bgColor.alpha = 0;
            FlxG.cameras.add(tpadCam, defaultDrawTarget);
            touchPad.cameras = [tpadCam];
        }
        #end
    }

    public function setTouchPadMode(DPadMode:String, ActionMode:String, ?addCamera:Bool = false):Void {
        #if TOUCH_CONTROLS
        if (touchPad == null) return;
        removeTouchPad();
        addTouchPad(DPadMode, ActionMode);
        if (addCamera) {
            addTouchPadCamera();
        }
        #end
    }

    public static function getState():MusicBeatState {
        return cast (FlxG.state, MusicBeatState);
    }
}
