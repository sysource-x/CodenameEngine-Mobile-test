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

/**
 * A storage class for mobile.
 * @author Karim Akra and Homura Akemi (HomuHomu833)
 * Fix for internal storage by @sysource_xyz
 */
class StorageUtil
{
    /**
     * Obtém o diretório de armazenamento interno.
     * Agora retorna um caminho fixo dentro do `.apk`.
     */
    public static function getStorageDirectory():String {
        return "assets/data/"; // Internal Directory of `.apk`
    }

    #if android
    /**
     * Remove a solicitação de permissões e ajusta para usar apenas arquivos internos.
     */
    public static function requestPermissions():Void {
        try {
            // Verifica se o diretório interno existe (simulado para o `.apk`)
            if (!FileSystem.exists(StorageUtil.getStorageDirectory())) {
                throw "Internal Directory not found: " + StorageUtil.getStorageDirectory();
            }
        } catch (e:Dynamic) {
            NativeAPI.showMessageBox(
                "Error!",
                "No are possible to get your Internal Directory:\n" + StorageUtil.getStorageDirectory() + "\nPressione OK para fechar o jogo"
            );
            lime.system.System.exit(1);
        }
    }
    #end
}