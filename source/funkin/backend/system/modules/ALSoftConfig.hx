package funkin.backend.system.modules;

import lime.system.System;
import haxe.io.Path;
#if android
import lime.system.JNI;
#end

#if sys
import sys.io.File;
import sys.FileSystem;
#end

/*
 * A class that simply points OpenALSoft to a custom configuration file when
 * the game starts up.
 *
 * The config overrides a few global OpenALSoft settings with the aim of
 * improving audio quality on native targets.
 */
class ALSoftConfig
{
    #if (desktop || android)
    #if android
    private static final ANDROID_OPENAL_CONFIG:String = "
[general]
channels = stereo
sample-rate = 44100
format = AL_FORMAT_STEREO16
"; // Configuração embutida diretamente no código
    #end

    public static function init():Void
    {
        var origin:String = #if android System.applicationStorageDirectory #elseif hl Sys.getCwd() #else Sys.programPath() #end;

        var configPath:String = Path.directory(Path.withoutExtension(origin));
        #if windows
        configPath += "/plugins/alsoft.ini";
        #elseif mac
        configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
        #elseif android
        configPath = origin + 'openal/alsoft.conf';
        FileSystem.createDirectory(Path.directory(configPath));
        File.saveContent(configPath, ANDROID_OPENAL_CONFIG);
        JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'nativeSetenv', '(Ljava/lang/String;Ljava/lang/String;)V')("ALSOFT_CONF", configPath);
        #else
        configPath += "/plugins/alsoft.conf";
        #end

        #if !android
        Sys.putEnv("ALSOFT_CONF", configPath);
        #end
    }
    #end
}