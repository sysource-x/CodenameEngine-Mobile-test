package funkin.menus;

#if MOD_SUPPORT
import haxe.io.Path;
import lime.utils.Assets;
import flixel.tweens.FlxTween;

class ModSwitchMenu extends MusicBeatSubstate {
    var mods:Array<String> = [];
    var alphabets:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    public override function create() {
        super.create();

        var bg = new FlxSprite(0, 0).makeSolid(FlxG.width, FlxG.height, 0xFF000000);
        bg.updateHitbox();
        bg.scrollFactor.set();
        add(bg);

        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.5}, 0.25, {ease: FlxEase.cubeOut});

        // Carregar lista de mods do diretório interno
        mods = getModsList();
        mods.push(null); // Adicionar opção para desativar mods

        alphabets = new FlxTypedGroup<Alphabet>();
        for (mod in mods) {
            var a = new Alphabet(0, 0, mod == null ? "DISABLE MODS" : mod, true);
            a.isMenuItem = true;
            a.scrollFactor.set();
            alphabets.add(a);
        }
        add(alphabets);
        changeSelection(0, true);

        addTouchPad('UP_DOWN', 'A_B');
        addTouchPadCamera(); // dawg wtf
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        changeSelection((controls.DOWN_P ? 1 : 0) + (controls.UP_P ? -1 : 0) - FlxG.mouse.wheel);

        if (controls.ACCEPT) {
            switchMod(mods[curSelected]);
            close();
        }

        if (controls.BACK)
            close();
    }

    public function changeSelection(change:Int, force:Bool = false) {
        if (change == 0 && !force) return;

        curSelected = FlxMath.wrap(curSelected + change, 0, alphabets.length - 1);

        CoolUtil.playMenuSFX(SCROLL, 0.7);

        for (k => alphabet in alphabets.members) {
            alphabet.alpha = 0.6;
            alphabet.targetY = k - curSelected;
        }
        alphabets.members[curSelected].alpha = 1;
    }

    // Função para carregar a lista de mods do diretório interno
    private function getModsList():Array<String> {
        var mods:Array<String> = [];
        var modsPath = "assets/mods/";

        // Verificar se o diretório de mods existe
        if (Assets.exists(modsPath)) {
            for (file in Assets.list(modsPath)) {
                if (file.endsWith(".mod")) { // Supondo que os mods tenham a extensão .mod
                    mods.push(Path.withoutExtension(file));
                }
            }
        }

        return mods;
    }

    // Função para alternar mods
    private function switchMod(mod:String):Void {
        if (mod == null) {
            trace("Mods desativados.");
            // Lógica para desativar mods
        } else {
            trace("Mod ativado: " + mod);
            // Lógica para ativar o mod selecionado
        }
    }
}
#end
