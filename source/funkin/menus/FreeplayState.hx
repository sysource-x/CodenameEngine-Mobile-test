package funkin.menus;

import funkin.backend.chart.Chart;
import funkin.backend.chart.ChartData.ChartMetaData;
import funkin.backend.system.Conductor;
import haxe.io.Path;
import openfl.text.TextField;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import funkin.game.HealthIcon;
import funkin.savedata.FunkinSave;
import funkin.backend.scripting.events.*;

using StringTools;

class FreeplayState extends MusicBeatState {
    public var songs:Array<ChartMetaData> = [];
    public var curSelected:Int = 0;
    public var curDifficulty:Int = 1;
    public var curCoopMode:Int = 0;
    public var scoreText:FlxText;
    public var diffText:FlxText;
    public var coopText:FlxText;
    public var lerpScore:Int = 0;
    public var intendedScore:Int = 0;
    public var songList:FreeplaySonglist;
    public var scoreBG:FlxSprite;
    public var bg:FlxSprite;
    public var canSelect:Bool = true;
    public var grpSongs:FlxTypedGroup<Alphabet>;
    public var curPlaying:Bool = false;
    public var iconArray:Array<HealthIcon> = [];
    public var interpColor:FlxInterpolateColor;

    override function create() {
        CoolUtil.playMenuSong();

        // Carregar lista de músicas do diretório interno
        songList = FreeplaySonglist.get();
        songs = songList.songs;

        for (k => s in songs) {
            if (s.name == Options.freeplayLastSong) {
                curSelected = k;
            }
        }

        if (songs[curSelected] != null) {
            for (k => diff in songs[curSelected].difficulties) {
                if (diff == Options.freeplayLastDifficulty) {
                    curDifficulty = k;
                }
            }
        }

        DiscordUtil.call("onMenuLoaded", ["Freeplay"]);

        super.create();

        // Carregar fundo do diretório interno
        bg = new FlxSprite(0, 0).loadGraphic("assets/images/menus/menuDesat.png");
        if (songs.length > 0) {
            bg.color = songs[0].color;
        }
        bg.antialiasing = true;
        add(bg);

        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);

        for (i in 0...songs.length) {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].displayName, true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpSongs.add(songText);

            var icon:HealthIcon = new HealthIcon("assets/images/icons/" + songs[i].icon + ".png");
            icon.sprTracker = songText;

            iconArray.push(icon);
            add(icon);
        }

        // Carregar fonte do diretório interno
        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
        scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);

        scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
        scoreBG.alpha = 0.6;
        add(scoreBG);

        diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
        diffText.font = scoreText.font;
        add(diffText);

        coopText = new FlxText(diffText.x, diffText.y + diffText.height + 2, 0, "[TAB] Solo", 24);
        coopText.font = scoreText.font;
        add(coopText);

        add(scoreText);

        changeSelection(0, true);
        changeDiff(0, true);
        changeCoopMode(0, true);

        interpColor = new FlxInterpolateColor(bg.color);

        addTouchPad('LEFT_FULL', 'A_B_X_Y');
    }

    public function select() {
        updateCoopModes();

        if (songs[curSelected].difficulties.length <= 0) return;

        var event = event("onSelect", EventManager.get(FreeplaySongSelectEvent).recycle(songs[curSelected].name, songs[curSelected].difficulties[curDifficulty], __opponentMode, __coopMode));

        if (event.cancelled) return;

        Options.freeplayLastSong = songs[curSelected].name;
        Options.freeplayLastDifficulty = songs[curSelected].difficulties[curDifficulty];

        // Carregar música do diretório interno
        PlayState.loadSong(event.song, event.difficulty, event.opponentMode, event.coopMode);
        FlxG.switchState(new PlayState());
    }

    #if PRELOAD_ALL
    public var timeUntilAutoplay:Float = 1;
    public var disableAutoPlay:Bool = false;
    public var disableAsyncLoading:Bool = #if desktop false #else true #end;
    public var autoplayElapsed:Float = 0;
    public var songInstPlaying:Bool = true;
    public var curPlayingInst:String = null;
    #end

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7) {
            FlxG.sound.music.volume += 0.5 * elapsed;
        }

        lerpScore = Math.floor(lerp(lerpScore, intendedScore, 0.4));

        if (Math.abs(lerpScore - intendedScore) <= 10)
            lerpScore = intendedScore;

        if (canSelect) {
            changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);
            changeDiff((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
            changeCoopMode(((#if TOUCH_CONTROLS touchPad.buttonX.justPressed || #end FlxG.keys.justPressed.TAB) ? 1 : 0));
            updateOptionsAlpha();
        }

        scoreText.text = "PERSONAL BEST:" + lerpScore;
        scoreBG.scale.set(Math.max(Math.max(diffText.width, scoreText.width), coopText.width) + 8, (coopText.visible ? coopText.y + coopText.height : 66));
        scoreBG.updateHitbox();
        scoreBG.x = FlxG.width - scoreBG.width;

        scoreText.x = coopText.x = scoreBG.x + 4;
        diffText.x = Std.int(scoreBG.x + ((scoreBG.width - diffText.width) / 2));

        interpColor.fpsLerpTo(songs[curSelected].parsedColor, 0.0625);
        bg.color = interpColor.color;

        #if PRELOAD_ALL
        var dontPlaySongThisFrame = false;
        autoplayElapsed += elapsed;
        if (!disableAutoPlay && !songInstPlaying && (autoplayElapsed > timeUntilAutoplay || FlxG.keys.justPressed.SPACE)) {
            if (curPlayingInst != (curPlayingInst = Paths.inst(songs[curSelected].name, songs[curSelected].difficulties[curDifficulty]))) {
                var huh:Void->Void = function() {
                    FlxG.sound.playMusic(curPlayingInst, 0);
                    Conductor.changeBPM(songs[curSelected].bpm, songs[curSelected].beatsPerMeasure, songs[curSelected].stepsPerBeat);
                }
                if(!disableAsyncLoading) Main.execAsync(huh);
                else huh();
            }
            songInstPlaying = true;
            if(disableAsyncLoading) dontPlaySongThisFrame = true;
        }
        #end

        if (controls.BACK) {
            CoolUtil.playMenuSFX(CANCEL, 0.7);
            FlxG.switchState(new MainMenuState());
        }

        #if sys
        if (#if TOUCH_CONTROLS touchPad.buttonY.justPressed || #end FlxG.keys.justPressed.EIGHT && Sys.args().contains("-livereload"))
            convertChart();
        #end

        if (controls.ACCEPT #if PRELOAD_ALL && !dontPlaySongThisFrame #end)
            select();
    }

    var __opponentMode:Bool = false;
    var __coopMode:Bool = false;

    function updateCoopModes() {
        __opponentMode = false;
        __coopMode = false;
        if (songs[curSelected].coopAllowed && songs[curSelected].opponentModeAllowed) {
            __opponentMode = curCoopMode % 2 == 1;
            __coopMode = curCoopMode >= 2;
        } else if (songs[curSelected].coopAllowed) {
            __coopMode = curCoopMode == 1;
        } else if (songs[curSelected].opponentModeAllowed) {
            __opponentMode = curCoopMode == 1;
        }
    }

    public function convertChart() {
        trace('Converting ${songs[curSelected].name} (${songs[curSelected].difficulties[curDifficulty]}) to Codename format...');
        var chart = Chart.parse(songs[curSelected].name, songs[curSelected].difficulties[curDifficulty]);
        Chart.save('${Main.pathBack}assets/songs/${songs[curSelected].name}', chart, songs[curSelected].difficulties[curDifficulty].toLowerCase());
    }

    public function changeDiff(change:Int = 0, force:Bool = false) {
        if (change == 0 && !force) return;

        var curSong = songs[curSelected];
        var validDifficulties = curSong.difficulties.length > 0;
        var event = event("onChangeDiff", EventManager.get(MenuChangeEvent).recycle(curDifficulty, validDifficulties ? FlxMath.wrap(curDifficulty + change, 0, curSong.difficulties.length-1) : 0, change));

        if (event.cancelled) return;

        curDifficulty = event.value;

        updateScore();

        if (curSong.difficulties.length > 1)
            diffText.text = '< ${curSong.difficulties[curDifficulty]} >';
        else
            diffText.text = validDifficulties ? curSong.difficulties[curDifficulty] : "-";
    }

    function updateScore() {
        if (songs[curSelected].difficulties.length <= 0) {
            intendedScore = 0;
            return;
        }
        updateCoopModes();
        var changes:Array<HighscoreChange> = [];
        if (__coopMode) changes.push(CCoopMode);
        if (__opponentMode) changes.push(COpponentMode);
        var saveData = FunkinSave.getSongHighscore(songs[curSelected].name, songs[curSelected].difficulties[curDifficulty], changes);
        intendedScore = saveData.score;
    }

    public var coopLabels:Array<String> = controls.touchC ? ["[X] Solo", "[X] Opponent Mode"] : 
    [
        "[TAB] Solo",
        "[TAB] Opponent Mode",
        "[TAB] Co-Op Mode",
        "[TAB] Co-Op Mode (Switched)"
    ];

    public function changeCoopMode(change:Int = 0, force:Bool = false) {
        if (change == 0 && !force) return;
        if (!songs[curSelected].coopAllowed && !songs[curSelected].opponentModeAllowed) return;

        var bothEnabled = songs[curSelected].coopAllowed && songs[curSelected].opponentModeAllowed;
        var changeThingy:Int = -1;
        if(controls.touchC)
            changeThingy = FlxMath.wrap(curCoopMode + change, 0, 1);
        else
            changeThingy = FlxMath.wrap(curCoopMode + change, 0, bothEnabled ? 3 : 1);

        var event = event("onChangeCoopMode", EventManager.get(MenuChangeEvent).recycle(curCoopMode, changeThingy, change));

        if (event.cancelled) return;

        curCoopMode = event.value;

        updateScore();

        if (bothEnabled) {
            coopText.text = coopLabels[curCoopMode];
        } else {
            coopText.text = coopLabels[curCoopMode * (songs[curSelected].coopAllowed ? 2 : 1)];
        }
    }

    public function changeSelection(change:Int = 0, force:Bool = false) {
        if (change == 0 && !force) return;

        var bothEnabled = songs[curSelected].coopAllowed && songs[curSelected].opponentModeAllowed;
        var event = event("onChangeSelection", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, songs.length-1), change));
        if (event.cancelled) return;

        curSelected = event.value;
        if (event.playMenuSFX) CoolUtil.playMenuSFX(SCROLL, 0.7);

        changeDiff(0, true);

        #if PRELOAD_ALL
            autoplayElapsed = 0;
            songInstPlaying = false;
        #end

        coopText.visible = songs[curSelected].coopAllowed || songs[curSelected].opponentModeAllowed;
    }

    function updateOptionsAlpha() {
        var event = event("onUpdateOptionsAlpha", EventManager.get(FreeplayAlphaUpdateEvent).recycle(0.6, 0.45, 1, 1, 0.25));
        if (event.cancelled) return;

        for (i in 0...iconArray.length)
            iconArray[i].alpha = lerp(iconArray[i].alpha, #if PRELOAD_ALL songInstPlaying ? event.idlePlayingAlpha : #end event.idleAlpha, event.lerp);

        iconArray[curSelected].alpha = #if PRELOAD_ALL songInstPlaying ? event.selectedPlayingAlpha : #end event.selectedAlpha;

        for (i=>item in grpSongs.members) {
            item.targetY = i - curSelected;

            item.alpha = lerp(item.alpha, #if PRELOAD_ALL songInstPlaying ? event.idlePlayingAlpha : #end event.idleAlpha, event.lerp);

            if (item.targetY == 0)
                item.alpha =  #if PRELOAD_ALL songInstPlaying ? event.selectedPlayingAlpha : #end event.selectedAlpha;
        }
    }
}

class FreeplaySonglist {
    public var songs:Array<ChartMetaData> = [];

    public function new() {}

    public function getSongsFromSource(source:funkin.backend.assets.AssetsLibraryList.AssetSource, useTxt:Bool = true) {
        var path:String = Paths.txt('freeplaySonglist');
        var songsFound:Array<String> = [];
        if (useTxt && Paths.assetsTree.existsSpecific(path, "TEXT", source)) {
            songsFound = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
        } else {
            songsFound = Paths.getFolderDirectories('songs', false, source);
        }

        if (songsFound.length > 0) {
            for(s in songsFound)
                songs.push(Chart.loadChartMeta(s, "normal", source == MODS));
            return false;
        }
        return true;
    }

    public static function get(useTxt:Bool = true) {
        var songList = new FreeplaySonglist();

        if (songList.getSongsFromSource(MODS, useTxt))
            songList.getSongsFromSource(SOURCE, useTxt);

        return songList;
    }
}
