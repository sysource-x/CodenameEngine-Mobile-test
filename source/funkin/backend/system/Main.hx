package funkin.backend.system;

import funkin.editors.SaveWarning;
import funkin.backend.assets.AssetsLibraryList;
import funkin.backend.system.framerate.SystemInfo;
import openfl.utils.AssetLibrary;
import openfl.text.TextFormat;
import flixel.system.ui.FlxSoundTray;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import funkin.backend.system.modules.*;

#if ALLOW_MULTITHREADING
import sys.thread.Thread;
#end

class Main extends Sprite
{
    public static final releaseCycle:String = "Beta";

    public static var instance:Main;

    public static var modToLoad:String = null;
    public static var forceGPUOnlyBitmapsOff:Bool = #if windows false #else true #end;
    public static var noTerminalColor:Bool = false;

    public static var scaleMode:FunkinRatioScaleMode;
    public static var framerateSprite:funkin.backend.system.framerate.Framerate;

    var gameWidth:Int = 1280;
    var gameHeight:Int = 720;
    var skipSplash:Bool = true;
    var startFullscreen:Bool = false;

    public static var game:FunkinGame;

    public static var timeSinceFocus(get, never):Float;
    public static var time:Int = 0;

    #if ALLOW_MULTITHREADING
    public static var gameThreads:Array<Thread> = [];
    #end

    public function new()
    {
        super();

        instance = this;

        #if mobile
        #if android
        StorageUtil.requestPermissions();
        #end
        // Removido Sys.setCwd para evitar dependência de diretórios externos
        #end

        CrashHandler.init();

        #if !web framerateSprite = new funkin.backend.system.framerate.Framerate(); #end

        addChild(game = new FunkinGame(gameWidth, gameHeight, MainState, Options.framerate, Options.framerate, skipSplash, startFullscreen));

        #if android FlxG.android.preventDefaultKeys = [BACK]; #end

        #if !web
        addChild(framerateSprite);
        #if mobile
        FlxG.stage.window.onResize.add((w:Int, h:Int) -> framerateSprite.setScale());
        #end
        SystemInfo.init();
        #end
    }

    public static function loadGameSettings() {
        WindowUtils.init();
        SaveWarning.init();
        MemoryUtil.init();
        @:privateAccess
        FlxG.game.getTimer = getTimer;
        #if ALLOW_MULTITHREADING
        for(i in 0...4)
            gameThreads.push(Thread.createWithEventLoop(function() {Thread.current().events.promise();}));
        #end
        FunkinCache.init();
        Paths.assetsTree = new AssetsLibraryList();

        #if UPDATE_CHECKING
        funkin.backend.system.updating.UpdateUtil.init();
        #end
        ShaderResizeFix.init();
        Logs.init();
        Paths.init();
        #if GLOBAL_SCRIPT
        funkin.backend.scripting.GlobalScript.init();
        #end

        // Ajustado para usar apenas arquivos internos ao `.apk`
        Paths.assetsTree.__defaultLibraries.push(ModsFolder.loadLibraryFromFolder('assets', 'assets/', true));

        var lib = new AssetLibrary();
        @:privateAccess
        lib.__proxy = Paths.assetsTree;
        Assets.registerLibrary('default', lib);

        funkin.options.PlayerSettings.init();
        funkin.savedata.FunkinSave.init();
        Options.load();

        FlxG.fixedTimestep = false;

        FlxG.scaleMode = scaleMode = new FunkinRatioScaleMode();

        Conductor.init();
        AudioSwitchFix.init();
        EventManager.init();
        FlxG.signals.focusGained.add(onFocus);
        FlxG.signals.preStateSwitch.add(onStateSwitch);
        FlxG.signals.postStateSwitch.add(onStateSwitchPost);

        FlxG.mouse.useSystemCursor = !Controls.instance.touchC;
        #if DARK_MODE_WINDOW
        if(funkin.backend.utils.NativeAPI.hasVersion("Windows 10")) funkin.backend.utils.NativeAPI.redrawWindowHeader();
        #end

        ModsFolder.init();
        #if MOD_SUPPORT
        ModsFolder.switchMod(modToLoad.getDefault(Options.lastLoadedMod));
        #end

        initTransition();
        #if mobile
        LimeSystem.allowScreenTimeout = Options.screenTimeOut;
        #end
    }

    public static function refreshAssets() {
        WindowUtils.resetTitle();

        FlxSoundTray.volumeChangeSFX = Paths.sound('menu/volume');
        FlxSoundTray.volumeUpChangeSFX = null;
        FlxSoundTray.volumeDownChangeSFX = null;

        if (FlxG.game.soundTray != null)
            FlxG.game.soundTray.text.setTextFormat(new TextFormat(Paths.font("vcr.ttf")));
    }

    public static function initTransition() {
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.7, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
    }

    public static function onFocus() {
        _tickFocused = FlxG.game.ticks;
    }

    private static function onStateSwitch() {
        scaleMode.resetSize();
    }

    private static function onStateSwitchPost() {
        MemoryUtil.clearMajor();
    }

    private static var _tickFocused:Float = 0;
    public static function get_timeSinceFocus():Float {
        return (FlxG.game.ticks - _tickFocused) / 1000;
    }
}
