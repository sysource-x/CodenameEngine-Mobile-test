package funkin.menus.credits;

import funkin.options.OptionsScreen;
import funkin.options.type.*;
import funkin.options.TreeMenu;
import haxe.xml.Access;
import flixel.util.FlxColor;

class CreditsMain extends TreeMenu {
    var bg:FlxSprite;
    var items:Array<OptionType> = [];

    public override function create() {
        // Carregar fundo do diretório interno
        bg = new FlxSprite(-80).loadAnimatedGraphic("assets/images/menus/menuBGBlue.png");
        bg.scale.set(1.15, 1.15);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set();
        bg.antialiasing = true;
        add(bg);

        // Carregar arquivo XML de créditos do diretório interno
        var xmlPath = "assets/data/config/credits.xml";
        if (Assets.exists(xmlPath)) {
            var access:Access = null;
            try {
                access = new Access(Xml.parse(Assets.getText(xmlPath)));
            } catch (e) {
                Logs.trace('Error while parsing credits.xml: ${Std.string(e)}', ERROR);
            }

            if (access != null) {
                for (c in parseCreditsFromXML(access)) {
                    items.push(c);
                }
            }
        }

        // Adicionar opções fixas
        items.push(new TextOption("Codename Engine >", "Select this to see all the contributors of the engine!", function() {
            optionsTree.add(Type.createInstance(CreditsCodename, []));
        }));
        items.push(new TextOption("Friday Night Funkin'", "Select this to open the itch.io page of the original game to donate!", function() {
            CoolUtil.openURL("https://ninja-muffin24.itch.io/funkin");
        }));

        main = new OptionsScreen('Credits', 'The people who made this possible!', items, 'UP_DOWN', 'A_B');

        super.create();

        DiscordUtil.call("onMenuLoaded", ["Credits Menu"]);
    }

    /**
     * XML Parsing
     */
    public function parseCreditsFromXML(xml:Access):Array<OptionType> {
        var credsMenus:Array<OptionType> = [];

        for (node in xml.elements) {
            var desc = node.getAtt("desc").getDefault("No Description");

            if (node.name == "github") {
                if (!node.has.user) {
                    Logs.trace("A github node requires a user attribute.", WARNING);
                    continue;
                }

                var username = node.getAtt("user");
                var user = {
                    login: username,
                    html_url: 'https://github.com/$username',
                    avatar_url: 'https://github.com/$username.png'
                };
                var opt:GithubIconOption = new GithubIconOption(user, desc, null,
                    node.has.customName ? node.att.customName : null, node.has.size ? Std.parseInt(node.att.size) : 96,
                    node.has.portrait ? node.att.portrait.toLowerCase() == "false" ? false : true : true
                );
                if (node.has.color)
                    @:privateAccess opt.__text.color = FlxColor.fromString(node.att.color);
                credsMenus.push(opt);
            } else {
                if (!node.has.name) {
                    Logs.trace("A credit node requires a name attribute.", WARNING);
                    continue;
                }
                var name = node.getAtt("name");

                switch (node.name) {
                    case "credit":
                        var opt:PortraitOption = new PortraitOption(name, desc, function() if (node.has.url) CoolUtil.openURL(node.att.url),
                            node.has.icon && Assets.exists("assets/images/credits/" + node.att.icon + ".png") ?
                            FlxG.bitmap.add("assets/images/credits/" + node.att.icon + ".png") : null, node.has.size ? Std.parseInt(node.att.size) : 96,
                            node.has.portrait ? node.att.portrait.toLowerCase() == "false" ? false : true : true
                        );
                        if (node.has.color)
                            @:privateAccess opt.__text.color = FlxColor.fromString(node.att.color);
                        credsMenus.push(opt);

                    case "menu":
                        credsMenus.push(new TextOption(name + " >", desc, function() {
                            optionsTree.add(new OptionsScreen(name, desc, parseCreditsFromXML(node), 'UP_DOWN', 'A_B'));
                        }));
                }
            }
        }

        return credsMenus;
    }
}