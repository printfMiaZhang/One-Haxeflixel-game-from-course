package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Bullet extends FlxSprite
{
	var _speed:Float = 0;

	public function new()
	{
		super();

		makeGraphic(6, 4, FlxColor.WHITE);

		_speed = 360;
	}

	override function update(elapsed:Float):Void
	{
		if (!alive)
			exists = false;
		else if (touching != 0)
		{
			kill();
		}
		super.update(elapsed);
	}

	override function kill():Void
	{
		if (!alive)
			return;
		velocity.set(0, 0);

		alive = false;
		solid = false;
	}

	// 调用该函数并传递一个坐标以及方向发射子弹
	public function shoot(position:FlxPoint, direction:Int)
	{
		super.reset(position.x - width / 2, position.y - height / 2);
		solid = true;
		switch (direction)
		{
			case FlxObject.LEFT:
				velocity.x = -_speed;

			case FlxObject.RIGHT:
				velocity.x = _speed;
		}
	}
}
