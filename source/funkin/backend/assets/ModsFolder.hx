package funkin.backend.assets;

import funkin.backend.system.MainState;
import funkin.menus.TitleState;
import funkin.backend.system.Main;
import openfl.utils.AssetCache;
import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxSignal.FlxTypedSignal;

import lime.text.Font;
import openfl.text.Font as OpenFLFont;

#if MOD_SUPPORT
import lime.utils.AssetLibrary;
#end

import flixel.FlxState;
import haxe.io.Path;

using StringTools;

class ModsFolder {
    /**
     * INTERNAL - Only use when editing source mods!!
     */
    @:dox(hide) public static var onModSwitch:FlxTypedSignal<String->Void> = new FlxTypedSignal<String->Void>();

    /**
     * Current mod folder. Will affect `Paths`.
     */
    public static var currentModFolder:String = null;

    /**
     * Path to the `mods` folder inside the APK.
     */
    public static var modsPath:String = "assets/mods/";

    /**
     * Path to the `addons` folder inside the APK.
     */
    public static var addonsPath:String = "assets/addons/";

    /**
     * If accessing a file as assets/data/global/LIB_mymod.hx should redirect to mymod:assets/data/global.hx
     */
    public static var useLibFile:Bool = true;

    /**
     * Whenever it's the first time mods have been reloaded.
     */
    private static var __firstTime:Bool = true;

    /**
     * Initializes the `mods` folder.
     */
    public static function init() {
        // Ensure the mods and addons paths exist within the APK
        if (!FileSystem.exists(modsPath)) {
            trace("Mods folder not found in APK: " + modsPath);
        }

        if (!FileSystem.exists(addonsPath)) {
            trace("Addons folder not found in APK: " + addonsPath);
        }
    }

    /**
     * Switches mod - unloads all the other mods, then load this one.
     * @param mod Name of the mod or more if you put this:
	public static function switchMod(mods:Array<String>) {
    // unload all the mods
    Options.lastLoadedMod = mods.join(", ");
    currentModFolder = mods.length > 0 ? mods[0] : null;

    // reload the mods
    reloadMods();

    // 1 for 1 mod loads
    for (mod in mods) {
        trace("Loading mod: " + mod);
        loadModLib(modsPath + mod);
    }
}
	or this
	ModsFolder.switchMod(["MyFirstMod", "MySecondMod", "AnotherMod"]);
	or one
	ModsFolder.switchMod(["MyFirstMod"]);
     */
    public static function switchMod(mod:String) {
        Options.lastLoadedMod = currentModFolder = mod;
        reloadMods();
    }

    public static function reloadMods() {
        if (!__firstTime) {
            FlxG.switchState(new MainState());
        }
        __firstTime = false;
    }

    /**
     * Loads a mod library from the specified path. Supports folders and zips.
     * @param modName Name of the mod
     * @param force Whether the mod should be reloaded if it has already been loaded
     */
    public static function loadModLib(path:String, force:Bool = false, ?modName:String) {
        #if MOD_SUPPORT
        if (FileSystem.exists(path + ".zip")) {
            return loadLibraryFromZip(path.toLowerCase(), path + ".zip", force, modName);
        } else {
            return loadLibraryFromFolder(path.toLowerCase(), path, force, modName);
        }
        #else
        return null;
        #end
    }

    public static function getModsList():Array<String> {
        var mods:Array<String> = [];
        #if MOD_SUPPORT
        // List mods from the APK's mods folder
        var modsList:Array<String> = FileSystem.readDirectory(modsPath);

        if (modsList == null || modsList.length <= 0) {
            return mods;
        }

        for (modFolder in modsList) {
            if (FileSystem.isDirectory(modsPath + modFolder)) {
                mods.push(modFolder);
            } else {
                var ext = Path.extension(modFolder).toLowerCase();
                switch (ext) {
                    case "zip":
                        // Is a zip mod
                        mods.push(Path.withoutExtension(modFolder));
                }
            }
        }
        #end
        return mods;
    }

    public static function getLoadedMods():Array<String> {
        var libs = [];
        for (i in Paths.assetsTree.libraries) {
            var l = i;
            if (l is openfl.utils.AssetLibrary) {
                var al = cast(l, openfl.utils.AssetLibrary);
                @:privateAccess
                if (al.__proxy != null) l = al.__proxy;
            }
            var libString:String;
            if (l is ScriptedAssetLibrary || l is IModsAssetLibrary) {
                libString = cast(l, IModsAssetLibrary).modName;
            } else {
                continue;
            }
            libs.push(libString);
        }
        return libs;
    }

    public static function prepareLibrary(libName:String, force:Bool = false) {
        var assets:AssetManifest = new AssetManifest();
        assets.name = libName;
        assets.version = 2;
        assets.libraryArgs = [];
        assets.assets = [];

        return AssetLibrary.fromManifest(assets);
    }

    public static function registerFont(font:Font) {
        var openflFont = new OpenFLFont();
        @:privateAccess
        openflFont.__fromLimeFont(font);
        OpenFLFont.registerFont(openflFont);
        return font;
    }

    public static function prepareModLibrary(libName:String, lib:IModsAssetLibrary, force:Bool = false) {
        var openLib = prepareLibrary(libName, force);
        lib.prefix = "assets/";
        @:privateAccess
        openLib.__proxy = cast(lib, lime.utils.AssetLibrary);
        return openLib;
    }

    #if MOD_SUPPORT
    public static function loadLibraryFromFolder(libName:String, folder:String, force:Bool = false, ?modName:String) {
        return prepareModLibrary(libName, new ModsFolderLibrary(folder, libName, modName), force);
    }

    public static function loadLibraryFromZip(libName:String, zipPath:String, force:Bool = false, ?modName:String) {
        return prepareModLibrary(libName, new ZipFolderLibrary(zipPath, libName, modName), force);
    }
    #end
}
