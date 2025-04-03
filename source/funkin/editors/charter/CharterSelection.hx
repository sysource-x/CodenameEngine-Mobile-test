package funkin.editors.charter;

import funkin.backend.chart.ChartData;
import funkin.backend.chart.ChartData.ChartMetaData;
import haxe.Json;
import funkin.editors.charter.SongCreationScreen.SongCreationData;
import funkin.options.type.NewOption;
import funkin.backend.system.framerate.Framerate;
import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.editors.EditorTreeMenu;
import funkin.options.*;
import funkin.options.type.*;

using StringTools;

class CharterSelection extends EditorTreeMenu {
    public var freeplayList:FreeplaySonglist;
    public var curSong:ChartMetaData;
    private final button:String = controls.touchC ? 'A' : 'ACCEPT';

    public override function create() {
        bgType = "charter";

        super.create();

        Framerate.offset.y = 60;

        // Carregar lista de músicas do armazenamento interno
        freeplayList = loadFreeplayList();

        var list:Array<OptionType> = [
            for(s in freeplayList.songs) new EditorIconOption(s.name, "Press " + button + " to choose a difficulty to edit.", s.icon, function() {
                curSong = s;
                var list:Array<OptionType> = [
                    for(d in s.difficulties) if (d != "")
                        new TextOption(d, "Press " + button + " to edit the chart for the selected difficulty", function() {
                            #if TOUCH_CONTROLS
                            if (funkin.backend.system.Controls.instance.touchC)
                            {
                                openSubState(new UIWarningSubstate("Charter: Touch Not Supported!", "Please connect a keyboard and mouse to access this editor.", [
                                    {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
                                ]));
                            } else
                            #end
                            FlxG.switchState(new Charter(s.name, d));
                        })
                ];
                list.push(new NewOption("New Difficulty", "New Difficulty", function() {
                    #if TOUCH_CONTROLS
                    if (funkin.backend.system.Controls.instance.touchC)
                    {
                        openSubState(new UIWarningSubstate("New Difficulty: Touch Not Supported!", "Please connect a keyboard and mouse to access this editor.", [
                            {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
                        ]));
                    } else
                    #end
                    FlxG.state.openSubState(new ChartCreationScreen(saveChart));
                }));
                optionsTree.add(new OptionsScreen(s.name, "Select a difficulty to continue.", list, 'UP_DOWN', 'A_B'));
            }, s.parsedColor.getDefault(0xFFFFFFFF))
        ];

        list.insert(0, new NewOption("New Song", "New Song", function() {
            #if TOUCH_CONTROLS
            if (funkin.backend.system.Controls.instance.touchC)
            {
                openSubState(new UIWarningSubstate("New Song: Touch Not Supported!", "Please connect a keyboard and mouse to access this editor.", [
                    {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
                ]));
            } else
            #end
            FlxG.state.openSubState(new SongCreationScreen(saveSong));
        }));

        main = new OptionsScreen("Chart Editor", "Select a song to modify the charts from.", list, 'UP_DOWN', 'A_B');

        DiscordUtil.call("onEditorTreeLoaded", ["Chart Editor"]);
    }

    override function createPost() {
        super.createPost();

        main.changeSelection(1);
    }

    // Função para carregar a lista de músicas do armazenamento interno
    private function loadFreeplayList():FreeplaySonglist {
        var path = lime.system.System.applicationStorageDirectory + "/songs/freeplayList.json";
        if (lime.utils.Assets.exists(path)) {
            var json = lime.utils.Assets.getText(path);
            return Json.parse(json);
        }
        return new FreeplaySonglist(); // Retorna uma lista vazia se o arquivo não existir
    }

    public function saveSong(creation:SongCreationData) {
        var songAlreadyExists:Bool = [for (s in freeplayList.songs) s.name.toLowerCase()].contains(creation.meta.name.toLowerCase());

        if (songAlreadyExists) {
            openSubState(new UIWarningSubstate("Creating Song: Error!", "The song you are trying to create already exists. If you would like to override it, delete the song first!", [
                {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
            ]));
            return;
        }

        // Caminhos internos
        var songsDir:String = lime.system.System.applicationStorageDirectory + "/songs/";
        var songFolder:String = '$songsDir${creation.meta.name}';

        // Criar diretórios
        sys.FileSystem.createDirectory(songFolder);
        sys.FileSystem.createDirectory('$songFolder/song');
        sys.FileSystem.createDirectory('$songFolder/charts');

        // Salvar arquivos
        CoolUtil.safeSaveFile('$songFolder/meta.json', Json.stringify(creation.meta, "\t"));
        if (creation.instBytes != null) sys.io.File.saveBytes('$songFolder/song/Inst.${Paths.SOUND_EXT}', creation.instBytes);
        if (creation.voicesBytes != null) sys.io.File.saveBytes('$songFolder/song/Voices.${Paths.SOUND_EXT}', creation.voicesBytes);

        // Atualizar lista de músicas
        freeplayList.songs.insert(0, creation.meta);
        main.insert(1, new EditorIconOption(creation.meta.name, "Press " + button + " to choose a difficulty to edit.", creation.meta.icon, function() {
            curSong = creation.meta;
        }, creation.meta.parsedColor.getDefault(0xFFFFFFFF)));
    }

    public function saveChart(name:String, data:ChartData) {
        var difficultyAlreadyExists:Bool = curSong.difficulties.contains(name);

        if (difficultyAlreadyExists) {
            openSubState(new UIWarningSubstate("Creating Chart: Error!", "The chart you are trying to create already exists. If you would like to override it, delete the chart first!", [
                {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
            ]));
            return;
        }

        // Caminhos internos
        var songFolder:String = lime.system.System.applicationStorageDirectory + "/songs/${curSong.name}";

        // Salvar arquivos
        CoolUtil.safeSaveFile('$songFolder/charts/${name}.json', Json.stringify(data, "\t"));

        // Atualizar lista de dificuldades
        curSong.difficulties.push(name);
    }
}