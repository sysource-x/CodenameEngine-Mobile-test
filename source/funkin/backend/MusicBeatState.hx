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

class MusicBeatState extends FlxState implements IBeatReceiver {
    public static var instance:MusicBeatState;

    #if TOUCH_CONTROLS
    public var touchPad:TouchPad;
    public var hitbox:Hitbox;
    public var hboxCam:FlxCamera;
    public var tpadCam:FlxCamera;
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

    override function destroy():Void {
        #if TOUCH_CONTROLS
        removeTouchPad();
        removeHitbox();
        #end

        super.destroy();
        graphicCache.destroy();
        call("destroy");
        stateScripts = FlxDestroyUtil.destroy(stateScripts);
    }

    public function call(name:String, ?args:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic {
        if (stateScripts != null)
            return stateScripts.call(name, args);
        return defaultVal;
    }

    public static function getState():MusicBeatState {
        return cast (FlxG.state, MusicBeatState);
    }
}
