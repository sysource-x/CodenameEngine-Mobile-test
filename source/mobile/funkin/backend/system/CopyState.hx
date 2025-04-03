/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * @author: sysource_xyz modificed file but originally by mobile Porting Team
 */

package mobile.funkin.backend.system;

#if mobile
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import openfl.utils.ByteArray;
import haxe.io.Path;
import funkin.backend.utils.NativeAPI;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;

using StringTools;

/**
 * ...
 * @author: Karim Akra
 */
class CopyState extends funkin.backend.MusicBeatState
{
    private static final textFilesExtensions:Array<String> = ['ini', 'txt', 'xml', 'hxs', 'hx', 'lua', 'json', 'frag', 'vert'];
    public static final IGNORE_FOLDER_FILE_NAME:String = "CopyState-Ignore.txt";
    private static var directoriesToIgnore:Array<String> = [];
    public static var locatedFiles:Array<String> = [];
    public static var maxLoopTimes:Int = 0;

    public var loadingImage:FlxSprite;
    public var loadingBar:FlxBar;
    public var loadedText:FlxText;

    var failedFilesStack:Array<String> = [];
    var failedFiles:Array<String> = [];
    var shouldCopy:Bool = false;
    var canUpdate:Bool = true;
    var loopTimes:Int = 0;

    override function create()
    {
        locatedFiles = [];
        maxLoopTimes = 0;
        checkExistingFiles();
        if (maxLoopTimes <= 0)
        {
            FlxG.resetGame();
            return;
        }

        NativeAPI.showMessageBox("Notice", "Some files are missing. Press OK to begin the copy process.");

        shouldCopy = true;

        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

        loadingImage = new FlxSprite(0, 0, Paths.image('menus/funkay'));
        loadingImage.setGraphicSize(0, FlxG.height);
        loadingImage.updateHitbox();
        loadingImage.screenCenter();
        add(loadingImage);

        loadingBar = new FlxBar(0, FlxG.height - 26, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 26);
        loadingBar.setRange(0, maxLoopTimes);
        add(loadingBar);

        loadedText = new FlxText(loadingBar.x, loadingBar.y + 4, FlxG.width, '', 16);
        loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        add(loadedText);

        for (file in locatedFiles)
        {
            loopTimes++;
            copyAsset(file);
        }

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (shouldCopy)
        {
            if (loopTimes >= maxLoopTimes && canUpdate)
            {
                if (failedFiles.length > 0)
                {
                    NativeAPI.showMessageBox('Failed To Copy ${failedFiles.length} File.', failedFiles.join('\n'), MSG_ERROR);
                }

                FlxG.sound.play(Paths.sound('menu/confirm')).onComplete = () ->
                {
                    FlxG.resetGame();
                };

                canUpdate = false;
            }

            if (loopTimes >= maxLoopTimes)
                loadedText.text = "Completed!";
            else
                loadedText.text = '$loopTimes/$maxLoopTimes';

            loadingBar.percent = Math.min((loopTimes / maxLoopTimes) * 100, 100);
        }
        super.update(elapsed);
    }

    public function copyAsset(file:String)
    {
        try
        {
            if (OpenFLAssets.exists(getFile(file)))
            {
                if (textFilesExtensions.contains(Path.extension(file)))
                    createContentFromInternal(file);
                else
                    File.saveBytes(file, getFileBytes(getFile(file)));
            }
            else
            {
                failedFiles.push(getFile(file) + " (File Doesn't Exist)");
                failedFilesStack.push('Asset ${getFile(file)} does not exist.');
            }
        }
        catch (e:haxe.Exception)
        {
            failedFiles.push('${getFile(file)} (${e.message})');
            failedFilesStack.push('${getFile(file)} (${e.stack})');
        }
    }

    public function createContentFromInternal(file:String)
    {
        try
        {
            var fileData:String = OpenFLAssets.getText(getFile(file));
            if (fileData == null)
                fileData = '';
            File.saveContent(file, fileData);
        }
        catch (e:haxe.Exception)
        {
            failedFiles.push('${getFile(file)} (${e.message})');
            failedFilesStack.push('${getFile(file)} (${e.stack})');
        }
    }

    public function getFileBytes(file:String):ByteArray
    {
        return OpenFLAssets.getBytes(file);
    }

    public static function getFile(file:String):String
    {
        if (OpenFLAssets.exists(file))
            return file;

        @:privateAccess
        for (library in LimeAssets.libraries.keys())
        {
            if (OpenFLAssets.exists('$library:$file') && library != 'default')
                return '$library:$file';
        }

        return file;
    }

    public static function checkExistingFiles():Bool
    {
        locatedFiles = Paths.assetsTree.list(null);

        // Remove arquivos desnecessários
        locatedFiles = locatedFiles.filter(file -> OpenFLAssets.exists(file));

        maxLoopTimes = locatedFiles.length;

        return (maxLoopTimes <= 0);
    }
}
#end