package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import openfl.display.Tilemap;

class PlayState extends FlxState
{
	// Tilemap 加载器（用于加载 Ogmo 编辑器的文件），以及 FlxTilemap 对象
	var mapLoader:FlxOgmo3Loader;
	var map:FlxTilemap;

	// 玩家与子弹对象，此处子弹使用对象池集中管理
	var player:Player;
	var bullets:FlxTypedGroup<Bullet>;

	// 画面下方会升降的岩浆
	var lava:Lava;

	// 背景图片
	var background:FlxSprite;

	// Player 与 Enemy 对象死亡时会触发粒子发射器发射粒子碎片
	var player_pieces:FlxEmitter;
	var enemy_pieces:FlxEmitter;

	// 敌人也使用对象池进行管理
	var enemys:FlxTypedGroup<Enemy>;

	// 敌人的复生计时器
	var spawn_tmr:Float = 0;

	// 用于存放 Enemy 对象与 Player 对象的 FlxGroup，主要是优化碰撞检测的性能（Flixel 建议把尽量多的需要进行碰撞检测的对象整合进 FlxGroup 进行管理）
	var creatures:FlxGroup;

	// 用于更新和显示 Player 对象的生命值以及当前分数
	var hud:HUD;

	// FlxState 的初始化函数
	override public function create()
	{
		// 玩家死亡时会修改游戏的运行时间（变慢），所以回到游戏状态时需要重置
		FlxG.timeScale = 1;

		// 播放游戏 bgm 此处的音频资源取自 HaxeFlixel 官方教程的开源资源
		FlxG.sound.playMusic(AssetPaths.HaxeFlixel_Tutorial_Game__ogg, 1, true);

		// 隐藏鼠标指针
		FlxG.mouse.visible = false;

		// 重置分数为 0
		Reg.score = 0;

		// 实例化 HUD 对象，HUD 用于显示玩家生命值与当前分数
		hud = new HUD();

		// 实例化背景图片
		background = new FlxSprite();
		background.loadGraphic(AssetPaths.BG__png, false, 320, 240);

		// 实例化地图加载器并加载数据至 FlxTilemap 对象
		mapLoader = new FlxOgmo3Loader(AssetPaths.test__ogmo, AssetPaths.test_room__json);
		map = mapLoader.loadTilemap(AssetPaths.walls_tile__png, "wall");

		// 加载粒子发射器所需的粒子
		player_pieces = new FlxEmitter();
		for (i in 0...100)
		{
			var piece:FlxParticle = new FlxParticle();
			piece.makeGraphic(6, 6, FlxColor.RED);
			player_pieces.add(piece);
		}
		player_pieces.velocity.set(-150, -200, 150, 0);
		player_pieces.angularVelocity.set(-720);
		player_pieces.acceleration.set(0, 350);
		player_pieces.elasticity.set(0.5);

		// 同上
		enemy_pieces = new FlxEmitter();
		for (i in 0...200)
		{
			var piece:FlxParticle = new FlxParticle();
			piece.makeGraphic(3, 3, FlxColor.GRAY);
			enemy_pieces.add(piece);
		}
		enemy_pieces.velocity.set(-150, -200, 150, 0);
		enemy_pieces.angularVelocity.set(-720);
		enemy_pieces.acceleration.set(0, 350);
		enemy_pieces.elasticity.set(0.5);

		// 初始化子弹对象池
		bullets = new FlxTypedGroup<Bullet>(15);

		// 初始化玩家角色
		player = new Player(bullets, player_pieces);

		// 初始化岩浆
		lava = new Lava(0, FlxG.height - 32);

		// 初始化敌人对象池
		enemys = new FlxTypedGroup<Enemy>(30);

		// creature group
		creatures = new FlxGroup();
		creatures.add(player);
		creatures.add(enemys);

		// 将可显示的对象添加至当前 state
		add(background);
		add(player);
		add(bullets);

		add(enemy_pieces);
		add(player_pieces);
		add(enemys);
		add(player);

		add(lava);
		add(map);
		add(hud);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// 碰撞检测
		FlxG.collide(creatures, map); // 玩家、敌人 与 墙体的碰撞检测
		FlxG.collide(enemys, enemys); // 敌人与敌人间不可以发生重叠
		FlxG.collide(creatures, lava, overlaped); // 玩家、敌人 与岩浆发生碰撞时调用 overlaped 函数（函数在下面有声明）
		FlxG.collide(bullets, map, overlaped); // 子弹与墙体发生碰撞时调用 overlaped 函数
		FlxG.overlap(bullets, enemys, overlaped); // 子弹与敌人发生碰撞时调用 overlaped 函数
		FlxG.overlap(player, enemys, conflict); // 玩家与敌人发生碰撞时调用 conflict 函数（函数在下面有声明）

		// 如果当前活动的敌人不足 10 个则在固定时间间隔后复生一个敌人
		if (enemys.countLiving() < 10)
		{
			spawn_tmr += FlxG.elapsed;
			spawnEnemy();
		}
	}

	function overlaped(Sprite_1:FlxObject, Sprite_2:FlxObject)
	{
		// 如果 sprite_1 是子弹
		if ((Sprite_1 is Bullet))
		{
			// 调用子弹对象的 kill() 方法
			Sprite_1.kill();

			// 如果 sprite_2 是敌人
			if ((Sprite_2 is Enemy))
			{
				// 敌人受到1点伤害
				Sprite_2.hurt(1);
			}
		}

		// 下面主要是玩家、敌人 与 岩浆发生碰撞时会执行的动作
		// 如果 sprite_1 是 Player 对象
		if (Std.isOfType(Sprite_1, Player))
		{
			// Player 对象死亡
			Sprite_1.kill();
		}
		// 否则如果是 Enemy 的话该敌人死亡
		else if (Std.isOfType(Sprite_1, Enemy))
		{
			// 设定该名敌人的死亡不会奖励分数
			cast(Sprite_1, Enemy).score_up = false;
			Sprite_1.kill();
		}
	}

	// 玩家与敌人发生碰撞时会受到 10 点伤害
	function conflict(Sprite_1:FlxObject, Sprite_2:FlxObject)
	{
		if ((Sprite_1 is Player))
		{
			Sprite_1.hurt(10);
		}
	}

	// 用于复生敌人的函数
	function spawnEnemy()
	{
		var offset:Float = 32;
		if (spawn_tmr >= 1.0)
		{
			spawn_tmr = 0;
			// 从敌人的对象池中回收一只小可爱
			enemys.recycle(Enemy).init(offset + Math.random() * (FlxG.width - offset), offset + Math.random() * (lava.y - 16), player, enemy_pieces);
		}
	}
}
