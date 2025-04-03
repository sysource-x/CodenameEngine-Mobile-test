package funkin.editors;

import haxe.io.Path;
import lime.system.System;

class SaveSubstate extends MusicBeatSubstate {
    public var saveOptions:Map<String, Bool>;
    public var options:SaveSubstateData;

    public var data:String;

    public var cam:FlxCamera;

    public function new(data:String, ?options:SaveSubstateData, ?saveOptions:Map<String, Bool>) {
        super();
        this.data = data;

        if (saveOptions == null)
            saveOptions = [];
        this.saveOptions = saveOptions;

        if (options != null)
            this.options = options;
    }

    public override function create() {
        super.create();

        // Salvar automaticamente no armazenamento interno
        var savePath = lime.system.System.applicationStorageDirectory + "/" + options.defaultSaveFile;
        CoolUtil.safeSaveFile(savePath, data);
        trace("Save file in: " + savePath);

        close();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        parent.persistentUpdate = false;
    }
}

typedef SaveSubstateData = {
    var ?defaultSaveFile:String;
    var ?saveExt:String;
}
