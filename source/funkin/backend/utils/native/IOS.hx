package funkin.backend.utils.native;

#if ios
@:cppFileCode("#include <sys/sysctl.h>")
class IOS {
    @:functionCode('
    int mib [] = { CTL_HW, HW_MEMSIZE };
    int64_t value = 0;
    size_t length = sizeof(value);

    if(-1 == sysctl(mib, 2, &value, &length, NULL, 0))
        return -1; // An error occurred

    return value / 1024 / 1024; // Retorna a memória total em MB
    ')
    public static function getTotalRam():Float
    {
        // Fallback para valor padrão em caso de erro
        var ram:Float = untyped __function__();
        if (ram <= 0) {
            trace("Erro ao obter memória total via sysctl. Retornando valor padrão.");
            return 2048; // Valor padrão em MB
        }
        return ram;
    }
}
#end
