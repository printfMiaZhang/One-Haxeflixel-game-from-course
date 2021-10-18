package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Lava extends FlxSpriteGroup
{
	var radians:Float = 0;
	var inc = Math.PI * 2 / 6;
	var init_pos:FlxPoint;
	var highest_pos:FlxPoint;

	// 计时器，分别对应两个状态的倒计时（cease状态的持续时间比riseup的持续时间更长），当一个状态的计时结束时切换至另一状态
	var rise_up_tmr:Float = 0;
	var cease_tmr:Float = 0;

	// 有限状态机，通过“组合”的方式组构进 Lava 类
	var fsm:FSM;

	public function new(posX:Float = 0, posY:Float = 0)
	{
		// 初始化状态机并设定初始状态为 cease
		fsm = new FSM(cease);
		init_pos = new FlxPoint(posX, posY);
		highest_pos = new FlxPoint(posX, FlxG.height / 2);
		super(posX, posY);

		// 由 20 个岩浆的“片段” sprite 构成整个岩浆
		for (i in 0...20)
		{
			var lava_sprite = new FlxSprite();
			lava_sprite.loadGraphic(AssetPaths.lava__png, true, 16, 144, true);
			lava_sprite.animation.add("boiling", [0, 1, 2, 3], 13);
			lava_sprite.animation.play("boiling");
			lava_sprite.x = 16 * i;
			lava_sprite.immovable = true;
			add(lava_sprite);
		}
	}

	override function update(elapsed:Float)
	{
		// 更新波浪
		lava_wave();

		// 更新状态机
		fsm.update();
		super.update(elapsed);
	}

	// 使用 sine 函数计算岩浆的波浪
	function lava_wave()
	{
		radians += 0.05;
		for (i in 0...members.length)
		{
			members[i].y = this.y + FlxMath.fastSin(radians + inc * i) * 2;
		}
	}

	// 下面两个函数对应岩浆的两个状态，会在有限状态机内被执行
	function riseUp()
	{
		if (velocity.y == 0)
		{
			cease_tmr += FlxG.elapsed;
			if (cease_tmr >= 2)
			{
				cease_tmr = 0;
				velocity.y = 50;
			}
		}
		if (y >= init_pos.y)
		{
			velocity.y = 0;
			setPosition(init_pos.x, init_pos.y);
			fsm.activeState = cease;
		}
	}

	function cease()
	{
		if (velocity.y == 0)
		{
			rise_up_tmr += FlxG.elapsed;
			if (rise_up_tmr >= 6)
			{
				rise_up_tmr = 0;
				velocity.y = -50;
			}
		}
		if (y <= highest_pos.y)
		{
			velocity.y = 0;
			setPosition(highest_pos.x, highest_pos.y);
			fsm.activeState = riseUp;
		}
	}
}
