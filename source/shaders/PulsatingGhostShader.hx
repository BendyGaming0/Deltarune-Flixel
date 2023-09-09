package shaders;

import flixel.system.FlxAssets.FlxShader;

class PulsatingGhostEffect
{
	public var shader(default, null):PulsatingGhostShader = new PulsatingGhostShader();
	public var size(default, set):Float = 0.33;
	public var power(default, set):Float = 0.3;
	public var speed(default, set):Float = 1;
	public var count(default, set):Int = 0;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}

	function set_size(v:Float):Float
	{
		size = v;
		shader.shiftSize.value = [size];
		return v;
	}

	function set_power(v:Float):Float
	{
		power = v;
		shader.power.value = [power];
		return v;
	}

	function set_count(v:Int):Int
	{
		count = v;
		shader.count.value = [count];
		return v;
	}

	function set_speed(v:Float):Float
	{
		speed = v;
		shader.speed.value = [speed];
		return v;
	}
}

class PulsatingGhostShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float uTime;

        float PI = radians(180.0);
        uniform float power; //.3 is default
        uniform float shiftSize; //one third is default
        uniform float speed; //one third is default

        uniform int count; //6 is default

        vec2 passUv( float shift, vec2 uvIn )
        {
            return (uvIn * (1.0 + (shift * 2.0))) - shift;
        }

        void main()
        {
            vec4 col = vec4(0.0, 0.0, 0.0, 1.0);
    
            for(int i=0;i<count;++i)
            {
                float power = sin(mod((uTime * speed) + float(i), float(count)) * (PI / float(count))) * power;
                float shift = mix(0.0, -shiftSize, (mod((uTime * speed) + float(i), float(count)) / float(count)));
                col.rgb += texture2D(bitmap, passUv(shift, openfl_TextureCoordv)).rgb * power;
            }

            // Output to screen
            gl_FragColor = col;
        }
    ')

	public function new()
	{
		super();
	}
}