package funkin.backend.utils;

#if sys
import sys.FileSystem;
#end
import flixel.text.FlxText;
import funkin.backend.utils.XMLUtil.TextFormat;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfThree;
import flixel.tweens.FlxTween;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.sound.FlxSound;
import funkin.backend.system.Conductor;
import flixel.sound.FlxSoundGroup;
import haxe.Json;
import haxe.io.Path;
import haxe.io.Bytes;
import haxe.xml.Access;
import flixel.input.keyboard.FlxKey;
import lime.utils.Assets;
import flixel.animation.FlxAnimation;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import openfl.geom.ColorTransform;
import haxe.CallStack;

using StringTools;

class CoolUtil
{
    /**
     * Shortcut to parse JSON from an Asset path
     * @param assetPath Path to the JSON asset.
     */
    public static function parseJson(assetPath:String) {
        return Json.parse(Assets.getText(assetPath));
    }

    /**
     * Deletes a folder recursively
     * @param delete Path to the folder.
     */
    @:noUsing public static function deleteFolder(delete:String) {
        #if sys
        var folder = lime.system.System.applicationStorageDirectory + "/" + delete;
        if (!FileSystem.exists(folder)) return;
        var files:Array<String> = FileSystem.readDirectory(folder);
        for(file in files) {
            if (FileSystem.isDirectory(folder + "/" + file)) {
                deleteFolder(folder + "/" + file);
                FileSystem.deleteDirectory(folder + "/" + file);
            } else {
                try FileSystem.deleteFile(folder + "/" + file)
                catch(e) Logs.trace("Could not delete " + folder + "/" + file, WARNING);
            }
        }
        #end
    }

    /**
     * Safe saves a file (even adding eventual missing folders) and shows a warning box instead of making the program crash
     * @param path Path to save the file at.
     * @param content Content of the file to save (as String or Bytes).
     */
    @:noUsing public static function safeSaveFile(path:String, content:OneOfTwo<String, Bytes>, showErrorBox:Bool = true) {
        #if sys
        try {
            var fullPath = lime.system.System.applicationStorageDirectory + "/" + path;
            addMissingFolders(Path.directory(fullPath));
            if(content is Bytes) sys.io.File.saveBytes(fullPath, content);
            else sys.io.File.saveContent(fullPath, content);
        } catch(e) {
            var errMsg:String = 'Error while trying to save the file: ${Std.string(e).replace("\n", " ")}';
            Logs.traceColored([Logs.logText(errMsg, RED)], ERROR);
            if(showErrorBox) funkin.backend.utils.NativeAPI.showMessageBox("Codename Engine Warning", errMsg, MSG_WARNING);
        }
        #end
    }

    /**
     * Creates eventual missing folders to the specified `path`
     * @param path Path to check.
     * @return The initial Path.
     */
    @:noUsing public static function addMissingFolders(path:String):String {
        #if sys
        var fullPath = lime.system.System.applicationStorageDirectory + "/" + path;
        var folders:Array<String> = fullPath.split("/");
        var currentPath:String = "";

        for (folder in folders) {
            currentPath += folder + "/";
            if (!FileSystem.exists(currentPath))
                FileSystem.createDirectory(currentPath);
        }
        #end
        return path;
    }

    /**
     * Allows you to split a text file from a path, into a "cool text file", AKA a list. Allows for comments.
     * @param path Path to the text file.
     * @return Array<String>
     */
    @:noUsing public static function coolTextFile(path:String):Array<String>
    {
        var fullPath = "assets/" + path; // Carregar do diretório interno
        var trim:String;
        return [for(line in Assets.getText(fullPath).split("\n")) if ((trim = line.trim()) != "" && !trim.startsWith("#")) trim];
    }

    /**
     * Plays music, while resetting the Conductor, and taking info from INI in count.
     * @param path Path to the music
     * @param Persist Whether the music should persist while switching states
     * @param DefaultBPM Default BPM of the music (102)
     * @param Volume Volume of the music (1)
     * @param Looped Whether the music loops (true)
     * @param Group A group that this music belongs to (default)
     */
    @:noUsing public static function playMusic(path:String, Persist:Bool = false, Volume:Int = 1, Looped:Bool = true, DefaultBPM:Int = 102, ?Group:FlxSoundGroup) {
        Conductor.reset();
        FlxG.sound.playMusic(path, Volume, Looped, Group);
        if (FlxG.sound.music != null) {
            FlxG.sound.music.persist = Persist;
        }

        var infoPath = "assets/" + Path.withoutExtension(path) + ".ini"; // Ajustado para carregar do diretório interno
        if (Assets.exists(infoPath)) {
            var musicInfo = IniUtil.parseAsset(infoPath, [
                "BPM" => null,
                "TimeSignature" => "4/4"
            ]);

            var timeSignParsed:Array<Null<Float>> = musicInfo["TimeSignature"] == null ? [] : [for(s in musicInfo["TimeSignature"].split("/")) Std.parseFloat(s)];
            var beatsPerMeasure:Float = 4;
            var stepsPerBeat:Float = 4;

            if (timeSignParsed.length == 2 && !timeSignParsed.contains(null)) {
                beatsPerMeasure = timeSignParsed[0] == null || timeSignParsed[0] <= 0 ? 4 : cast timeSignParsed[0];
                stepsPerBeat = timeSignParsed[1] == null || timeSignParsed[1] <= 0 ? 4 : cast timeSignParsed[1];
            }

            var bpm:Null<Float> = Std.parseFloat(musicInfo["BPM"]).getDefault(DefaultBPM);
            Conductor.changeBPM(bpm, beatsPerMeasure, stepsPerBeat);
        } else
            Conductor.changeBPM(DefaultBPM);
    }
}