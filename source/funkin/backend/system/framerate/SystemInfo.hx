package funkin.backend.system.framerate;

import funkin.backend.utils.MemoryUtil;
import funkin.backend.system.Logs;
import lime.system.System;

#if android
//import android.os.Build;
//import android.os.Build.VERSION;
#end

class SystemInfo extends FramerateCategory {
    public static var osInfo:String = "Unknown";
    public static var gpuName:String = "Unknown";
    public static var vRAM:String = "Unknown";
    public static var cpuName:String = "Unknown";
    public static var totalMem:String = "Unknown";
    public static var memType:String = "Unknown";
    public static var gpuMaxSize:String = "Unknown";

    static var __formattedSysText:String = "";

    public static inline function init() {
        // Obter informações do sistema operacional
        #if android
        osInfo = '${Build.BRAND.charAt(0).toUpperCase() + Build.BRAND.substring(1)} ${Build.MODEL} (${Build.BOARD})';
        #else
        osInfo = System.platformLabel + " " + System.platformVersion;
        #end

        // Obter informações da CPU
        #if android
        cpuName = (VERSION.SDK_INT >= 31 /* VERSION_CODES.S */) ? Build.SOC_MODEL : Build.HARDWARE;
        #else
        cpuName = System.cpuArchitecture;
        #end

        // Obter informações da GPU
        try {
            @:privateAccess {
                if (flixel.FlxG.stage.context3D != null && flixel.FlxG.stage.context3D.gl != null) {
                    gpuName = Std.string(flixel.FlxG.stage.context3D.gl.getParameter(flixel.FlxG.stage.context3D.gl.RENDERER)).split("/")[0].trim();
                    #if !flash
                    var size = FlxG.bitmap.maxTextureSize;
                    gpuMaxSize = size + "x" + size;
                    #end
                } else {
                    Logs.trace('Unable to grab GPU Info', ERROR, RED);
                }
            }
        } catch (e:Dynamic) {
            Logs.trace('Unable to grab GPU Info: $e', ERROR, RED);
        }

        // Obter informações de memória
        #if cpp
        totalMem = Std.string(MemoryUtil.getTotalMem() / 1024) + " GB";
        #else
        Logs.trace('Unable to grab RAM Amount', ERROR, RED);
        #end

        try {
            memType = MemoryUtil.getMemType();
        } catch (e:Dynamic) {
            Logs.trace('Unable to grab RAM Type: $e', ERROR, RED);
        }

        formatSysInfo();
    }

    static function formatSysInfo() {
        __formattedSysText = #if android 'Device: $osInfo\n' #else "" #end;
        if (osInfo != "Unknown") __formattedSysText += 'System: $osInfo';
        if (cpuName != "Unknown") __formattedSysText += '\nCPU: $cpuName ${getCPUArch()}';
        if (gpuName != cpuName || vRAM != "Unknown") {
            var gpuNameKnown = gpuName != "Unknown" && gpuName != cpuName;
            var vramKnown = vRAM != "Unknown";

            if (gpuNameKnown || vramKnown) __formattedSysText += "\n";

            if (gpuNameKnown) __formattedSysText += 'GPU: $gpuName';
            if (gpuNameKnown && vramKnown) __formattedSysText += " | ";
            if (vramKnown) __formattedSysText += 'VRAM: $vRAM';
        }
        if (totalMem != "Unknown" && memType != "Unknown") __formattedSysText += '\nTotal MEM: $totalMem $memType';
    }

    public function new() {
        super("System Info");
    }

    public override function __enterFrame(t:Int) {
        if (alpha <= 0.05) return;

        _text = __formattedSysText;
        _text += '${__formattedSysText == "" ? "" : "\n"}Garbage Collector: ${MemoryUtil.disableCount > 0 ? "OFF" : "ON"} (${MemoryUtil.disableCount})';

        this.text.text = _text;
        super.__enterFrame(t);
    }

    #if cpp
    @:functionCode('
        struct utsname osInfo{};
        uname(&osInfo);
        return ::String(osInfo.machine);
    ')
    #end
    @:noCompletion
    private static function getCPUArch():String {
        #if cpp
        return System.cpuArchitecture;
        #else
        return "Unknown";
        #end
    }
}