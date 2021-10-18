package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	static var FIRE_RATE:Float = 1 / 13;

	var fire_timer:FlxTimer = new FlxTimer();
	var _bullets:FlxTypedGroup<Bullet>;
	var _direction:Int = FlxObject.RIGHT;

	var _pieces:FlxEmitter;

	var flickering:Bool = false;
	var bulletFireSound:FlxSound;

	public var MAX_HEALTH:Float = 100;

	var deadSound:FlxSound;

	// 初始化时需要为 Player 对象传递一组子弹的对象池的引用，以及传递一个粒子发射器
	public function new(bullets:FlxTypedGroup<Bullet>, pieces:FlxEmitter)
	{
		deadSound = FlxG.sound.load(AssetPaths.deadSound__wav);
		super(FlxG.width / 2 - 8, FlxG.height / 2 - 8);
		bulletFireSound = FlxG.sound.load(AssetPaths.bullet__wav);
		_pieces = pieces;
		health = MAX_HEALTH;
		_bullets = bullets;
		// makeGraphic(16, 16, FlxColor.RED);
		loadGraphic(AssetPaths.player__png, true, 16, 16);

		// 角色有两帧构成 分别表示 跳跃与下坠动作
		animation.add("fall", [0]);
		animation.add("jump", [1]);

		// 设定碰撞盒的大小与位置
		setSize(9, 13);
		offset.set(4, 2);
		drag.x = 260;
		maxVelocity.x = 150;

		// 更新全局变量的数据供 HUD 跟进当前角色的血量
		Reg.player_MAX_HEALTH = MAX_HEALTH;

		// Player 的掉落速度
		acceleration.y = 400;
	}

	override function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.SPACE)
		{
			velocity.y = -130;
			animation.play("jump");
		}
		else if (velocity.y > 0)
			animation.play("fall");

		if (FlxG.keys.pressed.LEFT)
		{
			flipX = false;
			velocity.x -= 10;
			_direction = FlxObject.RIGHT;
			shoot();
		}

		if (FlxG.keys.pressed.RIGHT)
		{
			flipX = true;
			velocity.x += 10;
			_direction = FlxObject.LEFT;
			shoot();
		}
		Reg.playerHealth = health;
		super.update(elapsed);
	}

	// 射击子弹
	function shoot():Void
	{
		if (fire_timer.active)
			return;
		fire_timer.start(FIRE_RATE);
		bulletFireSound.play();
		getMidpoint(_point);
		_bullets.recycle(Bullet).shoot(_point, _direction);
	}

	// 死亡时调用该函数
	override function kill()
	{
		Reg.playerHealth = 0;
		FlxG.timeScale = 0.35;
		deadSound.play();
		// 保存当前分数
		MyUtil.saveScore();
		// 激活粒子发射器发射粒子
		if (_pieces != null)
		{
			_pieces.focusOn(this);
			_pieces.start(true, 0, 50);
		}

		// 屏幕震动
		FlxG.camera.shake(0.05, 0.5, function()
		{
			FlxG.sound.destroy(true);
			// 屏幕震动结束后切换至 GameOver 状态
			FlxG.switchState(new GameOverState());
		});

		super.kill();
		// FlxG.switchState(new GameOverState());
	}

	// 受到伤害时调用该函数
	override function hurt(Damage:Float)
	{
		// 如果玩家受到伤害，会进入短暂的闪烁无敌状态
		if (flickering)
			return;

		// 如果玩家当前无闪烁状态，会受到伤害并进入闪烁状态，同时会产生一定的击退效果
		flicker(1.3);

		if (velocity.x > 0)
			velocity.x = -maxVelocity.x;
		else
			velocity.x = maxVelocity.x;

		super.hurt(Damage);
	}

	// 调用该函数传递一个以秒为单位的 Float （表示闪烁持续时间），进入闪烁状态
	function flicker(Duration:Float):Void
	{
		FlxSpriteUtil.flicker(this, Duration, 0.02, true, true, function(_)
		{
			flickering = false;
		});
		flickering = true;
	}
}
