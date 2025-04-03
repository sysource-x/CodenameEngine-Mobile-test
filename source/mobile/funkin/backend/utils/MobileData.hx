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

#if TOUCH_CONTROLS
import haxe.ds.Map;
import haxe.Json;
import openfl.utils.Assets;
import flixel.util.FlxSave;

/**
 * ...
 * @author: Karim Akra... and me sysource-xyz
 */
class MobileData
{
    public static var actionModes:Map<String, TouchButtonsData> = new Map();
    public static var dpadModes:Map<String, TouchButtonsData> = new Map();

    public static var save:FlxSave;

    /**
     * Inicializa os dados móveis, carregando configurações de controles do diretório interno.
     */
    public static function init()
    {
        save = new FlxSave();
        save.bind('MobileControls', 'CodenameEngine');

        // Carregar configurações de DPad e Action Modes do diretório interno
        setMap('assets/mobile/DPadModes', dpadModes);
        setMap('assets/mobile/ActionModes', actionModes);
    }

    /**
     * Carrega os dados de um diretório interno e os adiciona ao mapa fornecido.
     *
     * @param folder O diretório interno onde os arquivos JSON estão localizados.
     * @param map    O mapa onde os dados serão armazenados.
     */
    public static function setMap(folder:String, map:Map<String, TouchButtonsData>)
    {
        // Listar arquivos JSON no diretório interno
        var files:Array<String> = Assets.list(folder, true);

        for (file in files)
        {
            if (file.endsWith('.json'))
            {
                // Carregar o conteúdo do arquivo JSON
                var str = Assets.getText(folder + "/" + file);
                var json:TouchButtonsData = cast Json.parse(str);
                var mapKey:String = file.split('/').pop().split('.').shift(); // Nome do arquivo sem extensão
                map.set(mapKey, json);
            }
        }
    }
}

typedef TouchButtonsData =
{
    buttons:Array<ButtonsData>
}

typedef ButtonsData =
{
    button:String, // Qual TouchButton deve ser usado, deve ser uma variável válida de TouchButton no TouchPad.
    graphic:String, // O gráfico do botão, geralmente localizado no TouchPad XML.
    x:Float, // A posição X do botão na tela.
    y:Float, // A posição Y do botão na tela.
    color:String // A cor do botão, a cor padrão é branca.
}
#end
