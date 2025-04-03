package funkin.backend.system.updating;

import openfl.Lib;
import haxe.zip.Reader;
import funkin.backend.utils.ZipUtil;
import haxe.io.Path;
import openfl.utils.ByteArray;
import sys.io.File;
import sys.io.FileOutput;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import sys.FileSystem;

class AsyncUpdater {
    public function new() {}

    public function execute() {
        installUpdates();
    }

    public function installUpdates() {
        prepareInstallationEnvironment();
        installFiles(["update-assets.zip"]);
    }

    public function installFiles(files:Array<String>) {
        for (file in files) {
            var path = lime.system.System.applicationStorageDirectory + "/updates/" + file;
            trace('Extracting file: $path');
            var reader = ZipUtil.openZip(path);

            ZipUtil.uncompressZip(reader, lime.system.System.applicationStorageDirectory, null, null);
        }
    }

    public function prepareInstallationEnvironment() {
        var path = lime.system.System.applicationStorageDirectory + "/updates/";
        if (!FileSystem.exists(path)) {
            FileSystem.createDirectory(path);
        }

        // Copiar arquivos de atualização do `assets` para o diretório interno
        copyAssetsToInternal(path);
    }

    private function copyAssetsToInternal(destination:String) {
        var assets:Array<String> = ["update-assets.zip"]; // Lista de arquivos internos no `assets`
        for (asset in assets) {
            var source = "assets/updates/" + asset;
            var dest = destination + asset;

            if (!FileSystem.exists(dest)) {
                var bytes = openfl.Assets.getBytes(source);
                if (bytes != null) {
                    File.saveBytes(dest, bytes);
                    trace('Copied $source to $dest');
                } else {
                    trace('Failed to copy $source');
                }
            }
        }
    }
}

class UpdaterProgress {
    public var step:UpdaterStep = PREPARING;
    public var curFile:Int = 0;
    public var files:Int = 0;
    public var bytesLoaded:Float = 0;
    public var bytesTotal:Float = 0;
    public var downloadSpeed:Float = 0;
    public var curFileName:String = "";
    public var done:Bool = false;

    public function new() {}
}

enum abstract UpdaterStep(Int) {
    var PREPARING = 0;
    var INSTALLING = 1;
}
