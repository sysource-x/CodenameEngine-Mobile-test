package funkin.editors.character;

import funkin.options.type.OptionType;
import funkin.options.type.NewOption;
import flixel.util.FlxColor;
import funkin.game.Character;
import funkin.backend.chart.Chart;
import funkin.options.type.TextOption;
import funkin.options.type.IconOption;
import funkin.options.OptionsScreen;

class CharacterSelection extends EditorTreeMenu
{
    public override function create()
    {
        bgType = "charter";
        super.create();

        // Carregar lista de personagens do diretório interno
        var modsList:Array<String> = loadCharacterList();

        final button:String = controls.touchC ? 'A' : 'ACCEPT';

        var list:Array<OptionType> = [
            for (char in modsList)
                new IconOption(char, "Press " + button + " to edit this character.", getCharacterIcon(char),
                function() {
                    #if TOUCH_CONTROLS
                    if (funkin.backend.system.Controls.instance.touchC)
                    {
                        openSubState(new UIWarningSubstate("CharacterEditor: Touch Not Supported!", "Please connect a keyboard and mouse to access this editor.", [
                            {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
                        ]));
                    } else
                    #end
                    FlxG.switchState(new CharacterEditor(char));
                })
        ];

        list.insert(0, new NewOption("New Character", "New Character", function() {
            openSubState(new UIWarningSubstate("New Character: Feature Not Implemented!", "This feature isn't implemented yet. Please wait for more cne updates to have this functional.\n\n\n- Codename Devs", [
                {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
            ]));
        }));

        main = new OptionsScreen("Character Editor", "Select a character to edit", list, 'UP_DOWN', 'A_B');

        DiscordUtil.call("onEditorTreeLoaded", ["Character Editor"]);
    }

    override function createPost() {
        super.createPost();

        main.changeSelection(1);
    }

    // Função para carregar a lista de personagens do diretório interno
    private function loadCharacterList():Array<String> {
        var path = "assets/data/characters.json"; // Caminho interno no `.apk`
        if (lime.utils.Assets.exists(path)) {
            var json = lime.utils.Assets.getText(path);
            return haxe.Json.parse(json);
        }
        return []; // Retorna uma lista vazia se o arquivo não existir
    }

    // Função para carregar ícones de personagens do diretório interno
    private function getCharacterIcon(charName:String):String {
        var path = "assets/images/characters/icons/" + charName + ".png"; // Caminho interno no `.apk`
        if (lime.utils.Assets.exists(path)) {
            return path;
        }
        return "assets/images/characters/icons/default.png"; // Ícone padrão
    }
}