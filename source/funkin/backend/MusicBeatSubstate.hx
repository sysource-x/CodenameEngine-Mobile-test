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

/*
@author of the code is sysource_xyz and HomuHomu of github images mobile.pngs (i rob sorry:(...)
*/
#if TOUCH_CONTROLS
import mobile.funkin.backend.utils.MobileData;
import mobile.objects.Hitbox;
import mobile.objects.TouchPad;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
#end

class MusicBeatSubstate extends FlxSubState implements IBeatReceiver {
    public static var instance:MusicBeatSubstate;

    #if TOUCH_CONTROLS
    private var touchControls:TouchControlsHandler;
    #end

    private var lastBeat:Float = 0;
    private var lastStep:Float = 0;

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

    public var stateScripts:ScriptPack;
    public var scriptsAllowed:Bool = true;

    public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
        super();
        instance = this;
        this.scriptsAllowed = scriptsAllowed;

        #if TOUCH_CONTROLS
        touchControls = new TouchControlsHandler();
        #end
    }

    public function setupTouchControls(DPad:String, Action:String, ?defaultDrawTarget:Bool = false):Void {
        #if TOUCH_CONTROLS
        touchControls.initialize(DPad, Action, defaultDrawTarget);
        add(touchControls.getTouchPad());
        add(touchControls.getHitbox());
        #end
    }

    public function clearTouchControls():Void {
        #if TOUCH_CONTROLS
        touchControls.cleanup();
        #end
    }

    public function updateTouchPadMode(DPadMode:String, ActionMode:String, ?addCamera:Bool = false):Void {
        #if TOUCH_CONTROLS
        touchControls.updateMode(DPadMode, ActionMode, addCamera);
        #end
    }

    override function destroy():Void {
        #if TOUCH_CONTROLS
        clearTouchControls();
        #end

        super.destroy();
        call("destroy");
        stateScripts = FlxDestroyUtil.destroy(stateScripts);
    }

    public static function getState():MusicBeatSubstate {
        return cast (FlxG.state, MusicBeatSubstate);
    }
}
