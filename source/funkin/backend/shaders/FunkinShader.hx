package funkin.backend.graphics;

import openfl.display.Shader;
import openfl.display.ShaderParameter;
import openfl.utils.ByteArrayData;

class FunkinShader extends Shader {
    public var glslVer:String = #if lime_opengles "100" #else "120" #end;

    /**
     * Constructor for FunkinShader.
     * @param frag Fragment shader code.
     * @param vert Vertex shader code.
     * @param glslVer Version of GLSL to use (defaults to 120 for OpenGL, 100 for OpenGL ES).
     */
    public override function new(frag:String, vert:String, glslVer:String = #if lime_opengles "100" #else "120" #end) {
        super();
		/*
		Create a shader here:
		var shader = new FunkinShader("shaders/example.frag", "shaders/example.vert");
		Manual version GLSL Specification:
		var shader = new FunkinShader("shaders/example.frag", "shaders/example.vert", "300 es");
		*/

        // Set GLSL version
        this.glslVer = glslVer;

        // Load the fragment and vertex shader code
        var fragCode:String = loadShaderCode(frag);
        var vertCode:String = loadShaderCode(vert);

        // Add GLSL version prefix
        fragCode = "#version " + glslVer + "\n" + fragCode;
        vertCode = "#version " + glslVer + "\n" + vertCode;

        // Compile the shaders
        this.data = compileShader(fragCode, vertCode);

        trace("Shader created with GLSL version: " + glslVer);
    }

    /**
     * Loads the shader code from a file or predefined string.
     * @param path Path to the shader file or inline shader code.
     * @return The shader code as a string.
     */
    private function loadShaderCode(path:String):String {
        #if (sys || html5)
        // Load shader code from a file
        if (openfl.utils.Assets.exists(path)) {
            return openfl.utils.Assets.getText(path);
        } else {
            throw "Shader file not found: " + path;
        }
        #else
        // For other platforms, return the path as inline code
        return path;
        #end
    }

    /**
     * Compiles the shader code into a usable shader program.
     * @param fragCode Fragment shader code.
     * @param vertCode Vertex shader code.
     * @return Compiled shader program.
     */
    private function compileShader(fragCode:String, vertCode:String):ByteArrayData {
        #if (js && html5)
        // Add precision for WebGL
        fragCode = "precision mediump float;\n" + fragCode;
        vertCode = "precision mediump float;\n" + vertCode;
        #end

        // Compile the shader program
        var shaderData:ByteArrayData = new ByteArrayData();
        shaderData.writeUTFBytes(fragCode + "\n" + vertCode);
        return shaderData;
    }
}