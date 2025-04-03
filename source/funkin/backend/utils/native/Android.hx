package funkin.backend.utils.native;

#if android
import lime.system.JNI;

class Android
{
    // Método para obter a memória total usando APIs internas do Android
    public static function getTotalRam():Float
    {
        // Usar JNI para acessar APIs do Android
        try {
            var activityClass = JNI.createStaticMethod(
                "org.libsdl.app.SDLActivity",
                "getTotalRam",
                "()F"
            );
            return activityClass();
        } catch (e:Dynamic) {
            trace("Erro ao obter memória total: " + e);
            return -1; // Valor padrão em caso de erro
        }
    }
}
#end
