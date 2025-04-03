package funkin.backend.system;

import funkin.backend.assets.ModsFolder;
import funkin.menus.TitleState;
import funkin.menus.BetaWarningState;
import funkin.backend.chart.EventsData;
import flixel.FlxState;
#if mobile
import mobile.funkin.backend.system.CopyState;
#end

/**
 * Simple state used for loading the game
 */
class MainState extends FlxState {
    public static var initiated:Bool = false;
    public static var betaWarningShown:Bool = false;

    public override function create() {
        super.create();

        #if mobile
        funkin.backend.system.Main.framerateSprite.setScale();
        #end

        if (!initiated) {
            Main.loadGameSettings();

            #if mobile
            if (!CopyState.checkExistingFiles()) {
                FlxG.switchState(new CopyState());
                return;
            }
            #end

            #if TOUCH_CONTROLS
            mobile.funkin.backend.utils.MobileData.init();
            #end
        }

        initiated = true;

        Options.save();

        FlxG.bitmap.reset();
        FlxG.sound.destroy(true);

        Paths.assetsTree.reset();

        // Ajustado para usar apenas arquivos internos ao `.apk`
        var internalAddons:Array<String> = [];
        var internalMods:Array<String> = [];

        // Carregar mods internos do diretório `assets`
        internalAddons = [for (addon in ModsFolder.listInternalAddons()) addon];
        internalMods = [for (mod in ModsFolder.listInternalMods()) mod];

        for (addon in internalAddons) {
            Paths.assetsTree.addLibrary(ModsFolder.loadModLib('assets/addons/$addon', addon));
        }

        for (mod in internalMods) {
            Paths.assetsTree.addLibrary(ModsFolder.loadModLib('assets/mods/$mod', mod));
        }

        MusicBeatTransition.script = "";
        Main.refreshAssets();
        ModsFolder.onModSwitch.dispatch(ModsFolder.currentModFolder);
        DiscordUtil.init();
        EventsData.reloadEvents();
        TitleState.initialized = false;

        if (betaWarningShown) {
            FlxG.switchState(new TitleState());
        } else {
            FlxG.switchState(new BetaWarningState());
            betaWarningShown = true;
        }
    }
}