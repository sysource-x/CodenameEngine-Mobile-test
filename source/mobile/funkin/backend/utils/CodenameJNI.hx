/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package mobile.funkin.backend.utils;

#if android
import lime.system.JNI;
import lime.system.System;

/**
 * ...
 * @author Homura Akemi (HomuHomu833) and sysource_xyz
 */
class CodenameJNI #if (lime >= "8.0.0") implements JNISafety #end
{
    // Constantes de orientação
    public static final SDL_ORIENTATION_UNKNOWN:Int = 0;
    public static final SDL_ORIENTATION_LANDSCAPE:Int = 1;
    public static final SDL_ORIENTATION_LANDSCAPE_FLIPPED:Int = 2;
    public static final SDL_ORIENTATION_PORTRAIT:Int = 3;
    public static final SDL_ORIENTATION_PORTRAIT_FLIPPED:Int = 4;

    /**
     * Define a orientação da tela.
     * Depende de JNI para Android.
     */
    public static inline function setOrientation(width:Int, height:Int, resizeable:Bool, hint:String):Dynamic {
        #if android
        return setOrientation_jni(width, height, resizeable, hint);
        #else
        trace("setOrientation not supported.");
        return null;
        #end
    }

    /**
     * Obtém a orientação atual da tela como uma string.
     * Depende de JNI para Android.
     */
    public static inline function getCurrentOrientationAsString():String {
        #if android
        return switch (getCurrentOrientation_jni()) {
            case SDL_ORIENTATION_PORTRAIT: "Portrait";
            case SDL_ORIENTATION_LANDSCAPE: "LandscapeRight";
            case SDL_ORIENTATION_PORTRAIT_FLIPPED: "PortraitUpsideDown";
            case SDL_ORIENTATION_LANDSCAPE_FLIPPED: "LandscapeLeft";
            default: "Unknown";
        }
        #else
        return "Unknown";
        #end
    }

    /**
     * Verifica se o teclado virtual está visível.
     * Depende de JNI para Android.
     */
    public static inline function isScreenKeyboardShown():Dynamic {
        #if android
        return isScreenKeyboardShown_jni();
        #else
        return false;
        #end
    }

    /**
     * Verifica se há texto na área de transferência.
     * Depende de JNI para Android.
     */
    public static inline function clipboardHasText():Dynamic {
        #if android
        return clipboardHasText_jni();
        #else
        return false;
        #end
    }

    /**
     * Obtém o texto da área de transferência.
     * Depende de JNI para Android.
     */
    public static inline function clipboardGetText():Dynamic {
        #if android
        return clipboardGetText_jni();
        #else
        return null;
        #end
    }

    /**
     * Define o texto na área de transferência.
     * Depende de JNI para Android.
     */
    public static inline function clipboardSetText(string:String):Dynamic {
        #if android
        return clipboardSetText_jni(string);
        #else
        trace("clipboardSetText not supported.");
        return null;
        #end
    }

    /**
     * Simula o botão "Voltar".
     * Depende de JNI para Android.
     */
    public static inline function manualBackButton():Dynamic {
        #if android
        return manualBackButton_jni();
        #else
        trace("manualBackButton not supported.");
        return null;
        #end
    }

    /**
     * Define o título da atividade.
     * Depende de JNI para Android.
     */
    public static inline function setActivityTitle(title:String):Dynamic {
        #if android
        return setActivityTitle_jni(title);
        #else
        trace("setActivityTitle not supported.");
        return null;
        #end
    }

    // Métodos JNI privados
    @:noCompletion private static var setOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'setOrientation',
        '(IIZLjava/lang/String;)V');
    @:noCompletion private static var getCurrentOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'getCurrentOrientation', '()I');
    @:noCompletion private static var isScreenKeyboardShown_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'isScreenKeyboardShown', '()Z');
    @:noCompletion private static var clipboardHasText_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'clipboardHasText', '()Z');
    @:noCompletion private static var clipboardGetText_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'clipboardGetText',
        '()Ljava/lang/String;');
    @:noCompletion private static var clipboardSetText_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'clipboardSetText',
        '(Ljava/lang/String;)V');
    @:noCompletion private static var manualBackButton_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'manualBackButton', '()V');
    @:noCompletion private static var setActivityTitle_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'setActivityTitle',
        '(Ljava/lang/String;)Z');
}
#end
