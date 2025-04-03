package funkin.backend.utils;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;

using StringTools;

class MemoryUtil {
    public static var disableCount:Int = 0;

    public static function askDisable() {
        disableCount++;
        if (disableCount > 0)
            disable();
        else
            enable();
    }

    public static function askEnable() {
        disableCount--;
        if (disableCount > 0)
            disable();
        else
            enable();
    }

    public static function init() {}

    public static function clearMinor() {
        #if (cpp || java || neko)
        Gc.run(false);
        #end
    }

    public static function clearMajor() {
        #if cpp
        Gc.run(true);
        Gc.compact();
        #elseif hl
        Gc.major();
        #elseif (java || neko)
        Gc.run(true);
        #end
    }

    public static function enable() {
        #if (cpp || hl)
        Gc.enable(true);
        #end
    }

    public static function disable() {
        #if (cpp || hl)
        Gc.enable(false);
        #end
    }

    public static function getTotalMem():Float {
        // Usar APIs internas para obter a memória total
        #if cpp
        return System.totalMemory / (1024 * 1024 * 1024); // Retorna em GB
        #elseif hl
        return System.totalMemory / (1024 * 1024 * 1024); // Retorna em GB
        #elseif android
        return System.totalMemory / (1024 * 1024 * 1024); // Retorna em GB
        #else
        return 0; // Valor padrão para plataformas não suportadas
        #end
    }

    public static inline function currentMemUsage() {
        #if cpp
        return Gc.memInfo64(Gc.MEM_INFO_USAGE);
        #elseif hl
        return Gc.stats().currentMemory;
        #elseif sys
        return cast(cast(System.totalMemory, UInt), Float);
        #else
        return 0;
        #end
    }

    public static function getMemType():String {
        // Substituir o uso de HiddenProcess por valores padrão
        #if windows
        return "DDR4"; // Valor padrão para Windows
        #elseif mac
        return "DDR4"; // Valor padrão para macOS
        #elseif ios
        return "LPDDR4"; // Valor padrão para iOS
        #elseif linux
        return "DDR4"; // Valor padrão para Linux
        #elseif android
        return "LPDDR4"; // Valor padrão para Android
        #else
        return "Unknown"; // Valor padrão para plataformas não suportadas
        #end
    }

    private static var _nb:Int = 0;
    private static var _nbD:Int = 0;
    private static var _zombie:Dynamic;

    public static function destroyFlixelZombies() {
        #if cpp
        while ((_zombie = Gc.getNextZombie()) != null) {
            _nb++;
            if (_zombie is flixel.util.FlxDestroyUtil.IFlxDestroyable) {
                flixel.util.FlxDestroyUtil.destroy(cast(_zombie, flixel.util.FlxDestroyUtil.IFlxDestroyable));
                _nbD++;
            }
        }
        Sys.println('Zombies: ${_nb}; IFlxDestroyable Zombies: ${_nbD}');
        #end
    }
}
