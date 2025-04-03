package funkin.editors;

import funkin.options.type.*;
import funkin.options.OptionsScreen;
import funkin.options.TreeMenu;
import funkin.backend.utils.NativeAPI;
import lime.system.System;

class DebugOptions extends TreeMenu {
    public override function create() {
        super.create();

        FlxG.camera.fade(0xFF000000, 0.5, true);

        // Carregar imagem do diretório interno ou assets
        var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('assets/menus/menuBGBlue'));
        bg.scale.set(1.15, 1.15);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set();
        bg.antialiasing = true;
        add(bg);

        main = new DebugOptionsScreen();
    }
}

class DebugOptionsScreen extends OptionsScreen {
    public override function new() {
        super("Debug Options", "Use this menu to change debug options.", null, 'LEFT_FULL', 'A_B');
        
        #if windows
        add(new TextOption(
            "Show Console",
            "Select this to show the debug console, which contains log information about the game.",
            function() {
                NativeAPI.allocConsole();
            }));
        #end

        add(new Checkbox(
            "Editor SFXs",
            "If checked, will play sound effects when working on editors (ex: will play sfxs when checking checkboxes...)",
            "editorSFX"));
        add(new Checkbox(
            "Pretty Print",
            "If checked, the saved files from the editor will be formatted to be easily viewable (does not apply to xmls...)",
            "editorPrettyPrint"));
        add(new Checkbox(
            "Intensive Blur",
            "If checked, will use more intensive blur that may be laggier but look better.",
            "intensiveBlur"));
        add(new Checkbox(
            "Editor Autosaves",
            "If checked, this will autosave your files in the editor, with the settings listed below.",
            "charterAutoSaves"));
        add(new NumOption(
            "Autosaving Time",
            "This controls how often the editor will autosave your file (in seconds...)",
            60, 60*10, 30,
            "charterAutoSaveTime"
        ));
        add(new NumOption(
            "Save Warning Time",
            "This controls how long the editor will warn you before it autosaves (in seconds..., 0 to disable)",
            0, 15, 1,
            "charterAutoSaveWarningTime"
        ));
        add(new Checkbox(
            "Autosaves Folder",
            "If checked, this will autosave your file in a separate folder with a time stamp instead of overriding your current file. (stored internally)",
            "charterAutoSavesSeperateFolder"));
    }

    // Salvar configurações no armazenamento interno
    public static function saveConfig(key:String, value:Dynamic):Void {
        var path = lime.system.System.applicationStorageDirectory + "/config.json";
        var config = loadConfig();
        config[key] = value;
        File.saveContent(path, Json.stringify(config));
    }

    // Carregar configurações do armazenamento interno
    public static function loadConfig():Dynamic {
        var path = lime.system.System.applicationStorageDirectory + "/config.json";
        if (FileSystem.exists(path)) {
            return Json.parse(File.getContent(path));
        }
        return {}; // Retorna um objeto vazio se o arquivo não existir
    }
}